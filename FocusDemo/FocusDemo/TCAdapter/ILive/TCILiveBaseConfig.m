//
//  TCILiveBaseConfig.m
//  TCShow
//
//  Created by AlexiChen on 16/8/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportILiveSDK
#import "TCILiveBaseConfig.h"

@implementation TCILiveBaseConfig

+ (BOOL)checkInitParam:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    if (!info || !user)
    {
        DebugLog(@"参数非法");
    }
    return YES;
}

- (instancetype)initWith:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    if ([TCILiveBaseConfig checkInitParam:info user:user])
    {
        if (self = [super init])
        {
            _liveScene = ETCILiveScene_Base;
            
            _isImmediatelyEnterLive = YES;
            _maxWaitFirstFrameSec = 10;
            _videoRecvMode = VIDEO_RECV_MODE_SEMI_AUTO_RECV_CAMERA_VIDEO;
            _authBits = QAV_AUTH_BITS_DEFAULT;
            _controlRole = nil;
            
            _isHost = [[[info liveHost] imUserId] isEqualToString:[user imUserId]];
            _createRoom = _isHost;
            if (_isHost)
            {
                // 主播配置
                _audioCategory = CATEGORY_MEDIA_PLAY_AND_RECORD;
                _avCtrlState = EAVCtrlState_All;
            }
            else
            {
                // 观众配置
                _audioCategory = CATEGORY_MEDIA_PLAYBACK;
                _avCtrlState = EAVCtrlState_Speaker;
            }
            
            _useDefaultNetListener = YES;
            _useDefaultCallListener = YES;
            
        }
        return self;
    }
    return nil;
}

- (BOOL)isEnableMic
{
    return (_avCtrlState & EAVCtrlState_Mic) == EAVCtrlState_Mic;
}
- (BOOL)isEnableSpeaker
{
    return (_avCtrlState & EAVCtrlState_Speaker) == EAVCtrlState_Speaker;
}
- (BOOL)isEnableCamera
{
    return (_avCtrlState & EAVCtrlState_Camera) == EAVCtrlState_Camera;
}

- (BOOL)isEnableIM
{
    return NO;
}

- (BOOL)isFixAVRoomIDAsAVChatRoomID
{
    return NO;
}

- (BOOL)needExitIMChatRoom
{
    return YES;
}

- (NSString *)imChatRoomType
{
    return @"AVChatRoom";
}

@end



@implementation TCILiveBaseRoomEngine

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

- (NSString *)imChatRoomType
{
    return @"";
}

@end


@implementation TCILiveBaseViewController

- (void)configRuntime:(TCILiveBaseConfig *)config
{
    if ([_roomEngine isRoomRunning])
    {
        DebugLog(@"使用过程中不允许设置");
        return;
    }
    
    _runtimeConfig = config;
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

- (void)createRoomEngine
{
    if (_runtimeConfig)
    {
        if (!_roomEngine)
        {
            TCILiveBaseRoomEngine *re = [[TCILiveBaseRoomEngine alloc] initWith:_currentUser];
            re.runtimeConfig = _runtimeConfig;
            _roomEngine = re;
            _roomEngine.delegate = self;
        }
    }
    else
    {
        [super createRoomEngine];
    }
}

@end

#endif