//
//  DialSessionCell.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "DialSessionCell.h"

@implementation DialSessionCell
{
    UIImageView * _sessIcon;
    UILabel * _sessName;
    UILabel * _time;
    id<DialSessionAble> _sessInfo;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_sessIcon layoutParentVerticalCenter];
    [_sessIcon alignParentLeftWithMargin:10];
    
    [_sessName alignTop:_sessIcon];
    [_sessName layoutToRightOf:_sessIcon margin:kDefaultMargin];
    [_sessName scaleToParentRightWithMargin:kDefaultMargin];
    
    [_time sameWith:_sessName];
    [_time layoutBelow:_sessName];
    [_time scaleToBelowOf:_sessIcon];
}

- (void)setSessionInfo:(id<DialSessionAble>)sessInfo
{
    _sessInfo = sessInfo;
    [self updateSubViews];
}

- (id<DialSessionAble>)getSessInfo
{
    return _sessInfo;
}

- (void)updateSubViews
{
    CGRect rect = self.bounds;
    _sessIcon = [UIImageView imageViewWithImage:kDefaultSessIcon];
    [_sessIcon setBounds:CGRectMake(0, 0, 40, 40)];
    [self addSubview:_sessIcon];
    
    _sessName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 20)];
    [_sessName setText:[_sessInfo getSessionName]];
    [_sessName setTextColor:kBlackColor];
    [self addSubview:_sessName];
    
    _time = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 100)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd HH:mm"];
    [_time setText:[dateFormatter stringFromDate:[_sessInfo getLastCallTime]]];
    [_time setTextColor:kGrayColor];
    [self addSubview:_time];
}

@end
