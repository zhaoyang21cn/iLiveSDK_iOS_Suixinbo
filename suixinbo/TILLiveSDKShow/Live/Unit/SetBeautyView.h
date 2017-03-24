//
//  SetBeautyView.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/11.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SetBeautyChanged)(CGFloat beauty);

@interface SetBeautyView : UIView
{
@protected
    UIView   *_clearBg;
    UIView   *_sliderBack;
    UISlider *_slider;
}

@property (nonatomic, readonly) UISlider *slider;
@property (nonatomic, assign) BOOL isWhiteMode;
@property (nonatomic, copy) SetBeautyChanged changeCompletion;

- (void)setBeauty:(CGFloat)beauty;
- (void)relayoutFrameOfSubViews;
@end
