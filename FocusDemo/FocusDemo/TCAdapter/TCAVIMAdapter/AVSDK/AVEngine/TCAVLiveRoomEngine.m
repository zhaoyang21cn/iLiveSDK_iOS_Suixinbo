//
//  TCAVLiveRoomEngine.m
//  TCShow
//
//  Created by AlexiChen on 16/4/11.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVLiveRoomEngine.h"

@interface TCAVLiveRoomEngine ()
{
    
    // Mic重试
    NSInteger   _handleMicTryCount;
    BOOL        _isHandlingMic;
    
    
    // Speaker重试
    NSInteger   _handleSpeakerTryCount;
    BOOL        _isHandlingSpeaker;
    
    
    // 相机重试
    NSInteger   _handleCameraTryCount;
    BOOL        _isHandlingCamera;
    
    
    // 请求主播画面
    NSInteger   _requestHostViewTryCount;
    BOOL        _isRequestingHostView;
    
    
    // 主播最后开启的美颜值
    NSInteger   _lastBeautyValue;
    // 主播最后开启的美白值
    NSInteger   _lastWhiteValue;
}

@end

@implementation TCAVLiveRoomEngine





- (instancetype)initWith:(id<IMHostAble>)host
{
    if (![host conformsToProtocol:@protocol(AVUserAble)])
    {
        NSString *reason = [NSString stringWithFormat:@"[%@ : %p]必须实现AVUserAble协议", [host class], host];
        DebugLog(@"%@", reason);
        NSException *e = [NSException exceptionWithName:@"TCAVLiveRoomEngineHostInVailed" reason:reason userInfo:nil];
        @throw e;
    }
    
    
    if ([super initWith:host])
    {
        _handleMicTryCount = 0;
        _isHandlingMic = NO;
        
        _handleSpeakerTryCount = 0;
        _isHandlingSpeaker = NO;
        
        _handleCameraTryCount = 0;
        _isHandlingCamera = NO;
        
        _requestHostViewTryCount = 0;
        _isRequestingHostView = NO;
        
        _lastBeautyValue = 0;
        _lastWhiteValue = 0;
        
        _cameraId = CameraPosFront;
        _enableChat = YES;
        
        _isSupportBeauty = YES;
    }
    return self;
}

- (instancetype)initWith:(id<IMHostAble, AVUserAble>)host enableChat:(BOOL)enable
{
    if (self = [self initWith:host])
    {
        _enableChat = enable;
    }
    return self;
}

- (void)completion:(TCAVCompletion)completion succ:(BOOL)succ withTag:(TCAVTipTag)tag
{
    NSString *tip = TAVLocalizedError(tag);
    [self completion:completion succ:succ withTip:tip];
}

- (void)completion:(TCAVCompletion)completion succ:(BOOL)succ withTip:(NSString *)tip
{
    DebugLog(@"%@", tip);
    if (completion)
    {
        completion(succ, tip);
    }
}

// 重试前的检查
- (BOOL)beforeTryCheck:(TCAVCompletion)completion;
{
    if (![self isRoomRunning])
    {
        [self completion:completion succ:NO withTag:ETCAVLiveRoomEngine_RoomNotRunning_Tip];
        return NO;
    }
    
    if (!_avContext)
    {
        [self completion:completion succ:NO withTag:ETCAVLiveRoomEngine_AVContextNull_Tip];
        return NO;
    }
    return YES;
}

- (void)asyncEnableMic:(BOOL)enable completion:(TCAVCompletion)completion
{
    [self asyncEnableMic:enable isEnterRoom:NO completion:completion];
}

// 根据本地的状态，作开关摄像头
- (void)asyncSwitchEnableMicCompletion:(TCAVCompletion)completion
{
    BOOL isMic = [self isMicEnable];
    [self asyncEnableMic:!isMic completion:completion];
}

- (void)asyncEnableMic:(BOOL)enable isEnterRoom:(BOOL)ise completion:(TCAVCompletion)completion
{
    if (!_isRoomAlive)
    {
        [self completion:completion succ:NO withTag:ETCAVLiveRoomEngine_RoomNotAlive_Tip];
        return;
    }
    
    if (_isHandlingMic)
    {
        [self completion:completion succ:NO withTag:ETCAVLiveRoomEngine_EnablingMic_Tip];
        return;
    }
    
    id<AVUserAble> ah = (id<AVUserAble>) _IMUser;
    NSInteger state = [ah avCtrlState];
    BOOL tarMic = (state & EAVCtrlState_Mic);
    if (!ise && enable == tarMic)
    {
        NSString *tip = [NSString stringWithFormat:TAVLocalizedError(ETCAVLiveRoomEngine_EnableMicNotTry_Format_Tip), enable ? @"打开" : @"关闭"];
        [self completion:completion succ:NO withTip:tip];
        return;
    }
    
    _isHandlingMic = YES;
    _handleMicTryCount = 0;
    DebugLog(@"开始%@Mic", enable ? @"打开" : @"关闭");
    [self enableMic:enable completion:completion];
}

