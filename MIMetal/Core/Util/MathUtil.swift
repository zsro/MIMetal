//
//  MathUtil.swift
//  Mirage3D
//
//  Created by 影子 on 2018/8/9.
//  Copyright © 2018年 影子. All rights reserved.
//

import Foundation
import OpenGLES
import simd

struct Uniforms_default {
    var modelViewProjectionMatrix: matrix_float4x4
    var modelViewMatrix: matrix_float4x4
    var normalMatrix: matrix_float3x3
}

struct Uniforms {
    var modelViewProjectionMatrix: matrix_float4x4
    var modelViewMatrix: matrix_float4x4
    var normalMatrix: matrix_float3x3
    var selectPos: simd_float3
    var lightPos: simd_float4
    var eyelidUniform: EyelidUniforms
}

struct Uniforms_highlight {
    var modelViewProjectionMatrix: matrix_float4x4
    var modelViewMatrix: matrix_float4x4
    var normalMatrix: matrix_float3x3
    var color: simd_float4
}

struct EyelidUniforms {
    var eyelidRectLeft:simd_float4
    var isEyelid:simd_bool
    var eyelidAlphaLeft:simd_float1
    var eyelidAlphaRight:simd_float1
    var eyelidRectRight:simd_float4
}

func matrix_float4x4_transform(pos: simd_float3, rotate: simd_float3, scale: simd_float3) -> simd_float4x4 {
    return matrix_float4x4_translation(t: pos) * matrix_float4x4_rotation_X(angle: rotate.x) * matrix_float4x4_rotation_Y(angle: rotate.y) * matrix_float4x4_rotation_Z(angle: rotate.z) * matrix_float4x4_uniform_scale(scale: scale)
}

func matrix_float4x4_translation(t:simd_float3) -> matrix_float4x4
{
    let X:simd_float4 = [1, 0, 0, 0]
    let Y:simd_float4 = [0, 1, 0, 0]
    let Z:simd_float4 = [0, 0, 1, 0]
    let W:simd_float4 = [t.x, t.y, t.z, 1]

    let mat:matrix_float4x4 = matrix_float4x4.init([X,Y,Z,W])
    return mat;
}

func matrix_float4x4_uniform_scale(scale:float3) -> matrix_float4x4
{
    let X:simd_float4 = [scale.x, 0, 0, 0]
    let Y:simd_float4 = [0, scale.y, 0, 0]
    let Z:simd_float4 = [0, 0, scale.z, 0]
    let W:simd_float4 = [0, 0, 0, 1]
    
    let mat:matrix_float4x4 = matrix_float4x4.init([X,Y,Z,W])
    return mat;
}

func matrix_float4x4_rotation_Z(angle: Float) -> matrix_float4x4 {
    return matrix_float4x4_rotation(axis: simd_float3.init(0, 0, 1), angle: angle)
}

func matrix_float4x4_rotation(axis:simd_float3, angle:Float) ->matrix_float4x4
{
    let c = cos(angle);
    let s = sin(angle);
    
    var X:simd_float4 = simd_float4.init();
    X.x = axis.x * axis.x + (1 - axis.x * axis.x) * c;
    X.y = axis.x * axis.y * (1 - c) - axis.z * s;
    X.z = axis.x * axis.z * (1 - c) + axis.y * s;
    X.w = 0.0;
    
    var Y:simd_float4 = simd_float4.init();
    Y.x = axis.x * axis.y * (1 - c) + axis.z * s;
    Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * c;
    Y.z = axis.y * axis.z * (1 - c) - axis.x * s;
    Y.w = 0.0;
    
    var Z:simd_float4 = simd_float4.init();
    Z.x = axis.x * axis.z * (1 - c) - axis.y * s;
    Z.y = axis.y * axis.z * (1 - c) + axis.x * s;
    Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * c;
    Z.w = 0.0;
    
    var W:simd_float4 = simd_float4.init();
    W.x = 0.0;
    W.y = 0.0;
    W.z = 0.0;
    W.w = 1.0;
    
    let mat:matrix_float4x4 = matrix_float4x4.init([X,Y,Z,W])
    return mat;
}

