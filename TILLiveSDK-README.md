
简介：TILLiveSDK基于ILiveSDK封装了直播的基础业务，包括创建直播、进入直播、邀请上麦、文本互动等功能，旨在为用户提供一套快速集成音视频能力的直播业务解决方案。顺利集成只需要一天就能打造属于自己的直播APP。[查看版本更新](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/doc/TILLiveSDK_ChangeList.md)

![](http://mc.qcloudimg.com/static/img/ad9de8957129351ffe24b54c44520490/image.png)

----------

# 1. 预先集成ILiveSDK

用户在使用TILLiveSDK前需要预先集成、初始化和登录ILiveSDK，[集成ILiveSDK步骤](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/ILiveSDK-README.md)。

# 2. TILLiveSDK集成和使用
TILLiveSDK基于ILiveSDK封装了直播的基础业务，包括创建直播、进入直播、邀请上麦、文本互动等功能，旨在为用户提供一套快速集成音视频能力的直播业务解决方案。顺利集成只需要一天就能打造属于自己的直播APP。

> * 基础功能（直播，观看）
> * 高级功能（上麦，文本互动）

## 2.1 基础功能
使用TILiveSDK只需要以下三步就可以开始直播啦。
> * 初始化ILiveSDK
> * 帐号登录
> * 创建房间（进入房间）


### 2.1.1 初始化ILiveSDK
在应用启动的时候初始化ILiveSDK。
```
[[ILiveSDK getInstance] initSdk:SDKAppID accountType:AccountType];

SDKAppID: 在腾讯云申请的APP唯一标识
AccountType：对应SDKAppID的帐号类型
```
### 2.1.2 帐号登录
托管模式：用户帐号系统托管到腾讯云。
独立模式：用户帐号系统由用户自己的服务器维护。独立模式需要获取sig
#### 托管模式
```
[[ILiveLoginManager getInstance] tlsLogin:name pwd:pwd succ:^{
  NSLog(@"登录成功");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
  NSLog(@"登录失败");
}];
```
#### 独立模式
```
[[ILiveLoginManager getInstance] iLiveLogin:name sig:sig succ:^{
  NSLog(@"登录成功");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
  NSLog(@"登录失败");
}];
```
### 2.1.3 创建房间（进入房间）
#### 主播创建房间
```
TILLiveRoomOption *option = [TILLiveRoomOption defaultHostLiveOption]; //默认主播配置
option.controlRole = @"腾讯云后台配置的主播角色";//配置spear角色

TILLiveManager *manager = [TILLiveManager getInstance];
[manager setAVListener:self];//av事件监听
[manager setIMListener:self];//im消息监听
[manager setAVRootView:self.view]; //设置渲染承载的视图
[manager addAVRenderView:viewRect forIdentifier:userIdentifier srcType:QAVVIDEO_SRC_TYPE_CAMERA]; //添加渲染位置
//viewRect 添加的渲染视图的frame
//userIdentifier 渲染视图渲染的是哪个用户的画面，userIdentifier就是这个用户的id
//QAVVIDEO_SRC_TYPE_CAMERA:相机采集的画面，QAVVIDEO_SRC_TYPE_SCREEN：屏幕分享画面

[manager createRoom:self.roomId option:option succ:^{
  NSLog(@"创建房间成功");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
  NSLog(@"创建房间失败");
}];
```
#### 观众进入房间
```
TILLiveRoomOption *option = [TILLiveRoomOption defaultGuestLiveOption]; //默认观众配置
option.controlRole = @"腾讯云后台配置的观众角色";//配置spear角色

TILLiveManager *manager = [TILLiveManager getInstance];
[manager setAVListener:self];
[manager setIMListener:self];
[manager setAVRootView:self.view]; //设置渲染承载的视图
[manager addAVRenderView:viewRect forIdentifier:userIdentifier srcType:QAVVIDEO_SRC_TYPE_CAMERA]; //添加渲染位置
//viewRect 添加的渲染视图的frame
//userIdentifier 渲染视图渲染的是哪个用户的画面，userIdentifier就是这个用户的id
//QAVVIDEO_SRC_TYPE_CAMERA:相机采集的画面，QAVVIDEO_SRC_TYPE_SCREEN：屏幕分享画面

[manager joinRoom:self.roomId option:option succ:^{
  NSLog(@"进入房间成功");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
  NSLog(@"进入房间失败");
}];
```
到此，主播可以开始主播，观众可以看到主播画面。
## 2.2 高级功能

> * 观众上麦
> * 文本互动
> * 其他个性化功能

### 2.2.1 观众上麦

```
// 1. 主播发送上麦自定义消息
TILLiveManager *manager = [TILLiveManager getInstance];
ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
msg.cmd = ILVLIVE_IMCMD_INVITE;     //邀请信令
msg.recvId = recvId;                //被邀请者id
msg.type = ILVLIVE_IMTYPE_C2C;      //C2C消息类型

[manager sendCustomMessage:msg succ:^{
  NSLog(@"邀请成功");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
  NSLog(@"邀请失败"); 
}];
```
```
// 2. 观众接受邀请开始上麦（观众在消息回调中可以收到主播发送自定义消息）
- (void)onCustomMessage:(ILVLiveCustomMessage *)msg{
  TILLiveManager *manager = [TILLiveManager getInstance];
  switch (msg.cmd) 
  {
    case ILVLIVE_IMCMD_INVITE:
    {
    //收到邀请调用上麦接口
      [manager upToVideoMember:ILVLIVEAUTH_INTERACT role:@"腾讯云后台配置的上麦角色" succ:^{
        NSLog(@"上麦成功"); 
      } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        NSLog(@"上麦失败"); 
      }];
    }
    break;
  }
}
```
```
// 3. 主播或观众添加上麦者渲染位置（主播或观众在音视频事件回调中收到摄像头打开事件时，指定上麦观众的渲染位置）
- (void)onUserUpdateInfo:(ILVLiveAVEvent)event users:(NSArray *)users
{
  TILLiveManager *manager = [TILLiveManager getInstance];
  switch (event) {
    case ILVLIVE_AVEVENT_CAMERA_ON:
    {
      for (NSString *user in users) {
        //因为主播的渲染位置创建或进入房间的时候已经指定，这里不需要再指定。
        //当然也可根据自己的逻辑再此处指定主播的渲染位置。
        if(![user isEqualToString:self.host]){ 
          [manager addAVRenderView:CGRectMake(20, 20, 120, 160) forIdentifier:user srcType:QAVVIDEO_SRC_TYPE_CAMERA];
        }
    }
    break;
  }
}
```
到此，观众完成上麦，可以和主播以及其他观众视频互动。

### 2.2.2 文本互动
主播或观众可以发送文本消息进行互动。
```
// 1. 发送文本消息
TILLiveManager *manager = [TILLiveManager getInstance];
ILVLiveTextMessage *msg = [[ILVLiveTextMessage alloc] init];
msg.text = text;                    //消息内容
msg.type = ILVLIVE_IMTYPE_GROUP;    //群消息（也可发C2C消息）
[manager sendTextMessage:msg succ:^{
  NSLog(@"发送成功");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
  NSLog(@"发送失败");
}];
```

```
// 2. 文本消息接收（在文本消息回调中接受文本消息）
- (void)onTextMessage:(ILVLiveTextMessage *)msg
{
  NSLog(@"收到消息：%@", msg.text);
}
```

### 2.2.3 其他个性化功能
大部分个性化功能可以以自定义消息为信令通道来实现。如点赞、送礼物等。但是信令范围必须控制在以下范围。
```
/**
* 自定义消息段下限
*/
ILVLIVE_IMCMD_CUSTOM_LOW_LIMIT     = 0x800,
/**
* 自定义消息段上限
*/
ILVLIVE_IMCMD_CUSTOM_UP_LIMIT      = 0x900,
```
自定义消息的发送和接收与主播邀请观众上麦类似，此处不再赘述。
