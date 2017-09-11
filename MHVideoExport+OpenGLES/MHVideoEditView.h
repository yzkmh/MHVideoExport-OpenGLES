//
//  MHVideoEditView.h
//  MHVideoExport+OpenGLES
//
//  Created by FUZE on 2017/9/4.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef NS_ENUM(NSUInteger, MHVideoEditItemType) {
    MHVideoEditItemTypeText,
    MHVideoEditItemTypeImage,
    MHVideoEditItemTypeParticle,
    MHVideoEditItemTypeAudio
};

@protocol MHVideoEditViewDelegate <NSObject>

- (void)didSelectedWithType:(MHVideoEditItemType)type andUrl:(NSURL *)url;

@end



@interface MHVideoEditView : UIView
@property (nonatomic, weak) id<MHVideoEditViewDelegate> delegate;

@end
