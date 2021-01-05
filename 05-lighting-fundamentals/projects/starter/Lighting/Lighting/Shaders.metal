//
/**
 * Copyright (c) 2019 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#include <metal_stdlib>
using namespace metal;
#import "Common.h"

struct VertexIn {
  float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
};

struct VertexOut{
    float4 position[[position]];
    float3 worldPosition;
    float3 worldNormal;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                          constant Uniforms &uniforms [[buffer(1)]])
{
    VertexOut out{
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertexIn.position,
        .worldPosition = (uniforms.modelMatrix * vertexIn.position).xyz,
        .worldNormal = uniforms.normalMatrix * vertexIn.normal
        //.normal = vertexIn.normal
    };
    
    return out;
//  float4 position = uniforms.projectionMatrix * uniforms.viewMatrix
//  * uniforms.modelMatrix * vertexIn.position;
//  return position;
}

fragment float4 fragment_main(VertexOut in[[stage_in]],
    constant Light *lights[[buffer(2)]],
    constant FragmentUniforms &fragmentUniforms [[buffer(3)]]) {
        
    float3 baseColor = float3(0,0,1);
    float3 diffuseColor = 0;
    
    //2
    float3 normalDirection = normalize(in.worldNormal);
    for(uint i = 0 ; i < fragmentUniforms.lightCount; i++){
        Light light = lights[i];
        if(light.type == Sunlight){
            float3 lightDirection = normalize(-light.position);
            float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
            
            diffuseColor += light.color * baseColor * diffuseIntensity;
        }
    }
    
    float3 color = diffuseColor;
    return float4(color, 1);
    
    //the sky is green colored, the earth emits blue color
//    float4 sky = float4(0.0, 1.0, 0.0, 1.0);
//    float4 earth = float4(0.0, 0.0, 1.0, 1.0);
//
//    //take the y of the normal and figure out which color to use between earth and sky.
//    //if the normal points down ie, the bottom of the train, intensity is 0, so the mix
//    //function returns the earth color.  if y is pointing straight up, then we get the sky color
//    float intensity = in.normal.y * 0.5 + 0.5;
//    return mix(earth, sky, intensity);
    //return float4(in.normal, 1);
  //return float4(0, 0, 1, 1);
}

