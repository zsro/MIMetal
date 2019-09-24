//
//  model_highlight.metal
//  Mirage3D
//
//  Created by 影子 on 2019/7/17.
//  Copyright © 2019 影子. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct Uniforms
{
    float4x4 modelViewProjectionMatrix;
    float4x4 modelViewMatrix;
    float3x3 normalMatrix;
    float4 color;
};

struct Vertex
{
    packed_float4 position;
    packed_float4 normal;
    packed_float2 texCoords;
};

struct ProjectedVertex
{
    float4 position [[position]];
    float4 position_real;
    float3 eyePosition;
    float3 normal;
    float2 texCoords;
    float4 color;
};

vertex ProjectedVertex highlight_vert(device Vertex *vertices [[buffer(0)]],
                                      constant Uniforms &uniforms [[buffer(1)]],
                                      uint vid [[vertex_id]])
{
    float4 position = vertices[vid].position;
    float4 normal = vertices[vid].normal;
    
    ProjectedVertex outVert;
    outVert.position = uniforms.modelViewProjectionMatrix * position;
    outVert.position_real = position;
    outVert.eyePosition = -(uniforms.modelViewMatrix * position).xyz;
    outVert.normal = uniforms.normalMatrix * normal.xyz;
    outVert.texCoords = vertices[vid].texCoords;
    float4 color = uniforms.color;
    outVert.color = float4(color.x,color.y,color.z, normal.w * color.w);
    return outVert;
}


fragment float4 highlight_frag(ProjectedVertex vert [[stage_in]])
{
    return vert.color;//rgba
}



