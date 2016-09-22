//
//  TCAVBaseRoomEngine.m
//  TCShow
//
//  Created by AlexiChen on 16/4/11.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVBaseRoomEngine.h"


@implementation TCAVBaseRoomEngine


- (void)dealloc
{
    DebugLog(@"======>>>>> [%@] %@ 释放成功 <<<<======", [self class], self);
#if kIsUseAVSDKAsLiveScene
#else
    [_avContext destroy];
#endif
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)initWith:(id<IMHostAble>)host
{
    if (!host)
    {
        DebugLog(@"host 信息不能为空");
        NSException *e = [NSException exceptionWithName:@"参数错误" reason:@"host信息不能为空" userInfo:nil];
        @throw e;
    }
    
    if(self = [super init])
    {
        _isAtForeground = YES;
        
#if kIsUseAVSDKAsLiveScene
        //
        QAVContext *context = [TCAVSharedContext sharedContext];
        DebugLog(@"=====>>>>>使用的QAVContext = %p", context);
        if (context)
        {
            _avContext = context;
            _isUseSharedContext = YES;
        }
        else
#endif
        {
            //            QAVContextConfig *config = [[QAVContextConfig alloc] init];
            //
            //            NSString *appid = [host imSDKAppId];
            //
            //            config.sdk_app_id = appid;
            //            config.app_id_at3rd = appid;
            //            config.identifier = [host imUserId];
            //            config.account_type = [host imSDKAccountType];
            _avContext = [QAVContext CreateContext];
        }
        
        
        
        _IMUser = host;
        
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    return self;
}

- (id<AVRoomAble>)getRoomInfo
{
    return _roomInfo;
}

- (id<IMHostAble>)getIMUser
{
    return _IMUser;
}

- (BOOL)isHostLive
{
    return [[_IMUser imUserId] isEqualToString:[[_roomInfo liveHost] imUserId]];
}

// 开始直播
- (void)enterLive:(id<AVRoomAble>)room
{
#if kSupportTimeStatistics
    [self onWillEnterLive];
#endif
    [self onRealEnterLive:room];
}


- (BOOL)switchToLive:(id<AVRoomAble>)room
{
    if (!_isRoomAlive)
    {
        DebugLog(@"上一次的房间还未进入成功，不能进行切换房间");
        return NO;
    }
    
    if (room == nil)
    {
        DebugLog(@"要切换的房间为空");
        return NO;
    }
    
    if ([room liveAVRoomId] == [_roomInfo liveAVRoomId])
    {
        DebugLog(@"要切换的房间与当前的房间一致，不用切换");
        return NO;
    }
    
    [self stopFirstFrameTimer];
    _switchingToRoom = room;
    [self exitLive];
    return YES;
    
}

- (void)onExitRoomCompleteToSwitchToLive
{
    if (_switchingToRoom)
    {
        _isAtForeground = YES;
        _hasRecvSemiAutoCamera = NO;
        [self stopFirstFrameTimer];
        _hasStatisticFirstFrame = NO;
        
        
#if kSupportTimeStatistics
        // 用于进出房间时间统计
        _logStartDate = nil;
        _hasShowLocalFirstFrame = NO;
        _hasSemiAutoCameraVideo = NO;
#endif
        _hasShowFirstRemoteFrame = NO;
        
        DebugLog(@"开始从房间［%@, %d］切换房间［%@, %d］", [_roomInfo liveTitle], [_roomInfo liveAVRoomId], [_switchingToRoom liveTitle], [_switchingToRoom liveAVRoomId]);
        [[HUDHelper sharedInstance] syncLoading:TAVLocalizedError(ETCAVBaseRoomEngine_SwitchRoom_Tip)];
        [self enterLive:_switchingToRoom];
    }
    else
    {
        [_delegate onAVEngine:self exitRoom:_roomInfo succ:YES tipInfo:TAVLocalizedError(ETCAVBaseRoomEngine_ExitRoom_Succ_Tip)];
    }
}

// 停止直播
- (void)exitLive
{
    [self stopFirstFrameTimer];
    
    if (!_isRoomAlive)
    {
        if (_switchingToRoom)
        {
            [self onExitRoomCompleteToSwitchToLive];
        }
        else
        {
            // 都没进房间过，直接返回退出成功
            [_delegate onAVEngine:self exitRoom:_roomInfo succ:YES tipInfo:TAVLocalizedError(ETCAVBaseRoomEngine_ExitRoom_Succ_Tip)];
        }
        return;
    }
    
    if (!_switchingToRoom)
    {
        _isRoomAlive = NO;
    }
    
    if (!_avContext)
    {
        if (_switchingToRoom)
        {
            [self onExitRoomCompleteToSwitchToLive];
        }
        else
        {
            DebugLog(@"avContext已销毁");
            [_delegate onAVEngine:self exitRoom:_roomInfo succ:YES tipInfo:TAVLocalizedError(ETCAVBaseRoomEngine_ExitRoom_Succ_Tip)];
        }
        return;
    }
#if kSupportTimeStatistics
    if (!_logStartDate)
    {
        [self onWillExitLive];
    }
    TCAVIMLog(@"%@ 开始退出直播:%@", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate]);
#else
    DebugLog(@"开始退出直播");
#endif
    QAVVideoCtrl *ctrl = [_avContext videoCtrl];
    [ctrl setLocalVideoDelegate:nil];
    [ctrl setRemoteVideoDelegate:nil];
    [_avContext exitRoom];
}