- (void)enableMic:(BOOL)enable completion:(TCAVCompletion)completion
{
    if ([self beforeTryCheck:completion])
    {
        
#if kAVSDKDefaultOpenMic
        QAVAudioCtrl *ctrl = [_avContext audioCtrl];
        BOOL succ = [ctrl enableMic:enable];
#else
        BOOL succ = YES;
#endif
        if (succ)
        {
            _handleMicTryCount = 0;
            _isHandlingMic = NO;
            if (enable)
            {
                [self enableHostCtrlState:EAVCtrlState_Mic];
            }
            else
            {
                [self disableHostCtrlState:EAVCtrlState_Mic];
            }
            
            TCAVLog(([NSString stringWithFormat:@"*** clogs.%@.%@|%@|SUCCEED|", [self isHostLive] ? @"host" : @"viewer", enable ? @"upShow" : @"unShow", [IMAPlatform sharedInstance].host.imUserId]));
            
            [self completion:completion succ:succ withTip:[NSString stringWithFormat:TAVLocalizedError(ETCAVLiveRoomEngine_EnableMic_Succ_Format_Tip), enable]];


        }
        else
        {
            _handleMicTryCount++;
            if (_handleMicTryCount >= [self enableMicMaxTryCount])
            {
                _handleMicTryCount = 0;
                _isHandlingMic = NO;
                [self completion:completion succ:succ withTip:[NSString stringWithFormat:TAVLocalizedError(ETCAVLiveRoomEngine_EnableMic_Fail_Format_Tip), enable]];
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self enableMic:enable completion:completion];
                });
            }
        }
    }
    else
    {
        _handleMicTryCount = 0;
        _isHandlingMic = NO;
    }
}

- (void)asyncEnableSpeaker:(BOOL)enable completion:(TCAVCompletion)completion
{
    [self asyncEnableSpeaker:enable isEnterRoom:NO completion:completion];
}

- (void)asyncEnableSpeaker:(BOOL)enable isEnterRoom:(BOOL)ise completion:(TCAVCompletion)completion
{
    if (!_isRoomAlive)
    {
        [self completion:completion succ:NO withTag:ETCAVLiveRoomEngine_RoomNotAlive_Tip];
        return;
    }
    
    if (_isHandlingSpeaker)
    {
        [self completion:completion succ:NO withTag:ETCAVLiveRoomEngine_EnablingSpeaker_Tip];
        return;
    }
    
    id<AVUserAble> ah = (id<AVUserAble>) _IMUser;
    NSInteger state = [ah avCtrlState];
    BOOL tarSpeaker = (state & EAVCtrlState_Speaker);
    if (!ise && enable == tarSpeaker)
    {
        NSString *tip = [NSString stringWithFormat:TAVLocalizedError(ETCAVLiveRoomEngine_EnableSpeakerNotTry_Format_Tip), enable ? @"打开" : @"关闭"];
        [self completion:completion succ:NO withTip:tip];
        return;
    }
    
    _isHandlingSpeaker = YES;
    _handleSpeakerTryCount = 0;
    DebugLog(@"开始%@speaker", enable ? @"打开" : @"关闭");
    [self enableSpeaker:enable completion:completion];
}

- (void)enableSpeaker:(BOOL)enable completion:(TCAVCompletion)completion
{
    if ([self beforeTryCheck:completion])
    {
        QAVAudioCtrl *ctrl = [_avContext audioCtrl];
        BOOL succ = [ctrl enableSpeaker:enable];
        if (succ)
        {
            _handleSpeakerTryCount = 0;
            _isHandlingSpeaker = NO;
            if (enable)
            {
                [self enableHostCtrlState:EAVCtrlState_Speaker];
            }
            else
            {
                [self disableHostCtrlState:EAVCtrlState_Speaker];
            }
            [self completion:completion succ:succ withTag:ETCAVLiveRoomEngine_EnableSpeaker_Succ_Tip];
        }
        else
        {
            _handleSpeakerTryCount++;
            if (_handleSpeakerTryCount >= [self enableSpeakerMaxTryCount])
            {
                _handleSpeakerTryCount = 0;
                _isHandlingSpeaker = NO;
                [self completion:completion succ:succ withTag:ETCAVLiveRoomEngine_EnableSpeaker_Fail_Tip];
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self enableSpeaker:enable completion:completion];
                });
            }
        }
    }
    else
    {
        _handleSpeakerTryCount = 0;
        _isHandlingSpeaker = NO;
    }
    
}


- (void)asyncEnableCamera:(BOOL)enable camera:(TCAVEngineCamera)camera
{
    if (!_isRoomAlive)
    {
        DebugLog(@"房间还未创建，请使用enterLive创建成功(enterRoom回调)之后再调此方法");
        return;
    }
    
    if (_isHandlingCamera)
    {
        DebugLog(@"正在处理Camera");
        return;
    }
    _isHandlingCamera = YES;
    _handleCameraTryCount = 0;
    DebugLog(@"开始%@相机", enable ? @"打开" : @"关闭");
    _cameraId = camera;
    [self enableCamera:enable];
}

- (void)asyncSwitchEnableCameraCompletion:(TCAVCompletion)completion
{
    BOOL isCar = [self isCameraEnable];
    [self asyncEnableCamera:!isCar isEnterRoom:NO needNotify:NO completion:completion];
}

- (void)asyncEnableCamera:(BOOL)enable
{
    [self asyncEnableCamera:enable needNotify:YES completion:nil];
}

- (void)asyncEnableCamera:(BOOL)enable completion:(TCAVCompletion)completion
{
    [self asyncEnableCamera:enable needNotify:NO completion:completion];
}

