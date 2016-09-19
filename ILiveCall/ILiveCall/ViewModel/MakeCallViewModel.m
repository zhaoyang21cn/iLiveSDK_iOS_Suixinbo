//
//  MakeCallViewModel.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "MakeCallViewModel.h"
#import "EngineHeaders.h"

@implementation MakeCallViewModel
{
    CallType _callType;
    NSTimer * _callTimer;
    NSString * _peerId;
    BOOL _isWait;
}

- (void)dialUserWithAudio:(NSString *)userId
{
    DebugLog(@"call user %@ with audio from dial number", userId);
    _callType = CALL_TYPE_AUDIO;
    _peerId = userId;
    [self makeCall];
}

- (void)dialUserWithVideo:(NSString *)userId
{
    DebugLog(@"call user %@ with video from dial number", userId);
    _callType = CALL_TYPE_VIDEO;
    _peerId = userId;
    
    [self makeCall];
}

- (void)hangup
{
    DebugLog(@"user call hangup");
    [[TCICallManager sharedInstance] endCallCompletion:nil];
}

- (BOOL)isWaitConn
{
    return _isWait;
}

- (NSString*)getPeer
{
    return _peerId;
}

- (AVGLBaseView *)createAVGLViewIn:(UIViewController *)vc
{
    return [[TCICallManager sharedInstance] createAVGLViewIn:vc];
}

- (AVGLRenderView *)addRenderFor:(NSString *)uid atFrame:(CGRect)rect
{
    return [[TCICallManager sharedInstance] addRenderFor:uid atFrame:rect];
}

- (AVGLRenderView *)addSelfRender:(CGRect)rect
{
    NSString * identifier = [[TCICallManager sharedInstance] host].identifier;
    return [[TCICallManager sharedInstance] addRenderFor:identifier atFrame:rect];
}

- (void)makeCall
{
    _isWait = YES;
    [self startCallTimer];
    [self registerConnListener];
    
    [[LiveCallPlatform sharedInstance] setChat:YES];
    
    if (_listener) {
        [_listener onStartConn];
    }
    
    NSString * identifier = [[TCICallManager sharedInstance] host].identifier;
    TCILiveRoom *room = [[TCILiveRoom alloc] initC2CCallWith:998998 liveHost:identifier curUserID:identifier callType:_callType==CALL_TYPE_AUDIO ? YES:NO];
    [[TCICallManager sharedInstance] enterRoom:room imChatRoomBlock:nil avRoomCallBack:^(BOOL succ, NSError *err) {
        if (succ)
        {
            TCICallCMD *cmd = [TCICallCMD analysisCallCmdFrom:room];
            cmd.userAction = AVIMCMD_Call_Dialing;
            cmd.callTip = @"正在呼叫";
            
            [[TCICallManager sharedInstance] makeC2CCall:_peerId callCMD:cmd completion:^(BOOL isFinished) {
                if (!isFinished) {
                    DebugLog(@"makec2c call faild");
                    [self onConnFailed];
                }
                DebugLog(@"make c2c call succ");
            }];
        }
        else
        {
            DebugLog(@"enter room failed");
            [self onConnFailed];
            
        }
    }];
}

- (void)registerConnListener
{
    __weak typeof(self) ws = self;
    [[TCICallManager sharedInstance] registCallHandle:^(TCICallCMD *callCmd) {
        switch (callCmd.userAction) {
            case AVIMCMD_Call_Connected:
                [ws onConnAccepted];
                break;
            case AVIMCMD_Call_Disconnected:
                [ws onPeerHangup];
                break;
            case AVIMCMD_Call_LineBusy:
            case AVIMCMD_Call_NoAnswer:
                [ws onConnFailed];
                break;
            default:
                break;
        }
    }];
}

- (void)startCallTimer
{
    _callTimer = [NSTimer scheduledTimerWithTimeInterval:kCallTimeOut target:self selector:@selector(onConnTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_callTimer forMode:NSRunLoopCommonModes];
}

- (void)stopCallTimer
{
    [_callTimer invalidate];
    _callTimer = nil;
}

- (CallType)getCallType
{
    return _callType;
}

- (void)onConnAccepted
{
    _isWait = NO;
    [self stopCallTimer];
    if (_listener) {
        [_listener onConnAccepted];
    }
}

- (void)onConnTimeout
{
    _isWait = NO;
    [self stopCallTimer];
    
    [[LiveCallPlatform sharedInstance] setChat:NO];
    [[TCICallManager sharedInstance] exitRoom:nil];

    if (_listener) {
        [_listener onConnTimeout];
    }
}

- (void)onConnRejected
{
    _isWait = NO;
    [self stopCallTimer];
    
    [[LiveCallPlatform sharedInstance] setChat:NO];
    [[TCICallManager sharedInstance] exitRoom:nil];
    
    if (_listener) {
        [_listener onConnRejected];
    }
}

- (void)onConnFailed
{
    _isWait = NO;
    [self stopCallTimer];
    
    [[LiveCallPlatform sharedInstance] setChat:NO];
    [[TCICallManager sharedInstance] exitRoom:nil];
    
    if (_listener) {
        [_listener onConnFailed];
    }
}

- (void)onPeerHangup
{
    _isWait = NO;
    [self stopCallTimer];
    
    [[LiveCallPlatform sharedInstance] setChat:NO];
    [[TCICallManager sharedInstance] exitRoom:nil];
    
    if (_listener) {
        [_listener onPeerHangup];
    }
}

@end
