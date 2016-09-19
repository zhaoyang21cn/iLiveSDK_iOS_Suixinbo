//
//  EngineListener.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "EngineListener.h"
#import "EngineHeaders.h"
#import "RecvCallViewModel.h"
#import "RecvCallViewController.h"

@implementation LiveMessageListener

- (void)onNewMessage:(NSArray *)msgs
{
    [[TCICallManager sharedInstance] filterCallMessageInNewMessages:msgs];
    if ([msgs count] > 0) {
        TIMMessage * msg = [msgs firstObject];
        TIMConversation * sess = [msg getConversation];
        [sess setReadMessage:msg];
    }
}

@end

@implementation LiveIncomingCallListener

- (void)onCallCmd:(TCICallCMD *)cmd
{
    if (cmd.userAction == AVIMCMD_Call_Dialing && [self shouldDealWithRecvCall:cmd]) {
        RecvCallViewModel * model = [[RecvCallViewModel alloc] initWithType:cmd.callType ? CALL_TYPE_AUDIO:CALL_TYPE_VIDEO peerId:cmd.callSponsor];
        [model setCallCmd:cmd];
        
        RecvCallViewController * vc = [[RecvCallViewController alloc] init];
        [vc setRecvCallModel:model];
        
        [[[AppDelegate sharedInstance] topViewController] presentViewController:vc animated:YES completion:nil];
    }
}

- (BOOL)shouldDealWithRecvCall:(TCICallCMD*)cmd
{
    time_t now = [[NSDate date] timeIntervalSince1970];
    time_t callTime = [cmd.callDate timeIntervalSince1970];
    
    if (now - callTime < kCallTimeOut
        && ![[LiveCallPlatform sharedInstance] isChat]) {
        return YES;
    }
    else {
        return NO;
    }
}

@end

@implementation LiveUserStatusListener

- (void)onForceOffline
{
    DebugLog(@"kick off by other device");
    
    UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"下线通知" message:@"您的帐号于另一台手机上登录。" cancelButtonTitle:@"退出" otherButtonTitles:@[@"重新登录"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0)
        {
            [[LiveCallPlatform sharedInstance] setAutoLogin:NO];
            [[TCICallManager sharedInstance] logout:^{
                [[AppDelegate sharedInstance] enterLoginUI];
            } fail:^(int code, NSString *msg) {
                [[AppDelegate sharedInstance] enterLoginUI];
            }];
        }
        else
        {
            // 重新登录
            [[LiveCallPlatform sharedInstance] setAutoLogin:YES];
            [[TCICallManager sharedInstance] logout:^{
                [[AppDelegate sharedInstance] enterLoginUI];
            } fail:^(int code, NSString *msg) {
                [[AppDelegate sharedInstance] enterLoginUI];
            }];
        }
        
    }];
    [alert show];
}

- (void)onReConnFailed:(int)code err:(NSString *)err
{
    DebugLog(@"断线重连失败");
}

- (void)onUserSigExpired
{
    DebugLog(@"usersig expired");
    [[LiveCallPlatform sharedInstance] setAutoLogin:NO];
    [HUDHelper alert:@"票据过期，请重新登录" action:^{
        [[TCICallManager sharedInstance] logout:^{
            [[AppDelegate sharedInstance] enterLoginUI];
        } fail:^(int code, NSString *msg) {
            [[AppDelegate sharedInstance] enterLoginUI];
        }];
    }];
}

@end