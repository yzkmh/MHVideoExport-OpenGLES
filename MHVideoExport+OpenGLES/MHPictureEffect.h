//
//  MHPictureEffect.h
//  MHVideoExport+OpenGLES
//
//  Created by FUZE on 2017/8/29.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLSLProgram.h"

@interface MHPictureEffect : NSObject
{
    GLSLProgram *pictureShader;
    GLuint  inPositionAttrib,
    inTexCoordAttrib,
    textureUniform,
    MPMtxUniform;
    GLuint vertexsId;
}
- (void)setContextSize:(CGSize)size;

- (void)renderWithImage:(CGImageRef)image andPosition:(CGPoint)aPoint;

- (void)renderWithImage:(CGImageRef)image andPosition:(CGPoint)aPoint andRadian:(CGFloat)radian andScale:(CGFloat)scale;

@end
