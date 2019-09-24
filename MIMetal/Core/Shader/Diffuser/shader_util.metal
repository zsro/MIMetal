////
////  shader_util.metal
////  Mirage3D
////
////  Created by 影子 on 2019/7/26.
////  Copyright © 2019 影子. All rights reserved.
////
//
//#include <metal_stdlib>
//using namespace metal;
//
//struct Uniforms
//{
//    float4x4 modelViewProjectionMatrix;
//    float4 color;
//    float size;
//}
//
//struct ProjectedVertex
//{
//    float4 position [[position]];
//    float pointSize [[point_size]];
//    float4 color;
//};
//
//vertex ProjectedVertex point_vert(device Vertex *vertices [[buffer(0)]],
//                                   constant Uniforms &uniforms [[buffer(1)]],
//                                   uint vid [[vertex_id]])
//{
//    float4 position = vertices[vid].position;
//    float4 normal = vertices[vid].normal;
//    
//    ProjectedVertex outVert;
//    outVert.position = uniforms.modelViewProjectionMatrix * position;
//    return outVert;
//}
//
//fragment float4 point_frag(ProjectedVertex vert [[stage_in]])
//{
//    return vert.color;
//}
