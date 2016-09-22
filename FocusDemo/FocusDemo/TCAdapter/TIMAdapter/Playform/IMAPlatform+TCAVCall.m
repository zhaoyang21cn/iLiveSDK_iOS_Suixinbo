//
//  IMAPlatform+TCAVCall.m
//  TIMChat
//
//  Created by AlexiChen on 16/6/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportCallScene
#import "IMAPlatform+TCAVCall.h"

@implementation IMAPlatform (TCAVCall)

static NSString *const kIMAPlatformCallViewController = @"kIMAPlatformCallViewController";

- (TCAVCallViewController *)callViewController
{
    return objc_getAssociatedObject(self, (__bridge const void *)kIMAPlatformCallViewController);
    
}

- (void)setCallViewController:(TCAVCallViewController *)callViewController
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAPlatformCallViewController, callViewController, OBJC_ASSOCIATION_RETAIN);
}


- (void)onRecvCall:(AVIMCMD *)cmd conversation:(id<AVIMCallHandlerAble>)conv isFromChatting:(BOOL)isChatting
{
    // 说明正在通话中
    if (self.callViewController)
    {
        int oldAVroomID = [self.callViewController.roomInfo liveAVRoomId];
        int newAVRoomID = [cmd liveAVRoomId];
        if (oldAVroomID != newAVRoomID)
        {
            // 回复占线
            AVIMCMD *busycmd = [[AVIMCMD alloc] initWithCall:AVIMCMD_Call_LineBusy avRoomID:[cmd liveAVRoomId] group:[cmd liveIMChatRoomId] groupType:[cmd callGroupType] type:[cmd isVoiceCall] tip:nil];
            [conv sendCallMsg:busycmd finish:nil];
            return;
        }
    }

    
    
    switch (cmd.msgType)
    {
        case AVIMCMD_Call_Dialing:       // 正在呼叫
        {
            DebugLog(@"======>>>>>>>>收到[%@]呼叫消息", [cmd.sender imUserId]);
            if (self.callViewController)
            {
                DebugLog(@"当前正在通话中");
                // 已在通话中，说明占线
                [self.callViewController onRecvCallButBusyLine:cmd];
            }
            else
            {
                [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
                
                // 没有通话，直接呼起
                self.callViewController = [[IMAAppDelegate sharedAppDelegate] presentCommingCallViewControllerWith:cmd conversation:conv isFromChatting:isChatting];
            }
            
        }
            break;
        case AVIMCMD_Call_Connected:     // 连接进行通话
        {
            DebugLog(@"======>>>>>>>>收到[%@]接听消息", [cmd.sender imUserId]);
            // 进入通话
            // 对方占线
            if (self.callViewController)
            {
                // 已在通话中，说明占线
                [self.callViewController onRecvConnectCall:cmd];
            }
        }
            break;
        case AVIMCMD_Call_LineBusy:      // 电话占线
        {
            DebugLog(@"======>>>>>>>>收到[%@]占线消息", [cmd.sender imUserId]);
            // 对方占线
            if (self.callViewController)
            {
                // 已在通话中，说明占线
                [self.callViewController onRecvBusyLineCall:cmd];
            }
        }
            break;
        case AVIMCMD_Call_Disconnected:  // 挂断
        {
            DebugLog(@"======>>>>>>>>收到[%@]挂断消息", [cmd.sender imUserId]);
            // 挂断
            if (self.callViewController)
            {
                // 已在通话中，说明占线
                [self.callViewController onRecvDisconnectCall:cmd];
            }
        }
            break;
        case AVIMCMD_Call_Invite:
        {
            DebugLog(@"======>>>>>>>>收到[%@]邀请消息", [cmd.sender imUserId]);
            // 邀请消息
            // 当前的消息是原来的人发送的
            if (self.callViewController)
            {
                [self.callViewController onRecvInviteCall:cmd];
            }
            else
            {
                //
                [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
                
                // 没有通话，直接呼起
                self.callViewController = [[IMAAppDelegate sharedAppDelegate] presentCommingCallViewControllerWith:cmd conversation:conv isFromChatting:isChatting];
            }
                
            
        }
            
            break;
        case AVIMCMD_Call_NoAnswer:
        {
            DebugLog(@"======>>>>>>>>收到无人应答消息");
            // 邀请消息
            [self.callViewController onRecvNoAnswerCall:cmd];
        }
            
            break;
            
        case  AVIMCMD_Call_EnableMic:
        {
            [self.callViewController onRecvEnableMic:cmd];
        }
            break;
        case  AVIMCMD_Call_DisableMic:
        {
            [self.callViewController onRecvDisableMic:cmd];
        }
            break;
        case  AVIMCMD_Call_EnableCamera:
        {
            [self.callViewController onRecvEnableCamera:cmd];
        }
            break;
        case  AVIMCMD_Call_DisableCamera:
        {
            [self.callViewController onRecvDisableCamera:cmd];
        }
            break;
            
        default:
            break;
    }
}

@end
#endif

