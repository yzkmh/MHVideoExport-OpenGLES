//
//  MHVideoPlayerManager.m
//  MHVideoExport
//
//  Created by FUZE on 2017/8/18.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import "MHVideoPlayerManager.h"
#import "MHVideoCompositor.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MHVideoEditView.h"
#import "MHVideoEditOperationView.h"
#import "MHAdjustFrameView.h"
#import <YYImage.h>

#define kVideoRadio 540.f/960.f
#define kVideoEidtToolHeight 200.f
#define kVideoEidtViewHeight 150.f
@interface MHVideoPlayerManager ()<MHVideoEditViewDelegate>
{
    id _notificationToken;
    BOOL isSeeking;
    MHVideoEditOperationView *editOpView;
    MHVideoEditView *editView;
}

@property (strong, nonatomic) AVMutableVideoComposition *videoComposition;
@property (strong, nonatomic) AVAssetImageGenerator     *imageGenerator;
@property (strong, nonatomic, nonnull) UIView *contentView;
@property (strong, nonatomic, nonnull) UIView *showView;
@property (strong, nonatomic, nonnull) UIView *showViewSuperView;
@property (strong ,nonatomic, nonnull) MHAdjustFrameView *frameView;
@end


@implementation MHVideoPlayerManager

+ (nullable instancetype)shareManager
{
    static MHVideoPlayerManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MHVideoPlayerManager alloc]init];
    });
    return instance;
}
- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.player = [[AVPlayer alloc]init];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}


- (void)loadVideoWithURL:(nullable NSURL *)url showOnView:(nullable UIView *)showView
{
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }
    self.playerLayer = (AVPlayerLayer *)showView.layer;
    [self.playerLayer setPlayer:self.player];
    self.showView = showView;
    self.showViewSuperView = showView.superview;
    
    _asset = [[AVURLAsset alloc]initWithURL:url options:nil];
    _videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:_asset];
    _videoComposition.frameDuration = CMTimeMake(1, 30);
    _videoComposition.renderSize = [_asset naturalSize];
    _videoComposition.customVideoCompositorClass = [MHVideoCompositor class];
    self.playerItem = [AVPlayerItem playerItemWithAsset:_asset];
    self.playerItem.videoComposition = _videoComposition;
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self addDidPlayToEndTimeNotificationForPlayerItem:self.playerItem];
    [self play];
    
    [self setupEditOperation];
}

- (void)setupEditOperation
{
    editOpView = [[[NSBundle mainBundle]loadNibNamed:@"MHVideoEditOperationView" owner:nil options:nil]firstObject];
    [editOpView setFrame:self.showViewSuperView.bounds];
    [self.showViewSuperView insertSubview:editOpView atIndex:0];
    editOpView.hidden = YES;
    
    editView = [[[NSBundle mainBundle]loadNibNamed:@"MHVideoEditView" owner:nil options:nil]firstObject];
    editView.delegate = self;
    [editView setFrame:self.showViewSuperView.bounds];
    [self.showViewSuperView insertSubview:editView atIndex:0];
    editView.hidden = YES;
}

- (void)setType:(MHVideoEditType)type
{
    _type = type;
    switch (type) {
        case MHVideoNormal:
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.showView setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            } completion:^(BOOL finished) {
                editOpView.hidden = YES;
                editView.hidden = YES;
            }];
        }
            break;
        case MHVideoPrepareToEdit:
        {
            
            if (_frameView) {
                [_frameView removeFromSuperview];
                _frameView = nil;
            }
//            [_frameView resetEdit];
            [self videoSeekToTime:0.0f];
            
            CGFloat height = kScreenHeight - kVideoEidtToolHeight;
            CGFloat width = height * kVideoRadio;
            [UIView animateWithDuration:0.3 animations:^{
                [self.showView setFrame:CGRectMake((kScreenWidth - width)/2, 64,width,height)];
            } completion:^(BOOL finished) {
                editOpView.hidden = YES;
                editView.hidden = NO    ;
            }];
        }
            break;
        case MHVideoEidting:
        {
            [_frameView finishEdit];
            
            CGFloat height = kScreenHeight - kVideoEidtViewHeight;
            CGFloat width = height * kVideoRadio;
            [UIView animateWithDuration:0.3 animations:^{
                [self.showView setFrame:CGRectMake((kScreenWidth - width)/2, 64,width,height)];
            } completion:^(BOOL finished) {
                editOpView.hidden = NO;
                editView.hidden = YES;
            }];
        }
            break;
        default:
            break;
    }
}




- (void)exportToAlbum
{
    [self.player pause];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:_asset presetName:AVAssetExportPresetHighestQuality];
    
    NSString *savePath = [NSTemporaryDirectory() stringByAppendingString:@"video.mp4"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
    }
    exportSession.outputURL = [NSURL fileURLWithPath:savePath];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.videoComposition = _videoComposition;
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
            [self saveVideo:[NSURL fileURLWithPath:savePath]];
        }else{
            NSLog(@"当前进度:%f",exportSession.progress);
        }
        NSLog(@"%@",exportSession.error.description);
    }];
}
- (void)saveVideo:(NSURL *)outputFileURL
{
    //ALAssetsLibrary提供了我们对iOS设备中的相片、视频的访问。
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"保存视频失败:%@",error);
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"保存完成" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"保存视频到相册成功");
        }
    }];
}



- (void)addDidPlayToEndTimeNotificationForPlayerItem:(AVPlayerItem *)item
{
    if (_notificationToken)
        _notificationToken = nil;
    
    /*
     Setting actionAtItemEnd to None prevents the movie from getting paused at item end. A very simplistic, and not gapless, looped playback.
     */
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    _notificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        // Simple item playback rewind.
        [[_player currentItem] seekToTime:kCMTimeZero];
    }];
}

- (CGImageRef _Nullable)currentVideoFrame;
{
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [self.imageGenerator copyCGImageAtTime:self.player.currentItem.currentTime actualTime:&actualTime error:&error];
    return image;
}
- (void)play
{
    [self.player play];
    self.isPlaying = YES;
}

- (void)pause
{
    [self.player pause];
    self.isPlaying = NO;
}
- (void)videoSeekToTime:(CGFloat)time
{
    if (isSeeking) {
        return;
    }else{
        isSeeking = YES;
        [self.player pause];
        self.isPlaying = NO;
    }
    
    if (_frameView) {
        [_frameView removeFromSuperview];
        _frameView = nil;
    }
    
    CGFloat value = self.playerItem.duration.value * time;
    
    [self.player seekToTime:CMTimeMake(value, self.playerItem.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        isSeeking = NO;
    }];
}

#pragma mark delegate
- (void)didSelectedWithType:(MHVideoEditItemType)type andUrl:(NSURL *)url
{
    _frameView = [[MHAdjustFrameView alloc]init];
    [_frameView setupWithURL:url];
    _frameView.center = CGPointMake(self.showView.frame.size.width/2, self.showView.frame.size.height/2);
    [self.showView addSubview:_frameView];
}

#pragma makr property

- (AVAssetImageGenerator *)imageGenerator
{
    if (!_imageGenerator) {
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_asset];
        _imageGenerator.appliesPreferredTrackTransform = YES;
        _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    }
    return _imageGenerator;
}


@end
