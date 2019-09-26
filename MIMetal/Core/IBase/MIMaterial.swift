//
//  MIMaterial.swift
//  Mirage3D
//
//  Created by 影子 on 2019/3/26.
//  Copyright © 2019 影子. All rights reserved.
//


import Foundation
import MetalKit



public class MIMaterial {
    
    var renderPipelineState: MTLRenderPipelineState!
    var depthStencilState: MTLDepthStencilState!
    
    public var winding: MTLWinding = .counterClockwise
    public var cullModel: MTLCullMode = .back

    var sampler: MTLSamplerState!
    var uniform = Uniforms()
    var uniformBuffer: MTLBuffer!
    public var diffuseTexture: MTLTexture?
    
    private var _depthCompareFunction: MTLCompareFunction = .less
    var depthCompareFunction: MTLCompareFunction{
        get{
            return _depthCompareFunction
        }
        set{
            _depthCompareFunction = newValue
            createDepthStencilState()
        }
    }
    
    struct Uniforms {
        var grayColor: simd_float4 = simd_float4([0.7, 0.7, 0.7, 0])
        var lightPos: simd_float4 = simd_float4([0.13, 0.72, 0.68, 0])
        var modelViewProjectionMatrix: matrix_float4x4 = matrix_float4x4()
        var modelViewMatrix: matrix_float4x4 = matrix_float4x4()
        var normalMatrix: matrix_float3x3 = matrix_float3x3()
    }
    
    public init() {
        createPipeline()
        createDepthStencilState()
        createSampler()
        setTexture(cgImage: UIImage.color2UIImage(color: UIColor.ZKGray, size: CGSize.init(width: 10, height: 10)).cgImage!)
        uniformBuffer = mtlDevice.makeBuffer(length: MemoryLayout<MIMaterial.Uniforms>.size * MIInFlightBufferCount, options: [])
    }
    
    public func setLightPos(_ pos: simd_float3) -> Void {
        uniform.lightPos.x = pos.x
        uniform.lightPos.y = pos.y
        uniform.lightPos.z = pos.z
    }
    
    public func setLightPos(by screenPoint: CGPoint) -> Void{
        let height: Float = Float(200 * ScreenHeight / ScreenWidth)
        let width: Float = 200
        setLightPos(float3(Float(screenPoint.x - 0.5) * width, Float(0.5 - screenPoint.y) * height, 80))
    }
    
    public func setLightEnable(_ enable: Bool) -> Void {
        uniform.lightPos.w = enable ? 1 : 0
    }
    
    public func setGrayColor(_ color: simd_float3) -> Void {
        uniform.grayColor.x = color.x
        uniform.grayColor.y = color.y
        uniform.grayColor.z = color.z
    }
    
    public func setGrayEnable(_ enable: Bool) -> Void {
        uniform.grayColor.w = enable ? 1 : 0
    }
    
    func createPipeline(){
        let vert_func = mtlLibrary.makeFunction(name: "objectDiffuse_vertex")!
        let frag_func = mtlLibrary.makeFunction(name: "objectDiffuse_fragment")!
        let rpld = MTLRenderPipelineDescriptor.init()
        rpld.vertexFunction = vert_func
        rpld.fragmentFunction = frag_func
        
        rpld.depthAttachmentPixelFormat = .depth32Float
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
//        rpld.sampleCount = 4
        renderPipelineState = try! mtlDevice.makeRenderPipelineState(descriptor: rpld)
    }
    
    func createDepthStencilState(){
        let depthStencilDescriptor = MTLDepthStencilDescriptor.init()
        depthStencilDescriptor.depthCompareFunction = depthCompareFunction
        depthStencilDescriptor.isDepthWriteEnabled = true

        depthStencilState = mtlDevice.makeDepthStencilState(descriptor: depthStencilDescriptor)!
    }
    
    public func setTexture(cgImage:CGImage) -> Void {
        let loader = MTKTextureLoader.init(device: mtlDevice)
        
        do{
            diffuseTexture = try loader.newTexture(cgImage: cgImage, options: nil)
        }catch{
            print("error: metal texture load failed !!!")
        }
    }
    
    public func setColor(color: UIColor) -> Void {
        if let image = UIImage.color2UIImage(color: UIColor.ZKGray, size: CGSize.init(width: 10, height: 10)).cgImage{
            setTexture(cgImage: image)
        }
    }
    
    func createSampler(){
        let msd = MTLSamplerDescriptor.init()
        msd.minFilter        = .nearest
        msd.magFilter        = .linear
        msd.mipFilter        = .linear
        msd.sAddressMode     = .clampToZero
        msd.rAddressMode     = .clampToZero
        msd.tAddressMode     = .clampToZero
        sampler = mtlDevice.makeSamplerState(descriptor: msd)
    }
    
    func render(commandEncoder: MTLRenderCommandEncoder, bufferIndex: Int, uniforms_default: Uniforms_default, bufferInfo: MIBufferInfo){
        commandEncoder.setDepthStencilState(depthStencilState)
        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setFrontFacing(winding)
        commandEncoder.setCullMode(cullModel)
        commandEncoder.setFragmentTexture(diffuseTexture, index: 0)
        commandEncoder.setFragmentSamplerState(sampler, index: 0)
        uniform.normalMatrix = uniforms_default.normalMatrix
        uniform.modelViewMatrix = uniforms_default.modelViewMatrix
        uniform.modelViewProjectionMatrix = uniforms_default.modelViewProjectionMatrix
        setLightPos(by: bufferInfo.lightPos)
        let uniformBufferOffset = MemoryLayout<Uniforms>.size * bufferIndex
        memcpy(uniformBuffer.contents() + uniformBufferOffset, &uniform, MemoryLayout<Uniforms>.size)
        commandEncoder.setVertexBuffer(uniformBuffer, offset: uniformBufferOffset, index: 1)
        commandEncoder.setFragmentBuffer(uniformBuffer, offset: uniformBufferOffset, index: 0)
    }
    
}
