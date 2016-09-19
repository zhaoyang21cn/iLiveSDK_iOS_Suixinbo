//
//  RecvCallView.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "RecvCallView.h"

@implementation RecvCallView
{
    UIImageView * _peerIcon;
    UILabel * _peerName;
    
    UIImageView * _soundSwitch;
    UIImageView * _cancel;
    UIImageView * _accept;
    UIImageView * _refuse;
    UIImageView * _speakerSwitch;
    
    id<RecvCallAble> _recvCallModel;
    __weak id<RecvCallViewDelegate> _delegate;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setBackgroundColor:kClearColor];
    
    if ([_recvCallModel getCallType] == CALL_TYPE_AUDIO) {
        [self showSubViews];
        if ([_recvCallModel isAccepted]) {
            [self layoutAudioChat];
        }
        else {
            [self layoutAudioWait];
        }
    }
    else if ([_recvCallModel getCallType] == CALL_TYPE_VIDEO) {
        [self showSubViews];
        if ([_recvCallModel isAccepted]) {
            [self layoutVideoChat];
        }
        else {
            [self layoutVideoWait];
        }
    }
    else {
        DebugLog(@"call type none, hide subviews");
        [self hideSubViews];
    }
}

- (void)layoutVideoChat
{
    DebugLog(@"layout video chat subviews");
    
    [_peerIcon alignParentTopWithMargin:20];
    [_peerIcon alignParentLeftWithMargin:20];
    
    [_peerName setText:[_recvCallModel getPeer]];
    [_peerName layoutToRightOf:_peerIcon margin:5];
    [_peerName alignTop:_peerIcon];
    [_peerName setTextAlignment:NSTextAlignmentLeft];
    
    [_cancel layoutParentCenter];
    [_cancel alignParentBottomWithMargin:60];
    
    [_accept setHidden:YES];
    [_refuse setHidden:YES];
}

- (void)layoutVideoWait
{
    DebugLog(@"layout video wait subviews");
    
    [_peerIcon alignParentTopWithMargin:20];
    [_peerIcon alignParentLeftWithMargin:20];
    
    [_peerName setText:[_recvCallModel getPeer]];
    [_peerName layoutToRightOf:_peerIcon margin:5];
    [_peerName alignTop:_peerIcon];
    [_peerName setTextAlignment:NSTextAlignmentLeft];
    
    [_accept layoutParentCenter];
    CGRect rect = _accept.frame;
    rect.origin.x += 60;
    [_accept setFrame:rect];
    [_accept alignParentBottomWithMargin:60];
    
    [_refuse layoutParentCenter];
    [_refuse alignParentBottomWithMargin:60];
    [_refuse layoutToLeftOf:_accept margin:60];
    
    [_cancel setHidden:YES];
}

- (void)layoutAudioWait
{
    DebugLog(@"layout audio wait subviews");
    
    [_peerIcon layoutParentCenter];
    [_peerIcon alignParentTopWithMargin:120];
    
    [_peerName setText:[_recvCallModel getPeer]];
    [_peerName layoutBelow:_peerIcon margin:10];
    [_peerName layoutParentHorizontalCenter];
    [_peerName setTextAlignment:NSTextAlignmentCenter];
    
    [_accept layoutParentCenter];
    CGRect rect = _accept.frame;
    rect.origin.x += 60;
    [_accept setFrame:rect];
    [_accept alignParentBottomWithMargin:60];
    
    [_refuse layoutParentCenter];
    [_refuse alignParentBottomWithMargin:60];
    [_refuse layoutToLeftOf:_accept margin:60];
    
    [_cancel setHidden:YES];
}

- (void)layoutAudioChat
{
    DebugLog(@"layout audio chat subviews");
    [_peerIcon layoutParentCenter];
    [_peerIcon alignParentTopWithMargin:120];
    
    [_peerName setText:[_recvCallModel getPeer]];
    [_peerName layoutBelow:_peerIcon margin:10];
    [_peerName layoutParentHorizontalCenter];
    [_peerName setTextAlignment:NSTextAlignmentCenter];
    
    [_cancel layoutParentCenter];
    [_cancel alignParentBottomWithMargin:60];
    
    [_accept setHidden:YES];
    [_refuse setHidden:YES];
}

- (void)hideSubViews
{
    [_peerIcon setHidden:YES];
    [_peerName setHidden:YES];
    [_cancel setHidden:YES];
    [_refuse setHidden:YES];
}

- (void)showSubViews
{
    [_peerIcon setHidden:NO];
    [_peerName setHidden:NO];
    [_cancel setHidden:NO];
    [_refuse setHidden:NO];
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
    
    _cancel = [UIImageView imageViewWithImage:kHangUpCall];
    [_cancel setBounds:CGRectMake(0, 0, 50, 50)];
    [_cancel setUserInteractionEnabled:YES];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hangup:)];
    [_cancel addGestureRecognizer:tap];
    [self addSubview:_cancel];
    
    _accept = [UIImageView imageViewWithImage:kAcceptCall];
    [_accept setBounds:CGRectMake(0, 0, 50, 50)];
    [_accept setUserInteractionEnabled:YES];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(accept:)];
    [_accept addGestureRecognizer:tap2];
    [self addSubview:_accept];
    
    _refuse = [UIImageView imageViewWithImage:kHangUpCall];
    [_refuse setBounds:CGRectMake(0, 0, 50, 50)];
    [_refuse setUserInteractionEnabled:YES];
    UITapGestureRecognizer * tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refuse:)];
    [_refuse addGestureRecognizer:tap3];
    [self addSubview:_refuse];
}

- (void)addRenderChatViews
{
    [_recvCallModel addRenderFor:[_recvCallModel getPeer] atFrame:self.bounds];
    
    CGRect rect = CGRectMake(0, 0, 60, 80);
    rect.origin.x = self.bounds.size.width - 80;
    rect.origin.y = 20;
    [_recvCallModel addSelfRender:rect];
}

- (void)setRecvCallModel:(id<RecvCallAble>)viewModel andDelegate:(id<RecvCallViewDelegate>)delegate
{
    _recvCallModel = viewModel;
    _recvCallModel.listener = self;
    _delegate = delegate;
    [self generateSubViews];
}

- (void)accept:(id)sender
{
    DebugLog(@"accept call");
    [_recvCallModel accept];
    [self setNeedsLayout];
}

- (void)refuse:(id)sender
{
    DebugLog(@"refuse call");
    [_recvCallModel refuse];
    if (_delegate) {
        [_delegate onExitCall:@"已拒绝通话"];
    }
}

- (void)hangup:(id)sender
{
    DebugLog(@"hangup call");
    [_recvCallModel hangup];
    if (_delegate) {
        [_delegate onExitCall:@"已退出通话"];
    }
}

- (void)onConnTimeout
{
    DebugLog(@"conn timeout");
    if (_delegate) {
        [_delegate onExitCall:@"请求通话结束"];
    }
}

- (void)onPeerHangup
{
    DebugLog(@"peer hangup");
    if (_delegate) {
        [_delegate onExitCall:@"对方已挂断"];
    }
}

- (void)onConnFailed
{
    DebugLog(@"conn failed");
    if (_delegate) {
        [_delegate onExitCall:@"连接失败"];
    }
}

- (void)onConnSucc
{
    DebugLog(@"conn succ");
    if ([_recvCallModel getCallType] == CALL_TYPE_VIDEO) {
        [self addRenderChatViews];
    }
}

@end
