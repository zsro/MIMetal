//
//  MIMetalScene.swift
//  Mirage3D
//
//  Created by 影子 on 2019/3/26.
//  Copyright © 2019 影子. All rights reserved.
//

import Foundation
import MetalKit

public protocol MIHitTestProtocol:NSObjectProtocol{
    func hitTest(_ scene: MIMetalScene, result: MIHitResult)
    func dragDirection(_ scene: MIMetalScene, direction: float3)
    func dragHitTest(_ scene: MIMetalScene, result: MIHitResult)
    func dragEnded(_ scene: MIMetalScene)
}

public class MIMetalInit: NSObject{
    
    public override init() {
        super.init()
        do{
            mtlDevice = MTLCreateSystemDefaultDevice()!
            mtlLibrary = try mtlDevice.makeDefaultLibrary(bundle: Bundle.init(for: self.classForCoder))
        }catch{
            print("MIMetal ERROR: Init failed!!!")
            print(error.localizedDescription)
        }
    }
}

public class MIMetalScene: NSObject {
    
    public let rootNode = MINode()
    public var controlNode: MINode?
    public let camera = MICamera()
    public let view: MIMetalView
    public let render: MIMetalRender
    
    public weak var hitTestDelegate: MIHitTestProtocol?

    public var isPinchHandle:Bool = true
    public var isPanHandle:Bool = true
    
    deinit {
        hitTestDelegate = nil
        render.clear()
        view.clear()
        rootNode.removeAllChildNode()
        print("---------- MIMetalScene deinit")
    }
    
    
    public init(frame: CGRect) {
        render = MIMetalRender.init()
        view = MIMetalView.init(frame: frame)
        view.delegate = render
        super.init()
        rootNode.addChildNode(camera)
     
        render.scene = self
        
        camera.position = float3.init(0, -45, 400)
        camera.aspect = Float(frame.size.width / frame.size.height)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panHandle(_:)))
        view.addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer.init(target: self, action: #selector(pinchHandle(_:)))  //缩放
        view.addGestureRecognizer(pinch)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapHandle(_:)))
        view.addGestureRecognizer(tap)
    }
    
    let kVelocityScale:Float = 0.0002
    @objc func tapHandle(_ sender: UITapGestureRecognizer) -> Void {
        let location = sender.location(in: view)
        if let result = hitTest(location){
            hitTestDelegate?.hitTest(self, result: result)
        }
    }
    
 
    
    var panStart = CGPoint()
    @objc func panHandle(_ sender: UIPanGestureRecognizer) ->Void{
        
        let velocity = sender.velocity(in: view)
        if sender.numberOfTouches == 2{
            //双指平移
            translation(velocity: velocity)
            return
        }
        
        //起始点检测
        if sender.state == .began{
            let location = sender.location(in: view)
            if let result = hitTest(location){
                hitTestDelegate?.dragHitTest(self, result: result)
                panStart = location
            }
            
            return
        }
        
        if sender.state == .ended{
            if isPanHandle == false{
                hitTestDelegate?.dragEnded(self)
            }
            return
        }
        
        guard controlNode != nil else{
            return
        }
        
        //移动方向计算
        if isPanHandle == false{
            let location = sender.location(in: view)
            let lerp: Float = 0.2
            let x = Float(location.x - panStart.x)
            let y = Float(panStart.y - location.y)

            let dir = float3.init(x * lerp, y * lerp, 0)
//            let viewMatrix:matrix_float4x4 = matrix_float4x4_translation(t: camera.position).inverse
//            let modelVM = matrix_multiply(viewMatrix, avatar.transform)
//            let projM = camera.projectionMatrix
//            let viewport = float4(0, 0, Float(view.bounds.width), Float(view.bounds.height))
//            
//            let v = gluUnProject(obj: float4(dir, 1), modelMatrix: modelVM, projMatrix: projM, viewport: viewport)!
// 
//            hitTestDelegate?.dragDirection(self, direction: v.xyz * camera.fieldOfView / 30)
            
            let rotateY = -controlNode!.rotate.y
            let rotateX = -controlNode!.rotate.x
            
            var v = float3()
            
            v.y = dir.y * cos(rotateX)// - dir.x * sin(rotateY)
            
            v.z = -dir.y * sin(rotateX)
            v.z += dir.x * sin(rotateY)
            
            v.x = dir.x * cos(rotateY)
            
            hitTestDelegate?.dragDirection(self, direction: v * camera.fieldOfView / 30)

            return
        }

        
        if sender.state == .changed{
            //旋转
            rotateByPoint(velocity: velocity)
        }
       
    }
    
    func translation(velocity: CGPoint) -> Void {
        guard let node = controlNode else{
            return
        }
        let limitPos: Float = 80
        var pos = node.position
        pos += float3.init(Float(velocity.x*10)*kVelocityScale, Float(-velocity.y*10)*kVelocityScale, 0)
        
        controlNode?.position.x = max(min(pos.x, limitPos), -limitPos)
        controlNode?.position.y = max(min(pos.y, limitPos), -limitPos)
    }
    
    public func rotateByPoint(velocity: CGPoint) -> Void {
        guard let node = controlNode else{
            return
        }
        var rotate = node.rotate
        
        rotate.y += kVelocityScale * Float(-velocity.x)
        rotate.y = max(min(rotate.y, Float.pi/2), -Float.pi/2)
        rotate.x += kVelocityScale * Float(-velocity.y)
        rotate.x = max(min(rotate.x, Float.pi/2), -Float.pi/2)
        controlNode?.rotate = rotate
    
    }
    
    @objc func pinchHandle(_ sender: UIPinchGestureRecognizer) ->Void{
        if isPinchHandle == false{
            return
        }
        
        if sender.state == .changed{
            let limit_max: Float = 120.0
            let limit_min: Float = 20.0
            camera.fieldOfView /= Float(sender.scale)
            camera.fieldOfView = max(min(camera.fieldOfView, limit_max), limit_min)
        }
        sender.scale = 1
    }
    
    
    func hitTest(_ point: CGPoint) -> MIHitResult? {
        let viewport = view.bounds
        let width = Float(viewport.size.width)
        let height = Float(viewport.size.height)
        
        let projectionMatrix = camera.projectionMatrix
        let inverseProjectionMatrix = projectionMatrix.inverse
        
        let viewMatrix = camera.worldTransform.inverse
        let inverseViewMatrix = viewMatrix.inverse
        
        let clipX = (2 * Float(point.x)) / width - 1
        let clipY = 1 - (2 * Float(point.y)) / height
        let clipCoords = float4(clipX, clipY, 0, 1)
        
        var eyeRayDir = inverseProjectionMatrix * clipCoords
        eyeRayDir.z = -1
        eyeRayDir.w = 0
        
        var worldRayDir = (inverseViewMatrix * eyeRayDir).xyz
        worldRayDir = normalize(worldRayDir)
        
        let eyeRayOrigin = float4(x: 0, y: 0, z: 0, w: 1)
        let worldRayOrigin = (inverseViewMatrix * eyeRayOrigin).xyz

        let ray = MIRay(origin: worldRayOrigin, direction: worldRayDir)
        
        hitOriNode?.position = worldRayOrigin + worldRayDir * 100
        hitOriNode?.runAction(MIAction.moveBy(worldRayOrigin + worldRayDir * 1000, duration: 1))
        
        return rootNode.hitTest(ray)
    }
    
    
    /// 碰撞响应点
    public var hitNode: MIObject?
    /// 画线工具
    public var lineNode: MIDrawLineObject?
    /// 射线显示工具
    var hitOriNode: MIObject?
    
