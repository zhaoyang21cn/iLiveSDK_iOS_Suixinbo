//
//  TCAVCallRoomEngine.m
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVCallRoomEngine.h"

@interface TCAVCallRoomEngine ()
{
@protected
    BOOL    _showFirstFrameLog;
    
}

@end

@implementation TCAVCallRoomEngine

- (instancetype)initWith:(id<IMHostAble, AVUserAble>)host enableChat:(BOOL)enable
{
    if (self = [super initWith:host enableChat:enable])
    {
        _showFirstFrameLog =  ([host avCtrlState] & EAVCtrlState_Camera) == EAVCtrlState_Camera;
    }
    return self;
}


- (UInt64)roomAuthBitMap
{
    // 电话场景中全权限全开
    return QAV_AUTH_BITS_DEFAULT;
}

- (void)onStartFirstFrameTimer
{
    // 不开启首帧计时
}

- (void)checkRequestHostViewFailed
{
    // 因没有主播概念，不需要再请求主播的画面
    // do nothing
    // 不检查
}

- (void)logFirstFrameTime
{
#if kSupportTimeStatistics
    if (_showFirstFrameLog)
    {
        // 不统计首帧画面
        [super logFirstFrameTime];
    }
#endif
}


@end
