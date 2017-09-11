//
//  MHVideoCompositionManager.m
//  MHVideoExport
//
//  Created by FUZE on 2017/8/18.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import "MHVideoCompositionManager.h"
#import "MHVideoEffect.h"
#import "MHPictureEffect.h"
#import "MHPictureManager.h"


@interface MHVideoCompositionManager ()

@property GLuint offscreenBufferHandle;
@property (nonatomic, strong) MHVideoEffect *videoEffect;
@property (nonatomic, strong) MHPictureEffect *pictureEffect;
@property EAGLContext *context;
@end


@implementation MHVideoCompositionManager

+ (instancetype)shareManager
{
    static MHVideoCompositionManager * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MHVideoCompositionManager alloc]init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:self.context];
        [self setupOffscreenRenderContext];
        self.videoEffect = [[MHVideoEffect alloc]initWithEAGLContext:self.context];
        self.pictureEffect = [[MHPictureEffect alloc]init];
        [self.pictureEffect setContextSize:CGSizeMake(330, 586)];
    }
    return self;
}

- (void)setupOffscreenRenderContext
{
    glGenFramebuffers(1, &_offscreenBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenBufferHandle);
}

- (void)prepareToDraw:(CVPixelBufferRef)videoPixelBuffer andDestination:(CVPixelBufferRef)destinationPixelBuffer andCompositionTime:(CMTime)time
{
    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenBufferHandle);
    [EAGLContext setCurrentContext:self.context];
    [self.videoEffect renderPixelBuffer:videoPixelBuffer andDestination:destinationPixelBuffer andFrameBuffer:_offscreenBufferHandle];
    
    NSArray *array = [[MHPictureManager shareManager]requestPictureInfoWithTime:CMTimeGetSeconds(time)];
    if (array.count > 0) {
        for (MHPictureInfo *  _Nonnull obj in array) {
            [self.pictureEffect renderWithImage:obj.imageRef andPosition:obj.position andRadian:obj.radian andScale:obj.scale];
        }
    }
    
    glFinish();
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

@end
