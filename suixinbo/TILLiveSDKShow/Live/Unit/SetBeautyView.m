//
//  SetBeautyView.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/11.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "SetBeautyView.h"
#import "UIView+CustomAutoLayout.h"

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
    if (_beautyType == BeautyViewType_Beauty)
    {
        _tip.text = [NSString stringWithFormat:@"美颜度 %d％", (int)(100 * beauty)];
    }
    if (_beautyType == BeautyViewType_White)
    {
        _tip.text = [NSString stringWithFormat:@"美白度 %d％", (int)(100 * beauty)];
    }
}
@end


@implementation SetBeautyView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addOwnViews];
        [self layoutViews];
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
    _sliderBack.backgroundColor = [kColorWhite colorWithAlphaComponent:0.3];
    _sliderBack.clipsToBounds = NO;
    [self addSubview:_sliderBack];
    
    _beautyLabel = [[UILabel alloc] init];
    _beautyLabel.text = @"美颜";
    [_sliderBack addSubview:_beautyLabel];
    
    UIImage *img = [UIImage imageNamed:@"beauty_slider"];
    _beautySlider = [[UISlider alloc] init];
    [_beautySlider setThumbImage:img forState:UIControlStateNormal];
//    [_beautySlider setThumbImage:img forState:UIControlStateSelected];
//    [_beautySlider setThumbImage:img forState:UIControlStateHighlighted];
    [_beautySlider addTarget:self action:@selector(onBeautyChanged:) forControlEvents:UIControlEventValueChanged];
    [_sliderBack addSubview:_beautySlider];
    
    _whiteLabel = [[UILabel alloc] init];
    _whiteLabel.text = @"美白";
    [_sliderBack addSubview:_whiteLabel];
    
    _whiteSlider = [[UISlider alloc] init];
    [_whiteSlider setThumbImage:img forState:UIControlStateNormal];
//    [_whiteSlider setThumbImage:img forState:UIControlStateSelected];
//    [_whiteSlider setThumbImage:img forState:UIControlStateHighlighted];
    [_whiteSlider addTarget:self action:@selector(onWhiteChanged:) forControlEvents:UIControlEventValueChanged];
    [_sliderBack addSubview:_whiteSlider];
    
    _beautyTipView = [[TCShowBeautyTipView alloc] init];
    _beautyTipView.beautyType = BeautyViewType_Beauty;
    [_sliderBack addSubview:_beautyTipView];
    
    _whiteTipView = [[TCShowBeautyTipView alloc] init];
    _whiteTipView.beautyType = BeautyViewType_White;
    [_sliderBack addSubview:_whiteTipView];
//    _tipView.frame = CGRectMake(0, 0, 75, 27);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [_clearBg addGestureRecognizer:tap];
}

- (void)layoutViews
{
    CGRect selfRect = self.bounds;
    
    _clearBg.frame = selfRect;
    
    [_sliderBack sizeWith:CGSizeMake(selfRect.size.width, 170)];
    [_sliderBack alignParentBottom];
    
    CGFloat height = 45;//(_sliderBack.frame.size.height - kDefaultMargin*3)/2;
    CGFloat bottomMargin = kDefaultMargin*6;
    
    [_whiteLabel sizeWith:CGSizeMake((selfRect.size.width-kDefaultMargin*3) * 2/10, height)];
    [_whiteLabel alignParentBottomWithMargin:bottomMargin];
    [_whiteLabel alignParentLeftWithMargin:kDefaultMargin];
    
    [_whiteSlider sizeWith:CGSizeMake((selfRect.size.width-kDefaultMargin*3) * 8/10, height)];
    [_whiteSlider alignParentBottomWithMargin:bottomMargin];
    [_whiteSlider layoutToRightOf:_whiteLabel margin:kDefaultMargin];
    
    [_whiteTipView sizeWith:CGSizeMake(75, 27)];
    [_whiteTipView layoutBelow:_whiteSlider margin:kDefaultMargin];
    
    [_beautyLabel sizeWith:CGSizeMake((selfRect.size.width-kDefaultMargin*3) * 2/10, height)];
    [_beautyLabel layoutAbove:_whiteLabel margin:kDefaultMargin*3];
    [_beautyLabel alignHorizontalCenterOf:_whiteLabel];
    
    [_beautySlider sizeWith:CGSizeMake((selfRect.size.width-kDefaultMargin*3) * 8/10, height)];
    [_beautySlider layoutAbove:_whiteSlider margin:kDefaultMargin*3];
    [_beautySlider alignHorizontalCenterOf:_whiteSlider];
    
    [_beautyTipView sizeWith:CGSizeMake(70, 27)];
    [_beautyTipView layoutBelow:_beautySlider margin:kDefaultMargin];
}

- (void)onBeautyChanged:(id)sender
{
    [self moveTip:_beautySlider tipView:_beautyTipView];
    if (_changeCompletion)
    {
        _changeCompletion(BeautyViewType_Beauty, _beautySlider.value);
    }
}

- (void)onWhiteChanged:(id)sender
{
    [self moveTip:_whiteSlider tipView:_whiteTipView];
    if (_changeCompletion)
    {
        _changeCompletion(BeautyViewType_White, _whiteSlider.value);
    }
}

- (void)moveTip:(UISlider *)silder tipView:(TCShowBeautyTipView *)tipView
{
    CGRect selfRect = [self bounds];
    CGRect tipFrame = tipView.frame;
    CGRect rect = silder.frame;
    tipFrame.origin.y = rect.origin.y - tipFrame.size.height;
    CGFloat value = silder.value;
    tipFrame.origin.x = rect.origin.x + value * rect.size.width - tipFrame.size.width/2;
    if (tipFrame.origin.x + tipFrame.size.width > selfRect.size.width)
    {
        tipFrame.origin.x = selfRect.size.width-tipFrame.size.width;
    }
    tipView.frame = tipFrame;
    [tipView setBeauty:silder.value];
}

- (void)onTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self close];
    }
}

- (void)close
{
    [UIView animateWithDuration:0.7 animations:^{
        CGRect selfRect = self.frame;
        selfRect.origin.y += selfRect.size.height;
        [self setFrame:selfRect];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setBeautyValue:(CGFloat)beauty
{
    _beautySlider.value = beauty;
    [self moveTip:_beautySlider tipView:_beautyTipView];
}

- (void)setWhiteValue:(CGFloat)white
{
    _whiteSlider.value = white;
    [self moveTip:_whiteSlider tipView:_whiteTipView];
}

@end
