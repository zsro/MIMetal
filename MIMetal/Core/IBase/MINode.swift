//
//  MINode.swift
//  metalTest
//
//  Created by 影子.zsr on 2018/8/30.
//  Copyright © 2018年 加冰. All rights reserved.
//

import Foundation
import simd
import MetalKit

public class MINode: NSObject{

    public var name: String?
    public let identifier = UUID()
    public var mesh: MIMesh?
    public var material: MIMaterial?
    public var isHiden: Bool = false
    
    /// 可否复用
    public var resuable: Bool = false
    
    //transform
    public weak var parent: MINode?
    public var children = [MINode]()
    
    public var isUserInteractionEnabled: Bool = false
    
    /// 动画计时器
    private var actionDic:Dictionary<String,MIActionData> = [:]
    
    public var rotate:float3 = float3.init()
    public var position:float3 = float3.init()
    public var scale:float3 = float3.init(1, 1, 1)
    
    public var transform: simd_float4x4{
        return matrix_float4x4_transform(pos: position, rotate: rotate, scale: scale)
    }
    
    public var worldTransform: simd_float4x4 {
        if let parent = parent {
            return parent.worldTransform * transform
        } else {
            return transform
        }
    }
    
    
    /// 暂时未计算旋转
    public var worldPosition: float3{
        if let parent = parent{
            return parent.worldPosition + position
        }else{
            return position
        }
    }
    
    deinit {
        parent = nil
        children.removeAll()
        actionDic.removeAll()
    }
    
    public override init() {
        super.init()
        
    }

    
    func render(commandEncoder: MTLRenderCommandEncoder, camera: MICamera, bufferIndex: Int, depthTexture: MTLTexture?, bufferInfo: MIBufferInfo) -> Void {
        updateAction(deltaTime: bufferInfo.deltaTime)
        
        let uniform = camera.getUniform(transform: worldTransform)
        
        material?.render(commandEncoder: commandEncoder, bufferIndex: bufferIndex, uniforms_default: uniform, depthTexture: depthTexture, bufferInfo: bufferInfo)
        
        mesh?.render(commandEncoder: commandEncoder)
    }
    
    func updateAction(deltaTime: Double) -> Void {
        weak var wealSelf = self
        for item in actionDic.values{
            if item.action.isFinish{
                wealSelf?.actionDic.removeValue(forKey: item.action.name)
                item.action.timingFunction = nil
                item.completionHandler?()
                return
            }

            item.action.timingFunction?(wealSelf, deltaTime)
        }
    }
}

public extension MINode{
    
    func addChildNode(_ node: MINode) {
        if node.parent != nil && node.resuable == false{
            node.removeFromParent()
        }
        children.append(node)
        node.parent = self
    }
    
    
    func removeChildNode(_ node: MINode) {
        children = children.filter { $0 != node } //  In Swift 4.2, this could be written with removeAll(where:)
    }
    
    func removeAllChildNode() -> Void {
        for item in children{
            item.parent = nil
        }
        children.removeAll()
    }
    
    func removeFromParent() {
        parent?.removeChildNode(self)
        parent = nil
    }
    
    
    static func == (lhs: MINode, rhs: MINode) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    override var debugDescription: String { return "<Node>: \(name ?? "unnamed")" }
    
}

private class MIActionData{
    var action: MIAction!
    var completionHandler: (() -> Void)?
    
    init(_ action: MIAction, completionHandler: (() -> Void)?) {
        self.action = action
        self.completionHandler = completionHandler
    }
}

extension MINode: MIActionable{
    
    
    public func runAction(_ action: MIAction) {
        runAction(action, completionHandler: nil)
    }
    
    public func runAction(_ action: MIAction, completionHandler block: (() -> Void)?) {
        for item in actionDic{
            if item.value.action.type == action.type{
                item.value.action.timingFunction = nil
                actionDic.removeValue(forKey: item.key)
                break
            }
        }

//        let timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1.0 / actionFrame), repeats: true) { (timer) in
//            if action.isFinish{
//                wealSelf?.actionDic.removeValue(forKey: action.name)
//
//                timer.invalidate()
//                action.timingFunction = nil
//                block?()
//                return
//            }
//
//            action.timingFunction?(wealSelf, <#TimeInterval#>)
//
//        }
        actionDic[action.name] = MIActionData.init(action, completionHandler: block)
    }
    
    public func runAction(_ action: MIAction, forKey key: String?) {
        guard let key = key else {
            return
        }
        
        action.name = key
        runAction(action)
    }
    
