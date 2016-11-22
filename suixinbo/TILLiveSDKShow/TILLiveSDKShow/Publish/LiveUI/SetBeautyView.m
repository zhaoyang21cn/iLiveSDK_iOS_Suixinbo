//
//  SetBeautyView.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/11.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "SetBeautyView.h"
@interface TCShowBeautyTipView : UIView
{
    UIImageView *_tipBg;
    UILabel     *_tip;
}
@property (nonatomic, assign) BOOL isWhiteMode;
- (void)setBeauty:(CGFloat)beauty;

@end


@implementation TCShowBeautyTipView

- (instancetype)init
{
    if (self = [super init])
    {
        _tipBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beautyTip"]];
        [self addSubview:_tipBg];
        
        _tip = [[UILabel alloc] init];
        _tip.font = [UIFont systemFontOfSize:13];
        _tip.adjustsFontSizeToFitWidth = YES;
        _tip.textAlignment = NSTextAlignmentCenter;
        _tip.textColor = [UIColor whiteColor];
        [self addSubview:_tip];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _tipBg.frame = self.bounds;
    _tip.frame = CGRectMake(0, 2, self.bounds.size.width, self.bounds.size.height - 10);
    
}

- (void)setBeauty:(CGFloat)beauty
{
    if (!_isWhiteMode)
    {
        _tip.text = [NSString stringWithFormat:@"美颜度 %d％", (int)(100 * beauty)];
    }
    else
    {
        _tip.text = [NSString stringWithFormat:@"美白度 %d％", (int)(100 * beauty)];
    }
}
@end



@interface SetBeautyView ()
{
    TCShowBeautyTipView *_tipView;
}

@end

@implementation SetBeautyView

- (instancetype)init
{
    if (self = [super init])
    {
        [self addOwnViews];
    }
    return self;
}

- (void)addOwnViews
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    _clearBg = [[UIView alloc] init];
    [self addSubview:_clearBg];
    
    _sliderBack = [[UIView alloc] init];
    _sliderBack.backgroundColor = kColorWhite;
    _sliderBack.clipsToBounds = NO;
    [self addSubview:_sliderBack];
    
    _slider = [[UISlider alloc] init];
    [_sliderBack addSubview:_slider];
    
    
    UIImage *img = [UIImage imageNamed:@"beauty_slider"];
    [_slider setThumbImage:img forState:UIControlStateNormal];
    [_slider setThumbImage:img forState:UIControlStateSelected];
    [_slider setThumbImage:img forState:UIControlStateHighlighted];
    [_slider addTarget:self action:@selector(onBeautyChanged:) forControlEvents:UIControlEventValueChanged];
    [_sliderBack addSubview:_slider];
    
    _tipView = [[TCShowBeautyTipView alloc] init];
    [_sliderBack addSubview:_tipView];
    _tipView.frame = CGRectMake(0, 0, 75, 27);
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [_clearBg addGestureRecognizer:tap];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self moveTip];
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.bounds;
    
    _clearBg.frame = rect;
    
    [_sliderBack sizeWith:CGSizeMake(rect.size.width, 60)];
    [_sliderBack alignParentBottom];
    
    rect = _sliderBack.bounds;
    _slider.frame = CGRectInset(rect, 30, 20);
}

- (void)onBeautyChanged:(id)sender
{
    [self moveTip];
    if (_changeCompletion)
    {
        _changeCompletion(_slider.value);
    }
}

- (void)moveTip
{
    CGRect tipFrame = _tipView.frame;
    CGRect rect = _slider.frame;
    tipFrame.origin.y = rect.origin.y - tipFrame.size.height;
    CGFloat value = _slider.value;
    tipFrame.origin.x = rect.origin.x + value * rect.size.width - tipFrame.size.width/2;
    _tipView.frame = tipFrame;
    [_tipView setBeauty:_slider.value];
}


- (void)onTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self close];
    }
}

- (void)setIsWhiteMode:(BOOL)isWhiteMode
{
    _isWhiteMode = isWhiteMode;
    _tipView.isWhiteMode = isWhiteMode;
}

- (void)close
{
    [self removeFromSuperview];
}

- (void)setBeauty:(CGFloat)beauty
{
    _slider.value = beauty;
    [self moveTip];
}
@end
