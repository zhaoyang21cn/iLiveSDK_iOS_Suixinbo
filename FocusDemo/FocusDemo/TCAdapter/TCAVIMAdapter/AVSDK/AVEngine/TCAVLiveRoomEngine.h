//
//  TCAVLiveRoomEngine.h
//  TCShow
//
//  Created by AlexiChen on 16/4/11.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVBaseRoomEngine.h"

/*
 * TCAVLiveRoomEngine 主要处理一个人做主播，多人同时在线观看，主播上传音频以音频，观人只能看和听，主播与观众间不存在小窗口互动场景
 * 同时在直播间内创建聊室（非必选），进入直播间后，并加入到对应的聊天室，用户可以在里面进行聊天互动
 * 注意事项：
 *  1. TCAVLiveRoomEngine在进入房间后成功后，通过外部传入和(id<IMHostAble, AVUserAble>)host的 avCtrlState 来控制控进入直播时是否开启麦克风(EAVCtrlState_Mic)，是否打开扬声器(EAVCtrlState_Speaker)，是否打开相机操作
 *      (EAVCtrlState_Camera)，这些操作全部由外部进入时来控制。
 *  2. 若外部创建时不设置(id<IMHostAble, AVUserAble>)host的 avCtrlState，即进入房间后，不会再做额外操作，用户可自行通过回调手动开起相关的功能。
 *  3. 推荐配置：主播 EAVCtrlState_All (功能全开)，观众：EAVCtrlState_Speaker （只开扬声器）
 *  4. TCAVLiveRoomEngine在TCAVBaseRoomEngine的基上增加了进入后操作Mic,Speaker,Camera,RequestHostView等操作，这些操作都是异步的，主要是部份机型硬件能力不一样，存在重试;
 */


typedef cameraPos TCAVEngineCamera;

@interface TCAVLiveRoomEngine : TCAVBaseRoomEngine
{
@protected
    TCAVEngineCamera _cameraId;     // 当前记录的相机ID
    
@protected
    BOOL             _enableChat;   // 是否在内部需要创建IM聊天室：YES，创建; NO不创建
    
@protected
    // 是否支持美颜功能，默认为YES，具体还要看机型，部分机型不支持美型功能
    // 美颜必须在相机打开后设置
    // 如果开启成功，默认设置到defaultBeautyValue
    // 启动时根据传入的avCtrlState & EAVCtrlState_Beauty 自动去判断是否在打开相机时开启美颜
    // 设置美颜时，画面会突然闪一下，属正常现象
    // 当前是否支持美颜
    // 1.8.1.300后，美颜与美白同时使用该字段控制
    BOOL             _isSupportBeauty;
    // 是否已开启美颜
    // 注意：1.8.1去掉setEnableBeauty接口，为保持逻辑，_isEnableBeauty 默认为YES
    BOOL             _isEnableBeauty;
    
@protected
    // 添加美白支持(1.8.1.300后才支持美白接口)
    // 是否已开启美白
    BOOL             _isEnableWhite;
    
    
@protected
    
    // 退后台前是否打开过相机
    BOOL            _hasEnableCameraBeforeEnterBackground;
    BOOL            _hasEnableMicBeforeEnterBackground;
}

// 当前摄像头ID，进入房间前设置即可，不设置默认开前置摄像头
@property (nonatomic, assign) TCAVEngineCamera cameraId;

// 用户是否在该类中创建聊天室
// enable YES: 外部不需要要创建IM聊天室，TCAVLiveRoomEngine内部自动帮助创建AV聊天室
// NO:TCAVLiveRoomEngine内部不自动帮助创建群（参考enterIMLiveChatRoom写法），用户可以在外面先创建好群（host liveIMChatRoomId 返回不为空即可），创始出来的TCAVLiveRoomEngine仍然支持IM功能
// 如果为enable = NO，并且host liveIMChatRoomId 返回为空，说明该TCAVLiveRoomEngine不支持IM功能
// 具体情况，用户根据自大业务类型来决定
- (instancetype)initWith:(id<IMHostAble, AVUserAble>)host enableChat:(BOOL)enable;


// 进入房间后调用
// 因为各个手机机型在硬件能力不一致，以及AVSDK初始化耗时不定，直接同步调用AVSDK操作mic,speaker,camera,requestViewlist(网络延迟因素)时，有可能会导致操作出现失败
// 于是在TCAVLiveRoomEngine内部增加重试逻辑
// 如果同步调用成功，则直接同步返回，如果不成功，则进行重试处理
// 超过最大重试次数，则返回失败

// 异步操作麦克风
- (void)asyncEnableMic:(BOOL)enable completion:(TCAVCompletion)completion;

// 根据本地的状态，作开关摄像头
- (void)asyncSwitchEnableMicCompletion:(TCAVCompletion)completion;

// 异步操作扬声器
- (void)asyncEnableSpeaker:(BOOL)enable completion:(TCAVCompletion)completion;


