//
//  MHPictureManager.h
//  MHVideoExport
//
//  Created by FUZE on 2017/8/21.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MHPictureInfo : NSObject

@property CGImageRef imageRef;
@property CGPoint    position;
@property CGFloat    radian;
@property CGFloat    scale;

@end

@interface MHPictureManager : NSObject

+ (instancetype)shareManager;

- (void)addPictureWithUrl:(NSURL *)url andTime:(CGFloat)time andRadian:(CGFloat)radian andScale:(CGFloat)scale;
- (void)addPictureInDrectory:(NSString *)dractory andTime:(CGFloat)time andRadian:(CGFloat)radian andScale:(CGFloat)scale;

- (void)updatePicturePosition:(CGPoint)aPoint withCompositionTime:(CMTime)aTime;

- (void)lastPictureEditFinishWithTime:(CMTime)aTime;

- (NSArray *)requestPictureInfoWithTime:(CGFloat)time;

- (CGImageRef)firstImage;


@end
