//
//  RecvCallViewModel.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "RecvCallViewModel.h"

@implementation RecvCallViewModel
{
    CallType _callType;
    NSString * _peerId;
    NSTimer * _recvTimer;
    BOOL _isAccepted;
}

- (instancetype)initWithType:(CallType)type peerId:(NSString*)userId
{
    self = [super init];
    if (self) {
        _callType = type;
        _peerId = userId;
        _isAccepted = NO;
        [[LiveCallPlatform sharedInstance] setChat:YES];
        _recvTimer = [NSTimer scheduledTimerWithTimeInterval:kCallTimeOut target:self selector:@selector(onConnTimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_recvTimer forMode:NSRunLoopCommonModes];
    }
    
    return self;
}

- (void)accept
{
    _isAccepted = YES;
    [self registerConnListener];
    
    [[TCICallManager sharedInstance] acceptCall:_callCmd completion:^(BOOL succ, NSError *err, TCILiveRoom *enterRoom) {
        if (!succ) {
            DebugLog(@"accept c2c call faild");
            [self onConnFailed];
        }
        
        DebugLog(@"accept c2c call succ");
        [self onConnSucc];
    } listener:self];
}

- (void)refuse
{
    [[LiveCallPlatform sharedInstance] setChat:NO];
    [[TCICallManager sharedInstance] rejectCallAt:_callCmd completion:nil];
}

- (void)hangup
{
    DebugLog(@"user call hangup");
    [[LiveCallPlatform sharedInstance] setChat:NO];
    [[TCICallManager sharedInstance] endCallCompletion:nil];
}

- (NSString*)getPeer
{
    return _peerId;
}

- (CallType)getCallType
{
    return _callType;
}

- (AVGLBaseView *)createAVGLViewIn:(UIViewController *)vc
{
    return [[TCICallManager sharedInstance] createAVGLViewIn:vc];
}

- (AVGLCustomRenderView *)addRenderFor:(NSString *)uid atFrame:(CGRect)rect
{
    return [[TCICallManager sharedInstance] addRenderFor:uid atFrame:rect];
}

- (AVGLCustomRenderView *)addSelfRender:(CGRect)rect
{
    NSString * identifier = [[TCICallManager sharedInstance] host].identifier;
    return [[TCICallManager sharedInstance] addRenderFor:identifier atFrame:rect];
}

- (BOOL)isAccepted
{
    return _isAccepted;
}

- (void)registerConnListener
{
    __weak typeof(self) ws = self;
    [[TCICallManager sharedInstance] registCallHandle:^(TCICallCMD *callCmd) {
        switch (callCmd.userAction) {
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

- (void)stopTimer
{
    [_recvTimer invalidate];
    _recvTimer = nil;
}

- (void)onConnTimeout
{
    [self stopTimer];
    
    [[LiveCallPlatform sharedInstance] setChat:NO];
    [[TCICallManager sharedInstance] exitRoom:nil];
    
    if (_listener) {
        [_listener onConnTimeout];
    }
}

- (void)onConnFailed
{
    [self stopTimer];
    
    [[LiveCallPlatform sharedInstance] setChat:NO];
    [[TCICallManager sharedInstance] exitRoom:nil];
    
    if (_listener) {
        [_listener onConnFailed];
    }
}

- (void)onPeerHangup
{
    [self stopTimer];
    
    [[LiveCallPlatform sharedInstance] setChat:NO];
    [[TCICallManager sharedInstance] exitRoom:nil];
    
    if (_listener) {
        [_listener onPeerHangup];
    }
}

- (void)onConnSucc
{
    [self stopTimer];
    
    if (_listener) {
        [_listener onConnSucc];
    }
}

@end