func matrix_float4x4_rotation_X(angle: Float) ->matrix_float4x4{
    let c = cos(angle)
    let s = sin(angle)
    
    var X:simd_float4 = simd_float4.init();
    X.x = 1
    X.y = 0
    X.z = 0
    X.w = 0.0;
    
    var Y:simd_float4 = simd_float4.init();
    Y.x = 0.0
    Y.y = c
    Y.z = -s
    Y.w = 0.0;
    
    var Z:simd_float4 = simd_float4.init();
    Z.x = 0.0
    Z.y = s
    Z.z = c
    Z.w = 0.0;
    
    var W:simd_float4 = simd_float4.init();
    W.x = 0.0;
    W.y = 0.0;
    W.z = 0.0;
    W.w = 1.0;
    
    let mat:matrix_float4x4 = matrix_float4x4.init([X,Y,Z,W])
    return mat;
}

func matrix_float4x4_rotation_Y(angle: Float) ->matrix_float4x4{
    let c = cos(angle)
    let s = sin(angle)
    
    var X:simd_float4 = simd_float4.init();
    X.x = c
    X.y = 0.0
    X.z = s
    X.w = 0.0;
    
    var Y:simd_float4 = simd_float4.init();
    Y.x = 0.0
    Y.y = 1
    Y.z = 0
    Y.w = 0.0;
    
    var Z:simd_float4 = simd_float4.init();
    Z.x = -s
    Z.y = 0
    Z.z = c
    Z.w = 0.0;
    
    var W:simd_float4 = simd_float4.init();
    W.x = 0.0;
    W.y = 0.0;
    W.z = 0.0;
    W.w = 1.0;
    
    let mat:matrix_float4x4 = matrix_float4x4.init([X,Y,Z,W])
    return mat;
}

func matrix_float4x4_perspective(_ aspect:Float,_ fovy:Float,_ near:Float,_ far:Float) -> matrix_float4x4
{
    let yScale = 1 / tan(fovy * 0.5);
    let xScale = yScale / aspect;
    let zRange = far - near;
    let zScale = -(far + near) / zRange;
    let wzScale = -2 * far * near / zRange;
    
    let P:simd_float4 = [ xScale, 0, 0, 0 ]
    let Q:simd_float4 = [ 0, yScale, 0, 0 ]
    let R:simd_float4 = [ 0, 0, zScale, -1 ]
    let S:simd_float4 = [ 0, 0, wzScale, 0 ]
    
    let mat:matrix_float4x4 = matrix_float4x4.init([P,Q,R,S])
    return mat;
}


func matrix_float4x4_extract_linear(m:matrix_float4x4) ->matrix_float3x3
{
    let X:simd_float3 = m.columns.0.xyz;
    let Y:simd_float3 = m.columns.1.xyz;
    let Z:simd_float3 = m.columns.2.xyz;
    let l:matrix_float3x3 = matrix_float3x3.init([X,Y,Z])
    return l;
}

extension simd_float4{
    
    public var xyz: simd_float3{
        get{
            return simd_float3.init([x,y,z])
        }
    }
    
    public var xz:simd_float2{
        get{
            return[x,z]
        }
    }
    
    public var xy:simd_float2{
        get{
            return[x,y]
        }
    }
    
    public var yz:simd_float2{
        get{
            return[y,z]
        }
    }
}


// MARK: - float4
public extension float4 {
    init(_ v: float3, _ w: Float) {
        self.init(x: v.x, y: v.y, z: v.z, w: w)
    }
    
