//
//  MIDrawLineObject.swift
//  Mirage3D
//
//  Created by 影子 on 2019/4/28.
//  Copyright © 2019 影子. All rights reserved.
//

import Foundation
import MetalKit
import simd

public class MIDrawLineObject: MINode {
    
    private var vertexBuffer: MTLBuffer?
    private var _vecs: [MIVertex] = []
    public var vecs: [MIVertex]{
        get{
            return _vecs
        }
        set{
            _vecs = newValue
            vertexBuffer = mtlDevice.makeBuffer(bytes: _vecs, length: MemoryLayout<MIVertex>.size * _vecs.count, options: [])
        }
    }
    
    
    override init() {
        super.init()
        mesh = MIMesh()
        material = MIDrawLineMaterial()
        
        vecs = [MIVertex.init(position: simd_float4(0,0,0,1), normal: simd_float4(), texcoord: simd_float2()),
        MIVertex.init(position: simd_float4(50,0,0,1), normal: simd_float4(), texcoord: simd_float2()),
        MIVertex.init(position: simd_float4(50,50,0,1), normal: simd_float4(), texcoord: simd_float2()),
        MIVertex.init(position: simd_float4(0,50,0,1), normal: simd_float4(), texcoord: simd_float2()),
        MIVertex.init(position: simd_float4(0,0,0,1), normal: simd_float4(), texcoord: simd_float2())]
    }
    
    override func render(commandEncoder: MTLRenderCommandEncoder, camera: MICamera, bufferIndex: Int, depthTexture: MTLTexture?, bufferInfo: MIBufferInfo) {
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        material?.render(commandEncoder: commandEncoder, bufferIndex: bufferIndex, uniforms_default: camera.getUniform(transform: worldTransform), depthTexture: depthTexture, bufferInfo: bufferInfo)
        commandEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: vecs.count)
    }
}

class MIDrawLineMaterial: MIMaterial {
    
    struct Uniform_line {
        let modelVP: matrix_float4x4
    }
    
    override init() {
        super.init()
        depthCompareFunction = .always
        createPipeline()
        uniformBuffer = mtlDevice.makeBuffer(length: MemoryLayout<Uniform_line>.size * MIInFlightBufferCount, options: [])
    }
    
    override func createPipeline() {
        let vert_func = mtlLibrary.makeFunction(name: "vertex_line")!
        let frag_func = mtlLibrary.makeFunction(name: "fragment_line")!
        let rpld = MTLRenderPipelineDescriptor.init()
        rpld.vertexFunction = vert_func
        rpld.fragmentFunction = frag_func
        
        rpld.depthAttachmentPixelFormat = .depth32Float
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineState = try! mtlDevice.makeRenderPipelineState(descriptor: rpld)
    }
    
    override func render(commandEncoder: MTLRenderCommandEncoder, bufferIndex: Int, uniforms_default: Uniforms_default, depthTexture: MTLTexture?, bufferInfo: MIBufferInfo) {
        var u = Uniform_line.init(modelVP: uniforms_default.modelViewProjectionMatrix)
        let uniformBufferOffset = MemoryLayout<Uniform_line>.size * bufferIndex
        memcpy(uniformBuffer.contents() + uniformBufferOffset, &u, MemoryLayout<Uniform_line>.size)
        commandEncoder.setCullMode(.none)
        commandEncoder.setDepthStencilState(depthStencilState)
        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(uniformBuffer, offset: uniformBufferOffset, index: 1)
    }
    
}