- (BOOL)isRoomRunning
{
    return _isRoomAlive && _isAtForeground;
}

- (BOOL)isRoomAlive
{
    return _isRoomAlive;
}

- (BOOL)isFrontCamera
{
    return [_avContext.videoCtrl isFrontcamera];
}

- (void)creatAVRoom
{
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        return;
    }
    
    QAVMultiParam *param = [self createdAVRoomParam];
    
    if ([[IMAPlatform sharedInstance] isConnected])
    {
        // 检查当前网络
        QAVResult result = [_avContext enterRoom:param delegate:self];
        
        if(QAV_OK != result)
        {
            TCAVIMLog(@"进入AVRoom出错:%d", (int)result);
            __weak TCAVBaseRoomEngine *ws = self;
#if kIsUseAVSDKAsLiveScene
            [ws onContextCloseComplete:TAVLocalizedError(ETCAVBaseRoomEngine_EnterRoom_Fail_Tip)];
#else
            [_avContext stopContext];
//            [_avContext stopContext:^(QAVResult result) {
            [ws onContextCloseComplete:TAVLocalizedError(ETCAVBaseRoomEngine_EnterRoom_Fail_Tip)];
//            }];
#endif
        }
    }
    else
    {
        TCAVIMLog(@"进入AVRoom出错:当前网络不可用");
        __weak TCAVBaseRoomEngine *ws = self;
#if kIsUseAVSDKAsLiveScene
        [ws onContextCloseComplete:TAVLocalizedError(ETCAVBaseRoomEngine_Network_Invailed_Tip)];
#else
        [_avContext stopContext];
        // 检查当前网络
//        [_avContext stopContext:^(QAVResult result) {
        [ws onContextCloseComplete:TAVLocalizedError(ETCAVBaseRoomEngine_Network_Invailed_Tip)];
//        }];
#endif
    }
}



#pragma AVRoomDelegate method

-(void)OnEnterRoomComplete:(int)result
{
    // 进入AV房间
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        return;
    }
    if(QAV_OK == result)
    {
        TCAVIMLog(@"进入AV房间成功");
        
        TCAVLog(([NSString stringWithFormat:@" *** clogs.viewer.enterRoom|%@|join av room|SUCCEED|room id %@", ((IMAHost *)_IMUser).imUserId, _roomInfo.liveIMChatRoomId]));
        [self onEnterAVRoomSucc];
        
    }
    else
    {
        TCAVIMLog(@"切换房间失败: %d", result);
        _switchingToRoom = nil;
        
#if kIsUseAVSDKAsLiveScene
        [self onContextCloseComplete:QAV_OK];
#else
        TCAVIMLog(@"进入AV房间失败: %d, 开始StopContext", result);
        __weak TCAVBaseRoomEngine *ws = self;
        [_avContext stopContext];
//        [_avContext stopContext:^(QAVResult result) {
            [ws onContextCloseComplete:TAVLocalizedError(ETCAVBaseRoomEngine_EnterAVRoom_Fail_Tip)];
//        }];
#endif
        
        
    }
}


