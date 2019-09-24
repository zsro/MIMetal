//
//  MIMesh.swift
//  Mirage3D
//
//  Created by 加冰 on 2018/12/13.
//  Copyright © 2018 影子. All rights reserved.
//

import MetalKit

public class MIVertexBuffer{
    public var vertexBuffer:MTLBuffer!
    public var indexBuffer:MTLBuffer!
}


public class MIMesh {
    public var mtkMesh: MTKMesh?
    public var vecs:[MIVertex]?
    public var face_uint16:[UInt16]?
    public var face_uint32:[UInt32]?
    
    public var miBuffer:MIVertexBuffer?
    
    public var primitiveType: MTLPrimitiveType = .triangle
    public var indexType: MTLIndexType = .uint32
    private var indexSize: Int{
        return indexType == .uint16 ? MemoryLayout<UInt16>.size : MemoryLayout<UInt32>.size
    }
    
    deinit {
        vecs?.removeAll()
        face_uint32?.removeAll()
        face_uint16?.removeAll()
        miBuffer?.vertexBuffer = nil
        miBuffer?.indexBuffer = nil
    }
    
    public init() {
        
    }
    
    public init(mesh: MTKMesh) {
        self.mtkMesh = mesh
    }
    
    public init(vecs: [MIVertex], face_uint16: [UInt16]) {
        self.vecs = vecs
        self.face_uint16 = face_uint16
        indexType = .uint16
        miBuffer = MIVertexBuffer.init()
        miBuffer?.vertexBuffer = mtlDevice.makeBuffer(bytes: vecs, length: MemoryLayout<MIVertex>.size * vecs.count, options: [])
        miBuffer?.indexBuffer = mtlDevice.makeBuffer(bytes: face_uint16, length: indexSize * face_uint16.count , options: [])
    }
    
    public init(vecs: [MIVertex], face_uint32: [UInt32]) {
        self.vecs = vecs
        self.face_uint32 = face_uint32
        indexType = .uint32
        miBuffer = MIVertexBuffer.init()
        miBuffer?.vertexBuffer = mtlDevice.makeBuffer(bytes: vecs, length: MemoryLayout<MIVertex>.size * vecs.count, options: [])
        miBuffer?.indexBuffer = mtlDevice.makeBuffer(bytes: face_uint32, length: indexSize * face_uint32.count, options: [])
    }
    
    
    func render(commandEncoder: MTLRenderCommandEncoder){
        if let mesh = mtkMesh{
            for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
                commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: index)
            }
            
            for submesh in mesh.submeshes {
                commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                           indexCount: submesh.indexCount,
                                                           indexType: submesh.indexType,
                                                           indexBuffer: submesh.indexBuffer.buffer,
                                                           indexBufferOffset: submesh.indexBuffer.offset)
            }
            return
        }

        commandEncoder.setVertexBuffer(miBuffer!.vertexBuffer, offset: 0, index: 0)

        commandEncoder.drawIndexedPrimitives(type: primitiveType,
                                             indexCount: miBuffer!.indexBuffer.length / indexSize,
                                             indexType: indexType,
                                             indexBuffer: miBuffer!.indexBuffer,
                                             indexBufferOffset: 0)
    }
}

public extension MIMesh {
    
    func createVertexBuffer() -> Void {
        if miBuffer != nil{
            miBuffer?.vertexBuffer = mtlDevice.makeBuffer(bytes: vecs!, length: MemoryLayout<MIVertex>.size * vecs!.count, options: [])
            /// 直接修改 buffer
            // let result = outBuffer.contents().bindMemory(to: Float.self, capacity: count)
            // var data = [Float](repeating:0, count: count)
            // for i in 0 ..< count { data[i] = result[i] }
        }
    }
    
    
    func updataVector(vs: NSMutableArray) -> Void {
        if vs.count == 0{
            return
        }
        for i in 0...vs.count/4 - 1{
            let index = (vs[i*4] as! NSNumber).intValue
            vecs?[index].position.x = (vs[i*4+1] as! NSNumber).floatValue
            vecs?[index].position.y = (vs[i*4+2] as! NSNumber).floatValue
            vecs?[index].position.z = (vs[i*4+3] as! NSNumber).floatValue
        }
        createVertexBuffer()
    }
    
    func getVec(index: Int) -> float3 {
        
        return float3.init((vecs![index].position.x), (vecs![index].position.y), (vecs![index].position.z))
        
    }
    
}


// MARK: - 保存obj
extension MIMesh{
    
    
    /// mesh数据保存为obj文件
    ///
    /// - Parameter path: 储存路径
    public func writeToObj(path: String) -> Void {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path){
            try? fileManager.removeItem(atPath: path)
        }
        
        fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        let handle = FileHandle.init(forWritingAtPath: path)!
        var writer: String = ""
        writer.write("mtllib result_source.mtl\n")
        
        for item in vecs!{
            let x = item.position.x
            let y = item.position.y
            let z = item.position.z
            writer.write("v \(x) \(y) \(z)")
            writer.write("\n")
        }
        writer.write("#Total \(vecs!.count) vertices\n")
        for item in vecs!{
            writer.write("vn \(item.normal.x) \(item.normal.y) \(item.normal.z)")
            writer.write("\n")
        }
        writer.write("#Total \(vecs!.count) vertice normals\n")
        for item in vecs!{
            writer.write("vt \(item.texcoord.x) \(1 - item.texcoord.y)")
            writer.write("\n")
        }

        let f = face_uint32!
        writer.write("#Total \(vecs!.count) vertice textures\n")

        writer.write("g Unknown\n")
        writer.write("usemtl material_0\n")

        for j in 0...f.count/3 - 1{
            let i = j * 3
            let x1 = f[i] + 1
            let x2 = f[i+1] + 1
            let x3 = f[i+2] + 1
            writer.write("f \(x1)/\(x1)/\(x1) \(x2)/\(x2)/\(x2) \(x3)/\(x3)/\(x3)")
            writer.write("\n")
        }

        handle.write(writer)
        handle.closeFile()
    }
    
    
}

extension FileHandle{
    
    func write(_ content: String) -> Void {
        write(content.data(using: String.Encoding.utf8)!)
    }
    
}
