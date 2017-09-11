//
//  MHParticleManager.m
//  MHVideoExport+OpenGLES
//
//  Created by FUZE on 2017/9/1.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import "MHParticleManager.h"

@implementation MHParticleManager

+ (instancetype)shareManager
{
    static MHParticleManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MHParticleManager alloc]init];
    });
    return _instance;
}



@end