-(void)OnExitRoomComplete
{
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        return;
    }
    TCAVLog(([NSString stringWithFormat:@" *** clogs.%@.quitRoom|%@|quit av room|SUCCEED|result %d", [self isHostLive] ? @"host" : @"viewer", ((IMAHost *)_IMUser).imUserId, result]));
#if kSupportTimeStatistics
    NSDate *date = [NSDate date];
    TCAVIMLog(@"%@ 从退房:%@ 到ExitRoom时间:%@ 总耗时:%0.3f (s)", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate], [kTCAVIMLogDateFormatter stringFromDate:date] , -[_logStartDate timeIntervalSinceDate:date]);
#else
    
    DebugLog(@"退出AVRoom完毕");
#endif
    
    __weak TCAVBaseRoomEngine *ws = self;
#if kIsUseAVSDKAsLiveScene
    [ws onContextCloseComplete:nil];
#else
    [_avContext stopContext];
//    [_avContext stopContext:^(QAVResult result) {
        [ws onContextCloseComplete:nil];
//    }];
#endif
    
}

- (void)OnRoomDisconnect:(int)reason
{
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        return;
    }
    TCAVLog(([NSString stringWithFormat:@" *** clogs.%@.sdkDisconnect|%@|sdkDisconnect room|SUCCEED|result %d", [self isHostLive] ? @"host" : @"viewer", ((IMAHost *)_IMUser).imUserId, result]));
    
    __weak TCAVBaseRoomEngine *ws = self;
#if kIsUseAVSDKAsLiveScene
    [ws onContextCloseComplete:nil];
#else
    [_avContext stopContext];
//    [_avContext stopContext:^(QAVResult result) {
    [ws onContextCloseComplete:nil];
//    }];
#endif
}

- (void)OnCameraSettingNotify:(int)width Height:(int)height Fps:(int)fps
{
    // no nothing
    // overwrite by subclass
   // TCAVIMLog(@"摄像头设置变更: width = %d, height=%d fps=%d", width, height, fps);
}

- (void)OnRoomEvent:(int)type subtype:(int)subtype data:(void *)data
{
    //
// TCAVIMLog(@"房间事件通知: type = %d, subtype=%d data=%p", type, subtype, data);
}

- (void)OnPrivilegeDiffNotify:(int)privilege
{
    // no nothing
    // overwrite by subclass
}

-(void)OnSemiAutoRecvCameraVideo:(NSArray*)identifierList
{
    TCAVIMLog(@"自动接收到的视频列表:%@", identifierList);
    if (!_hasRecvSemiAutoCamera)
    {
#if kSupportTimeStatistics
        
        if (!_hasSemiAutoCameraVideo)
        {
            _hasSemiAutoCameraVideo = YES;
            NSDate *date = [NSDate date];
            TCAVIMLog(@"%@ 从进房:%@ 到收到推送视频:%@ 总耗时:%0.3f (s)", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate], [kTCAVIMLogDateFormatter stringFromDate:date] , -[_logStartDate timeIntervalSinceDate:date]);
        }
#endif
        [_delegate onAVEngine:self recvSemiAutoVideo:identifierList];
        _hasRecvSemiAutoCamera = YES;
        
        // 防止半自动下，也会有画面无法到达情况
        DebugLog(@"开始首帧画面计时");
        _hasStatisticFirstFrame = YES;
        
        [self onStartFirstFrameTimer];
    }
}


- (void)onRoomEnterForeground
{
    _isAtForeground = YES;
}
- (void)onRoomEnterBackground
{
    _isAtForeground = NO;
}

