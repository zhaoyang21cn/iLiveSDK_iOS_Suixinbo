//
//  TCILiveRoom.h
//  ILiveSDK
//
//  Created by AlexiChen on 16/9/9.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QAVSDK/QAVVideoCtrl.h>

@interface TCILiveRoomConfig : NSObject

// 外部根据Spear配置指定，不指定则创建房时时为空，使用默认角色进入
@property (nonatomic, copy) NSString *roomControlRole;

// 外部根据Spear配置指定，不指定则创建房时时为空，使用默认角色进入
@property (nonatomic, copy) NSString *roomInteractRole;

// 是否支持IM消息，默认为YES(支持)
@property (nonatomic, assign) BOOL isSupportIM;

// 是否固定AVRoomID作为IM聊天室ID，默认为YES
@property (nonatomic, assign) BOOL isFixAVRoomIDAsChatRoomID;

// IM聊天室类型，默认为AVChatRoom, 只能为Private,Public,ChatRoom,AVChatRoom
@property (nonatomic, copy) NSString  *imChatRoomType;

// 是否支持后台模式: 默认自动检查info.plist中后台模式配置。
// 若要支持后台发声，显示进入设置为NO，并在target->capabilities->Background Modes勾选 "Audio, AirPlay and Picture in Picture"
@property (nonatomic, assign) BOOL isSupportBackgroudMode;

// 进入房间默认开mic
@property (nonatomic, assign) BOOL autoEnableMic;

// 进入房间相机操作，主播默认打开
@property (nonatomic, assign) BOOL autoEnableCamera;

// 所有场景下，默认打开:YES
@property (nonatomic, assign) BOOL autoEnableSpeaker;

// 进入房间默认打开的摄像头，默认前置
@property (nonatomic, assign) cameraPos autoCameraId;

// 是否自动请求画面
@property (nonatomic, assign) BOOL autoRequestView;

// 自动监听直播中（进入音视频房间后）的网络变化，默认YES(自动监听)
@property (nonatomic, assign) BOOL autoMonitorNetwork;

// 自动监听直播中（进入音视频房间后）的外部电话处理，默认YES(自动监听)
@property (nonatomic, assign) BOOL autoMonitorCall;

// 自动监听直播中（进入音视频房间后）的互踢下线，默认YES(自动监听)
@property (nonatomic, assign) BOOL autoMonitorKiekedOffline;

// 自动监听直播中（进入音视频房间后）的音频中断处理，默认YES(自动监听)
@property (nonatomic, assign) BOOL autoMonitorAudioInterupt;

// 自动监听直播中（进入音视频房间后）的前后台切换逻辑，默认YES(自动监听)，如果己监听前后台切换逻辑，建建为NO
@property (nonatomic, assign) BOOL autoMonitorForeBackgroundSwitch;

// 退出时，是否要退出IM群
@property (nonatomic, assign) BOOL isNeedExitIMChatRoom;

// 电话场景下使用
@property (nonatomic, assign) BOOL isVoiceCall;


@end


// 直播/互动直播房间
@interface TCILiveRoom : NSObject
{
@protected
    int         _avRoomID;
    NSString    *_chatRoomID;
}

// 直播音视频房间号
@property (nonatomic, readonly) int avRoomID;

// 音视频房间号
@property (nonatomic, copy) NSString *chatRoomID;

// 不能为空
@property (nonatomic, readonly) NSString *liveHostID;

// 建入房间后，外部不要轻易修改里面的值
@property (nonatomic, strong) TCILiveRoomConfig *config;

// 直播场景：主播调用
- (instancetype)initLiveWith:(int)avRoomID liveHost:(NSString *)liveHostID curUserID:(NSString *)curID;

// 直播场景：观众调用
- (instancetype)initLiveWith:(int)avRoomID liveHost:(NSString *)liveHostID chatRoomID:(NSString *)chatRoomID curUserID:(NSString *)curID;

// 电话场景：C2C电话
- (instancetype)initC2CCallWith:(int)avRoomID liveHost:(NSString *)liveHostID curUserID:(NSString *)curID callType:(BOOL)isVoiceCall;

// 电话场景：Group电话
- (instancetype)initGroupCallWith:(int)avRoomID liveHost:(NSString *)liveHostID groupID:(NSString *)chatRoomID groupType:(NSString *)groupType curUserID:(NSString *)curID callType:(BOOL)isVoiceCall;

- (BOOL)isHostLive;
@end
