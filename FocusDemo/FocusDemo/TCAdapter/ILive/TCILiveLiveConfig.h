//
//  TCILiveLiveConfig.h
//  TCShow
//
//  Created by AlexiChen on 16/8/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportILiveSDK
#import "TCILiveBaseConfig.h"

@interface TCILiveLiveConfig : TCILiveBaseConfig

// 默认支持IM，为YES
@property (nonatomic, assign) BOOL enableIM;

// 默认为AVChatRoom，直播时建议使用AVChatRoom，只能是四个值 AVChatRoom/ChatRoom/Private/Public
@property (nonatomic, copy) NSString *imChatRoomType;

// enableIM为YES时有效
@property (nonatomic, assign) BOOL isFixAVRoomIDAsAVChatRoomID;

// 默闪直播结束时退出，默认为YES，NO时，结束直播时，不退出聊天室
@property (nonatomic, assign) BOOL needExitIMChatRoom;


// 默认前置摄像头
@property (nonatomic, assign) TCAVEngineCamera defaultCamera;

// 进入房间后，avCtrlState & EAVCtrlState_Beauty = EAVCtrlState_Beauty时，使用defaultBeautyValue为默认开启的美颜值，默认为5
@property (nonatomic, assign) NSInteger defaultBeautyValue;

// 进入房间后，avCtrlState & EAVCtrlState_Beauty = EAVCtrlState_White时，使用defaultWhiteValue为默认开启的美颜值，默认为5
@property (nonatomic, assign) NSInteger defaultWhiteValue;

// 进入房间后，avCtrlState & EAVCtrlState_Mic = EAVCtrlState_Mic时，打开mic失败时，则会进行进行重试，此为重试次数，默认为5
@property (nonatomic, assign) NSInteger enableMicMaxTryCount;

// 进入房间后，avCtrlState & EAVCtrlState_Speaker = EAVCtrlState_Speaker时，打开Speaker失败时，则会进行进行重试，此为重试次数，默认为5
@property (nonatomic, assign) NSInteger enableSpeakerMaxTryCount;

// 进入房间后，avCtrlState & EAVCtrlState_Camera = EAVCtrlState_Camera时，打开camera失败时，则会进行进行重试，此为重试次数，默认为5
@property (nonatomic, assign) NSInteger enableCameraMaxTryCount;

// 进入房间后，观众主播请求画面时，因可能hasCamera事件未到达，会导致请求失败，于是进行重试，此为重试次数，默认为10
@property (nonatomic, assign) NSInteger requestHostViewMaxTryCount;


@end


@interface TCILiveLiveRoomEngine : TCAVLiveRoomEngine

@property (nonatomic, strong) TCILiveLiveConfig *runtimeConfig;

@end


@interface TCILiveLiveViewController : TCAVLiveViewController
{
@protected
    
    TCILiveLiveConfig *_runtimeConfig;
}

@property (nonatomic, readonly) TCILiveLiveConfig *runtimeConfig;

// init之后，显示之前配置有效
- (void)configRuntime:(TCILiveLiveConfig *)config;


@end
#endif