    public func runAction(_ action: MIAction, forKey key: String?, completionHandler block: (() -> Void)?) {
        guard let key = key else {
            return
        }
        
        action.name = key
        runAction(action, completionHandler: block)
    }
    
    public func action(forKey key: String) -> MIAction? {
        return actionDic[key]?.action
    }
    
    public func removeAction(forKey key: String) {
        actionDic.removeValue(forKey: key)
    }
    
    public func removeAllActions() {
        actionDic.removeAll()
    }
    
    public var hasActions: Bool {
        return actionDic.count > 0
    }
    
    public var actionKeys: [String] {
        var arr:[String] = []
        for item in actionDic.keys{
            arr.append(item)
        }
        return arr
    }
    
    
}


extension MINode{
    
    public func hitTest(_ ray: MIRay) -> MIHitResult? {
        var nearest: MIHitResult?
        if isUserInteractionEnabled{
            nearest = hitTestDetect(ray)
        }
        
        var nearestChildHit: MIHitResult?
        for child in children {
            if let childHit = child.hitTest(ray) {
                if let nearestActualChildHit = nearestChildHit {
                    if childHit < nearestActualChildHit {
                        nearestChildHit = childHit
                    }
                } else {
                    nearestChildHit = childHit
                }
            }
        }
        
        if let nearestActualChildHit = nearestChildHit {
            if let nearestActual = nearest {
                if nearestActualChildHit < nearestActual {
                    return nearestActualChildHit
                }
            } else {
                return nearestActualChildHit
            }
        }
        
        return nearest
    }
    
    private func hitTestDetect(_ ray: MIRay) -> MIHitResult?{
        if let mesh = mesh{
            let modelToWorld = worldTransform
            let localRay = modelToWorld.inverse * ray

            let count = mesh.vecs!.count
            var index: Int = -1
            var parameter: Float = Float.greatestFiniteMagnitude
            var distence: Float = Float.greatestFiniteMagnitude
            for i in 0...count-1{
                let vec = mesh.vecs![i]
                if localRay.intersectionAngle(vec.normal.xyz) < Float.pi/2{
                    continue
                }

                let worldParameter = localRay.distence(vec.position.xyz)
                let worldDistence = length(vec.position.xyz - localRay.origin)
                
                if worldParameter > 5{
                    continue
                }

                if distence - worldDistence > 5{
                    distence = worldDistence
                    parameter = worldParameter
                    index = i
                    continue
                }
                
                
                if worldParameter < parameter && worldDistence < distence + 5{
                    distence = worldDistence
                    parameter = worldParameter
                    index = i
                    continue
                }
                

//                if let modelPoint = localRay.intersect(center: vec.position.xyz){
//                    let worldPoint = modelToWorld * modelPoint
//                    let worldParameter = ray.interpolate(worldPoint)
//                    if worldParameter < parameter{
//                        parameter = worldParameter
//                        index = i
//                    }
//                }
                
            }
            
            if index != -1{
                 return MIHitResult.init(ray: ray, node: self, faceIndex: 0, vertexIndex: index, textureCoordinates: mesh.vecs![index].texcoord, localCoordinates: mesh.vecs![index], worldCoordinates: mesh.vecs![index], parameter: parameter)
            }
           
        }
        
        return nil
    }
    
}



// MARK: - 功能扩展
public extension MINode{
    
    func look(at pos: float3) -> Void {
//        let diff = pos - position
//        let q = SCNQuaternion
//
//        let forward = float3.init(0, 0, 1)
        
    }
    
}


public typealias MIQuaternion = simd_float4

public extension MIQuaternion{
    
    static func fromEuler(_ rotation: float3) -> MIQuaternion {
        let X = rotation.x
        let Y = rotation.y
        let Z = rotation.z
        
        let x = sin(Y/2)*sin(Z/2)*cos(X/2)+cos(Y/2)*cos(Z/2)*sin(X/2)
        let y = sin(Y/2)*cos(Z/2)*cos(X/2)+cos(Y/2)*sin(Z/2)*sin(X/2)
        let z = cos(Y/2)*sin(Z/2)*cos(X/2)-sin(Y/2)*cos(Z/2)*sin(X/2)
        let w = cos(Y/2)*cos(Z/2)*cos(X/2)-sin(Y/2)*sin(Z/2)*sin(X/2)
        return float4.init([x, y, z, w])
    }
    
    static func fromToRotation(v0: float3, v1: float3) -> MIQuaternion{
        return float4()
        
    }
    
}

let Rad2Deg: Float = 360/(2*Float.pi)



