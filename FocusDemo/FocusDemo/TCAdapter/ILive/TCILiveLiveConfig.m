//
//  TCILiveLiveConfig.m
//  TCShow
//
//  Created by AlexiChen on 16/8/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportILiveSDK
#import "TCILiveLiveConfig.h"

@implementation TCILiveLiveConfig

- (instancetype)initWith:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    if ([TCILiveBaseConfig checkInitParam:info user:user])
    {
        if (self = [super initWith:info user:user])
        {
            _liveScene = ETCILiveScene_Live;
            
            _enableIM = YES;
            _isFixAVRoomIDAsAVChatRoomID = YES;
            _defaultCamera = CameraPosFront;
            _needExitIMChatRoom = YES;
            _defaultBeautyValue = 5;
            _defaultWhiteValue = 5;
            
            _enableMicMaxTryCount = 5;
            _enableSpeakerMaxTryCount = 5;
            _enableCameraMaxTryCount = 5;
            
            _requestHostViewMaxTryCount = 10;
            
            _imChatRoomType = @"AVChatRoom";
            
            if (self.isHost)
            {
                self.authBits = QAV_AUTH_BITS_DEFAULT;
            }
            else
            {
                self.authBits = QAV_AUTH_BITS_JOIN_ROOM | QAV_AUTH_BITS_RECV_AUDIO | QAV_AUTH_BITS_RECV_VIDEO | QAV_AUTH_BITS_RECV_SUB;
            }
        }
        return self;
    }
    return nil;
}

- (BOOL)isEnableIM
{
    return _enableIM;
}


- (BOOL)needExitIMChatRoom
{
    return _needExitIMChatRoom;
}

- (BOOL)isFixAVRoomIDAsAVChatRoomID
{
    return _isFixAVRoomIDAsAVChatRoomID;
}

- (NSString *)imChatRoomType
{
    return _imChatRoomType;
}


@end




@implementation TCILiveLiveRoomEngine

- (void)setRuntimeConfig:(TCILiveLiveConfig *)runtimeConfig
{
    if (_runtimeConfig)
    {
        DebugLog(@"已设置时，不允许中途替换");
        return;
    }
    
    if (runtimeConfig)
    {
        _runtimeConfig = runtimeConfig;
        _enableChat = _runtimeConfig.enableIM;
        _cameraId = _runtimeConfig.defaultCamera;
    }
}

// 默认使用的美颜值
- (NSInteger)defaultBeautyValue
{
    if (_runtimeConfig)
    {
        return _runtimeConfig.defaultBeautyValue;
    }
    else
    {
        return [super defaultBeautyValue];
    }
}

- (NSInteger)defaultWhiteValue
{
    if (_runtimeConfig)
    {
        return _runtimeConfig.defaultWhiteValue;
    }
    else
    {
        return [super defaultWhiteValue];
    }
}

- (BOOL)needExitIMChatRoom
{
    if (_runtimeConfig)
    {
        return _runtimeConfig.needExitIMChatRoom;
    }
    else
    {
        return [super needExitIMChatRoom];
    }
}
- (NSInteger)enableMicMaxTryCount
{
    if (_runtimeConfig)
    {
        return _runtimeConfig.enableMicMaxTryCount;
    }
    else
    {
        return [super enableMicMaxTryCount];
    }
}

- (NSInteger)enableSpeakerMaxTryCount
{
    if (_runtimeConfig)
    {
        return _runtimeConfig.enableSpeakerMaxTryCount;
    }
    else
    {
        return [super enableSpeakerMaxTryCount];
    }
}

- (NSInteger)enableCameraMaxTryCount
{
    if (_runtimeConfig)
    {
        return _runtimeConfig.enableCameraMaxTryCount;
    }
    else
    {
        return [super enableCameraMaxTryCount];
    }
}

// 请求主播画面最大重试次数
- (NSInteger)requestHostViewMaxTryCount
{
    if (_runtimeConfig)
    {
        return _runtimeConfig.requestHostViewMaxTryCount;
    }
    else
    {
        return [super requestHostViewMaxTryCount];
    }
}

