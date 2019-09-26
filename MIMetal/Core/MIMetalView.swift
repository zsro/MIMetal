//
//  MIMetalView.swift
//  Mirage3D
//
//  Created by 加冰 on 2018/8/14.
//  Copyright © 2018年 影子. All rights reserved.
//

import Foundation
import MetalKit

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

let avatarTextureWidth: CGFloat = 4096
let avatarTextureHeight: CGFloat = 2048

public var mtlDevice: MTLDevice!// = MTLCreateSystemDefaultDevice()!
public var mtlLibrary: MTLLibrary!// = try mtlDevice.makeDefaultLibrary(bundle: Bundle.main)

public class MIMetalView: MTKView {
    
    var depthTexture: MTLTexture?
    private var time: Timer?
    private var framecount: CGFloat = 120

    init(frame: CGRect) {
        
        super.init(frame: frame, device: mtlDevice)

        self.autoResizeDrawable = false
        autoresizingMask = .init(rawValue: AutoresizingMask.flexibleHeight.rawValue | AutoresizingMask.flexibleWidth.rawValue)
//        self.preferredFramesPerSecond = 120
        self.isPaused = true
        setPaused(false)
        makeDepthTexture()
//        sampleCount = 4
    }
    
    
    func clear() -> Void {
        removeFromSuperview()
        setPaused(true)
    }
    
    deinit {
        print("---------- MIMetalView deinit")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPaused(_ isPaused:Bool) -> Void {
        time?.invalidate()
        if isPaused{
            return
        }else{
            time = Timer.scheduledTimer(withTimeInterval: TimeInterval(1.0/framecount), repeats: true) { (time) in
                self.draw()
            }
        }
    }
    
    override public var currentRenderPassDescriptor: MTLRenderPassDescriptor?{
        get{
            if self.currentDrawable == nil{
                return nil
            }
            let passDescriptor = MTLRenderPassDescriptor.init()
            passDescriptor.colorAttachments[0].texture = self.currentDrawable?.texture
            passDescriptor.colorAttachments[0].clearColor = self.clearColor
            passDescriptor.colorAttachments[0].storeAction = .store;
            passDescriptor.colorAttachments[0].loadAction = .clear
            
            passDescriptor.depthAttachment.texture = self.depthTexture;
            passDescriptor.depthAttachment.clearDepth = 1.0;
            passDescriptor.depthAttachment.loadAction = .clear;
            passDescriptor.depthAttachment.storeAction = .dontCare;
            
            return passDescriptor;
        }
    }

    
    func makeDepthTexture() -> Void {
        if (self.depthTexture?.width != Int(drawableSize.width) ||
            self.depthTexture?.height != Int(drawableSize.height))
        {
            let des = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: Int(drawableSize.width), height: Int(drawableSize.height), mipmapped: false)
            
            des.usage = .renderTarget;
            self.depthTexture = self.device?.makeTexture(descriptor: des)
        }
    }
    

    
}
