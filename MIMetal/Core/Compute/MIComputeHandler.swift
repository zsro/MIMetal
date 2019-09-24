//
//  MIComputeHandler.swift
//  Mirage3D
//
//  Created by 影子 on 2018/12/13.
//  Copyright © 2018 影子. All rights reserved.
//

import Foundation
import MetalKit

public class MIComputeHandle{
    
    public var eyelidComputeRender: MIEyelidComputeRender?
    var queue: MTLCommandQueue?
    
    public static let share:MIComputeHandle = MIComputeHandle.init()
    
    private init() {
        queue = mtlDevice.makeCommandQueue()
        eyelidComputeRender = MIEyelidComputeRender.init()
    }
    
    
    public func computeTexture(uniforms: Uniforms_DrawEyelid, textures: [MTLTexture]) -> Void {
        
        guard let buffer = queue?.makeCommandBuffer() else{
            return
        }
        eyelidComputeRender?.catchOne(uniforms, textures: textures)
        eyelidComputeRender?.render(buffer: buffer)
        
    }
    
  
    
    
}