- (QAVMultiParam *)createdAVRoomParam
{
    if (_runtimeConfig)
    {
        QAVMultiParam *param = [[QAVMultiParam alloc] init];
        param.relationId = [_roomInfo liveAVRoomId];
        param.audioCategory = [_runtimeConfig audioCategory];
        param.controlRole = [_runtimeConfig controlRole];
        param.authBits = [_runtimeConfig authBits];
        param.createRoom = [self isHostLive];
        param.videoRecvMode = [_runtimeConfig videoRecvMode];
        NSInteger avcs = [_runtimeConfig avCtrlState];
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
    else
    {
        return [super createdAVRoomParam];
    }
}


- (void)enterIMLiveChatRoom:(id<AVRoomAble>)room
{
    
    if (_runtimeConfig.isFixAVRoomIDAsAVChatRoomID)
    {
#if kSupportTimeStatistics
        [self onWillEnterLive];
#endif
        
        __weak TCAVLiveRoomEngine *ws = self;
        __weak id<TCAVRoomEngineDelegate> wd = _delegate;
        __weak id<AVRoomAble> wr = room;
#if kSupportTimeStatistics
        __weak NSDate *wl = _logStartDate;
#endif
        BOOL isHost = [self isHostLive];
        [[IMAPlatform sharedInstance] asyncEnterAVChatRoomWithAVRoomID:room succ:^(id<AVRoomAble> room) {
#if kSupportTimeStatistics
            NSDate *date = [NSDate date];
            TCAVIMLog(@"%@ 从进房到进入IM聊天室（%@）: 开始进房时间:%@ 创建聊天室完成时间:%@ 总耗时 :%0.3f (s)", isHost ? @"主播" : @"观众", [room liveIMChatRoomId] , [kTCAVIMLogDateFormatter stringFromDate:wl], [kTCAVIMLogDateFormatter stringFromDate:date] , -[wl timeIntervalSinceDate:date]);
#endif
            [ws onRealEnterLive:room];
        } fail:^(int code, NSString *msg) {
            [wd onAVEngine:ws enterRoom:wr succ:NO tipInfo:isHost ? @"创建直播聊天室失败" : @"加入直播聊天室失败"];
        }];
    }
    else
    {
        [super enterIMLiveChatRoom:room];
    }
}

@end

@implementation TCILiveLiveViewController

- (void)configRuntime:(TCILiveLiveConfig *)config
{
    if ([_roomEngine isRoomRunning])
    {
        DebugLog(@"使用过程中不允许设置");
        return;
    }
    
    _runtimeConfig = config;
    
    if (_runtimeConfig.enableIM != self.enableIM)
    {
        DebugLog(@"enableIM参数与传入的配置config不一致，以config为主");
        _enableIM = _runtimeConfig.enableIM;
    }
}

- (BOOL)isImmediatelyEnterLive
{
    if (_runtimeConfig)
    {
        return _runtimeConfig.isImmediatelyEnterLive;
    }
    else
    {
        return [super isImmediatelyEnterLive];
    }
}

- (NSInteger)defaultAVHostConfig
{
    if (_runtimeConfig)
    {
        return _runtimeConfig.avCtrlState;
    }
    else
    {
        return [super defaultAVHostConfig];
    }
}

- (void)createRoomEngine
{
    if (_runtimeConfig)
    {
        if (!_roomEngine)
        {
            id<AVUserAble> ah = (id<AVUserAble>)_currentUser;
            [ah setAvCtrlState:[self defaultAVHostConfig]];
            TCILiveLiveRoomEngine *re = [[TCILiveLiveRoomEngine alloc] initWith:(id<IMHostAble, AVUserAble>)_currentUser enableChat:_enableIM];
            re.runtimeConfig = _runtimeConfig;
            _roomEngine = re;
            _roomEngine.delegate = self;
            if (!_isHost)
            {
                [_liveView setRoomEngine:_roomEngine];
            }
        }
    }
    else
    {
        [super createRoomEngine];
    }
}

@end

#endif