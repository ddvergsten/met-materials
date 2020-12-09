//
//  Shaders.metal
//  DgdChapter4
//
//  Created by David Dvergsten on 11/25/20.
//
#import "Common.h"
#include <metal_stdlib>
using namespace metal;

//struct VertexOut{
//    float4 position2 [[position]];
//    float point_size [[point_size]];
//
//};


struct VertexIn {
  float4 position [[attribute(0)]];
};


vertex float4 vertex_main(const VertexIn vertexIn[[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]])
{
    float4 position = uniforms.modelMatrix * vertexIn.position;
    return position;
}

//fragment float4 fragment_main()//constant float4 &color [[buffer(0)]])
fragment float4 fragment_main(constant float4 &color [[buffer(0)]])
{
    //return float4(1.0, 0.0, 0.0, 1.0);//color;
    return color;
}