- (NSString *)engineLog
{
    if (_isRoomAlive)
    {
        NSString *videoParam = [_avContext.videoCtrl getQualityTips];
        NSString *audioParam = [_avContext.audioCtrl getQualityTips];
        NSString *commonParam = [_avContext.room getQualityTips];
        return [NSString stringWithFormat:@"Video:\n%@Audio:\n%@Common:\n%@", videoParam, audioParam, commonParam];
    }
    else
    {
        DebugLog(@"[%@] 当前room不是直播状态", [self class]);
        return nil;
    }
}

- (NSDictionary *)GetLiveQualityParam
{
    return [_avContext.room GetQualityParam];
}

- (QAVVideoCtrl *)getVideoCtrl
{
    return _avContext.videoCtrl;
}

// 修改角色 此前，角色被设定为在进入房间之前指定、进入房间之后不能动态修改。这个接口的作用就是修改这一设定，即：在进入房间之后也能动态修改角色。业务测可以通过此接口让用户在房间内动态调整音视频、网络参数，如将视频模式从清晰切换成流畅。
// role 角色字符串，可为空，为空时对应后台默认角色，注意传入的参数，要与腾讯云台Spear引擎配置一致
// 修改角色不包括修改音频场景，音频场景仍然需要在进入房间前指定而且进入房间以后不能修改
- (QAVResult)changeAVControlRole:(NSString *)role
{
    if ([self isRoomRunning])
    {
        QAVMultiRoom *room = (QAVMultiRoom *)_avContext.room;
        if ([room respondsToSelector:@selector(ChangeAVControlRole:delegate:)])
        {
            QAVResult res = [room ChangeAVControlRole:role delegate:self];
            return res;
        }
        else
        {
            DebugLog(@"创建房间时，传入的参数不是QAVMultiParam类型，无法修改role");
        }
        
    }
    else
    {
        DebugLog(@"房间状态不正确，无法changeRole");
    }
    return QAV_ERR_FAILED;
}

- (void)OnChangeRoleDelegate:(int)ret_code
{
    if ([_delegate respondsToSelector:@selector(onAVEngine:changeRole:tipInfo:)])
    {
        BOOL succ = ret_code == QAV_OK;
        [_delegate onAVEngine:self changeRole:succ tipInfo:succ ? @"修改成功" : @"修改失败"];
    }
}

- (void)OnEndpointsUpdateInfo:(QAVUpdateEvent)eventID endpointlist:(NSArray *)endpoints
{
    DebugLog(@"endpoints = %@ evenId = %d %@", endpoints, (int)eventID, [self eventTip:eventID]);
    
    if (eventID == QAV_EVENT_ID_ENDPOINT_EXIT)
    {
        if ([_delegate respondsToSelector:@selector(onAVEngine:users:exitRoom:)])
        {
            // 有人退出
            [_delegate onAVEngine:self users:endpoints exitRoom:_roomInfo];
        }
    }
    else if (eventID == QAV_EVENT_ID_ENDPOINT_ENTER)
    {
        if ([_delegate respondsToSelector:@selector(onAVEngine:users:enterRoom:)])
        {
            // 进有进入
            [_delegate onAVEngine:self users:endpoints enterRoom:_roomInfo];
        }
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(onAVEngine:users:event:)])
        {
            // 其他事件监听
            [_delegate onAVEngine:self users:endpoints event:eventID];
        }
    }
    
}



/**
 @brief 本地画面预览回调
 @param 本地视频帧数据
 */
-(void)OnLocalVideoPreview:(QAVVideoFrame*)frameData
{
#if kSupportTimeStatistics
    if (!_hasShowLocalFirstFrame)
    {
        _hasShowLocalFirstFrame = YES;
        [self logFirstFrameTime];
    }
#endif
    [_delegate onAVEngine:self videoFrame:frameData];
}

/**
 @brief 本地画面预处理视频回调，修改了data的数据后会在编码后传给服务器。
 @param 本地视频帧数据
 */
-(void)OnLocalVideoPreProcess:(QAVVideoFrame*)frameData
{
    // do nothing
    // over write by subclass
    //    [self onPreProcessLocalVideoFrame:frameData];
    
}

