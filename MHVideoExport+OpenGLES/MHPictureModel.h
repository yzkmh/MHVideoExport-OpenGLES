//
//  MHPictureModel.h
//  MHVideoExport
//
//  Created by FUZE on 2017/8/21.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MHPictureModel : NSObject
@property (nonatomic, strong, readonly) NSMutableArray *images;
@property (nonatomic, strong, readonly) NSMutableArray *delays;
@property (nonatomic, strong) NSMutableDictionary *gestures;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@property (nonatomic, assign) BOOL    editing;
@property CGFloat    radian;
@property CGFloat    scale;

- (instancetype)initWithUrl:(NSURL *)url andStartTime:(CGFloat )startTime;

- (instancetype)initWithDirection:(NSString *)direction andStartTime:(CGFloat)startTime;



- (void)addGesturePosition:(CGPoint)aPoint withCompositionTime:(CMTime)aTime;

@end
