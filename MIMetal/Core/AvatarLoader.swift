//
//  AvatarLoader.swift
//  Mirage3D
//
//  Created by 影子 on 2019/6/21.
//  Copyright © 2019 影子. All rights reserved.
//

import Foundation

public class MIAvatarData {
    
    let path: String
    public var texture: UIImage?
    
    public var vs: [MIVertex] = []
    public var face: [UInt32] = []
    
    public var tri_map:Dictionary<Int,[UInt32]> = [:]
    public var vecTri_Map:Dictionary<UInt32,[Int]> = [:]
    public var vecNeighbor:Dictionary<UInt32,[UInt32]> = [:]
    
    private var operationQueue:OperationQueue?
    
    deinit {
        operationQueue?.cancelAllOperations()
        print("--------- MIAvatarData deinit")
    }
    
    init(path: String) {
        self.path = path
    }
    
    private func loadMeshData(){
        //33256
        let loader = ObjLoaderBridge.init()
        loader.load(path)
        
        let _vs = loader.data_v!
        let _vns = loader.data_vn!
        let _vts = loader.data_vt!
        let _face = loader.data_face!
        
        for i in 0..._vs.count/3 - 1{
            
            let x = (_vs[i*3] as! NSNumber).floatValue
            let y = (_vs[i*3+1] as! NSNumber).floatValue
            let z = (_vs[i*3+2] as! NSNumber).floatValue
            
            let nx = (_vns[i*3] as! NSNumber).floatValue
            let ny = (_vns[i*3+1] as! NSNumber).floatValue
            let nz = (_vns[i*3+2] as! NSNumber).floatValue
            
            let tx = (_vts[i*2] as! NSNumber).floatValue
            let ty = (_vts[i*2+1] as! NSNumber).floatValue
            
            let v = MIVertex(position: simd_float4(x,y,z,1), normal: simd_float4(nx,ny,nz,1), texcoord: simd_float2(tx,ty))
            vs.append(v)
        }
        
        for i in 0..._face.count/3 - 1{
            let p1 = (_face[i*3] as! NSNumber).uint32Value
            let p2 = (_face[i*3 + 1] as! NSNumber).uint32Value
            let p3 = (_face[i*3 + 2] as! NSNumber).uint32Value
            let tri_ves:[UInt32] = [p1,p2,p3]
            face.append(contentsOf: tri_ves)
            tri_map[i] = tri_ves
        }
        
    }
    
    func loadDetalData() -> Void {
        operationQueue = OperationQueue.init()
        operationQueue?.maxConcurrentOperationCount = 1
        operationQueue?.qualityOfService = .userInteractive
        operationQueue?.addOperation({
            //点面集合
            for item in self.tri_map{
                for v in item.value{
                    if self.vecTri_Map[v] == nil{
                        self.vecTri_Map[v] = []
                    }
                    self.vecTri_Map[v]!.append(item.key)
                }
            }
            
            for item in self.vecTri_Map{
                var arr:[UInt32] = []
                for face in item.value{
                    let fs = self.tri_map[face]!
                    
                    for v in fs{
                        if arr.contains(v) == false{
                            arr.append(v)
                        }
                    }
                    
                }
                self.vecNeighbor[item.key] = arr
            }
            print("------------------------计算完成")
        })
    }
    
    
}