/**
 @brief 摄像头返回的本地画面原始数据
 @param 本地视频帧数据
 */
-(void)OnLocalVideoRawSampleBuf:(CMSampleBufferRef)buf result:(CMSampleBufferRef *)ret
{
    // do nothing
    // over write by subclass
    // 本地对画面进行预处理
}

-(void)OnVideoPreview:(QAVVideoFrame*)frameData
{
    if (!_hasShowFirstRemoteFrame)
    {
        _hasShowFirstRemoteFrame = YES;
        
        [self stopFirstFrameTimer];
        if ([_delegate respondsToSelector:@selector(onAVEngineFirstRemoteFrameRender:)])
        {
            DebugLog(@"第一帧画面开始显示");
            [_delegate onAVEngineFirstRemoteFrameRender:self];
        }
        
#if kSupportTimeStatistics
        [self logFirstFrameTime];
#endif
    }
    [_delegate onAVEngine:self videoFrame:frameData];
}


@end




@implementation TCAVBaseRoomEngine (ProtectedMethod)
#if kSupportTimeStatistics
- (void)onWillEnterLive
{
    if (!_logStartDate)
    {
        _logStartDate = [NSDate date];
        TCAVIMLog(@"%@ 进入房间开始计时:%@", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate]);
    }
}




- (void)onWillExitLive
{
    if (!_logStartDate)
    {
        _logStartDate = [NSDate date];
        TCAVIMLog(@"%@ 退出房间开始间计时:%@", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate]);
    }
}

- (void)onDidExitLive
{
    if (_logStartDate)
    {
        NSDate *date = [NSDate date];
        TCAVIMLog(@"%@ 退出直播流程完毕。开始计时:%@ 结束时间:%@, 总共耗时:%0.3f", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate], [kTCAVIMLogDateFormatter stringFromDate:date], -[_logStartDate timeIntervalSinceDate:date]);
    }
    _logStartDate = nil;
    
}
#endif

- (BOOL)checkAppSupportBackgroundMode
{
    NSArray *modes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIBackgroundModes"];
    DebugLog(@"开启的后台模式:%@", modes);
    return modes.count;
}

- (void)onRealEnterLive:(id<AVRoomAble>)room
{
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        return;
    }
    
    if ([room liveAVRoomId] == 0)
    {
        DebugLog(@"房间id为空");
        if (_switchingToRoom)
        {
            _switchingToRoom = nil;
            if ([_delegate respondsToSelector:@selector(onAVEngine:switchRoom:succ:tipInfo:)])
            {
                [_delegate onAVEngine:self switchRoom:_roomInfo succ:NO tipInfo:TAVLocalizedError(ETCAVBaseRoomEngine_NotRightRoomInfo_Tip)];
            }
        }
        else
        {
            [_delegate onAVEngine:self enterRoom:room succ:NO tipInfo:TAVLocalizedError(ETCAVBaseRoomEngine_NotRightRoomInfo_Tip)];
        }
        return;
    }
#if kSupportTimeStatistics
    if (!_logStartDate)
    {
        _logStartDate = [NSDate date];
    }
#endif
    
#if kIsUseAVSDKAsLiveScene
    TCAVIMLog(@"-----[%@]>>>>>开始进入直播间：%@", [self isHostLive] ? @"主播" : @"观众", _isUseSharedContext ? @"" : @"StartContext");
#else
    TCAVIMLog(@"-----[%@]>>>>>开始进入直播间：%@", [self isHostLive] ? @"主播" : @"观众", @"StartContext");
#endif
    _roomInfo = room;
    
    
#if kIsUseAVSDKAsLiveScene
    if (_isUseSharedContext)
    {
        [self creatAVRoom];
    }
    else
