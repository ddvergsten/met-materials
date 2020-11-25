//
//  Shaders.metal
//  DgdChapter4
//
//  Created by David Dvergsten on 11/25/20.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float point_size [[point_size]];
};

vertex VertexOut vertex_main(constant float3 *vertices [[buffer(0)]], uint id[[vertex_id]])
{
    VertexOut vertex_out{   .position = float4(vertices[id], 1),
                            .point_size = 20.0
    };
    return vertex_out;
}

//fragment float4 fragment_main()//constant float4 &color [[buffer(0)]])
fragment float4 fragment_main(constant float4 &color [[buffer(0)]])
{
    //return float4(1.0, 0.0, 0.0, 1.0);//color;
    return color;
}
