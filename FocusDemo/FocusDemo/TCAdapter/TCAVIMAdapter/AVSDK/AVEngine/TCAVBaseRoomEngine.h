//
//  TCAVBaseRoomEngine.h
//  TCShow
//
//  Created by AlexiChen on 16/4/11.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 修改日志
 *================================================================
 * 时间: 20160524
 * 改动项: 新增加controlRole说明配置说明，主要是后端新增，App代码进行指定，以及直播过程中修改controlRole
 * 描述: 使用代码控制不同的role,详见TCShowLiveEngine
 *================================================================
 * 时间: 20160524
 * 改动项: 当用户量较大时，用户长时间使用直播场景时，用户每次进入直播的时候，如果重新创建context，会去拉取配置，导致进入房间变慢
 *        新增TCAVSharedContext，方便处理上面的逻辑，添加kIsUseAVSDKAsLiveScene ＝ 1在TCAVBaseRoomEngine不再重复创建context
 *        即用户在直播过程中，不再stopContext，只有enterRoom/ExitRoom操作，用户在IMSDK登出(logout时)作销毁context
 * 描述: 相关关有TCAVSharedContext, TCAVBaseRoomEngine, IMAPlatform logout
 *
 */


/*
 * TCAVBaseRoomEngine AVSDK封装的基类，主要将AVSDK进出房间流程作封装
 */


@interface TCAVBaseRoomEngine : NSObject<QAVRoomDelegate, QAVLocalVideoDelegate, QAVRemoteVideoDelegate, QAVChangeRoleDelegate>
{
@protected
    QAVContext                              *_avContext;    // kIsUseAVSDKAsLiveScene = 1时，不需要在dealloc中销毁
    __weak id<TCAVRoomEngineDelegate>       _delegate;
    
#if kIsUseAVSDKAsLiveScene
@private
    BOOL                                    _isUseSharedContext;// 是否使用的是共用的context
#endif

    
@protected
    id<AVRoomAble>                          _roomInfo;          // 房间信息
    id<IMHostAble>                          _IMUser;            // 当前登录IMSDK的用户
    
@protected
    BOOL                                    _isRoomAlive;       // 当前是否在
    BOOL                                    _isAtForeground;    // 当前是否在前台，默认为YES
    BOOL                                    _hasRecvSemiAutoCamera; // 是否收到了推送的视频;
    
@protected
    NSTimer                                 *_firstFrameTimer;  // 首帧画面显示计时器
    BOOL                                    _hasStatisticFirstFrame; // 是否已统计过首帧，如果已统计，后续不再进行统计
    
#if kSupportTimeStatistics
@protected
    // 用于进出房间时间统计
    NSDate                                  *_logStartDate;                 // 用户计时
    BOOL                                    _hasShowLocalFirstFrame;        // 摄像头打开后是否显示画面
    BOOL                                    _hasSemiAutoCameraVideo;        // 是否收到推送的视频画面
#endif
    
    BOOL                                    _hasShowFirstRemoteFrame;
    
    
@protected
    id<AVRoomAble>                          _switchingToRoom;               // 要切换到的房间信息
//    BOOL                                    _isSwitchingRoom;             // 当前是否在切换房间
}

@property (nonatomic, weak) id<TCAVRoomEngineDelegate> delegate;

- (id<AVRoomAble>)getRoomInfo;

- (id<IMHostAble>)getIMUser;

// 根据当前的用户信息创建直播
// host为当前登录IMSDK的用户，不能为空
- (instancetype)initWith:(id<IMHostAble>)host;

// 当前是主播，还是观众
- (BOOL)isHostLive;

// 主播：开始直播
// 观众：观看直播
- (void)enterLive:(id<AVRoomAble>)room;

// 切换直播间
// 本质上是先退出上一次的房间，enterLive到要切换的房间
- (BOOL)switchToLive:(id<AVRoomAble>)room;

// 主播：退出直播
// 观众：退出直播
- (void)exitLive;

