//
//  MICamera.swift
//  Mirage3D
//
//  Created by 加冰 on 2018/12/13.
//  Copyright © 2018 影子. All rights reserved.
//

import Foundation
import simd

public class MICamera: MINode {
    
    private var _aspect:Float = 417/579
    private var _fieldOfView: Float = 62.0
    private var _near:Float = 1
    private var _far:Float = 10000
    
    public var aspect: Float{ get{ return _aspect} set{ _aspect = newValue}}
    public var fieldOfView: Float{ get{ return _fieldOfView} set{ _fieldOfView = newValue}}
    public var near: Float{ get{ return _near} set{ _near = newValue}}
    public var far: Float{ get{ return _far} set{ _far = newValue}}
    
    public var projectionMatrix: matrix_float4x4{
        get{
            return float4x4(perspectiveProjectionRHFovY: radians_from_degrees(fieldOfView),
                            aspectRatio: aspect,
                            nearZ: near,
                            farZ: far)
        }
    }
    
    
    public func reset() -> Void {
        position = [0,-45,400]
        fieldOfView = 62
        near = 1
        far = 10000
    }
    
    public override init() {
        super.init()
        
        self.position = [0,-45,400]
    }
    
    func getUniform(transform: simd_float4x4) -> Uniforms_default {
        let viewMatrix:matrix_float4x4 = matrix_float4x4_translation(t: position).inverse
        
        let projectionMatrix:matrix_float4x4 = self.projectionMatrix
        let modelViewMatrix = matrix_multiply(viewMatrix, transform)
        let modelViewProjectionMatrix = matrix_multiply(projectionMatrix, modelViewMatrix)
        let normalMatrix = matrix_float4x4_extract_linear(m: modelViewMatrix)
        
        let uniform = Uniforms_default.init(modelViewProjectionMatrix: modelViewProjectionMatrix,
                                            modelViewMatrix: modelViewMatrix,
                                            normalMatrix: normalMatrix)
        return uniform
    }
    
}

func radians_from_degrees(_ degrees: Float) -> Float {
    return (degrees / 180) * .pi
}