//    private func hitResult() -> Void {
//        let mesh = MIModelCreater.plane(length: 1, width: 1)
//        hitNode = MIObject.init(mdlMesh: mesh)
//        hitNode?.isHiden = true
//        avatar.addChildNode(hitNode!)
    
//        let mesh2 = MIModelCreater.sphere(radius: 5)
//        hitOriNode = MIObject.init(mdlMesh: mesh2)
//        hitOriNode?.material?.setColor(color: UIColor.ZKBlue)
//        hitOriNode?.isHiden = false
//        rootNode.addChildNode(hitOriNode!)
        
//        lineNode = MIDrawLineObject.init()
//        lineNode?.isHiden = true
//        avatar.addChildNode(lineNode!)
//    }
    
    public func setHitResultPos(vexter: MIVertex) -> Void {
        hitNode?.position = vexter.position.xyz
        let v0 = float3(-1, 0, 0)
        let v1 = vexter.normal.xyz
        let z = angleByVector(v0: float2(0,1), v1: v1.zy) + Float.pi/2
        hitNode?.rotate.z =  z
        hitNode?.rotate.y = Float.pi - angleByVector(v0: v0.xz, v1: v1.xz)
        
    }
    
    public func setHitResultTexture(image: UIImage, width: Float) -> Void{
        hitNode?.scale.y = width
        hitNode?.scale.z = width
        hitNode?.material?.setTexture(cgImage: image.cgImage!)
    }
    
    
    /// 世界转屏幕坐标
    ///
    /// - Parameter worldPos: 世界坐标
    /// - Returns: 屏幕坐标
    public func worldToScreenSpace(worldPos: float3) -> CGPoint {
        
        let viewMatrix:matrix_float4x4 = matrix_float4x4_translation(t: camera.position).inverse
        let viewPos = matrix_multiply(viewMatrix, simd_float4(worldPos, 1.0))
        let projectionPos = matrix_multiply(camera.projectionMatrix, viewPos)
        let screenPos = projectionPos.xyz / projectionPos.w
        let x = (screenPos.x+1)/2 * Float(view.bounds.width)
        let y = (1 - (screenPos.y+1)/2) * Float(view.bounds.height)
        print(screenPos)
        
        return CGPoint.init(x, y)
    }
    
}

