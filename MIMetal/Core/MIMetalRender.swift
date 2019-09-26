//
//  MetalView.swift
//  Mirage3D
//
//  Created by 影子.zsr on 2018/8/7.
//  Copyright © 2018年 影子. All rights reserved.
//

import Foundation
import MetalKit
import MetalPerformanceShaders

let MIInFlightBufferCount:Int = 3

public class MIMetalRender: NSObject {

    var queue: MTLCommandQueue!

    weak var scene: MIMetalScene?
    public var bgRender: MIMetalBackground!

    var displaySemaphore = DispatchSemaphore(value: MIInFlightBufferCount)
    var bufferIndex:Int = 0
    var deltaTime: TimeInterval = 0.0
    
    var viewportSize: simd_uint2 = vector2(0, 0)
    private var currentTime: Double = 0
    
    func clear() -> Void {
        queue = nil
        bgRender = nil
        scene = nil
    }
    
    deinit {
        print("---------- MIMetalRender deinit")
    }
    
    override init() {
        super.init()
        queue = mtlDevice.makeCommandQueue()
        bgRender = MIMetalBackground.init()
        let bg = UIImage.color2UIImage(color: UIColor.black, size: CGSize.init(width: 20, height: 20))
        bgRender.setTexture(from: bg)
        bgRender.initialize()
    }
    
}

extension MIMetalRender: MTKViewDelegate{
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("-------- drawableSizeWillChange !!!")
        scene?.camera.aspect = Float(size.width / size.height)
    }
    
    public func draw(in view: MTKView) {
        guard let rpd = view.currentRenderPassDescriptor else { return }
        guard let drawable = view.currentDrawable else { return }
        guard let commandBuffer = queue.makeCommandBuffer() else { return }
        
        let _ = self.displaySemaphore.wait(timeout: DispatchTime.distantFuture)
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd) else { return }
        
        bgRender.render(commandEncoder: commandEncoder)
       
        if let scene = scene{
            drawNode(node: scene.rootNode, camera: scene.camera, commandEncoder: commandEncoder, bufferInfo: MIBufferInfo.init(lightPos: CGPoint(), deltaTime: deltaTime))
        }
    
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        
        commandBuffer.addCompletedHandler { (buffer) in
            self.bufferIndex = (self.bufferIndex + 1) % MIInFlightBufferCount
            self.displaySemaphore.signal()
            let time = CFAbsoluteTimeGetCurrent()
            self.deltaTime = time - self.currentTime
            self.currentTime = time
        }
        
        commandBuffer.commit()
    }
    
    public func drawNode(node: MINode, camera: MICamera, commandEncoder: MTLRenderCommandEncoder, bufferInfo: MIBufferInfo) -> Void {
        if node.mesh != nil && node.isHiden == false{
            node.render(commandEncoder: commandEncoder, camera: camera, bufferIndex: bufferIndex, bufferInfo: bufferInfo)
        }
        for item in node.children{
            drawNode(node: item, camera: camera, commandEncoder: commandEncoder, bufferInfo: bufferInfo)
        }
    }
    
}

public struct MIBufferInfo {
    let lightPos: CGPoint
    let deltaTime: Double
}




