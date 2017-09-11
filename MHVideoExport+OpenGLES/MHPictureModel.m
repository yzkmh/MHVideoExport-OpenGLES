//
//  MHPictureModel.m
//  MHVideoExport
//
//  Created by FUZE on 2017/8/21.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import "MHPictureModel.h"
#import <ImageIO/ImageIO.h>
#import <QuartzCore/CoreAnimation.h>

static const float defaultDelay = 1.0/24;


/*
 * @brief resolving gif information
 */
void getFrameInfo(CFURLRef url, NSMutableArray *frames, NSMutableArray *delayTimes, CGFloat *totalTime,CGFloat *gifWidth, CGFloat *gifHeight)
{
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL(url, NULL);
    
    // get frame count
    size_t frameCount = CGImageSourceGetCount(gifSource);
    for (size_t i = 0; i < frameCount; ++i) {
        // get each frame
        CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        [frames addObject:(__bridge id)frame];
        CGImageRelease(frame);
        
        // get gif info with each frame
        NSDictionary *dict = (__bridge_transfer  NSDictionary*)CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL);
//        NSLog(@"kCGImagePropertyGIFDictionary %@", [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary]);
        
        // get gif size
        if (gifWidth != NULL && gifHeight != NULL) {
            *gifWidth = [[dict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
            *gifHeight = [[dict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
        }
        
        // kCGImagePropertyGIFDictionary中kCGImagePropertyGIFDelayTime，kCGImagePropertyGIFUnclampedDelayTime值是一样的
        NSDictionary *gifDict = [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
        [delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
        
        if (totalTime) {
            *totalTime = *totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
        }
        
        //        CFRelease((__bridge CFDictionaryRef)(dict));
    }
    
    if (gifSource) {
        CFRelease(gifSource);
    }
}

@implementation MHPictureModel


- (instancetype)initWithUrl:(NSURL *)url andStartTime:(CGFloat)startTime
{
    self = [super init];
    if (self) {
        _startTime = startTime;
        _images = [[NSMutableArray alloc]init];
        _delays = [[NSMutableArray alloc]init];
        _gestures = [[NSMutableDictionary alloc]init];
        
        getFrameInfo((__bridge CFURLRef)url, _images, _delays, &_duration, &_width, &_height);
        if (_images.count <= 0) {
            NSLog(@"初始化失败");
            return NULL;
        }
        self.editing = YES;
    }
    return self;
}
- (instancetype)initWithDirection:(NSString *)direction andStartTime:(CGFloat)startTime
{
    self = [super init];
    if (self) {
        self.startTime = startTime;
        _images = [[NSMutableArray alloc]init];
        _delays = [[NSMutableArray alloc]init];
        _gestures = [[NSMutableDictionary alloc]init];
        NSArray *array = [[NSBundle mainBundle]pathsForResourcesOfType:@"png" inDirectory:direction];
        
        BOOL once = YES;
        
        for (int i = 0; i < array.count; i ++) {
            CGImageRef image = [[UIImage alloc]initWithContentsOfFile:array[i]].CGImage;
            
            [_images addObject:(__bridge id)image];
            [_delays addObject:[NSString stringWithFormat:@"%f",defaultDelay]];
            if (once) {
                self.width = CGImageGetWidth(image);
                self.height = CGImageGetHeight(image);
                once = NO;
            }
        }
        _duration = array.count * defaultDelay;
        
        self.editing = YES;
        
    }
    return self;
}




- (void)addGesturePosition:(CGPoint)aPoint withCompositionTime:(CMTime)aTime
{
    [_gestures setObject:NSStringFromCGPoint(aPoint) forKey:[NSString stringWithFormat:@"%f",CMTimeGetSeconds(aTime)]];
}

@end
