//
//  HostInfoView.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "HostInfoView.h"
#import "HostInfoViewModel.h"

@implementation HostInfoView
{
    UIImageView * _hostIcon;
    UILabel * _hostName;
    UILabel * _hostID;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_hostIcon layoutParentVerticalCenter];
    [_hostIcon alignParentLeftWithMargin:20];
    
    [_hostName alignTop:_hostIcon];
    [_hostName layoutToRightOf:_hostIcon margin:kDefaultMargin];
    [_hostName scaleToParentRightWithMargin:kDefaultMargin];
    
    [_hostID sameWith:_hostName];
    [_hostID layoutBelow:_hostName];
    [_hostID scaleToBelowOf:_hostIcon];
}

- (void)setHostInfo
{
    _hostInfoModel = [[HostInfoViewModel alloc] init];
    [self updateSubViews];
}

- (void)updateSubViews
{
    CGRect rect = self.bounds;
    _hostIcon = [UIImageView imageViewWithImage:kDefaultUserIcon];
    [_hostIcon setBounds:CGRectMake(0, 0, 60, 60)];
    [self addSubview:_hostIcon];
    
    _hostName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 28)];
    [_hostName setText:[_hostInfoModel getHostNick]];
    [_hostName setTextColor:kBlackColor];
    [self addSubview:_hostName];
    
    _hostID = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 28)];
    [_hostID setText:[NSString stringWithFormat:@"账号ID: %@",[_hostInfoModel getHostId]]];
    [_hostID setTextColor:kGrayColor];
    [self addSubview:_hostID];
}

@end
