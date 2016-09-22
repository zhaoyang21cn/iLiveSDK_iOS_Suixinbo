//
//  TCILiveBaseConfig.h
//  TCShow
//
//  Created by AlexiChen on 16/8/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportILiveSDK
#import <Foundation/Foundation.h>

// 用户重点配置权限authBits与角色信息controlRole，以及avCtrlState

typedef NS_ENUM(NSInteger, TCILiveScene)
{
    ETCILiveScene_Base,     // 基础场景，主要只关注进出房间
    ETCILiveScene_Live,     // 直播
    ETCILiveScene_MultiLive,// 互动直播
#if kSupportCallScene
    ETCILiveScene_Call,     // 电话
#endif
};

@interface TCILiveBaseConfig : NSObject
{
@protected
    TCILiveScene _liveScene;
    
}

@property (nonatomic, readonly) TCILiveScene liveScene;

@property (nonatomic, readonly) BOOL isHost;
// 进入直播界面后是否立即开始进入房间操作，
// 默认YES
// YES:自动开始，NO:用户手动开始
@property (nonatomic, assign) BOOL isImmediatelyEnterLive;

// 音视频场景策略，多人房间专用。
// 默认为:有上麦权限（主播，互动观众）的为CATEGORY_MEDIA_PLAY_AND_RECORD，无上麦权限(普通观众)CATEGORY_MEDIA_PLAYBACK
// 房音音频参数配置
// 备注：1.8.1以及之前的版本，客户端填音频场景，其实是无效的，不会起作用，主要是以SPEAR配置为准，为保留逻辑的完整性，添加该接口，以备后续SDK版本升级中可能使用代码进行设置音频场景
@property (nonatomic, assign) avAudioCategory audioCategory;

// 音视频权限位
// 进入房间的时候权限位，与Spear引擎对应
// 默认所有权限QAV_AUTH_BITS_DEFAULT
// 用户重点配置
@property (nonatomic, assign) UInt64 authBits;

// 角色名，web端音视频参数配置工具(Spear配置)所设置的角色名。
// 默认为nil
@property (nonatomic, copy) NSString *controlRole;

// 是否自动创建音视频房间。如果房间不存在时，是否自动创建它。
// 默认主播创建房间（为YES），观众加入房间(NO)
@property (nonatomic, assign) BOOL createRoom;

// 视频接收模式。
// 默认自动接收：VIDEO_RECV_MODE_SEMI_AUTO_RECV_CAMERA_VIDEO
@property (nonatomic, assign) VideoRecvMode videoRecvMode;

// 进入房间后的配置，主要控制进房间后的是否自动开启mic,speaker,camera,美颜，美白，推流，录制等功能
// 详见AVIMAble.h
@property (nonatomic, assign) NSInteger avCtrlState;

// 观众请求画面时，首帧等时间，默认10s
@property (nonatomic, assign) NSInteger maxWaitFirstFrameSec;

// 直播过程是是否使用默认的状态监听
@property (nonatomic, assign) BOOL useDefaultNetListener;
@property (nonatomic, assign) BOOL useDefaultCallListener;

// 检查构造参数
+ (BOOL)checkInitParam:(id<AVRoomAble>)info user:(id<IMHostAble>)user;

- (instancetype)initWith:(id<AVRoomAble>)info user:(id<IMHostAble>)user;


- (BOOL)isEnableMic;
- (BOOL)isEnableSpeaker;
- (BOOL)isEnableCamera;
- (BOOL)isEnableIM;
- (BOOL)isFixAVRoomIDAsAVChatRoomID;
- (BOOL)needExitIMChatRoom;
- (NSString *)imChatRoomType;

@end

@interface TCILiveBaseRoomEngine : TCAVBaseRoomEngine

@property (nonatomic, strong) TCILiveBaseConfig *runtimeConfig;

@end


@interface TCILiveBaseViewController : TCAVBaseViewController
{
@protected
    
    TCILiveBaseConfig *_runtimeConfig;
}

@property (nonatomic, readonly) TCILiveBaseConfig *runtimeConfig;

// init之后，显示之前配置有效
- (void)configRuntime:(TCILiveBaseConfig *)config;


@end
#endif