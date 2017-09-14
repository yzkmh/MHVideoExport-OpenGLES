//
//  MHVideoEditOperationView.m
//  MHVideoExport+OpenGLES
//
//  Created by FUZE on 2017/9/4.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import "MHVideoEditOperationView.h"
#import "MHVideoPlayerManager.h"


@interface MHVideoEditOperationView ()
@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, strong) NSTimer *avTimer;
@end

@implementation MHVideoEditOperationView


- (void)drawRect:(CGRect)rect
{
    self.avTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
    [self.avTimer fire];
}


- (IBAction)buttonAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:
            //返回
            [MHVideoPlayerManager shareManager].type = MHVideoPrepareToEdit;
            break;
        case 101:{
            //完成??
            [[MHVideoPlayerManager shareManager] exportToAlbum];
        }
            break;
        case 102:{
            //撤销
        }
            break;
        case 200:{
            //播放
            if (![[MHVideoPlayerManager shareManager] isPlaying]) {
                [sender setTitle:@"暂停" forState:UIControlStateNormal];
                [[MHVideoPlayerManager shareManager] play];
            }else{
                [sender setTitle:@"播放" forState:UIControlStateNormal];
                [[MHVideoPlayerManager shareManager] pause];
            }
        }
            break;
        default:
            break;
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



@end
