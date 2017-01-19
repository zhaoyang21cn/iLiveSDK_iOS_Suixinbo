//
//  LiveCallView.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveCallView.h"

#define kCallTimeout 60
@implementation LiveCallView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame])
    {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"defaul_publishcover"]];
        _imageView.userInteractionEnabled = YES;
        [self addSubview:_imageView];
        
        _userLabel = [[UILabel alloc] init];
        _userLabel.textAlignment = NSTextAlignmentCenter;
        _userLabel.textColor = kColorWhite;
        [_imageView addSubview:_userLabel];
        
        _hangUpBtn = [[UIButton alloc] init];
        [_hangUpBtn setBackgroundImage:[UIImage imageNamed:@"phone"] forState:UIControlStateNormal];
        [_hangUpBtn addTarget:self action:@selector(cancelInivte) forControlEvents:UIControlEventTouchUpInside];
        [_imageView addSubview:_hangUpBtn];
        
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:kCallTimeout target:self selector:@selector(cancelInivte) userInfo:nil repeats:NO];
        
        [self setBackgroundColor:[kColorBlack colorWithAlphaComponent:0.5]];
    }
    return self;
}

- (void)cancelInivte
{
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.recvId = _userLabel.text;
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_Multi_Host_CancelInvite;
    msg.type = ILVLIVE_IMTYPE_C2C;
    
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        
    }];
    
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
    
    //超时
    [[NSNotificationCenter defaultCenter] postNotificationName:kCancelConnect_Notification object:_userLabel.text];
}

- (void)layoutSubviews
{
    CGRect selfRect = self.bounds;
    [_imageView sizeWith:CGSizeMake(selfRect.size.width, selfRect.size.height)];
    [_imageView alignParentTop];
    
    [_userLabel sizeWith:CGSizeMake(selfRect.size.width * 2/3, selfRect.size.height * 1/4)];
    [_userLabel alignParentTopWithMargin:kDefaultMargin];
    [_userLabel layoutParentHorizontalCenter];
    
    [_hangUpBtn sizeWith:CGSizeMake(selfRect.size.width * 2/3, selfRect.size.height * 1/4)];
    [_hangUpBtn alignParentBottom];
    [_hangUpBtn layoutParentHorizontalCenter];
}


@end
