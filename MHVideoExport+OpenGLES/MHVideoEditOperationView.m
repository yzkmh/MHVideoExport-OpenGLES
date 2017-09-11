//
//  MHVideoEditOperationView.m
//  MHVideoExport+OpenGLES
//
//  Created by FUZE on 2017/9/4.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import "MHVideoEditOperationView.h"
#import "MHVideoPlayerManager.h"

@implementation MHVideoEditOperationView


- (void)drawRect:(CGRect)rect
{
    
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
        }
            break;
        case 102:{
            //撤销
        }
            break;
        case 200:{
            //播放
            if ([[MHVideoPlayerManager shareManager] isPlaying]) {
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

@end