- (void)asyncEnableCamera:(BOOL)enable needNotify:(BOOL)notify
{
    [self asyncEnableCamera:enable needNotify:notify completion:nil];
}

- (void)asyncEnableCamera:(BOOL)enable needNotify:(BOOL)notify completion:(TCAVCompletion)completion
{
    [self asyncEnableCamera:enable isEnterRoom:NO needNotify:notify completion:completion];
}

- (void)asyncEnableCamera:(BOOL)enable isEnterRoom:(BOOL)ise needNotify:(BOOL)notify completion:(TCAVCompletion)completion
{
    if (!_isRoomAlive)
    {
        [self completion:completion succ:NO withTag:ETCAVLiveRoomEngine_RoomNotAlive_Tip];
        return;
    }
    
    if (_isHandlingCamera)
    {
        [self completion:completion succ:NO withTag:ETCAVLiveRoomEngine_EnablingCamera_Tip];
        return;
    }
    
    id<AVUserAble> ah = (id<AVUserAble>) _IMUser;
    NSInteger state = [ah avCtrlState];
    BOOL tarCar = (state & EAVCtrlState_Camera);
    if (!ise && enable == tarCar)
    {
        NSString *tip = [NSString stringWithFormat:TAVLocalizedError(ETCAVLiveRoomEngine_EnableCameraNotTry_Format_Tip), enable ? @"打开" : @"关闭"];
        [self completion:completion succ:NO withTip:tip];
        return;
    }
    
    _isHandlingCamera = YES;
    _handleCameraTryCount = 0;
    DebugLog(@"开始%@相机", enable ? @"打开" : @"关闭");
    [self enableCamera:enable needNotify:notify completion:completion];
}

- (void)enableCamera:(BOOL)enable
{
    [self enableCamera:enable needNotify:YES completion:nil];
}

- (void)enableCamera:(BOOL)enable needNotify:(BOOL)notify completion:(TCAVCompletion)completion
{
    if ([self beforeTryCheck:nil])
    {
        [self enableCamera:enable needTry:YES needNotify:notify completion:completion];
    }
    else
    {
        // 重置参数
        [self onEnableCameraComplete:_cameraId enable:enable result:QAV_ERR_FAILED needNotify:notify completion:completion];
        _handleCameraTryCount = 0;
        _isHandlingCamera = NO;
    }
}

- (void)enableCamera:(BOOL)enable needTry:(BOOL)needTry needNotify:(BOOL)notify completion:(TCAVCompletion)completion
{
    QAVVideoCtrl *videoCtrl = [_avContext videoCtrl];
    if(videoCtrl)
    {
        __weak TCAVLiveRoomEngine *ws = self;
        int camerid = _cameraId;
        QAVResult result = [videoCtrl enableCamera:_cameraId isEnable:enable complete:^(int result) {
            if (needTry)
            {
                if (result == QAV_OK)
                {
                    // 操作成功
                    TCAVLog(([NSString stringWithFormat:@" *** clogs.open.camera |SUCCEED|"]));
                    [ws onEnableCameraComplete:camerid enable:enable result:result needNotify:notify completion:completion];
                }
                else
                {
                    if (result == QAV_ERR_HAS_IN_THE_STATE)
                    {
                        // 已是重复状态不处理
                        [ws onEnableCameraComplete:camerid enable:enable result:QAV_OK needNotify:notify completion:completion];
                    }
                    else
                    {
                        // 打开相机重试
                        [ws tryEnableCamera:enable needNotify:notify completion:completion];
                    }
                }
            }
            else
            {
                [ws onEnableCameraComplete:camerid enable:enable result:result needNotify:notify completion:completion];
            }
        }];
        if (result != QAV_OK)
        {
            DebugLog(@"videoCtrl enableCamera : %d ", (int)result);
            if (result == QAV_ERR_EXCLUSIVE_OPERATION)
            {
                // 互斥操作时，不会走回调
                [ws onEnableCameraComplete:camerid enable:enable result:result needNotify:notify completion:completion];
            }

        }
    }
    else
    {
        if (needTry)
        {
            // 视频源未获取到，重试
            [self tryEnableCamera:enable needNotify:notify completion:completion];
        }
        else
        {
            [self onEnableCameraComplete:_cameraId enable:enable result:QAV_ERR_FAILED needNotify:notify completion:completion];
        }
    }
}

- (void)tryEnableCamera:(BOOL)enable needNotify:(BOOL)notify completion:(TCAVCompletion)completion
{
    _handleCameraTryCount++;
    if (_handleCameraTryCount >= [self enableCameraMaxTryCount])
    {
        [self onEnableCameraComplete:_cameraId enable:enable result:QAV_ERR_FAILED needNotify:notify completion:completion];
    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self enableCamera:enable needNotify:notify completion:completion];
        });
    }
}


