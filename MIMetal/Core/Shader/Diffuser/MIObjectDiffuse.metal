//
//  MIObjectDiffuse.metal
//  Mirage3D
//
//  Created by 影子 on 2019/3/30.
//  Copyright © 2019 影子. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct Uniforms
{
    float4 grayColor;
    float4 lightPos;
    float4x4 modelViewProjectionMatrix;
    float4x4 modelViewMatrix;
    float3x3 normalMatrix;
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
    float3 eyePosition;
    float3 normal;
    float2 texCoords;
};

vertex ProjectedVertex objectDiffuse_vertex(device Vertex *vertices [[buffer(0)]],
                                      constant Uniforms &uniforms [[buffer(1)]],
                                      uint vid [[vertex_id]])
{
    float4 position = vertices[vid].position;
    float4 normal = vertices[vid].normal;
    
    ProjectedVertex outVert;
    outVert.position = uniforms.modelViewProjectionMatrix * position;
    outVert.eyePosition = -(uniforms.modelViewMatrix * position).xyz;
    outVert.normal = uniforms.normalMatrix * normal.xyz;
    outVert.texCoords = vertices[vid].texCoords;
    return outVert;
}

fragment float4 objectDiffuse_fragment(ProjectedVertex vert [[stage_in]],
                                 constant Uniforms &uniforms [[buffer(0)]],
                                 texture2d<float> diffuseTexture [[texture(0)]],
                                 sampler samplr [[sampler(0)]])
{
    float3 color = diffuseTexture.sample(samplr, vert.texCoords).rgb;
    
    if (uniforms.grayColor.w == 1){
        color = uniforms.grayColor.xyz;
    }
    
    if (uniforms.lightPos.w == 1){
        color *= dot(normalize(uniforms.lightPos.xyz), normalize(vert.normal.xyz));
    }
    
    return float4(color,1);
}

