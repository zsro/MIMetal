//
//  MITextureComputeRender.swift
//  Mirage3D
//
//  Created by 影子 on 2018/12/11.
//  Copyright © 2018 影子. All rights reserved.
//

import Foundation
import MetalKit

public class MIEyelidComputeRender {
    
    var cps:MTLComputePipelineState?
    var sampler:MTLSamplerState!
    var outTexture:MTLTexture?
    var inTexture:[MTLTexture] = []
    var uniformBuffer:MTLBuffer!
    
    var isHiden:Bool = true
    public var completeBlock:((UIImage?) ->Void)?
    
    deinit {
        inTexture.removeAll()
        completeBlock = nil
    }
    
    init() {
        createCPS()
        createSample()
        createBuffer()
    }
    
    func createBuffer() -> Void {
        uniformBuffer = mtlDevice.makeBuffer(length: MemoryLayout<Uniforms_DrawEyelid>.size, options: [])
    }
    
    func catchOne(_ eyelidUniforms: Uniforms_DrawEyelid, textures: [MTLTexture]) -> Void {
        inTexture.append(contentsOf: textures)
        let texture = inTexture[0]
        let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: texture.pixelFormat, width: texture.width, height: texture.height, mipmapped: false)
        outTextureDescriptor.usage = MTLTextureUsage.init(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue)
        outTexture = mtlDevice.makeTexture(descriptor: outTextureDescriptor)

        var uniforms = eyelidUniforms
        memcpy(uniformBuffer.contents(), &uniforms, MemoryLayout<Uniforms_DrawEyelid>.size)
        isHiden = false
    }
    
    func createCPS() -> Void {
        guard let compute_func = mtlLibrary.makeFunction(name: "eyelid_draw") else{
            print("create eyelid_draw CPS faild!!!")
            return
        }
        do{
            cps = try mtlDevice.makeComputePipelineState(function: compute_func)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func createSample() -> Void {
        let msd = MTLSamplerDescriptor.init()
        msd.minFilter        = .nearest
        msd.magFilter        = .linear
        msd.mipFilter        = .linear
        msd.sAddressMode     = .clampToZero
        msd.rAddressMode     = .clampToZero
        msd.tAddressMode     = .clampToZero
        
        sampler = mtlDevice.makeSamplerState(descriptor: msd)
    }
    
    
    func render(buffer: MTLCommandBuffer) -> Void {
        guard isHiden == false else{
            return
        }
        isHiden = true
        
        print("=================111------------------====")
        
        if let computeEncoder = buffer.makeComputeCommandEncoder(),
            let cps = cps{
            computeEncoder.setComputePipelineState(cps)
            computeEncoder.setSamplerState(sampler, index: 0)
            
            computeEncoder.setTexture(outTexture, index: 0)
            for i in 1...inTexture.count{
                computeEncoder.setTexture(inTexture[i-1], index: i)
            }
            
            computeEncoder.setBuffer(uniformBuffer, offset: 0, index: 0)
            
            let w = 8
            let h = 2
            let threadGroupCount = MTLSize.init(width: w, height: h, depth: 1)
            let threadGroups = MTLSize.init(width: Int(avatarTextureWidth)/threadGroupCount.width,
                                           height: Int(avatarTextureHeight)/threadGroupCount.height,
                                           depth: 1)

            computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
            
            computeEncoder.endEncoding()

            buffer.addCompletedHandler { (buffer) in
                self.completeBlock?(self.outTexture?.toUIImage())
                self.outTexture = nil
                self.completeBlock = nil
                self.inTexture.removeAll()
                print(222)
            }

            buffer.commit()
            buffer.waitUntilCompleted()
            print(333)
            inTexture.removeAll()
        }
        
    }
    
}

extension MTLTexture {
    
    public func toUIImage() -> UIImage {
        let bytesPerPixel: Int = 4
        let imageByteCount = self.width * self.height * bytesPerPixel
        let bytesPerRow = self.width * bytesPerPixel
        var src = [UInt8](repeating: 0, count: Int(imageByteCount))
        
        let region = MTLRegionMake2D(0, 0, self.width, self.height)
        self.getBytes(&src, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerComponent = 8
        let context = CGContext(data: &src, width: self.width, height: self.height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue);
        
        let dstImageFilter = context?.makeImage();
        
        return UIImage(cgImage: dstImageFilter!)
    }
}


public struct Uniforms_DrawEyelid
{
    var rectLeft: simd_float4
    var rectRight: simd_float4
    var size: simd_float2
    var rotationLeft: Float
    var rotationRigh: Float
}


