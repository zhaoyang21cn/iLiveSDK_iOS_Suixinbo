//
//  FocusDemoViewController.m
//  FocusDemo
//
//  Created by wilderliao on 16/9/18.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "FocusDemoViewController.h"

typedef void(^ChangeFocusSucc)(AVCaptureDevice *captureDevice, CGPoint focusPoint);

@implementation FocusDemoViewController

- (void)addLiveView
{
    FocusDemoUIViewController *vc = [[FocusDemoUIViewController alloc] initWith:self];
    [self addChild:vc inRect:self.view.bounds];
    
    _liveView = vc;
}

- (void)createRoomEngine
{
    if (!_roomEngine)
    {
        id<AVUserAble> ah = (id<AVUserAble>)_currentUser;
        [ah setAvCtrlState:[self defaultAVHostConfig]];
        _roomEngine = [[TCAVMultiLiveRoomEngine alloc] initWith:(id<IMHostAble, AVUserAble>)_currentUser enableChat:NO];
        _roomEngine.delegate = self;
        
        //默认打开后置摄像头，前置摄像头暂不支持聚焦
        TCAVLiveRoomEngine *engine = (TCAVLiveRoomEngine *)_roomEngine;
        engine.cameraId = 1;
        
        if (!_isHost)
        {
            [_liveView setRoomEngine:_roomEngine];
        }
    }
}
@end
