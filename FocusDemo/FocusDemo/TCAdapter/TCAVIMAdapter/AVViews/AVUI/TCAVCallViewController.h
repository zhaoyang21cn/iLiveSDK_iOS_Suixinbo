//
//  TCAVCallViewController.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportCallScene
#import "TCAVMultiLiveViewController.h"

// 电话呼叫场景
// C2C场景下：进入到电话场景下时，用户需要作接听/挂断操作，当接听时，才真正进入
// 挂断时，直接退出

@interface TCAVCallViewController : TCAVMultiLiveViewController
{
@protected
    BOOL                    _isCallSponsor;
    BOOL                    _isVoice;
}

@property (nonatomic, assign) BOOL isCallSponsor;
@property (nonatomic, assign) BOOL isVoice;

- (void)startEnterCallRoom;


// 当收到电话消息时，本身占线时
- (void)onRecvCallButBusyLine:(AVIMCMD *)cmd;

// 收到占线消息
- (void)onRecvBusyLineCall:(AVIMCMD *)cmd;

// 收到挂断消息
- (void)onRecvDisconnectCall:(AVIMCMD *)cmd;

- (void)onRecvConnectCall:(AVIMCMD *)cmd;

// 通话中收到邀请消息
- (void)onRecvInviteCall:(AVIMCMD *)cmd;

- (void)onRecvNoAnswerCall:(AVIMCMD *)cmd;

- (void)onRecvEnableMic:(AVIMCMD *)cmd;
- (void)onRecvDisableMic:(AVIMCMD *)cmd;

- (void)onRecvEnableCamera:(AVIMCMD *)cmd;
- (void)onRecvDisableCamera:(AVIMCMD *)cmd;



@end

#endif