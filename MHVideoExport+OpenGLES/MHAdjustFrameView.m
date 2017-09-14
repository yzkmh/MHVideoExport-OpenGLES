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
@property (nonatomic, strong) UIRotationGestureRecognizer *rotationGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) NSURL *pictureUrl;
//@property (nonatomic, strong) IBOutlet YYAnimatedImageView *imageView;
//@property (nonatomic, strong) IBOutlet UIView *contentView;
//@property (nonatomic, strong) IBOutlet UIButton *adjustBtn;
//@property (nonatomic, strong) IBOutlet UIButton *mirrorBtn;
@end


@implementation MHAdjustFrameView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.userInteractionEnabled = YES;
//    self.contentView.userInteractionEnabled = YES;
    self.isEditing = YES;
    [self addGesture];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    oldFrame = frame;
}


- (void)addGesture
{
    _rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [self addGestureRecognizer:_rotationGesture];
    // 缩放手势
    _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self addGestureRecognizer:_pinchGesture];
    // 移动手势
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self addGestureRecognizer:_panGesture];
    
}

#pragma mark 处理旋转
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGesture
{
    UIView *view = rotationGesture.view;
    if (rotationGesture.state == UIGestureRecognizerStateBegan || rotationGesture.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, rotationGesture.rotation);
        [rotationGesture setRotation:0];
        //log下查看view.transform是怎么处理原理
    }else if(rotationGesture.state == UIGestureRecognizerStateEnded){
        
    }
}

- (void) pinchView:(UIPinchGestureRecognizer *)pinchGesture
{
    UIView *view = pinchGesture.view;
    
    if (pinchGesture.state == UIGestureRecognizerStateBegan || pinchGesture.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGesture.scale, pinchGesture.scale);
        if (self.frame.size.width <= oldFrame.size.width ) {
            [UIView beginAnimations:nil context:nil]; // 开始动画
            [UIView setAnimationDuration:0.5f]; // 动画时长
            /**
             *  固定一倍
             */
            view.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
            [UIView commitAnimations]; // 提交动画
        }
        if (self.frame.size.width > 3 * oldFrame.size.width) {
            [UIView beginAnimations:nil context:nil]; // 开始动画
            [UIView setAnimationDuration:0.5f]; // 动画时长
            /**
             *  固定三倍
             */
            view.transform = CGAffineTransformMake(3, 0, 0, 3, 0, 0);
            [UIView commitAnimations]; // 提交动画
        }
        pinchGesture.scale = 1;
    }else if (pinchGesture.state == UIGestureRecognizerStateEnded){
        //        [MHPictureManager shareManager].scale = (self.frame.size.width/oldFrame.size.width);
    }
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
        [self startAnimating];
        //开始拖动  视频继续播放，并记录图片时间点
        [[MHVideoPlayerManager shareManager] play];
        CGAffineTransform _trans = self.transform;
        CGFloat scale = sqrt(_trans.a*_trans.a + _trans.c*_trans.c);
        
        CGFloat rotate = atanf(_trans.b/_trans.a); //acosf(_trans.a);
        if (_trans.a < 0 && _trans.b > 0) {
            rotate += M_PI;
        }else if(_trans.a <0 && _trans.b < 0){
            rotate -= M_PI;
        }
        
        [[MHPictureManager shareManager]addPictureWithUrl:self.pictureUrl andTime:CMTimeGetSeconds([MHVideoPlayerManager shareManager].player.currentItem.currentTime) andRadian:rotate andScale:scale];
    }else if (panGesture.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [panGesture translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGesture setTranslation:CGPointZero inView:view.superview];
        //拖动中 记录手势轨迹
        [[MHPictureManager shareManager] updatePicturePosition:view.center withCompositionTime:[MHVideoPlayerManager shareManager].player.currentItem.currentTime];
    }else{
        [self stopAnimating];
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
//    self.contentView.hidden = NO;
}

- (void)finishEdit
{
    self.isEditing = NO;
//    self.contentView.hidden = YES;
}

- (void)setupWithURL:(NSURL*)url
{
    
    UIImage *image = [YYImage imageWithData:[NSData dataWithContentsOfURL:url]];
    CGFloat radio = image.size.width/image.size.height;
    CGSize size = CGSizeMake(150 + 20, 150/radio + 20);
    self.frame = CGRectMake(0, 0, size.width, size.height);
    [self setImage:image];
    self.pictureUrl = url;
}

//- (void)hiddenToolView
//{
//    self.contentView.hidden = YES;
//}
//
//- (void)displayToolView
//{
//    self.contentView.hidden = YES;
//}

- (void)finishWithScale:(CGFloat *)scale andRadian:(CGFloat *)radian
{
    *scale = 1;
    *radian = 0;
    [self removeFromSuperview];
}

@end
