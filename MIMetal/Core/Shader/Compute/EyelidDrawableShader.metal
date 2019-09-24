//
//  EyelidDrawableShader.metal
//  Mirage3D
//
//  Created by 影子 on 2018/11/27.
//  Copyright © 2018 影子. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms_DrawEyelid
{
    float4 rectLeft;
    float4 rectRight;
    float2 size;
    float rotationLeft;
    float rotationRight;
};

float4 blendEyelid_draw(float4 color,float2 uv,float4 rect,float rotation,texture2d<float> texture,sampler samplr)
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

kernel void eyelid_draw(texture2d<float, access::read> inTexture [[texture(1)]],
                        texture2d<float, access::sample> eyelidTextureLeft [[texture(2)]],
                        texture2d<float, access::sample> eyelidTextureRight [[texture(3)]],
                        texture2d<float, access::write> outTexture [[texture(0)]],
                        constant Uniforms_DrawEyelid &uniforms [[buffer(0)]],
                        sampler samplr [[sampler(0)]],
                        uint2 gid [[thread_position_in_grid]])
{
    float2 uv = float2(gid.x / uniforms.size.x, gid.y / uniforms.size.y);
    
    float4 color = inTexture.read(gid);
    color = blendEyelid_draw(color, uv, uniforms.rectRight, uniforms.rotationRight, eyelidTextureRight,samplr);
    color = blendEyelid_draw(color, uv, uniforms.rectLeft, uniforms.rotationLeft, eyelidTextureLeft,samplr);

    outTexture.write(color, uint2(gid.x, gid.y));
}

