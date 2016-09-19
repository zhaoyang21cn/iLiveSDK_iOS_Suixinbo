//
//  MakeCallView.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "MakeCallView.h"

@implementation MakeCallView
{
    UIImageView * _peerIcon;
    UILabel * _peerName;
    UILabel * _tips;
    
    UIImageView * _soundSwitch;
    UIImageView * _cancel;
    UIImageView * _speakerSwitch;
    
    id<MakeCallAble> _makeCallModel;
    __weak id<MakeCallViewDelegate> _delegate;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setBackgroundColor:kClearColor];
    
    if ([_makeCallModel getCallType] == CALL_TYPE_AUDIO) {
        [self showSubViews];
        if ([_makeCallModel isWaitConn]) {
            [self layoutAudioWait];
        }
        else {
            [self layoutAudioChat];
        }
    }
    else if ([_makeCallModel getCallType] == CALL_TYPE_VIDEO){
        [self showSubViews];
        if ([_makeCallModel isWaitConn]) {
            [self layoutVideoWait];
        }
        else {
            [self layoutVideoChat];
        }
    }
    else {
        DebugLog(@"call type none, hide subviews");
        [self hideSubViews];
    }
}

- (void)hideSubViews
{
    [_peerIcon setHidden:YES];
    [_peerName setHidden:YES];
    [_cancel setHidden:YES];
    [_tips setHidden:YES];
}

- (void)showSubViews
{
    [_peerIcon setHidden:NO];
    [_peerName setHidden:NO];
    [_cancel setHidden:NO];
    [_tips setHidden:NO];
}

- (void)layoutAudioWait
{
    DebugLog(@"layout audio wait subviews");
    
    [_peerIcon layoutParentCenter];
    [_peerIcon alignParentTopWithMargin:120];
    
    [_peerName setText:[_makeCallModel getPeer]];
    [_peerName layoutBelow:_peerIcon margin:10];
    [_peerName layoutParentHorizontalCenter];
    [_peerName setTextAlignment:NSTextAlignmentCenter];
    
    [_tips layoutBelow:_peerName margin:5];
    [_tips layoutParentHorizontalCenter];
    [_tips setTextAlignment:NSTextAlignmentCenter];
    
    [_cancel layoutParentCenter];
    [_cancel alignParentBottomWithMargin:60];
}

- (void)layoutAudioChat
{
    DebugLog(@"layout audio chat subviews");
    [_tips setHidden:YES];
}

- (void)layoutVideoWait
{
    DebugLog(@"layout video wait subviews");
    
    [_peerIcon alignParentTopWithMargin:20];
    [_peerIcon alignParentLeftWithMargin:20];
    
    [_peerName setText:[_makeCallModel getPeer]];
    [_peerName layoutToRightOf:_peerIcon margin:5];
    [_peerName alignTop:_peerIcon];
    [_peerName setTextAlignment:NSTextAlignmentLeft];
    
    [_tips layoutBelow:_peerName margin:5];
    [_tips layoutToRightOf:_peerIcon margin:5];
    [_tips setTextAlignment:NSTextAlignmentLeft];
    
    [_cancel layoutParentCenter];
    [_cancel alignParentBottomWithMargin:60];
}

- (void)layoutVideoChat
{
    DebugLog(@"layout video chat subviews");
    [_tips setHidden:YES];
}

- (void)generateSubViews
{
    _peerIcon = [UIImageView imageViewWithImage:kDefaultUserIcon];
    [_peerIcon setBounds:CGRectMake(0, 0, 60, 60)];
    [self addSubview:_peerIcon];
    
    _peerName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    [_peerName setTextColor:kGrayColor];
    [_peerName setFont:[UIFont systemFontOfSize:20]];
    [self addSubview:_peerName];
    
    _tips = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 15)];
    [_tips setText:@"等待接听..."];
    [_tips setTextColor:kGrayColor];
    [_tips setFont:kCommonSmallTextFont];
    [self addSubview:_tips];
    
    _cancel = [UIImageView imageViewWithImage:kHangUpCall];
    [_cancel setBounds:CGRectMake(0, 0, 50, 50)];
    [_cancel setUserInteractionEnabled:YES];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hangup:)];
    [_cancel addGestureRecognizer:tap];
    [self addSubview:_cancel];
}

- (void)addRenderWaitViews
{
    [_makeCallModel addRenderFor:[_makeCallModel getPeer] atFrame:self.bounds];
    
    CGRect rect = CGRectMake(0, 0, 60, 80);
    rect.origin.x = self.bounds.size.width - 80;
    rect.origin.y = 20;
    [_makeCallModel addSelfRender:rect];
}

- (void)addRenderChatViews
{
//    [_makeCallModel addRenderFor:[_makeCallModel getPeer] atFrame:self.bounds];
//    
//    CGRect rect = CGRectMake(0, 0, 60, 60);
//    rect.origin.x = self.bounds.size.width - 80;
//    rect.origin.y = 20;
//    [_makeCallModel addSelfRender:rect];
}

- (void)setMakeCallModel:(id<MakeCallAble>)viewModel andDelegate:(id<MakeCallViewDelegate>)delegate
{
    _makeCallModel = viewModel;
    _makeCallModel.listener = self;
    _delegate = delegate;
    [self generateSubViews];
}

- (void)hangup:(UITapGestureRecognizer*)gesture
{
    [_makeCallModel hangup];
    
    if (_delegate) {
        [_delegate onExitCall:@"已退出通话"];
    }
}

- (void)onStartConn
{
    DebugLog(@"start make call");
    
    if ([_makeCallModel getCallType] == CALL_TYPE_VIDEO) {
        [self addRenderWaitViews];
    }
    
    [self setNeedsLayout];
}

- (void)onConnAccepted
{
    DebugLog(@"peer accept call");
    if ([_makeCallModel getCallType] == CALL_TYPE_VIDEO) {
        [self addRenderChatViews];
    }
    [self setNeedsLayout];
}


- (void)onConnTimeout
{
    DebugLog(@"conn timeout");
    if (_delegate) {
        [_delegate onExitCall:@"对方没有接听"];
    }
}

- (void)onConnRejected
{
    DebugLog(@"peer rejected");
    if (_delegate) {
        [_delegate onExitCall:@"对方已拒绝"];
    }
}

- (void)onConnFailed
{
    DebugLog(@"conn failed");
    if (_delegate) {
        [_delegate onExitCall:@"请求通话失败"];
    }
}

- (void)onPeerHangup
{
    DebugLog(@"peer hangup");
    if (_delegate) {
        [_delegate onExitCall:@"对方已挂断"];
    }
}

@end
