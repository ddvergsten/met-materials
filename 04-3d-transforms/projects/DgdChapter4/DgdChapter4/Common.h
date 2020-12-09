//
//  Common.h
//  DgdChapter4
//
//  Created by David Dvergsten on 12/9/20.
//

#ifndef Common_h
#define Common_h
#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
}Uniforms;

#endif /* Common_h */