- (void)asyncSwitchCameraWithCompletion:(TCAVCompletion)completion
{
    if (!_isRoomAlive)
    {
        [self completion:completion succ:NO withTag:ETCAVLiveRoomEngine_RoomNotAlive_Tip];
        return;
    }
    
    if (_isHandlingCamera)
    {
        [self completion:completion succ:NO withTag:ETCAVLiveRoomEngine_EnablingCamera_Tip];
        return;
    }
    
    if (![self isCameraEnable])
    {
        // 相机未打开情况下，后置摄像头，直接switch切换不到前置，
        [self completion:completion succ:NO withTag:ETCAVLiveRoomEngine_SwitchCamera_NotOn_Tip];
        return;
    }
    
    
    _isHandlingCamera = YES;
    _handleCameraTryCount = 0;
    
    if(CameraPosFront == _cameraId)
    {
        _cameraId = CameraPosBack;
    }
    else
    {
        _cameraId = CameraPosFront;
    }
    DebugLog(@"开始切换相机摄像头");
    [self switchCameraWithCompletion:completion];
}

- (void)switchCameraWithCompletion:(TCAVCompletion)completion
{
    if ([self beforeTryCheck:completion])
    {
        QAVVideoCtrl *avvc = [_avContext videoCtrl];
        if (avvc)
        {
            TCAVEngineCamera camera = _cameraId;
            __weak TCAVLiveRoomEngine *ws = self;
            QAVResult res = [avvc switchCamera:camera complete:^(int result) {
                if (QAV_OK == result)
                {
                    [ws onSwitchCameraComplete:camera result:result completion:completion];
                }
                else
                {
                    if (result == QAV_ERR_HAS_IN_THE_STATE)
                    {
                        // 已是重复状态不处理
                        [ws onSwitchCameraComplete:_cameraId result:QAV_OK completion:completion];
                    }
                    else
                    {
                        [ws trySwitchCameraWith:completion];
                    }
                    
                }
            }];
            
            if (res != QAV_OK)
            {
                if (res == QAV_ERR_EXCLUSIVE_OPERATION)
                {
                    //  互斥操作时是会走回调
                    // 重置参数
                    [self onSwitchCameraComplete:_cameraId result:QAV_ERR_FAILED completion:completion];
                }
                
            }
        }
        else
        {
            [self trySwitchCameraWith:completion];
        }
    }
    else
    {
        // 重置参数
        [self onSwitchCameraComplete:_cameraId result:QAV_ERR_FAILED completion:completion];
    }
    
}

- (void)trySwitchCameraWith:(TCAVCompletion)completion
{
    _handleCameraTryCount++;
    if (_handleCameraTryCount >= [self enableCameraMaxTryCount])
    {
        [self onSwitchCameraComplete:_cameraId result:QAV_ERR_FAILED completion:completion];
    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self switchCameraWithCompletion:completion];
        });
    }
}

- (void)onRoomEnterForeground
{
    [super onRoomEnterForeground];
    
    if (_isRoomAlive && _hasEnableCameraBeforeEnterBackground)
    {
        DebugLog(@"进入前台开相机");
        // 到前台的时候打开摄像头，但不需要通知到处面
        [self asyncEnableCamera:YES needNotify:NO];
    }
    
    if ([self checkAppSupportBackgroundMode] && _isRoomAlive && _hasEnableMicBeforeEnterBackground)
    {
        // 有后台模式时，开mic
        // 无后台模式，系统自动开
        DebugLog(@"进入前台开mic");
        [self asyncEnableMic:YES completion:nil];
    }
    
}
- (void)onRoomEnterBackground
{
    if (!_hasEnableCameraBeforeEnterBackground)
    {
        _hasEnableCameraBeforeEnterBackground = [self isCameraEnable];
    }
    if (_hasEnableCameraBeforeEnterBackground && _isRoomAlive)
    {
        DebugLog(@"退到后台关相机");
        // 到前台的时候打开摄像头，但不需要通知到处面
        [self enableCamera:NO needTry:NO needNotify:NO completion:nil];
    }
    
    if (!_hasEnableMicBeforeEnterBackground)
    {
        _hasEnableMicBeforeEnterBackground = [self isMicEnable];
    }
    if (_hasEnableMicBeforeEnterBackground && [self checkAppSupportBackgroundMode] && _isRoomAlive)
    {
        // 有后台模式时，关mic
        // 无后台模式，系统自动关
        DebugLog(@"进入关开mic");
        [self asyncEnableMic:NO completion:nil];
    }
    
    [super onRoomEnterBackground];
}


// 异步请求主播画面
- (void)asyncRequestHostView
{
    if ([self isHostLive])
    {
        DebugLog(@"此方法只能在观众端调用");
        return;
    }
    
    if (!_isRoomAlive)
    {
        DebugLog(@"房间还未创建，请使用enterLive创建成功(enterRoom回调)之后再调此方法");
        return;
    }
    
    if (_isRequestingHostView)
    {
        DebugLog(@"正在请求主播画面");
        return;
    }
    
    if (_hasRecvSemiAutoCamera)
    {
        DebugLog(@"已收到服务器自动推送的主播视频，不需要再重新请求主播画面");
        return;
    }
    
    _isRequestingHostView = YES;
    _requestHostViewTryCount = 0;
    
    
    [self requestHostView];
}