// 创建建房间成功，并且在前台
// 主要用于进入房间后的操作audioctrl以及videoctrl的判断，在YES时，才能操作audioctrl以及videoctrl
- (BOOL)isRoomRunning;
- (BOOL)isRoomAlive;

// 是否是前置摄像头
- (BOOL)isFrontCamera;

// 程序前后台切换时使用
- (void)onRoomEnterForeground;
- (void)onRoomEnterBackground;


// 获取运行日志
- (NSString *)engineLog;


// 修改角色 此前，角色被设定为在进入房间之前指定、进入房间之后不能动态修改。这个接口的作用就是修改这一设定，即：在进入房间之后也能动态修改角色。业务测可以通过此接口让用户在房间内动态调整音视频、网络参数，如将视频模式从清晰切换成流畅。
// role 角色字符串，可为空，为空时对应后台默认角色，注意传入的参数，要与腾讯云台Spear引擎配置一致
// 修改角色不包括修改音频场景，音频场景仍然需要在进入房间前指定而且进入房间以后不能修改
- (QAVResult)changeAVControlRole:(NSString *)role;

- (NSDictionary *)GetLiveQualityParam;

- (QAVVideoCtrl *)getVideoCtrl;
@end



//================================================
// Protected方法，部份方法供子类重写
// 外部禁止直接调用
@interface TCAVBaseRoomEngine (ProtectedMethod)

#if kSupportTimeStatistics
// 用于时间统计，外部不要重写
- (void)onWillEnterLive;
- (void)onWillExitLive;
#endif

// 是否支持后台模模式
// 随心播示例中默认不支持后台模式，若支持后台模式，app进入后台时，程序仍可在后台进行录音，不建议这么做（有窃听隐私的问题存在）
// TCAdapter中默认是只要是检测到开了后台模式（尤其是音频模式），则在切换到后台时，会自动关mic，切回前吧时，再打开mic
// 后台模式可在XCode-->Target-->Capabilities-->Bacground Modes 或info.plist文件中查看
// 用户可重写以下方法，来控制如果上述逻辑
- (BOOL)checkAppSupportBackgroundMode;

// 因外部可能会重写enterLive方法，如果重写了，子类的子类内部再调[super enterLive] ，可能会有问题
// 用户不要重写此方法
- (void)onRealEnterLive:(id<AVRoomAble>)room;

// 创建房间的信息，重写此方法来修改房间参数
- (QAVMultiParam *)createdAVRoomParam;

- (UInt64)roomAuthBitMap;

// 房音音频参数配置
// 1.8.1以及之前的版本，客户端填音频场景，其实是无效的，不会起作用，主要是以SPEAR配置为准
// 为保留逻辑的完整性，添加该接口，以备后续SDK版本升级中可能使用代码进行设置音频场景
- (avAudioCategory)roomAudioCategory;

// 增加此方法方便用户处理在直播过程中通过配置不同的角色名，控制直播效果
// TCAdapter中使用的默认值，具体如何操作，可看Demo中的配置
// 具体示例参考TCShowLiveRoomEngine
- (NSString *)roomControlRole;

// 进入AVRoom成功之后要进行的操作
- (void)onEnterAVRoomSucc;

// startContext完成
- (void)onContextStartComplete:(int)result;

// stopContext完成
- (void)onContextCloseComplete:(NSString *)tip;

- (NSString *)eventTip:(QAVUpdateEvent)event;


// 主要用于统计观众进入僵尸房间(主播异常退出，然后进入的观众requestviewlist成功，但会一直请求不到画面)，较长时间没有画面显示
// 首帧画面计时，
- (void)startFirstFrameTimer;
// 直实开计时器方法
- (void)onStartFirstFrameTimer;
// 等待第一帧的时长，默认10s
- (NSInteger)maxWaitFirstFrameSec;

- (void)logFirstFrameTime;

- (void)onWaitFirstFrameTimeOut;
// 停步首帧计时
- (void)stopFirstFrameTimer;

@end

