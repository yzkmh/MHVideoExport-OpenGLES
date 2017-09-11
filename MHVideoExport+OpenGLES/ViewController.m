//
//  ViewController.m
//  MHVideoExport+OpenGLES
//
//  Created by FUZE on 2017/8/29.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import "ViewController.h"
#import "MHVideoPlayerManager.h"
#import "MHVideoView.h"

@interface ViewController ()
{

}
@property (nonatomic, strong) MHVideoView *videoView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [[NSBundle mainBundle]URLForResource:@"IMG_3481" withExtension:@"mp4"];
    _videoView = [[MHVideoView alloc]initWithFrame:self.view.bounds];
    _videoView.layer.masksToBounds = YES;
    [self.view addSubview:_videoView];
    [[MHVideoPlayerManager shareManager]loadVideoWithURL:url showOnView:_videoView];
    
    
    UIButton *addEffect = [UIButton buttonWithType:UIButtonTypeCustom];
    [addEffect setTitle:@"特效" forState:UIControlStateNormal];
    [addEffect addTarget:self action:@selector(addEffect:) forControlEvents:UIControlEventTouchUpInside];
    addEffect.frame = CGRectMake(0, 0, 80, 40);
    addEffect.center = _videoView.center;
    [_videoView addSubview:addEffect];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)addEffect:(UIButton *)sender
{
    [MHVideoPlayerManager shareManager].type = MHVideoPrepareToEdit;
    sender.hidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
