//
//  MHCustomFrameView.m
//  LearnOpenGLTag
//
//  Created by FUZE on 2017/8/17.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import "MHAdjustFrameView.h"
#import "MHPictureManager.h"
#import "MHVideoPlayerManager.h"

@interface MHAdjustFrameView ()
{
    CGRect oldFrame;
}
@property (nonatomic, strong) UIPanGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) NSURL *pictureUrl;
@property (nonatomic, strong) IBOutlet YYAnimatedImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UIButton *adjustBtn;
@property (nonatomic, strong) IBOutlet UIButton *mirrorBtn;
@end


@implementation MHAdjustFrameView


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
    self.isEditing = YES;
    [self addGesture];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    oldFrame = frame;
}

- (void)setImage:(UIImage *)image
{
    [self.imageView setImage:image];
}

- (void)addGesture
{
    // 缩放和旋转手势
    _pinchGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.adjustBtn addGestureRecognizer:_pinchGesture];
    
    // 移动手势
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self addGestureRecognizer:_panGesture];
    
}

#pragma mark 处理旋转
- (void)pinchView:(UIPanGestureRecognizer *)panGesture
{
    
}
#pragma mark 处理拖拉
-(void)panView:(UIPanGestureRecognizer *)panGesture
{
    
    UIView *view = panGesture.view;
    
    if (self.isEditing) {
        CGPoint translation = [panGesture translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGesture setTranslation:CGPointZero inView:view.superview];
        return;
    }
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self.imageView startAnimating];
        //开始拖动  视频继续播放，并记录图片时间点
        [[MHVideoPlayerManager shareManager] play];
        
        CGAffineTransform _trans = self.transform;
        CGFloat rotate = acosf(_trans.a);
        
        [[MHPictureManager shareManager]addPictureWithUrl:self.pictureUrl andTime:CMTimeGetSeconds([MHVideoPlayerManager shareManager].player.currentItem.currentTime) andRadian:rotate andScale:self.frame.size.width/oldFrame.size.width];
        
    }else if (panGesture.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [panGesture translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGesture setTranslation:CGPointZero inView:view.superview];
        //拖动中 记录手势轨迹
        [[MHPictureManager shareManager] updatePicturePosition:view.center withCompositionTime:[MHVideoPlayerManager shareManager].player.currentItem.currentTime];
    }else{
        [self.imageView stopAnimating];
        //拖动结束
        [[MHVideoPlayerManager shareManager] pause];
        [[MHPictureManager shareManager]lastPictureEditFinishWithTime:[MHVideoPlayerManager shareManager].player.currentItem.currentTime];
    }
}

- (IBAction)buttonAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 101:
        {
            //镜像
        }
            
            break;
        case 102:
        {
            //取消
            [self removeFromSuperview];
        }
            break;
        default:
            break;
    }
}

- (void)resetEdit
{
    self.isEditing = YES;
    self.contentView.hidden = NO;
}

- (void)finishEdit
{
    self.isEditing = NO;
    self.contentView.hidden = YES;
}

- (void)setupWithURL:(NSURL*)url
{
    
    UIImage *image = [YYImage imageWithData:[NSData dataWithContentsOfURL:url]];
    CGFloat radio = image.size.width/image.size.height;
    CGSize size = CGSizeMake(150 + 20, 150/radio + 20);
    self.frame = CGRectMake(0, 0, size.width, size.height);
    [self.imageView setImage:image];
    self.pictureUrl = url;
}

- (void)hiddenToolView
{
    self.contentView.hidden = YES;
}

- (void)displayToolView
{
    self.contentView.hidden = YES;
}

- (void)finishWithScale:(CGFloat *)scale andRadian:(CGFloat *)radian
{
    *scale = 1;
    *radian = 0;
    [self removeFromSuperview];
}

@end
