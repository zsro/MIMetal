//
//  MIDiffuseMaterial.swift
//  Mirage3D
//
//  Created by 影子 on 2019/3/30.
//  Copyright © 2019 影子. All rights reserved.
//

import Foundation
import simd
import MetalKit


class MIObjectMaterial: MIMaterial {
    
    struct Uniforms_Obj {
        var modelViewProjectionMatrix: simd_float4x4
        var normalMatrix: simd_float3x3
        var state: simd_float4 //(灯光，描边，待定，待定)
    }
    
    var constants = Uniforms_Obj(modelViewProjectionMatrix: float4x4(), normalMatrix: float3x3(), state: float4())
    
    override init() {
        super.init()
        
        uniformBuffer = mtlDevice.makeBuffer(length:  MemoryLayout<Uniforms_Obj>.size * MIInFlightBufferCount, options: [])
    }
    
    func createPipeline(vertexDescriptor: MTLVertexDescriptor) -> Void {
        let vert_func = mtlLibrary.makeFunction(name: "vertex_light")!
        let frag_func = mtlLibrary.makeFunction(name: "fragment_light")!
        let rpld = MTLRenderPipelineDescriptor.init()
        rpld.vertexFunction = vert_func
        rpld.fragmentFunction = frag_func
        rpld.vertexDescriptor = vertexDescriptor
        rpld.depthAttachmentPixelFormat = .depth32Float
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
      
        let renderbufferAttachment = rpld.colorAttachments[0]
        renderbufferAttachment?.pixelFormat = MTLPixelFormat.bgra8Unorm;
        renderbufferAttachment?.isBlendingEnabled = true;
        renderbufferAttachment?.rgbBlendOperation = MTLBlendOperation.add;
        renderbufferAttachment?.alphaBlendOperation = MTLBlendOperation.add;

        renderbufferAttachment?.sourceRGBBlendFactor = MTLBlendFactor.sourceAlpha;
        renderbufferAttachment?.destinationRGBBlendFactor = MTLBlendFactor.oneMinusSourceAlpha;
        
        renderbufferAttachment?.sourceAlphaBlendFactor = MTLBlendFactor.sourceAlpha;
        renderbufferAttachment?.destinationAlphaBlendFactor = MTLBlendFactor.oneMinusSourceAlpha;
        
        self.renderPipelineState = try! mtlDevice.makeRenderPipelineState(descriptor: rpld)
    }

    
    override func render(commandEncoder: MTLRenderCommandEncoder, bufferIndex: Int, uniforms_default: Uniforms_default, depthTexture: MTLTexture?, bufferInfo: MIBufferInfo) {
        commandEncoder.setDepthStencilState(depthStencilState)
        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setFrontFacing(winding)
        commandEncoder.setCullMode(cullModel)
        constants.modelViewProjectionMatrix = uniforms_default.modelViewProjectionMatrix
        constants.normalMatrix = uniforms_default.normalMatrix

        let uniformBufferOffset = MemoryLayout<Uniforms_Obj>.size * bufferIndex
        memcpy(uniformBuffer.contents(), &constants + uniformBufferOffset, MemoryLayout<Uniforms_Obj>.size)

        commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        commandEncoder.setFragmentTexture(diffuseTexture, index: 0)
        commandEncoder.setFragmentTexture(depthTexture, index: 1)
        commandEncoder.setFragmentSamplerState(sampler, index: 0)
    }
    

}
