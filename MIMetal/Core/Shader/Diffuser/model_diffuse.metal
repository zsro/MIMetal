//
//  DiffuseShader.metal
//  Mirage3D
//
//  Created by 影子.zsr on 2018/8/7.
//  Copyright © 2018年 影子. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Light
{
    float3 direction;
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
};

//constant Light light = {
//    .direction = { 0.13, 0.72, 0.68 },
//    .ambientColor = { 0.05, 0.05, 0.05 },
//    .diffuseColor = { 1, 1, 1 },
//    .specularColor = { 0.2, 0.2, 0.2 }
//};

//constant float3 kSpecularColor= { 1, 1, 1 };
//constant float kSpecularPower = 80;

struct EyelidUniform {
    float4 rectLeft;
    bool isEyelid;
    float rotate_left;
    float rotate_right;
    float4 rectRight;
};

struct Uniforms
{
    float4x4 modelViewProjectionMatrix;
    float4x4 modelViewMatrix;
    float3x3 normalMatrix;
    float3 selectPos;
    float4 lightPos;
    EyelidUniform eyelid;
};



struct EyelidRect{
    float4 left;
    float4 right;
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
};

vertex ProjectedVertex vertex_func(device Vertex *vertices [[buffer(0)]],
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
    return outVert;
}

float4 blendEyelid(float4 color,float2 uv,float4 rect,float rotation,texture2d<float> texture,sampler samplr)
{
    //计算矩阵中心
    float2 center = float2(rect.x + rect.z/2,rect.y + rect.w/2);

    //当前uv坐标
    float part_x = (uv.x - rect.x) / rect.z;
    float part_y = (uv.y - rect.y) / rect.w;
    float2 part_uv = float2(part_x,part_y);
    //相对坐标
    part_uv = part_uv - center;
    //计算旋转
    float cosValue = cos(rotation);
    float sinValue = sin(rotation);
    part_uv = float2(part_uv.x * cosValue + part_uv.y * sinValue, -part_uv.x * sinValue + part_uv.y * cosValue);
    //将旋转后的坐标映射回来
    part_uv = part_uv + center;
    
    float4 part_color = texture.sample(samplr, part_uv);
    color.xyz = part_color.xyz * part_color.w + color.xyz * (1 - part_color.w);
    return color;
}

fragment float4 fragment_func(ProjectedVertex vert [[stage_in]],
                                 constant Uniforms &uniforms [[buffer(0)]],
                                 texture2d<float> diffuseTexture [[texture(0)]],
                                 texture2d<float> eyelidTexture [[texture(1)]],
                                 texture2d<float> eyelidTexture2 [[texture(2)]],
                                 texture2d<float> selectTexture [[texture(3)]],
                                 sampler samplr [[sampler(0)]],
                                 sampler samplr2 [[sampler(1)]])
{
    float4 oriColor = diffuseTexture.sample(samplr, vert.texCoords);
    float4 color = oriColor;

    if(uniforms.eyelid.isEyelid){
        color = blendEyelid(color,vert.texCoords, uniforms.eyelid.rectRight, uniforms.eyelid.rotate_right, eyelidTexture,samplr);
        color = blendEyelid(color,vert.texCoords, uniforms.eyelid.rectLeft, uniforms.eyelid.rotate_left, eyelidTexture2,samplr);
    }
    
    float radius = uniforms.selectPos.z;
    float2 selectCenter = uniforms.selectPos.xy;
    float2 selectUV = (vert.texCoords - selectCenter + float2(radius, radius * 2))/float2(radius * 2, radius * 4);
    float4 selectColor = selectTexture.sample(samplr, selectUV);
    color.xyz = selectColor.xyz * selectColor.w + color.xyz * (1 - selectColor.w);
    
    if (uniforms.lightPos.w == 1){
        color = float4(float3(1, 1, 1) * dot(normalize(uniforms.lightPos.xyz), normalize(vert.normal.xyz)), 1);
    }
    
//    float2 netUV = vert.texCoords * 10;
//    netUV.x = vert.position_real.x/40;
//    float4 netColor = selectTexture.sample(samplr2, netUV);
//    return netColor;
    
//    if (color.w == 0){
//        discard_fragment();
//    }
    
    return color;//rgba
}