#endif
    {
        __weak TCAVBaseRoomEngine *ws = self;
        
        
        QAVContextConfig *config = [[QAVContextConfig alloc] init];
        
        NSString *appid = [_IMUser imSDKAppId];
        
        config.sdk_app_id = appid;
        config.app_id_at3rd = appid;
        config.identifier = [_IMUser imUserId];
        config.account_type = [_IMUser imSDKAccountType];
        
        [_avContext startContextwithConfig:config andblock:^(QAVResult result) {
            [ws onContextStartComplete:(int)result];
        }];
        
        //        [_avContext startContext:^(QAVResult result) {
        //            [ws onContextStartComplete:(int)result];
        //        }];
    }
    
    
    
    
}

- (QAVMultiParam *)createdAVRoomParam
{
    QAVMultiParam *param = [[QAVMultiParam alloc] init];
    param.relationId = [_roomInfo liveAVRoomId];
    param.audioCategory = [self roomAudioCategory];
    param.controlRole = [self roomControlRole];
    param.authBits = [self roomAuthBitMap];
    param.createRoom = [self isHostLive];
    // 与原1.8.2之前逻辑统一
    param.enableMic = NO;
    param.enableSpeaker = YES;
    param.videoRecvMode = VIDEO_RECV_MODE_SEMI_AUTO_RECV_CAMERA_VIDEO;
    return param;
}

- (UInt64)roomAuthBitMap
{
    // 权限默认全开
    return QAV_AUTH_BITS_DEFAULT;
}

// 房音音频参数配置
// 1.8.1以及之前的版本，客户端填音频场景，其实是无效的，不会起作用，主要是以SPEAR配置为准
// 为保留逻辑的完整性，添加该接口，以备后续SDK版本升级中可能过代码进行设置
- (avAudioCategory)roomAudioCategory
{
    if ([self isHostLive])
    {
        return CATEGORY_MEDIA_PLAY_AND_RECORD;
    }
    else
    {
        return CATEGORY_MEDIA_PLAYBACK;
    }
}
- (NSString *)roomControlRole
{
    // 具体与云平台spear引擎配置有关
    // 所返回的内容必须要与云端一致
    // 若返回nil或返回与Spear上没有角色，则使用默认配置
    return nil;
}

- (void)onContextStartComplete:(int)result
{
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        return;
    }
    
#if kIsUseAVSDKAsLiveScene
    if (!_isUseSharedContext)
    {
        // 配置共享的context
        [TCAVSharedContext configWithStartedContext:_avContext];
    }
#endif
    
    if (result == QAV_OK)
    {
        TCAVIMLog(@"StartContext成功，开始进入AVRoom");
        [self creatAVRoom];
    }
    else
    {
        __weak TCAVBaseRoomEngine *ws = self;
        
        QAVResult res =  [_avContext stopContext];
        TCAVIMLog(@"StartContextr失败，StopContext = %ld", (long)res);
        [ws onContextCloseComplete:nil];
        //        [_avContext stopContext:^(QAVResult result) {
        //            [ws onContextCloseComplete:nil];
        //        }];
    }
    
}

// 进入AVRoom成功之后要进行的操作
- (void)onEnterAVRoomSucc
{
    _isRoomAlive = YES;
    NSString *tip = [self isHostLive] ? TAVLocalizedError(ETCAVBaseRoomEngine_Host_EnterAVRoom_Succ_Tip) : TAVLocalizedError(ETCAVBaseRoomEngine_Guest_EnterAVRoom_Succ_Tip);
    
#if kSupportTimeStatistics
    
    NSDate *date = [NSDate date];
    TCAVIMLog(@"%@ 从进房:%@ 到创建AVRoom成功:%@ 总耗时:%0.3f (s)", tip, [kTCAVIMLogDateFormatter stringFromDate:_logStartDate], [kTCAVIMLogDateFormatter stringFromDate:date] , -[_logStartDate timeIntervalSinceDate:date]);
#else
    DebugLog(@"%@", tip);
#endif
    
    if (_switchingToRoom)
    {
        if ([_delegate respondsToSelector:@selector(onAVEngine:switchRoom:succ:tipInfo:)])
        {
            [_delegate onAVEngine:self switchRoom:_roomInfo succ:YES tipInfo:TAVLocalizedError(ETCAVBaseRoomEngine_SwitchRoom_Succ_Tip)];
        }
        _switchingToRoom = nil;
    }
    else
    {
        [_delegate onAVEngine:self enterRoom:_roomInfo succ:YES tipInfo:tip];
    }
}

