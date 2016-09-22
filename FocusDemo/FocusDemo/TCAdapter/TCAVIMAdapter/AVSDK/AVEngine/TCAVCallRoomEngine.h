//
//  TCAVCallRoomEngine.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVMultiLiveRoomEngine.h"

// 其内部逻辑较TCAVMultiLiveRoomEngine增加
// 1. mic连线控制（最大连mic限制:6路下行，1路上行＋5路下行）
// 2. 概念变化，没有主播，只有发起者。在直播/互动直播场景下，主播退出，表示直播结束。
// 3. 支持C2C模式，多人模式。（C2C模式下，任何一方退出，意味着结束，多人模式下，发起者退出，其他人可以继续）
// 4. 通话过程中会有频繁的camera/mic等操作，其进入房间后的流程变得不一致，相关的计时操作也会有影响

@interface TCAVCallRoomEngine : TCAVMultiLiveRoomEngine
{
@protected
    BOOL                        _isC2CCall;
}

@end
