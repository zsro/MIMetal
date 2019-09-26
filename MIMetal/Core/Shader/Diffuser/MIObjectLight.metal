//
//  MIObjectLight.metal
//  Mirage3D
//
//  Created by 影子 on 2019/4/2.
//  Copyright © 2019 影子. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct Uniforms {
    float4x4 modelViewProjectionMatrix;
    float3x3 normalMatrix;
    float4 state;   //(灯光，描边，待定，待定)
};

struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal   [[attribute(1)]];
    float2 texCoords [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float2 texCoords;
    float o;
};

vertex VertexOut vertex_light(VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]])
{
    VertexOut out;
    
    const float extrusionMagnitude = 0.05;
    float3 modelPosition = in.position + normalize(in.normal) * extrusionMagnitude;
    
    float4 position(modelPosition, 1);
    float4 normal(in.normal, 0);
    
    out.position = uniforms.modelViewProjectionMatrix * position;
    out.normal = (uniforms.normalMatrix * normal.xyz).xyz;
    out.texCoords = in.texCoords;
    
    return out;
}

fragment float4 fragment_light(VertexOut i [[stage_in]],
                              texture2d<float> diffuseTexture [[texture(0)]],
                              sampler samplr [[sampler(0)]])
{
    float4 color = diffuseTexture.sample(samplr, i.texCoords);
    return color;
}
