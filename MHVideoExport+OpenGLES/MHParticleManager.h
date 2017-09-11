//
//  MHParticleManager.h
//  MHVideoExport+OpenGLES
//
//  Created by FUZE on 2017/9/1.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface MHParticleInfo : NSObject

@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGPoint position;
@property (nonatomic, strong) NSURL *particleUrl;


@end

typedef struct {
    GLKVector2 position;
    GLKVector2 direction;
    GLKVector2 startPos;
    GLKVector4 color;
    GLKVector4 deltaColor;
    GLfloat rotation;
    GLfloat rotationDelta;
    GLfloat radialAcceleration;
    GLfloat tangentialAcceleration;
    GLfloat radius;
    GLfloat radiusDelta;
    GLfloat angle;
    GLfloat degreesPerSecond;
    GLfloat particleSize;
    GLfloat particleSizeDelta;
    GLfloat timeToLive;
    GLfloat startTime;
} Particle;


@interface MHParticleManager : NSObject
{
    Particle *particles;
}

+ (instancetype)shareManager;

@end