- (void)requestHostView
{
    if (_avContext)
    {
        __weak TCAVLiveRoomEngine *ws = self;
        NSString *hostId = [[_roomInfo liveHost] imUserId];
        DebugLog(@"[%@][%@] 开始请求[%@]画面", [self class], [_IMUser imUserId] , hostId);
        
        int res = [_avContext.room requestViewList:@[hostId] srcTypeList:@[@(QAVVIDEO_SRC_TYPE_CAMERA)] ret:^(QAVResult result) {
            if (QAV_OK == result)
            {
                [ws onRequestViewCompleteResult:result];
            }
            else
            {
                _requestHostViewTryCount++;
                if (_requestHostViewTryCount >= [ws requestHostViewMaxTryCount])
                {
                    [ws onRequestViewCompleteResult:QAV_ERR_FAILED];
                }
                else
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [ws requestHostView];
                    });
                }
                
            }
        }];
        
        //        int res = [QAVEndpoint requestViewList:_avContext identifierList:@[hostId] srcTypeList:@[@(QAVVIDEO_SRC_TYPE_CAMERA)] ret:^(QAVResult result) {
        //            if (QAV_OK == result)
        //            {
        //                [ws onRequestViewCompleteResult:result];
        //            }
        //            else
        //            {
        //                _requestHostViewTryCount++;
        //                if (_requestHostViewTryCount >= [ws requestHostViewMaxTryCount])
        //                {
        //                    [ws onRequestViewCompleteResult:QAV_ERR_FAILED];
        //                }
        //                else
        //                {
        //                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //                        [ws requestHostView];
        //                    });
        //                }
        //
        //            }
        //        }];
        if (res != QAV_OK)
        {
            DebugLog(@"QAVEndpoint requestViewList 直接返回: %d", res);
        }
    }
    else
    {
        TCAVIMLog(@"请求画面失败, _avContext为空");
        [self onRequestViewCompleteResult:QAV_ERR_FAILED];
    }
    
    
}

- (void)onRequestViewCompleteResult:(int)result
{
    DebugLog(@"请求主播画面重试次数：%d", (int)_requestHostViewTryCount);
    
    
    _requestHostViewTryCount = 0;
    _isRequestingHostView = NO;
    
    BOOL succ = result == QAV_OK;
    if (succ)
    {
        [self startFirstFrameTimer];
    }
    
    NSString *tip = succ ? TAVLocalizedError(ETCAVLiveRoomEngine_RequestHostView_Succ_Tip) : TAVLocalizedError(ETCAVLiveRoomEngine_RequestHostView_Fail_Tip);
    [_delegate onAVEngine:self requestViewOf:_IMUser succ:succ tipInfo:tip];
}

- (void)enterLive:(id<AVRoomAble>)room
{
    if (!room)
    {
        DebugLog(@"room不能为空");
        return;
    }
    _roomInfo = room;
    if (_enableChat)
    {
        [self enterIMLiveChatRoom:room];
    }
    else
    {
        [super enterLive:room];
    }
}




- (void)exitLive
{
#if kSupportTimeStatistics
    [self onWillExitLive];
#endif
    
    if ([self needExitIMChatRoom])
    {
        [[IMAPlatform sharedInstance] asyncExitAVChatRoom:_roomInfo succ:nil fail:nil];
    }
    _enableChat = NO;
    
#if kSupportAudioTransmission
    
    [self stopAudioTransmission];
#endif
    
    if ([IMAPlatform sharedInstance].isConnected)
    {
        //
        [self onAsyncStopPushStreamOnExitRoom:^(BOOL succ, NSString *tip) {
            
            [self onAsyncStopRecordOnExitRoom:^(BOOL succ, TCAVLiveRoomRecordRequest *req) {
                [super exitLive];
            }];
            
        }];
    }
    else
    {
        [super exitLive];
    }
    
}

- (void)turnOnFlash:(BOOL)on
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch])
    {
        [device lockForConfiguration:nil];
        [device setTorchMode: on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
        
    }
}

// 是否支持美颜
- (BOOL)isSupporBeauty
{
    return _isSupportBeauty && _isRoomAlive && [self isHostLive];
}

// 支持美颜的情况下，返回具体的值[0-9]
// 否则返回0
- (NSInteger)getBeauty
{
    if (![self isSupporBeauty])
    {
        return 0;
    }
    
    return _lastBeautyValue;
    
}

// 支持美颜的情况下才可以设置
- (void)enableBeauty:(NSInteger)beauty
{
    DebugLog(@"开始设置美颜");
    // 此处有潜在问题
    QAVVideoCtrl *videoCtrl = _avContext.videoCtrl;
    if (videoCtrl)
    {
        _isEnableBeauty = YES; //[videoCtrl enableBeauty:YES];
        
        if (_isEnableBeauty)
        {
            _lastBeautyValue = beauty;
            [videoCtrl inputBeautyParam:_lastBeautyValue];
            DebugLog(@"开启美颜成功，并设置美颜值为：%d", (int)_lastBeautyValue);
            [self enableHostCtrlState:EAVCtrlState_Beauty];
        }
        else
        {
            DebugLog(@"开启美颜失败");
            [self disableHostCtrlState:EAVCtrlState_Beauty];
        }
    }
}


// 支持美颜的情况下，设置美美颜值[0-9]
- (void)setBeauty:(NSInteger)beauty
{
    if (_lastBeautyValue == beauty)
    {
        // 已经是一致了，不需要得新设置
        return;
    }
    
    if (![self isSupporBeauty])
    {
        
        // do nothing
        DebugLog(@"当前不支持美颜功能");
        return;
    }
    
    if (!_isEnableBeauty)
    {
        [self enableBeauty:beauty];
        return;
    }
    
    
    [self setBeautyOnEnable:beauty];
    
}


