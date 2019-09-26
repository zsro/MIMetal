//
//  MIModelCreater.swift
//  Mirage3D
//
//  Created by 影子 on 2019/4/2.
//  Copyright © 2019 影子. All rights reserved.
//

import Foundation
import ModelIO
import MetalKit


class MIModelCreater{
    
    
    static var vertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        
        vertexDescriptor.vertexAttributes[0].name = MDLVertexAttributePosition
        vertexDescriptor.vertexAttributes[0].format = .float3
        vertexDescriptor.vertexAttributes[0].offset = 0
        vertexDescriptor.vertexAttributes[0].bufferIndex = 0
        vertexDescriptor.vertexAttributes[1].name = MDLVertexAttributeNormal
        vertexDescriptor.vertexAttributes[1].format = .float3
        vertexDescriptor.vertexAttributes[1].offset = MemoryLayout<Float>.size * 3
        vertexDescriptor.vertexAttributes[1].bufferIndex = 0
        vertexDescriptor.vertexAttributes[2].name = MDLVertexAttributeTextureCoordinate
        vertexDescriptor.vertexAttributes[2].format = .float2
        vertexDescriptor.vertexAttributes[2].offset = MemoryLayout<Float>.size * 6
        vertexDescriptor.vertexAttributes[2].bufferIndex = 0
        
        vertexDescriptor.bufferLayouts[0].stride = MemoryLayout<Float>.size * 8
        return vertexDescriptor
    }()
    
    
    static func sphere(radius: Float) -> MDLMesh{
        let sphereRadius: Float = radius
        let meshAllocator = MTKMeshBufferAllocator(device: mtlDevice)
        let mdlMesh = MDLMesh.init(sphereWithExtent: float3(sphereRadius, sphereRadius, sphereRadius),
                                   segments: uint2(20, 20),
                                   inwardNormals: false,
                                   geometryType: .triangles,
                                   allocator: meshAllocator)
        mdlMesh.vertexDescriptor = vertexDescriptor
        
        return mdlMesh
    }
    
    
    static func plane(length: Float, width: Float, height: Float = 0.1) -> MDLMesh{

        let meshAllocator = MTKMeshBufferAllocator(device: mtlDevice)
        let mdlMesh = MDLMesh.init(planeWithExtent: float3(length, width, height), segments: uint2(5,5), geometryType: .triangles, allocator: meshAllocator)
        mdlMesh.vertexDescriptor = vertexDescriptor
        
        return mdlMesh
    }
    
    static func box(length: Float, width: Float, height: Float) -> MDLMesh{
        let meshAllocator = MTKMeshBufferAllocator(device: mtlDevice)
        let mdlMesh = MDLMesh.init(boxWithExtent: float3(length, width, height), segments: uint3(10,10,10), inwardNormals: false, geometryType: .triangles, allocator: meshAllocator)
        mdlMesh.vertexDescriptor = vertexDescriptor

        return mdlMesh
    }
    
    
}

// do Fix your stuff, guys.
extension MDLVertexDescriptor {
    var vertexAttributes: [MDLVertexAttribute] {
        return attributes as! [MDLVertexAttribute]
    }
    var bufferLayouts: [MDLVertexBufferLayout] {
        return layouts as! [MDLVertexBufferLayout]
    }
}

