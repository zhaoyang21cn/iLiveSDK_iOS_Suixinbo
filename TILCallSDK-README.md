
简介：TILCallSDK在ILiveSDK能力平台上，致力于提供一套完整的双人音视频即时通讯解决方案，提供“连麦”，“消息”，打造跨平台的通话场景。TILCallSDK旨在无限可能的降低用户接入成本，从用户角度考虑问题，全方位考虑用户接入体验，并提供接入服务专业定向支持，为用户应用上线保驾护航，本文档目的在于帮助用户快速接入使用TILCallSDK,达到发起方请求通话、接受方响应通话的效果。

----------

## 1. 预先集成ILiveSDK

用户在使用TILCallSDK前需要预先集成、初始化和登录ILiveSDK，集成步骤见下文。
<span id="ILiveSDK"></span>

### 1.1 开始集成

1.创建Single View Application
![](http://img.blog.csdn.net/20161104162329407)

命名ILiveSDKDemo
![](http://img.blog.csdn.net/20161104162412611)

此时工程目录应该是下图这样的，如果不是，请重新创建工程

![](http://img.blog.csdn.net/20161104162443849)

2.下载相关模块SDK解压放到目录TCILiveSDKDemo/，并导入工程
导入之后的工程目录应该是如下图所示，如果不是，请重新导入。（Framework下载看这里[这里](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos)）

![](http://img.blog.csdn.net/20161104162726288)

3.导入系统库
导入系统库之后的工程目录应该是如下图所示，如果不是，请重新导入

![](http://img.blog.csdn.net/20161104162855134)

4.连接配置

![](http://img.blog.csdn.net/20161104162928476)

5.Bitcode配置

![](http://img.blog.csdn.net/20161104162940211)

**注：完成以上步骤，ILiveSDK集成工作已经完成，接下来验证一下是否集成成功，在ViewController中打印ILiveSDK版本号。**

```
NSString *ver = [[ILiveSDK getInstance] getVersion];
NSLog(@”ILiveSDK Version is %@”, ver);
```

如果打印失败，请检查以上5个步骤。

### 1.2 初始化SDK

在使用ILiveSDK前需要进行初始化。

```
@interface ILiveSDK : NSObject

/**
 初始化SDK

 @param appId       用户标识接入SDK的应用ID
 @param accountType 用户的账号类型
 */
- (void)initSdk:(int)appId accountType:(int)accountType;

@end

```

**参数说明：**

参数 | 说明 
--- | --- 
| appid | 腾讯云控制台分配的sdkAppid，见[接入指引](https://www.qcloud.com/doc/product/269/%E5%BA%94%E7%94%A8%E6%8E%A5%E5%85%A5%E6%8C%87%E5%BC%95)
| accountType | 腾讯云控制台分配的accountType


### 1.3 登录SDK

用户登录腾讯云后台成功后，才可以正常收发消息和使用音视频功能。

```
@interface ILiveLoginManager : NSObject

/**
 独立模式登录(独立模式下直接使用该接口，托管模式需先用tlsLogin登录)

 @param uid    用户id
 @param sig    用户签名
 @param succ   成功回调
 @param failed 失败回调
 */
- (void)iLiveLogin:(NSString *)uid sig:(NSString *)sig succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

@end

```

参数 | 说明 
--- | --- | 
| uid | 登录用户的identifier
| sig | 用户的登录签名，见[帐号集成](https://www.qcloud.com/doc/product/269/1507)
| succ | 成功回调
| fail | 失败回调

------

## 2. TILCallSDK集成和使用

### 2.1 集成TILCallSDK

在使用TILCallSDK之前需要初始化和登录ILiveSDK，可以[查看](#ILiveSDK)。然后从下载包中\Frameworks\ILiveSDK\引入TILCallSDK.framework到工程即可。

使用TILCallSDK时只需考虑4个步骤：监听来电、发起通话、接听通话和结束通话。

### 2.2 设置来电监听

```
@interface TILCallManager : NSObject

/**
 设置来电监听

 @param listener 来电监听
 */
- (void)setIncomingCallListener:(id<TILCallIncomingCallListener>)listener;

@end

/**
 来电监听协议
 */
@protocol TILCallIncomingCallListener <NSObject>

/**
 监听来电

 @param invitation 来电邀请
 */
- (void)onC2CCallInvitation:(TILC2CCallInvitation*)invitation;

@end

```

**参数说明：**

参数 | 说明
--- | ---  
| listener | TILCallIncomingCallListener，监听收到的通话请求

通话请求对象TILC2CCallInvitation的定义如下：

```

/**
 通话邀请
 */
@interface TILC2CCallInvitation : NSObject

/**
 通话id
 */
@property(nonatomic,assign) int callId;

/**
 通话类型
 */
@property(nonatomic,assign) TILCallType callType;

/**
 发起者id
 */
@property(nonatomic,strong) NSString * sponsorId;

/**
 通话信息
 */
@property(nonatomic,strong) NSString * callTip;

/**
 邀请时间
 */
@property(nonatomic,strong) NSDate * inviteDate;

/**
 自定义信息
 */
@property(nonatomic,strong) NSString * custom;

@end

```

### 2.3 如何实现发起通话业务

实现发起通话业务需要4个步骤：生成初始化通话对象、添加渲染View、发起通话请求和加载渲染结果。

```
// 生成管理通话业务的UIVIew
MakeC2CCallView * callView = [[MakeC2CCallView alloc] init];

// 生成通话对象的配置项
TILC2CCallConfig * c2cConfig = [[TILC2CCallConfig alloc] init];
c2cConfig.callType = TILCALL_TYPE_VIDEO;;
c2cConfig.isSponsor = YES;
c2cConfig.peerId = @"test2";
c2cConfig.heartBeatInterval = 3;
c2cConfig.notifListener = callView;
c2cConfig.msgListener = callView;
c2cConfig.msgNumNotifyInterval = 250;
c2cConfig.memberEventListener = callView;
c2cConfig.callStatusListener = callView;
TILC2CSponsorConfig * sponsorConfig = [[TILC2CSponsorConfig alloc] init];
sponsorConfig.waitLimit = kCallTimeOut;
sponsorConfig.callId = (int)([[NSDate date] timeIntervalSince1970]) % 1000 * 1000 + arc4random() % 1000;
c2cConfig.sponsorConfig = sponsorConfig;
// 生成并初始化通话对象
TILC2CCall * call = [[TILC2CCall alloc] initWithConfig:c2cConfig];

// 添加渲染视图
UIView * renderView = [_call createRenderViewIn:self.view];
[callView addSubView:renderView];

// 发情通话请求
[_call makeCall:nil custom:nil result:^(TILCallError *err) {
        if (err) {
           NSLog([NSString stringWithFormat:@"通话失败：%@", err.errMsg]);
        }
        else {
        	// 加载发起者本人的渲染结果
        	CGRect selfRect = callView.bounds;
            [call addSelfRender:selfRect];
            // 加载接收方的渲染结果
            CGRect peerRect = CGRectMake(0,0,60,80);
            [call addRenderFor:@"test2" atFrame:peerRect];
        }
    }];
    
```
<span id="TILMakeCallParam"></span>
参数  | 说明
--- | ---
callType | 语音类型或者为音视频类型 
isSponsor | 是否为通话发起者 
peerId | 接收方的identifier
haertBeatInterval | 心跳间隔，s为单位
notifListener | 心跳及自定义通知监听器
msgListener | IM消息监听器
msgNumNotifyInterval | 接收到的消息数量通知间隔
memberEventListener | 通话内成员音视频数据开关监听器
waitLimit | 发起通话的超时时间，超时后进入onCallEnd:回调
callId | 通话ID，全局唯一

**主意事项：**
1. callId同ILiveSDK中roomId概念一致，全局保持唯一。
2. 发起方需要设置isSponsor、callType、peerId、和sponsorConfig，否则不能正常工作。

### 2.4 如何实现接听通话业务

实现发起通话业务需要5个步骤：捕获通话请求、生成初始化通话对象、添加渲染View、接受通话和加载渲染结果。

```

// 实现监听来电请求的协议，过期时间为30s
@implementation LiveIncomingCallListener

- (void)onC2CCallInvitation:(TILC2CCallInvitation*)invitation;
{
	// 判断来电邀请是否过期
    if (![self isOutDated:invitation]) {
        if (![self isChatting]) {
            RecvC2CCallViewController * vc = [[RecvC2CCallViewController alloc] init];
            vc.peerId = invitation.sponsorId;
            vc.callType = invitation.callType;
            vc.invite = invitation;
            
            // 进入接收通话界面
            [[[AppDelegate sharedInstance] topViewController] presentViewController:vc animated:YES completion:nil];
        }
        else {
        	// 正在通话中，回复正忙
            TILC2CCallConfig * config = [[TILC2CCallConfig alloc] init];
            config.isSponsor = NO;
            config.peerId = invitation.sponsorId;
            config.callType = invitation.callType;
            
            TILC2CCall * call = [[TILC2CCall alloc] initWithConfig:config];
            [call responseLineBusy:nil];
        }
    }
}

- (BOOL)isOutDated:(TILC2CCallInvitation*)invitation
{
    time_t now = [[NSDate date] timeIntervalSince1970];
    time_t callTime = [invitation.inviteDate timeIntervalSince1970];
    
    return now -callTime >30;
}

- (BOOL)isChatting
{
    return [[LiveCallPlatform sharedInstance] isChat];
}

@end

// 生成管理通话业务的UIView
RecvC2CCallView * recvView = [[RecvC2CCallView alloc] init];

// 生成通话对象的配置项
TILC2CCallConfig * c2cConfig = [[TILC2CCallConfig alloc] init];
c2cConfig.callType = _callType; // 来电邀请中有callType类型
c2cConfig.isSponsor = NO;
c2cConfig.peerId = _peerId; // 来电邀请中有发起者id
c2cConfig.heartBeatInterval = 3;
c2cConfig.notifListener = recvView;
c2cConfig.msgListener = recvView;
c2cConfig.memberEventListener = recvView;
c2cConfig.msgNumNotifyInterval = 250;
c2cConfig.callStatusListener = recvView;
TILC2CResponderConfig * responderConfig = [[TILC2CResponderConfig alloc] init];
responderConfig.callInvitation = self.invite; // 将捕获的邀请对象传入配置属性中
c2cConfig.responderConfig = responderConfig;
// 生成并初始化通话对象
TILC2CCall * call = [[TILC2CCall alloc] initWithConfig:c2cConfig];

// 添加渲染视图
UIView * renderView = [call createRenderViewIn:self.view];
[recvView addSubview:renderView];

// 接受通话请求
[call accept:^(TILCallError *err) {
        if (err) {
            NSLog（@"接受失败"）;;
        }
        else {
        	// 加载对方的渲染结果
            CGRect peerRect = recvView.bounds;
            [call addRenderFor:[call getPeer] atFrame:peerRect];
            // 加载自己的渲染结果
            CGRect selfRect = CGRectMake(0,0,60,80);
            [call addSelfRender:selfRect];
        }
    }];

```

参数  | 说明
--- | ---
callInvitation | 捕获到的来电邀请对象 
其他参数 | 参考[发起通话参数列表](#TILMakeCallParam)

**主意事项：**
1. 接收方需要设置isSponsor、callType、peerId、responderConfig，否则不能正常工作。

### 2.5 如何结束通话

对于发起方，如果希望在对方相应通话请求前取消通话，需要调用如下接口。

**取消通话邀请：**

```
@interface TILC2CCall : TILBaseCall

/**
 取消通话邀请

 @param result 取消结果
 */
- (void)cancelCall:(TILResultBlock)result;

@end

```

在其他情况下，调用如下接口。

**结束通话：**

```
@interface TILC2CCall : TILBaseCall

/**
 挂断通话
 
 @param result 挂断结果
 */
- (void)hangup:(TILResultBlock)result;

@end

```

## 3. API文档

TILCallSDK除了提供上述请求通话和接收通话的功能外，更高级的能力如下。

### 3.1 通话的基本信息

**获取通话的基本信息：**

```

@interface TILC2CCall : TILBaseCall

/**
 获取通话类型

 @return 通话类型
 */
- (TILCallType)getCallType;

/**
 获取通话成员列表

 @return 成员（TILCallMember*）列表
 */
- (NSArray*)getMembers;

/**
 获取上行视频的成员列表

 @return 成员（TILCallMember*）列表
 */
- (NSArray*)getVideoMembers;


/**
 获取上行音频的成员列表

 @return 成员（TILCallMember*）列表
 */
- (NSArray*)getAudioMembers;

@end

```

**监听通话状态变化：**

```
@protocol TILC2CCallStatusListener <NSObject>
/**
 建立通话成功
 */
- (void)onCallEstablish;

/**
 通话结束

 @param code 结束原因
 */
- (void)onCallEnd:(TILC2CCallEndCode)code;

@end

```

### 3.2 控制通话的渲染结果

```
@interface TILC2CCall : TILBaseCall

/**
 获得可渲染的view

 @param view 承载渲染view的view

 @return 可渲染的view
 */
- (UIView*)createRenderViewIn:(UIView*)view;

/**
 在给定区域绘制用户的视频结果

 @param uid  用户id
 @param rect 位置区域
 */
- (void)addRenderFor:(NSString *)uid atFrame:(CGRect)rect;

/**
 在给定区域绘制自己的视频结果

 @param rect 位置区域
 */
- (void)addSelfRender:(CGRect)rect;

/**
 移除用户的渲染结果

 @param uid 用户id
 */
- (void)removeRenderFor:(NSString*)uid;

/**
 移除自己的渲染结果
 */
- (void)removeSelfRender;

/**
 移动已有用户渲染结果的区域，否则新建用户的渲染结果

 @param uid  用户id
 @param rect 新的区域
 */
- (void)modifyRenderFor:(NSString*)uid toFrame:(CGRect)rect;

@end
```

### 3.3 管理通话中的摄像头、麦克风和扬声器

**管理自己的设备：**

```

@interface TILC2CCall : TILBaseCall

/**
 设置开启/关闭摄像头

 @param enable 是否开启
 @param pos    摄像头位置
 @param result 开启结果
 */
- (void)enableCamera:(BOOL)enable pos:(TILCallCameraPos)pos result:(TILResultBlock)result;

/**
 是否开启了摄像头

 @return YES 已开启
 */
- (BOOL)isCameraEnabled;

/**
 切换摄像头位置

 @param pos    摄像头位置
 @param result 切换结果
 */
- (void)switchCamera:(TILCallCameraPos)pos result:(TILResultBlock)result;

/**
 获取摄像头位置

 @return 摄像头位置
 */
- (TILCallCameraPos)getCameraPos;

/**
 开启/关闭扬声器

 @param enable 是否开启扬声器

 @return 操作结果
 */

/**
 开启/关闭扬声器

 @param enable 是否开启扬声器
 @param result 操作结果
 */
- (void)enableSpeaker:(BOOL)enable result:(TILResultBlock)result;

/**
 是否开启了扬声器

 @return YES 已开启
 */
- (BOOL)isSpeakerEnabled;

/**
 开启/关闭麦克风
 
 @param enable 是否开启麦克风
 
 @return 操作结果
 */

/**
 开启/关闭麦克风

 @param enable 是否开启麦克风
 @param result 操作结果
 */
- (void)enableMic:(BOOL)enable result:(TILResultBlock)result;

/**
 是否开启了麦克风
 
 @return YES 已开启
 */
- (BOOL)isMicEnabled;

@end

```

**监听通话中设备状态变化：**

```

@protocol TILCallMemberEventListener <NSObject>
@optional

/**
 成员有视频流事件

 @param isOn    YES 开启视频流
 @param members TILCallMember*列表
 */
- (void)onMemberCameraVideoOn:(BOOL)isOn members:(NSArray*)members;

/**
 成员音频流事件

 @param isOn    YES 开启音频流
 @param members TILCallMember*列表
 */
- (void)onMemberAudioOn:(BOOL)isOn members:(NSArray*)members;

@end

```

### 3.4 发送IM消息和控制信令

**发送消息和通知：**

```
/**
 向对方发送消息
 
 @param msg    消息
 @param result 发送结果
 */
- (void)sendMessage:(TIMMessage*)msg result:(TILResultBlock)result;

/**
 获取聊天消息，last为nil时返回最新的消息
 
 @param last  最新的一条消息
 @param count 获取的数目
 
 @return 返回的消息
 */
- (NSArray*)getMessages:(TIMMessage*)last count:(uint32_t)count;

/**
 将消息缓存中的消息数减少为size
 
 @param size 缓存中消息的数目
 */
- (void)resizeMessageCache:(uint32_t)size;

/**
 发送自定义通知

 @param notif  通知
 @param result 发送结果
 */
- (void)postNotification:(TILCallNotification*)notif result:(TILResultBlock)result;

```

**监听消息和通知的协议：**

```
/**
 事件通知监听协议
 */
@protocol TILCallNotificationListener <NSObject>
@optional

/**
 监听通知

 @param notify 通知
 */
- (void)onRecvNotification:(TILCallNotification*)notify;

@end


/**
 C2C通话消息监听协议
 */
@protocol TILC2CCallMessageListener <NSObject>
@optional

/**
 新消息通知

 @param messages 新消息（TIMMessage*）列表
 */
- (void)onNewMessages:(NSArray*)messages;

/**
 消息缓存量通知

 @param count 当前缓存的消息数
 */
- (void)onMessageCountUpdate:(uint32_t)count;

@end

```
