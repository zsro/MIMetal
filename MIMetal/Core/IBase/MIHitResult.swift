//
//  MIHit.swift
//  Mirage3D
//
//  Created by 影子 on 2019/3/25.
//  Copyright © 2019 影子. All rights reserved.
//

import Foundation
import simd

public struct MIHitResult {
    
    public var ray: MIRay
    public var node: MINode
    public var faceIndex: Int
    public var vertexIndex: Int
    public var textureCoordinates: simd_float2
    public var localCoordinates: MIVertex
    public var worldCoordinates: MIVertex
    
    public var parameter: Float
    
    var intersectionPoint: float4 {
        return float4(ray.origin + parameter * ray.direction, 1)
    }
    
    static func < (_ lhs: MIHitResult, _ rhs: MIHitResult) -> Bool {
        return lhs.parameter < rhs.parameter
    }
    
}

public struct MIRay {
    public var origin: simd_float3
    public var direction: simd_float3
    
    static func *(transform: simd_float4x4, ray: MIRay) -> MIRay{
        let originT = (transform * simd_float4(ray.origin, 1)).xyz
        let directionT = (transform * simd_float4(ray.direction, 0)).xyz
        return MIRay(origin: originT, direction: directionT)
    }
    
    func interpolate(_ point: simd_float4) -> Float{
        return length(point.xyz - origin) / length(direction)
    }
    
    func distence(_ point: simd_float3) -> Float {
        let v0 = point - origin
        let angle = acos(dot(v0, direction)/(length(v0) * length(direction)))
        return sin(angle) * length(v0)
    }
    
    func intersectionAngle(_ normal: float3) -> Float {
        return acos(dot(normal, direction)/(length(normal) * length(direction)))
    }
    
    /// 碰撞：球
    ///
    /// - Parameters:
    ///   - center: 目标点坐标
    ///   - radius: 半径
    /// - Returns: 相交
    func intersect(center: simd_float3, radius: Float = 5) -> simd_float4? {
        var t0, t1: Float
        let radius2 = radius * radius
        if (radius2 == 0) { return nil }
        let L = center - origin
        let tca = simd_dot(L, direction)
        
        let d2 = simd_dot(L, L) - tca * tca
        if (d2 > radius2) { return nil }
        let thc = sqrt(radius2 - d2)
        t0 = tca - thc
        t1 = tca + thc
        
        if (t0 > t1) { swap(&t0, &t1) }
        
        if t0 < 0 {
            t0 = t1
            if t0 < 0 { return nil }
        }
        
        return float4(origin + direction * t0, 1)
    }
    
    
    /// 碰撞： 三角面
    ///
    /// - Parameters:
    ///   - v0: v0
    ///   - v1: v1
    ///   - v2: v2
    /// - Returns: 是否在面内部
    func IntersectTriangle(v0: simd_float3, v1: simd_float3, v2: simd_float3) -> Bool{
        let orig = origin
        let dir = direction
        
        let E1 = v1 - v0
        let E2 = v2 - v0
        let p = cross(dir, E2)
        
        var det = dot(E1, p)
        
        var t: simd_float3
        if det > 0{
            t = orig - v0
        }else{
            t = v0 - orig
            det = -det
        }
        
        if det < 0.0001{
            return false
        }
        
        let u = dot(t, p)
        if u < 0.0 || u > det{
            return false
        }
        
        let Q = cross(t, E1)
        
        let v = dot(dir, Q)
        
        if v < 0.0 || u + v > det{
            return false
        }
        
        return true
    }
    
}