    // RGB color from HSV color (all parameters in range [0, 1])
    init(hue: Float, saturation: Float, brightness: Float) {
        let c = brightness * saturation
        let x = c * (1 - fabsf(fmodf(hue * 6, 2) - 1))
        let m = brightness - saturation
        
        var r: Float = 0
        var g: Float = 0
        var b: Float = 0
        switch hue {
        case _ where hue < 0.16667:
            r = c; g = x; b = 0
        case _ where hue < 0.33333:
            r = x; g = c; b = 0
        case _ where hue < 0.5:
            r = 0; g = c; b = x
        case _ where hue < 0.66667:
            r = 0; g = x; b = c
        case _ where hue < 0.83333:
            r = x; g = 0; b = c
        case _ where hue <= 1.0:
            r = c; g = 0; b = x
        default:
            break
        }
        
        r += m; g += m; b += m
        self.init(x: r, y: g, z: b, w: 1)
    }
    
}

public extension float3{
    
    var xy: float2{
        return float2.init(x, y)
    }
    
    var yx: float2{
        return float2.init(y, x)
    }
    
    var xz: float2{
        return float2.init(x, z)
    }
    
    var zx: float2{
        return float2.init(z, x)
    }
    
    var yz: float2{
        return float2.init(y, z)
    }

    var zy: float2{
        return float2.init(z, y)
    }
}

public extension float2{
    
    var length: Float{
        return sqrt(x * x + y * y)
    }
    
}


func angleByVector(v0: float2, v1: float2) -> Float{
    return acos(dot(v0, v1))
}



// MARK: - float4x4
public extension float4x4 {
    init(rotationAroundAxis axis: float3, by angle: Float) {
        let unitAxis = normalize(axis)
        let ct = cosf(angle)
        let st = sinf(angle)
        let ci = 1 - ct
        let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
        self.init(columns:(float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
                           float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
                           float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
                           float4(                  0,                   0,                   0, 1)))
    }
    
    init(translationBy v: float3) {
        self.init(columns:(float4(1, 0, 0, 0),
                           float4(0, 1, 0, 0),
                           float4(0, 0, 1, 0),
                           float4(v.x, v.y, v.z, 1)))
    }
    
    init(perspectiveProjectionRHFovY fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) {
        let ys = 1 / tanf(fovy * 0.5)
        let xs = ys / aspectRatio
        let zs = farZ / (nearZ - farZ)
        self.init(columns:(float4(xs,  0, 0,   0),
                           float4( 0, ys, 0,   0),
                           float4( 0,  0, zs, -1),
                           float4( 0,  0, zs * nearZ, 0)))
    }
}



/// 坐标矩阵映射
///
/// - Parameters:
///   - M: 坐标矩阵
///   - i: in
/// - Returns: out
func transform_point(M: simd_float4x4, i: simd_float4) -> simd_float4{
    return M * i
}


func gluProject(obj: float4, modelMatrix: simd_float4x4, projMatrix: simd_float4x4, viewport: simd_float4) -> float4?{
    
    var inValue = modelMatrix * obj
    inValue = projMatrix * inValue
    
    if inValue[3] == 0.0{
        return nil
    }
    
    //向量齐次化
    inValue[0] /= inValue[3]
    inValue[1] /= inValue[3]
    inValue[2] /= inValue[3]
    
    let out = float4.init(viewport[0] + (1 + inValue[0]) * viewport[2] / 2,
                          viewport[1] + (1 + inValue[1]) * viewport[3] / 2,
                          (1 + inValue[2]) / 2,
                          1)
    return out
}

func gluUnProject(obj: float4, modelMatrix: simd_float4x4, projMatrix: simd_float4x4, viewport: simd_float4) -> float4?{
    
    var inValue = obj
    inValue.x = (inValue.x - viewport.x) / viewport.z
    inValue.y = (inValue.y - viewport.y) / viewport.w
    
    inValue = inValue * 2 - 1
    
    var out = modelMatrix * projMatrix * inValue
    
    out.x /= out.w
    out.y /= out.w
    out.z /= out.w
    
    return out
}
