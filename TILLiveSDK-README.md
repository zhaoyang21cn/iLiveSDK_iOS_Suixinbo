
简介：TILLiveSDK基于ILiveSDK封装了直播的基础业务，包括创建直播、进入直播、邀请上麦、文本互动等功能，旨在为用户提供一套快速集成音视频能力的直播业务解决方案。顺利集成只需要一天就能打造属于自己的直播APP。

----------

# 1. 预先集成ILiveSDK

用户在使用TILCallSDK前需要预先集成、初始化和登录ILiveSDK，集成步骤见下文。
<span id="ILiveSDK"></span>

## 1.1 开始集成

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
ILiveRoomOption *option = [ILiveRoomOption defaultHostLiveOption]; //默认主播配置
TILLiveManager *manager = [TILLiveManager getInstance];
[manager setAVRootView:self.view]; //设置渲染承载的视图
[manager addAVRenderView:self.view.bounds forKey:self.host]; //添加渲染位置

[manager createRoom:self.roomId option:option succ:^{
NSLog(@"创建房间成功");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
NSLog(@"创建房间失败");
}];
```
#### 观众进入房间
```
ILiveRoomOption *option = [ILiveRoomOption defaultGuestLiveOption]; //默认观众配置
TILLiveManager *manager = [TILLiveManager getInstance];
[manager setAVRootView:self.view]; //设置渲染承载的视图
[manager addAVRenderView:self.view.bounds forKey:self.host]; //添加渲染位置

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
// 1. 在创建或进入房间前设置事件和消息监听。
TILLiveManager *manager = [TILLiveManager getInstance];
[manager setAVListener:self]; //设置音视频事件监听
[manager setIMListener:self]; //设置消息监听
```

```
// 2. 主播发送上麦自定义消息
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
// 3. 观众接受邀请开始上麦（观众在消息回调中可以收到主播发送自定义消息）
- (void)onCustomMessage:(ILVLiveCustomMessage *)msg{
TILLiveManager *manager = [TILLiveManager getInstance];
switch (msg.cmd) {
case ILVLIVE_IMCMD_INVITE:
{
//收到邀请调用上麦接口
[manager upToVideoMember:ILVLIVEAUTH_INTERACT role:@"腾讯云后台配置的角色" succ:^{
NSLog(@"上麦成功"); 
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
NSLog(@"上麦失败"); 
}];
}
default:
break;
}
}
```
```
// 4. 主播或观众添加上麦者渲染位置（主播或观众在音视频事件回调中收到摄像头打开事件时，指定上麦观众的渲染位置）
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
[manager addAVRenderView:CGRectMake(20, 20, 120, 160) forKey:user];
}
}
break;
}
default:
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
}];## 标题 ##
```

```
// 2. 文本消息接收（在文本消息回调中接受文本消息）
- (void)onTextMessage:(ILVLiveTextMessage *)msg{
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
