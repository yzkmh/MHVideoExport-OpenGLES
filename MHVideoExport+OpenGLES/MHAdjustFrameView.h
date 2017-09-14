//
//  MHCustomFrameView.h
//  LearnOpenGLTag
//
//  Created by FUZE on 2017/8/17.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YYImage/YYImage.h>

@interface MHAdjustFrameView : YYAnimatedImageView
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL isRecording;

- (void)setupWithURL:(NSURL *)url;

- (void)resetEdit;

- (void)finishEdit;

- (void)hiddenToolView;

- (void)displayToolView;

@end
