//
//  ILiveRoomOption.h
//  ILiveSDK
//
//  Created by AlexiChen on 2016/10/24.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QAVSDK/QAVSDK.h>
#import "ILiveRoomLisenter.h"
#import "ILiveCommon.h"


@class ILiveRoomIMOption;
@class ILiveRoomAVOption;
@class ILiveRoomRunTimeOption;

typedef NSString *(^ILiveGroupIDFunc)(unsigned int roomid);

/**
 单次进入房间配置选项类
 */
@interface ILiveRoomOption : NSObject

/** IM相关配置 */
@property (nonatomic, strong) ILiveRoomIMOption *imOption;

/** AV相关配置 */
@property (nonatomic, strong) ILiveRoomAVOption *avOption;

/** 房间运行相关配置 */
@property (nonatomic, strong) ILiveRoomRunTimeOption *rtOption;

/** 进房间的成员所属角色名，web端音视频参数配置工具所设置的角色名 */
@property (nonatomic, copy) NSString *controlRole;

/** IM群id与音视频房间id的对应关系，默认使用相同的id，用户可不用关心 */
@property (nonatomic, copy) ILiveGroupIDFunc generateImGroupFunc;

/** 房间内用户状态变化通知 */
@property (nonatomic, weak) id<ILiveMemStatusListener> memberStatusListener;

/** SDK30秒超时主动退出房间 */
@property (nonatomic, weak) id<ILiveRoomDisconnectListener> roomDisconnectListener;

/** 首帧到达监听 */
@property (nonatomic, weak) id<ILiveFirstFrameListener> firstFrameListener;

/** 半自动模式接收摄像头视频的事件通知 */
@property (nonatomic, weak) id<ILiveSemiAutoRecvCameraVideoListener> autoRecvListener;

/**
 主播默认配置
 
 @return ILiveRoomOption 实例
 */
+ (instancetype)defaultHostLiveOption;

/**
 观众默认配置

 @return ILiveRoomOption 实例
 */
+ (instancetype)defaultGuestLiveOption;

/**
 互动用户默认配置

 @return ILiveRoomOption 实例
 */
+ (instancetype)defaultInteractUserLiveOption;

/**
 音频场景配置
 
 @return ILiveRoomOption 实例
 */
+ (instancetype)defaultAudioOption;
@end




@interface ILiveRoomIMOption : NSObject

/** 是否自动创建IM群组 */
@property (nonatomic, assign) BOOL imSupport;

/** IM群组ID。如果不填写，当imSupport为YES时，将使用RoomID作为IM群组ID。如果填写，将使用传入的值作为IM群组ID */
@property (nonatomic, copy) NSString *imGroupId;

/** IM群组类型 @"Public" @"Private" @"ChatRoom" @"AVChatRoom" 直播场景下用@"AVChatRoom" */
@property (nonatomic, copy) NSString *groupType;

/**
 * 默认im配置
 * imSupport = YES;
 * groupType = @"AVChatRoom";
 */
+ (instancetype)defaultRoomIMOption;

@end



@interface ILiveRoomAVOption : NSObject

/** 是否默认创建av房间*/
@property (nonatomic, assign) BOOL avSupport;

/** 音视频场景策略 取值为: avAudioCategory */
@property (nonatomic, assign) int audioCategory;

/** 通话权限位 <QAVSDK/QAVCommon.h> 中 QAV_AUTH_BITS_DEFAULT 可查看详细定义  */
@property (nonatomic, assign) uint64 authBits;

/** 音视频权限加密串，默认nil */
@property (nonatomic, strong) NSData *authBuffer;

/** 进房间是否自动打开相机 */
@property (nonatomic, assign) BOOL autoCamera;

/** 进房间是否自动打开麦克风 */
@property (nonatomic, assign) BOOL autoMic;

/** 是否开启扬声器 */
@property(assign, nonatomic) BOOL autoSpeaker;

/** 打开相机的位置 */
@property (nonatomic, assign) cameraPos cameraPos;

/** 高音质开关 */
@property(assign, nonatomic) BOOL autoHdAudio;

/** 视频接收模式 */
@property (nonatomic, assign) VideoRecvMode videoRecvMode;

/**
 主播默认配置

 audioCategory = CATEGORY_MEDIA_PLAY_AND_RECORD;
 authBits = QAV_AUTH_BITS_DEFAULT;
 autoCamera = YES;
 cameraPos = CameraPosFront;
 autoMic = YES;
 autoSpeaker = YES;
 autoHdAudio = NO;
 videoRecvMode = VIDEO_RECV_MODE_SEMI_AUTO_RECV_CAMERA_VIDEO;
 
 @return ILiveRoomAVOption
 */
+ (instancetype)defaultHostLiveOption;

/**
 观众默认配置
 
 audioCategory = CATEGORY_MEDIA_PLAYBACK;
 authBits = QAV_AUTH_BITS_JOIN_ROOM | QAV_AUTH_BITS_RECV_AUDIO | QAV_AUTH_BITS_RECV_VIDEO | QAV_AUTH_BITS_RECV_SUB;
 autoCamera = NO;
 autoMic = NO;
 autoSpeaker = YES;
 autoHdAudio = NO;
 videoRecvMode = VIDEO_RECV_MODE_SEMI_AUTO_RECV_CAMERA_VIDEO;
 
 @return ILiveRoomAVOption
 */
+ (instancetype)defaultGuestLiveOption;

/**
 连麦默认配置（连麦默认配置和主播默认配置一样）
 
 @return ILiveRoomAVOption
 */
+ (instancetype)defaultInteractUserLiveOption;

/**
 音频场景默认配置（音频通话专用）
 
 audioCategory = CATEGORY_VOICECHAT;
 authBits = QAV_AUTH_BITS_DEFAULT;
 autoCamera = NO;
 cameraPos = CameraPosFront;
 autoMic = YES;
 autoSpeaker = YES;
 autoHdAudio = NO;
 videoRecvMode = VIDEO_RECV_MODE_SEMI_AUTO_RECV_CAMERA_VIDEO;
 
 @return ILiveRoomAVOption
 */
+ (instancetype)defaultAudioOption;

@end



@interface ILiveRoomRunTimeOption : NSObject

/** 异常监听 */
@property (nonatomic, copy) TCIErrorBlock exceptionListener;

/** 是否支持后台模式 */
@property (nonatomic, assign) BOOL bgMode;

/** 主播ID */
@property (nonatomic, copy) NSString *hostID;

/** 自动请求画面 */
@property (nonatomic, assign) BOOL autoRequestView;


/**
 房间运行时默认配置
 
 bgMode = YES;
 autoRequestView = YES;
 
 @return ILiveRoomRunTimeOption
 */
+ (instancetype)defaultRoomRunTimeOption;

@end