- (void)onContextCloseComplete:(NSString *)tip
{
#if kSupportTimeStatistics
    [self onDidExitLive];
#else
    DebugLog(@"退房成功");
#endif
    
    if (_switchingToRoom)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self onExitRoomCompleteToSwitchToLive];
        });
    }
    else
    {
        [_delegate onAVEngine:self exitRoom:_roomInfo succ:YES tipInfo: tip ? tip : TAVLocalizedError(ETCAVBaseRoomEngine_ExitRoom_Succ_Tip)];
    }
}

- (NSString *)eventTip:(QAVUpdateEvent)event
{
    switch (event)
    {
        case QAV_EVENT_ID_NONE:
            return @"no thing";
            break;
        case QAV_EVENT_ID_ENDPOINT_ENTER:
            return @"进入房间";
        case QAV_EVENT_ID_ENDPOINT_EXIT:
            return @"退出房间";
        case QAV_EVENT_ID_ENDPOINT_HAS_CAMERA_VIDEO:
            return @"打开摄像头";
        case QAV_EVENT_ID_ENDPOINT_NO_CAMERA_VIDEO:
            return @"关闭摄像头";
        case QAV_EVENT_ID_ENDPOINT_HAS_AUDIO:
            return @"打开麦克风";
        case QAV_EVENT_ID_ENDPOINT_NO_AUDIO:
            return @"关闭麦克风";
        case QAV_EVENT_ID_ENDPOINT_HAS_SCREEN_VIDEO:
            return @"发屏幕";
        case QAV_EVENT_ID_ENDPOINT_NO_SCREEN_VIDEO:
            return @"不发屏幕";
            
        default:
            return nil;
            break;
    }
}


// 首帧画面计时，
- (void)startFirstFrameTimer
{
    if (_hasStatisticFirstFrame || _hasShowFirstRemoteFrame)
    {
        if (_hasShowFirstRemoteFrame)
        {
            DebugLog(@"首帧画面已显示，不需要再计时");
        }
        
        return;
    }
    DebugLog(@"开始首帧画面计时");
    _hasStatisticFirstFrame = YES;
    
    [self onStartFirstFrameTimer];
}

- (void)onStartFirstFrameTimer
{
    [_firstFrameTimer invalidate];
    _firstFrameTimer = nil;
    _firstFrameTimer = [NSTimer scheduledTimerWithTimeInterval:[self maxWaitFirstFrameSec] target:self selector:@selector(onWaitFirstFrameTimeOut) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_firstFrameTimer forMode:NSRunLoopCommonModes];
    
}

- (void)onWaitFirstFrameTimeOut
{
    DebugLog(@"请求首帧画面超时");
    if ([_delegate respondsToSelector:@selector(onAVEngineWaitFirstRemoteFrameTimeOut:)])
    {
        [_delegate onAVEngineWaitFirstRemoteFrameTimeOut:self];
    }
}
// 等待第一帧的时长
- (NSInteger)maxWaitFirstFrameSec
{
    return 10;
}

- (void)logFirstFrameTime
{
#if kSupportTimeStatistics
    NSDate *date = [NSDate date];
    TCAVIMLog(@"%@ 从进房:%@ 到画面显示时间:%@ 整个流程完毕 总耗时 :%0.3f (s)", [self isHostLive] ? @"主播" : @"观众",  [kTCAVIMLogDateFormatter stringFromDate:_logStartDate], [kTCAVIMLogDateFormatter stringFromDate:date] , -[_logStartDate timeIntervalSinceDate:date]);
    _logStartDate = nil;
#endif
}
// 停步首帧计时
- (void)stopFirstFrameTimer
{
    if (_firstFrameTimer)
    {
        [_firstFrameTimer invalidate];
        _firstFrameTimer = nil;
    }
}



@end