// 是否支持美白
- (BOOL)isSupporWhite
{
    return [self isSupporBeauty];
}

// 支持美颜的情况下，返回具体的值[0-9]
// 否则返回0
- (NSInteger)getWhite
{
    if (![self isSupporWhite])
    {
        return 0;
    }
    
    return _lastWhiteValue;
    
}

// 支持美颜的情况下才可以设置
- (void)enableWhite:(NSInteger)white
{
    DebugLog(@"开始设置美颜");
    // 此处有潜在问题
    QAVVideoCtrl *videoCtrl = _avContext.videoCtrl;
    if (videoCtrl)
    {
        _isEnableWhite = YES; //[videoCtrl enableBeauty:YES];
        
        if (_isEnableWhite)
        {
            _lastWhiteValue = white;
            [videoCtrl inputWhiteningParam:_lastWhiteValue];
            DebugLog(@"开启美白成功，并设置美白值为：%d", (int)_lastWhiteValue);
            [self enableHostCtrlState:EAVCtrlState_White];
        }
        else
        {
            DebugLog(@"开启白失败");
            [self disableHostCtrlState:EAVCtrlState_White];
        }
    }
}


// 支持美颜的情况下，设置美美颜值[0-9]
- (void)setWhite:(NSInteger)white
{
    if (_lastWhiteValue == white)
    {
        // 已经是一致了，不需要得新设置
        return;
    }
    
    if (![self isSupporWhite])
    {
        
        // do nothing
        DebugLog(@"当前不支持美白功能");
        return;
    }
    
    if (!_isEnableWhite)
    {
        [self enableWhite:white];
        return;
    }
    
    
    [self setWhiteOnEnable:white];
    
}

// 在支持美颜的情况下设置
- (void)setBeautyOnEnable:(NSInteger)beauty
{
    if (beauty > 9)
    {
        beauty = 9;
    }
    else if (beauty < 0)
    {
        beauty = 0;
    }
    
    if (_avContext && _avContext.videoCtrl)
    {
        _lastBeautyValue = beauty;
        [_avContext.videoCtrl inputBeautyParam:beauty];
    }
    else
    {
        DebugLog(@"_avContext 或 _avContext.videoCtrl 为空，无法设置美颜值");
    }
}

// 在支持美颜的情况下设置
- (void)setWhiteOnEnable:(NSInteger)white
{
    if (white > 9)
    {
        white = 9;
    }
    else if (white < 0)
    {
        white = 0;
    }
    
    if (_avContext && _avContext.videoCtrl)
    {
        _lastWhiteValue = white;
        [_avContext.videoCtrl inputWhiteningParam:white];
    }
    else
    {
        DebugLog(@"_avContext 或 _avContext.videoCtrl 为空，无法设置美白值");
    }
}

- (NSInteger)getHostCtrlState
{
    if (!_isRoomAlive)
    {
        return 0;
    }
    id<AVUserAble> ah = (id<AVUserAble>) _IMUser;
    NSInteger state = [ah avCtrlState];
    return state;
}

// 查控直播控件的状态，进入房间后才能查到，未进入房间时返回NO
// Mic是否开启
- (BOOL)isMicEnable
{
    NSInteger state = [self getHostCtrlState];
    
    return state & EAVCtrlState_Mic;
}

// 是否开启扬声器
- (BOOL)isSpeakerEnable
{
    NSInteger state = [self getHostCtrlState];
    return state & EAVCtrlState_Speaker;
}

// 是否开启相机
- (BOOL)isCameraEnable
{
    NSInteger state = [self getHostCtrlState];
    return state & EAVCtrlState_Camera;
}

- (void)OnEndpointsUpdateInfo:(QAVUpdateEvent)eventID endpointlist:(NSArray *)endpoints
{
    [super OnEndpointsUpdateInfo:eventID endpointlist:endpoints];
    
    if (eventID == QAV_EVENT_ID_ENDPOINT_HAS_CAMERA_VIDEO)
    {
        [self requestViewOfHostOnAVSDKCallBack:endpoints];
    }
    
}



@end


@implementation TCAVLiveRoomEngine (ProtectedMethod)

// 默认使用的美颜值
- (NSInteger)defaultBeautyValue
{
    return 5;
}

- (NSInteger)defaultWhiteValue
{
    return 5;
}

- (BOOL)needExitIMChatRoom
{
    return YES;
}
- (NSInteger)enableMicMaxTryCount
{
    return 5;
}

- (NSInteger)enableSpeakerMaxTryCount
{
    return 5;
}

- (NSInteger)enableCameraMaxTryCount
{
    return 5;
}

// 请求主播画面最大重试次数
- (NSInteger)requestHostViewMaxTryCount
{
    return 5;
}

- (QAVMultiParam *)createdAVRoomParam
{
    QAVMultiParam *param = [[QAVMultiParam alloc] init];
    param.relationId = [_roomInfo liveAVRoomId];
    param.audioCategory = [self roomAudioCategory];
    param.controlRole = [self roomControlRole];
    param.authBits = [self roomAuthBitMap];
    param.createRoom = [self isHostLive];
    param.videoRecvMode = VIDEO_RECV_MODE_SEMI_AUTO_RECV_CAMERA_VIDEO;
    NSInteger avcs = [(id<AVUserAble>)_IMUser avCtrlState];
#if kAVSDKDefaultOpenMic
    param.enableMic = (avcs & EAVCtrlState_Mic) == EAVCtrlState_Mic;
#else
    param.enableMic = NO;
#endif
    param.enableSpeaker = (avcs & EAVCtrlState_Speaker) == EAVCtrlState_Speaker;
    param.enableHdAudio = (avcs & EAVCtrlState_HDAudio) == EAVCtrlState_HDAudio;
    param.autoRotateVideo = (avcs & EAVCtrlState_AutoRotateVideo) == EAVCtrlState_AutoRotateVideo;
    return param;
}

