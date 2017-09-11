//
//  MHPictureManager.m
//  MHVideoExport
//
//  Created by FUZE on 2017/8/21.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import "MHPictureManager.h"
#import "MHPictureModel.h"

@implementation MHPictureInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.position = CGPointMake(-1, -1);
        self.scale = 1;
        self.radian = 0;
    }
    return self;
}
@end


@interface MHPictureManager ()
@property (nonatomic, strong) NSMutableArray <MHPictureModel *> *pictures;
@end


@implementation MHPictureManager

+ (instancetype)shareManager
{
    static MHPictureManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MHPictureManager alloc]init];
    });
    return _instance;
}

- (NSMutableArray <MHPictureModel *>*)pictures
{
    if (!_pictures) {
        _pictures = [[NSMutableArray alloc]init];
    }
    return _pictures;
}

- (void)addPictureWithUrl:(NSURL *)url andTime:(CGFloat)time andRadian:(CGFloat)radian andScale:(CGFloat)scale
{
    MHPictureModel *model = [[MHPictureModel alloc]initWithUrl:url andStartTime:time];
    if (model) {
        model.radian = radian;
        model.scale = scale;
        [self.pictures addObject:model];
    }
}

- (void)addPictureInDrectory:(NSString *)dractory andTime:(CGFloat)time andRadian:(CGFloat)radian andScale:(CGFloat)scale
{
    MHPictureModel *model = [[MHPictureModel alloc]initWithDirection:dractory andStartTime:time];
    if (model) {
        model.radian = radian;
        model.scale = scale;
        [self.pictures addObject:model];
    }
}


- (void)updatePicturePosition:(CGPoint)aPoint withCompositionTime:(CMTime)aTime
{
    
    MHPictureModel *lastModel = [self.pictures lastObject];
    if (lastModel) {
        [lastModel addGesturePosition:aPoint withCompositionTime:aTime];
    }
}
- (void)lastPictureEditFinishWithTime:(CMTime)aTime
{
    MHPictureModel *lastModel = [self.pictures lastObject];
    if (lastModel) {
        lastModel.editing = NO;
        lastModel.endTime = CMTimeGetSeconds(aTime);
    }
}

- (NSArray *)requestPictureInfoWithTime:(CGFloat)time
{
    NSMutableArray <MHPictureInfo *>* array = [[NSMutableArray alloc]init];
    
    [_pictures enumerateObjectsUsingBlock:^(MHPictureModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.editing) {
            
        }else if(time > obj.startTime && time < obj.endTime) {
            
            CGFloat timeless = time - obj.startTime;
            while (timeless > obj.duration) {
                timeless -= obj.duration;
            }
            CGImageRef image = [self searchPictureWithTime:timeless fromPictureInfo:obj];
            if (image) {
                MHPictureInfo *info = [[MHPictureInfo alloc]init];
                info.imageRef = image;
                [obj.gestures enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    CGFloat padding =time - [(NSString *)key floatValue];
                    if (padding > 0 && padding < 0.02) {
                        info.position = CGPointFromString(obj);
                        *stop = YES;
                    }
                }];
                info.radian = obj.radian;
                info.scale = obj.scale;
                [array addObject:info];
            }else{
                NSAssert(0, @"image is nil");
            }
        }
    }];
    return array;
}

- (CGImageRef)searchPictureWithTime:(CGFloat)time fromPictureInfo:(MHPictureModel *)model
{
    GLint index = 0;
    
    CGFloat elapsedTime = time;
    
    while (elapsedTime >= 0) {
        elapsedTime -= [model.delays[index] floatValue];
        index ++;
        if (index >= model.delays.count) {
            break;
        }
    }
    if (elapsedTime <= 0) {
        
        return (__bridge CGImageRef)(model.images[--index]);
    }
    return NULL;
}

- (CGImageRef)firstImage
{
    if (self.pictures.count > 0) {
        return (__bridge CGImageRef)(self.pictures.lastObject.images[0]);
    }
    return NULL;
}

@end
