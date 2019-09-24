//
//  MIObject.swift
//  Mirage3D
//
//  Created by 影子 on 2019/3/30.
//  Copyright © 2019 影子. All rights reserved.
//

import Foundation
import MetalKit

public class MIObject: MINode {

    init(mdlMesh: MDLMesh) {
        super.init()
        do{
            let m = try MTKMesh.init(mesh: mdlMesh, device: mtlDevice)
            self.mesh = MIMesh.init(mesh: m)
        }catch{
            print(error)
        }
        
        let material = MIObjectMaterial()
        let mtlVertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)!
        
        material.createPipeline(vertexDescriptor: mtlVertexDescriptor)
        material.depthCompareFunction = .always
        material.cullModel = .none
        self.material = material
    }
    
    
    
}