// 进入AVRoom成功之后要进行的操作
- (void)onEnterAVRoomSucc
{
    [super onEnterAVRoomSucc];
    
    TCAVIMLog(@"进入AVRoom成功");
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        return;
    }
    
    //设置麦克风和扬声器（在进入房间设置才有效）
    QAVVideoCtrl *ctrl = [_avContext videoCtrl];
    if (ctrl)
    {
        [ctrl setLocalVideoDelegate:self];
        [ctrl setRemoteVideoDelegate:self];
    }
    
    id<AVUserAble> ah = (id<AVUserAble>) _IMUser;
    
    // AVSDK默认开Speaker，关Mic，关Camera
    NSInteger state = [ah avCtrlState];
    
    // ===================================================
    // 因1.8.2将进入房间时的mic以及speaker的控制改进房间前进行控制，TCAdapter在进房间后不用再控制
    //    if (!((state & EAVCtrlState_Speaker) == EAVCtrlState_Speaker))
    //    {
    //        // AVSDK默认开扬声器，如果进入设置不打开，则需要手动关掉
    //        [self asyncEnableSpeaker:NO isEnterRoom:YES completion:nil];
    //    }
    //    else
    //    {
    //        [self enableHostCtrlState:EAVCtrlState_Speaker];
    //    }
    //
    //
    //    _hasEnableMicBeforeEnterBackground = ((state & EAVCtrlState_Mic) == EAVCtrlState_Mic);
    //    if (_hasEnableMicBeforeEnterBackground)
    //    {
    //        // 打开麦克风
    //        [self asyncEnableMic:YES isEnterRoom:YES completion:nil];
    //    }
    //    else
    //    {
    //        // AVSDK默认关mic
    //        [self disableHostCtrlState:EAVCtrlState_Mic];
    //    }
    // ===================================================
    
    if (state & EAVCtrlState_Camera)
    {
        // 开相机操作是异步，AVSDK默认不开，所以不像上面的写法
        // 开启相机
        // 此处记录，防止进直播后，马上退后台或进其他应用，导致相机无法开启成功
        if ([self isHostLive])
        {
            _hasEnableCameraBeforeEnterBackground = YES;
        }
        [self asyncEnableCamera:YES isEnterRoom:YES needNotify:YES completion:nil];
    }
#if kSupportTimeStatistics
    else
    {
        [self disableHostCtrlState:EAVCtrlState_Camera];
        // 不开相计时，不作首帧计时
        _hasShowLocalFirstFrame = YES;
    }
#endif
    
    [self onEnterRoomCheckPush];
    
    [self onEnterRoomCheckRecord];
    
}

- (void)onSwitchCameraComplete:(int)cameraid result:(int)result completion:(TCAVCompletion)completion
{
    _handleCameraTryCount = 0;
    _isHandlingCamera = NO;
    
    BOOL succ = result == QAV_OK;
    NSString *tip = succ ? TAVLocalizedError(ETCAVLiveRoomEngine_SwitchCamera_Succ_Tip) : TAVLocalizedError(ETCAVLiveRoomEngine_SwitchCamera_Fail_Tip);
    DebugLog(@"%@", tip);
    
    if (completion)
    {
        completion(succ, tip);
    }
    
    if (!succ)
    {
        // 退回到先前使用的摄像头
        if(CameraPosFront == _cameraId)
        {
            _cameraId = CameraPosBack;
        }
        else
        {
            _cameraId = CameraPosFront;
        }
    }
    else
    {
        // 关闭状态下，可以直接打开摄像头
        [self enableHostCtrlState:EAVCtrlState_Camera];
    }
}


