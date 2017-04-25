//
//  EnvInfoView.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/4/13.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "EnvInfoView.h"

@implementation EnvInfoView

- (instancetype)init
{
    if ([super init])
    {
        [self addSubViews];
//        [self layoutViews];
    }
    return self;
}

- (void)addSubViews
{
    _cpuRateLabel = [[UILabel alloc] init];
    _cpuRateLabel.text = @"CPU占用率:0%";
    _cpuRateLabel.font = kAppSmallTextFont;
    [self addSubview:_cpuRateLabel];
    
    _lossRateLabel = [[UILabel alloc] init];
    _lossRateLabel.text = @"丢包率:0%";
    _lossRateLabel.font = kAppSmallTextFont;
    [self addSubview:_lossRateLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect selfRect = self.bounds;
    int magrin = kDefaultMargin/2;
    [_cpuRateLabel sizeWith:CGSizeMake(selfRect.size.width - magrin*2, (selfRect.size.height - magrin*3)/2)];
    [_cpuRateLabel alignParentLeftWithMargin:magrin];
    [_cpuRateLabel alignParentTopWithMargin:magrin];
    
    [_lossRateLabel sizeWith:CGSizeMake(selfRect.size.width - magrin*2, (selfRect.size.height - magrin*3)/2)];
    [_lossRateLabel alignParentLeftWithMargin:magrin];
    [_lossRateLabel alignParentBottomWithMargin:magrin];
}
//- (void)layoutViews
//{
//    CGRect selfRect = self.bounds;
//    [_cpuRateLabel sizeWith:CGSizeMake(selfRect.size.width - kDefaultMargin*2, (selfRect.size.height - kDefaultMargin*3)/2)];
//    [_cpuRateLabel alignParentLeftWithMargin:kDefaultMargin];
//    
//    [_lossRateLabel sizeWith:CGSizeMake(selfRect.size.width - kDefaultMargin*2, (selfRect.size.height - kDefaultMargin*3)/2)];
//    [_lossRateLabel layoutBelow:_cpuRateLabel margin:kDefaultMargin];
//    [_lossRateLabel alignParentLeftWithMargin:kDefaultMargin];
//}

- (void)configWith:(EnvInfoItem *)item
{
    _cpuRateLabel.text = [NSString stringWithFormat:@"CPU占用率:%.2f%%",(CGFloat)item.cpuRate/(CGFloat)100];
    _lossRateLabel.text = [NSString stringWithFormat:@"丢包率:%.2f%%",(CGFloat)item.lossRate/(CGFloat)100];
}

@end

@implementation EnvInfoItem
@end
