//
//  MHVideoEditView.m
//  MHVideoExport+OpenGLES
//
//  Created by FUZE on 2017/9/4.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import "MHVideoEditView.h"
#import <YYImage.h>
#import "MHAdjustFrameView.h"
#import "MHVideoPlayerManager.h"

@interface MHVideoEditView ()
@property IBOutlet YYAnimatedImageView *imageView1;
@property IBOutlet YYAnimatedImageView *imageView2;
@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, strong) NSTimer *avTimer;
@end

@implementation MHVideoEditView


- (void)awakeFromNib
{
    [super awakeFromNib];
    YYImage *image1 = [YYImage imageNamed:@"girl.gif"];
    [_imageView1 setImage:image1];
    
    YYImage *image2 = [YYImage imageNamed:@"fire.gif"];
    [_imageView2 setImage:image2];
    
    self.avTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
    [self.avTimer fire];
    
    [[MHVideoPlayerManager shareManager] addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:nil];
    
    [[MHVideoPlayerManager shareManager].player.currentItem addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionNew context:nil];
}

- (IBAction)buttonAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 10001:
        {
            //取消
            [MHVideoPlayerManager shareManager].type = MHVideoNormal;
        }
            break;
        case 10002:{
            //完成
            [MHVideoPlayerManager shareManager].type = MHVideoEidting;
        }
            break;
        default:
            break;
    }
}

- (IBAction)addImage:(id)sender
{
    NSURL *url = [[NSBundle mainBundle]URLForResource:@"girl" withExtension:@"gif"];
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedWithType:andUrl:)]) {
        [_delegate didSelectedWithType:MHVideoEditItemTypeImage andUrl:url];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object

                        change:(NSDictionary *)change context:(void *)context {
    if ([MHVideoPlayerManager shareManager].isPlaying) {
        [_avTimer setFireDate:[NSDate date]];
    }else{
        [_avTimer setFireDate:[NSDate distantFuture]];
    }
}

/**
 *  监听属性值发生改变时回调
 */
- (void)timer
{
    CGFloat number = CMTimeGetSeconds([MHVideoPlayerManager shareManager].player.currentItem.currentTime)/CMTimeGetSeconds([MHVideoPlayerManager shareManager].player.currentItem.duration);
    if (number>0 && number < 1) {
        self.slider.value = number;
    }
}

- (IBAction)didChangeValueFromSlider:(UISlider *)slider
{
    [[MHVideoPlayerManager shareManager] videoSeekToTime:slider.value];
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
