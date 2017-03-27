//
//  SetBeautyView.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/11.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SetBeautyChanged)(BeautyViewType type, CGFloat beauty);

@interface TCShowBeautyTipView : UIView

@property (nonatomic, strong) UILabel     *tip;
@property (nonatomic, strong) UIImageView *tipBg;
@property (nonatomic, assign) BeautyViewType beautyType;

- (void)setBeauty:(CGFloat)beauty;
@end


@interface SetBeautyView : UIView
//背景
@property (nonatomic, strong) UIView *clearBg;      //用来做点击消失事件
@property (nonatomic, strong) UIView *sliderBack;

//美颜
@property (nonatomic, strong) UILabel *beautyLabel;
@property (nonatomic, readonly) UISlider *beautySlider;
@property (nonatomic, strong)  TCShowBeautyTipView *beautyTipView;
//美白
@property (nonatomic, strong) UILabel *whiteLabel;
@property (nonatomic, readonly) UISlider *whiteSlider;
@property (nonatomic, strong)  TCShowBeautyTipView *whiteTipView;

//回调函数
@property (nonatomic, copy) SetBeautyChanged changeCompletion;

- (void)setBeautyValue:(CGFloat)beauty;
- (void)setWhiteValue:(CGFloat)white;

@end