- (void)onEnableCameraComplete:(int)cameraid enable:(BOOL)enable result:(int)result needNotify:(BOOL)needNotify completion:(TCAVCompletion)completion
{
    DebugLog(@"操作摄像头(0为成功):%d，重试了%d次", result, (int)_handleCameraTryCount);
    
    _handleCameraTryCount = 0;
    _isHandlingCamera = NO;
    
    
    BOOL succ = result == QAV_OK;
    if (succ)
    {
        QAVVideoCtrl *videoCtrl = _avContext.videoCtrl;
        _isSupportBeauty = [videoCtrl isEnableBeauty];
        // 开摄像头时，才支持
        id<AVUserAble> ah = (id<AVUserAble>) _IMUser;
        NSInteger state = [ah avCtrlState];
        
        if (enable && _isSupportBeauty && videoCtrl)
        {
            BOOL eb = ((state & EAVCtrlState_Beauty) == EAVCtrlState_Beauty);
            BOOL ew = ((state & EAVCtrlState_White) == EAVCtrlState_White);
            
            if (eb || ew)
            {
                // 立即设置容易失效
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (eb)
                    {
                        [self enableBeauty:[self defaultBeautyValue]];
                    }
                    if (ew)
                    {
                        [self enableWhite:[self defaultWhiteValue]];
                    }
                });
            }
        }
        
        if (enable)
        {
            [self enableHostCtrlState:EAVCtrlState_Camera];
        }
        else
        {
            [self disableHostCtrlState:EAVCtrlState_Camera];
        }
    }
    
    
    NSString *returnTip = [NSString stringWithFormat:TAVLocalizedError(ETCAVLiveRoomEngine_EnableCamera_Format_Tip), enable ? @"打开" : @"关闭", succ ? @"成功" : @"失败"];
    DebugLog(@"enableCamera %@", returnTip);
    if (needNotify)
    {
#if kSupportTimeStatistics
        if (_logStartDate)
        {
            NSDate *date = [NSDate date];
            TCAVIMLog(@"%@ 从进房:%@ 到将相机%@时间:%@ 总耗时间:%0.3f (s)", [self isHostLive] ? @"主播" : @"观众",  [kTCAVIMLogDateFormatter stringFromDate:_logStartDate], enable ? @"打开" : @"关闭",[kTCAVIMLogDateFormatter stringFromDate:date] , -[_logStartDate timeIntervalSinceDate:date]);
        }
#endif
        
        if (_delegate && [_delegate respondsToSelector:@selector(onAVEngine:enableCamera:tipInfo:)])
        {
            [_delegate onAVEngine:self enableCamera:succ tipInfo:returnTip];
        }
    }
    
    if (completion)
    {
        completion(succ, returnTip);
    }
}


- (void)onContextCloseComplete:(NSString *)tip
{
    if (_enableChat &&  [self needExitIMChatRoom])
    {
        [[IMAPlatform sharedInstance] asyncExitAVChatRoom:_roomInfo succ:nil fail:nil];
    }
    [super onContextCloseComplete:tip];
}

- (void)requestViewOfHostOnAVSDKCallBack:(NSArray *)endpoints
{
    // 非主播才去进行请求
    if (![self isHostLive])
    {
        // 找到主播的ID
        for (id<AVUserAble> ep in endpoints)
        {
            if ([[ep imUserId] isEqualToString:[_IMUser imUserId]])
            {
                [self asyncRequestHostView];
                break;
            }
        }
    }
}


- (void)enterIMLiveChatRoom:(id<AVRoomAble>)room
{
#if kSupportTimeStatistics
    [self onWillEnterLive];
#endif
    
    __weak TCAVLiveRoomEngine *ws = self;
    __weak id<TCAVRoomEngineDelegate> wd = _delegate;
    __weak id<AVRoomAble> wr = room;
    
    BOOL isHost = [self isHostLive];
#if kSupportTimeStatistics
    __weak NSDate *wl = _logStartDate;
#endif
    [[IMAPlatform sharedInstance] asyncEnterAVChatRoom:room succ:^(id<AVRoomAble> room) {
        
#if kSupportTimeStatistics
        NSDate *date = [NSDate date];
        TCAVIMLog(@"%@ 从进房到进入IM聊天室（%@）: 开始进房时间:%@ 创建聊天室完成时间:%@ 总耗时 :%0.3f (s)", isHost ? @"主播" : @"观众", [room liveIMChatRoomId] , [kTCAVIMLogDateFormatter stringFromDate:wl], [kTCAVIMLogDateFormatter stringFromDate:date] , -[wl timeIntervalSinceDate:date]);
#endif
        [super onRealEnterLive:room];
    } fail:^(int code, NSString *msg) {
        
        NSString *tip = isHost ? TAVLocalizedError(ETCAVLiveRoomEngine_HostEnterIMChatRoom_Succ_Tip) : TAVLocalizedError(ETCAVLiveRoomEngine_GuestEnterIMChatRoom_Fail_Tip);
        DebugLog(@"%@", tip);
        [wd onAVEngine:ws enterRoom:wr succ:NO tipInfo:tip];
    }];
}

- (void)enableHostCtrlState:(AVCtrlState)bitState
{
    id<AVUserAble> ah = (id<AVUserAble>) _IMUser;
    NSInteger state = [ah avCtrlState];
    NSInteger nstate = state | bitState;
    if (nstate != state)
    {
        [ah setAvCtrlState:nstate];
    }
    DebugLog(@"Host Ctrl State : %p state = %d", _IMUser, (int)[ah avCtrlState]);
}
- (void)disableHostCtrlState:(AVCtrlState)bitState
{
    id<AVUserAble> ah = (id<AVUserAble>) _IMUser;
    NSInteger state = [ah avCtrlState];
    NSInteger nstate = state & ~bitState;
    if (nstate != state)
    {
        [ah setAvCtrlState:nstate];
    }
    DebugLog(@"Host Ctrl State : %p state = %d", _IMUser, (int)[ah avCtrlState]);
}

- (UInt64)roomAuthBitMap
{
    if ([self isHostLive])
    {
        // 主播权限全开
        return QAV_AUTH_BITS_DEFAULT;
    }
    else
    {
        // 观众只开接收权限
        return QAV_AUTH_BITS_JOIN_ROOM | QAV_AUTH_BITS_RECV_AUDIO | QAV_AUTH_BITS_RECV_VIDEO | QAV_AUTH_BITS_RECV_SUB;
    }
}

@end