// 进入房时时推荐使用该方法打开相机
// 打开相机走delegate回调
// 默认开启前置摄像头
// notify 是否需要回调- (void)onAVEngine:(TCAVBaseRoomEngine *)engine enableCamera:(BOOL)succ tipInfo:(NSString *)tip;
- (void)asyncEnableCamera:(BOOL)enable;

// notify 是否需要回调- (void)onAVEngine:(TCAVBaseRoomEngine *)engine enableCamera:(BOOL)succ tipInfo:(NSString *)tip;
- (void)asyncEnableCamera:(BOOL)enable completion:(TCAVCompletion)completion;

- (void)asyncEnableCamera:(BOOL)enable needNotify:(BOOL)notify;

- (void)asyncEnableCamera:(BOOL)enable camera:(TCAVEngineCamera)camera;

// 根据本地的状态，作开关摄像头
- (void)asyncSwitchEnableCameraCompletion:(TCAVCompletion)completion;

// 需要在相机打开条件下使用
// 正常使用过程中切换摄像头
// 切换摄像头
- (void)asyncSwitchCameraWithCompletion:(TCAVCompletion)completion;

// 异步请求主播画面
// 内部有重试逻辑，正常使用AVSDK时，是需要收到HAS_Camera事件之后才能去请求视频画面的，这样，
- (void)asyncRequestHostView;

// on:YES 打开闪光灯 NO:光闭闪光灯
// 系统限制：如果当前是开前置摄像头，开闪光灯的话，画面会静止
- (void)turnOnFlash:(BOOL)on;

// 开启过相机后才能查询
// 是否支持美颜
- (BOOL)isSupporBeauty;

// 支持美颜的情况下，返回具体的值[0-9]
// 否则返回0
- (NSInteger)getBeauty;

// 支持美颜，并且已开启的情况下，设置美颜值[0-9]
// 支持美颜，未开启的情况下，先开启美颜，再设置美颜值[0-9]
- (void)setBeauty:(NSInteger)beauty;



// 开启过相机后才能查询
// 是否支持美白
- (BOOL)isSupporWhite;

// 支持美白的情况下，返回具体的值[0-9]
// 否则返回0
- (NSInteger)getWhite;

// 支持美白，并且已开启的情况下，设置美白值[0-9]
// 支持美白，未开启的情况下，先开启美白，再设置美白值[0-9]
- (void)setWhite:(NSInteger)white;

// 查控直播控件的状态，进入房间后才能查到，未进入房间时返回NO
// Mic是否开启
- (BOOL)isMicEnable;

// 是否开启扬声器
- (BOOL)isSpeakerEnable;

// 是否开启相机
- (BOOL)isCameraEnable;


// 内部调用
// 并供子类重写
// 重试前会进行参数检查
- (BOOL)beforeTryCheck:(TCAVCompletion)completion;

@end

@interface TCAVLiveRoomEngine (ProtectedMethod)

// 默认使用的美颜值
// 返回[0, 9]
- (NSInteger)defaultBeautyValue;

// 默认使用的美白值
// 返回[0, 9]
- (NSInteger)defaultWhiteValue;

// 退出时，是否需要退出直播间
// 具体看场景
// 直播场景下不退
- (BOOL)needExitIMChatRoom;

// enableMic最大重试次数
- (NSInteger)enableMicMaxTryCount;

// enableSpeaker最大重试次数
- (NSInteger)enableSpeakerMaxTryCount;

// enableCamera最大重数次数
- (NSInteger)enableCameraMaxTryCount;

// 请求主播画面最大重试次数
- (NSInteger)requestHostViewMaxTryCount;

// 进入IM聊天室操作
- (void)enterIMLiveChatRoom:(id<AVRoomAble>)room;

// 切换摄像头完毕
- (void)onSwitchCameraComplete:(int)cameraid result:(int)result completion:(TCAVCompletion)completion;

// 打开/关闭摄像头完毕
- (void)onEnableCameraComplete:(int)cameraid enable:(BOOL)enable result:(int)result needNotify:(BOOL)needNotify completion:(TCAVCompletion)completion;


// 因为AVSDK QAVEndpoint requestViewList 接口请求的视频画面的id必须包含在
// -(void)OnEndpointsUpdateInfo:(QAVUpdateEvent)eventID endpointlist:(NSArray *)endpoints
// 的endpoint里面，如果传入id的不在里面，目前返回的错误码是0，TCAVLiveRoomEngine asyncRequestHostView 主要是添加重试屏蔽掉了此逻辑
// 添加以下函数主要是防止一些业务中，因为网络原因，导致AVSDK回调慢，而无法重试的问题
- (void)requestViewOfHostOnAVSDKCallBack:(NSArray *)endpoints;

- (void)enableHostCtrlState:(AVCtrlState)bitState;

- (void)disableHostCtrlState:(AVCtrlState)bitState;

@end
