
 因GitHub有文件大小限制，现将ILiveSDK、IMSDK、AVSDK以及相关Framework上传到腾讯云COS上。 更新时，请到对应的地址进行更新，并添加到工程下面对应的目录下.

Frameworks : http://dldir1.qq.com/hudongzhibo/ILiveSDK/Frameworks.zip 下载后解压，然后再放至对应放到工程目录 TILLiveSDKShow/

简介：ILiveSDK(全称:Interactive Live SDK)整合了互动直播SDK(AVSDK)，即时通讯SDK(IMSDK)，登录服务(TLSSDK)等几大模块，致力于提供一套完整的音视频即时通讯解决方案，提供“连麦”，“多画面特效”，打造跨平台一对多，多对多的酷炫直播场景。ILiveSDK旨在无限可能的降低用户接入成本，从用户角度考虑问题，全方位考虑用户接入体验，并提供接入服务专业定向支持，为用户应用上线保驾护航，本文档目的在于帮助用户快速接入使用ILiveSDK,达到主播端画面本地渲染，观众端可进入房间观看主播端画面的效果。

主要功能接口列表：

接口|所属类别|描述
---|---|---
initSdk:accountType|ILiveSDK|ILiveSDK初始化接口，传入appid和accountType
tlsLogin:pwd:succ:fail:|ILiveLoginManager|托管模式登录接口，传入用户名和密码
tlsLogout:succ:fail:|ILiveLoginManager	|托管模式登出接口
iLiveLogin:sig:succ:fail:|ILiveLoginManager|独立模式登录接口
iLiveLogout:succ:fail:|ILiveLoginManager|独立模式登出接口
createRoom:option:succ:fail:|ILiveRoomManager|创建直播间(主播调用)
joinRoom:iotion:succ:fail|ILiveRoomManager|加入直播间(观众调用)
quitRoom:succ:fail|ILiveRoomManager|退出直播间
createGLViewIn:|ILiveRoomManager|创建渲染根视图
addRenderAt:forKey:|ILiveGLBaseView	|创建渲染子视图

通过以上简单的接口，即可实现简易的直播方案。

本文档介绍3个SDK的集成和使用，分别是ILiveSDK，TILLiveSDK，TILCallSDK，架构关系如下：
![](http://img.blog.csdn.net/20161104170912962)

----------

请特别注意，这几个SDK是相互组合使用，不同场景使用不同的组合

直播场景：ILiveSDK+TILLiveSDK

可视电话：ILiveSDK+TILCallSDK

----------


#ILiveSDK集成和使用
## 1、新建工程
### 1.1创建Single View Application
![](http://img.blog.csdn.net/20161104162329407)

命名ILiveSDKDemo
![](http://img.blog.csdn.net/20161104162412611)

此时工程目录应该是下图这样的，如果不是，请重新创建工程

![](http://img.blog.csdn.net/20161104162443849)

## 2、下载相关模块SDK解压放到目录TCILiveSDKDemo/，并导入工程
导入之后的工程目录应该是如下图所示，如果不是，请重新导入。（文章开头处有下载链接）

![](http://img.blog.csdn.net/20161104162726288)

## 3、导入系统库
导入系统库之后的工程目录应该是如下图所示，如果不是，请重新导入

![](http://img.blog.csdn.net/20161104162855134)

## 4、工程配置
4.1连接配置

![](http://img.blog.csdn.net/20161104162928476)

### 4.2 Bitcode配置

![](http://img.blog.csdn.net/20161104162940211)



注：完成以上4个步骤，ILiveSDK集成工作已经完成，接下来验证一下是否集成成功，在ViewController中打印ILiveSDK版本号，

```
NSString *ver = [[ILiveSDK getInstance] getVersion];
NSLog(@”ILiveSDK Version is %@”, ver);
```
如果打印失败，请检查以上4个步骤。

下面的步骤是简单的使用接口方法，一下操作是建立在集成成功的基础上进行的：
调用顺序和示例代码：
## 5、初始化和登录

```
[[ILiveSDK getInstance] initSdk:[kSdkAppId intValue] accountType:[kSdkAccountType intValue]];
[[ILiveLoginManager getInstance] tlsLogin:@"userid" pwd:password succ:^{
NSLog(@"-----> succ");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
NSLog(@"-----> fail %@,%d,%@",moudle,errId,errMsg);
}];
```

## 6、创建房间(主播)

```
__weak LiveViewController *ws = self;
ILiveRoomOption *option = [ILiveRoomOption defaultHostLiveOption];
[[ILiveRoomManager getInstance] createRoom:47589374 option:option succ:^{
NSLog(@"-----> create room succ");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
NSLog(@"-----> create room fail,%@ %d %@",moudle, errId, errMsg);
}];
```

## 7、加入房间(观众)

```
__weak LiveViewController *ws = self;
ILiveRoomOption *option = [ILiveRoomOption defaultGuestLiveOption];
[[ILiveRoomManager getInstance] joinRoom:47589374 option:option succ:^{
NSLog(@"-----> join room succ");
} failed:^(NSString *module, int errId, NSString *errMsg) {
NSLog(@"-----> join room fail,%@ %d %@",module, errId, errMsg);
}];
```

## 8、添加渲染视图
注：添加渲染视图必须在创建房间成功回调之后，addRenderAt:forKey接口，如果是主播端，那直接传主播的登录id，如果是观众端，就传如画面所属成员的id(主播id)，也就是说，这里保证key一定是画面所属成员的id。
```
ILiveGLBaseView *baseView = [[ILiveRoomManager getInstance] createGLViewIn:ws.view];
[baseView addRenderAt:ws.view.bounds forKey:@"userid"];
```
以上步骤如果都执行成功，那么在测试机上可以看到视屏画面了。
## 9、API文档
------
#TILLiveSDK集成和使用
------
TILLiveSDK基于ILiveSDK封装了直播的基础业务，包括创建直播、进入直播、邀请上麦、文本互动等功能，旨在为用户提供一套快速集成音视频能力的直播业务解决方案。顺利集成只需要一天就能打造属于自己的直播APP。

> * 基础功能（直播，观看）
> * 高级功能（上麦，文本互动）

##1. 基础功能
使用TILiveSDK只需要以下三步就可以开始直播啦。
> * 初始化ILiveSDK
> * 帐号登录
> * 创建房间（进入房间）


###1.1 初始化ILiveSDK
在应用启动的时候初始化ILiveSDK。
```
[[ILiveSDK getInstance] initSdk:SDKAppID accountType:AccountType];

SDKAppID: 在腾讯云申请的APP唯一标识
AccountType：对应SDKAppID的帐号类型
```
###1.2 帐号登录
托管模式：用户帐号系统托管到腾讯云。
独立模式：用户帐号系统由用户自己的服务器维护。独立模式需要获取sig
####托管模式
```
[[ILiveLoginManager getInstance] tlsLogin:name pwd:pwd succ:^{
NSLog(@"登录成功");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
NSLog(@"登录失败");
}];
```
####独立模式
```
[[ILiveLoginManager getInstance] iLiveLogin:name sig:sig succ:^{
NSLog(@"登录成功");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
NSLog(@"登录失败");
}];
```
###1.3 创建房间（进入房间）
####主播创建房间
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
####观众进入房间
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
##2. 高级功能

> * 观众上麦
> * 文本互动
> * 其他个性化功能

###2.1 观众上麦
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

###2.2 文本互动
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

###2.3 其他个性化功能
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

------
# TILCallSDK(多人通话)集成和使用
-------

请参照这里 https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/TILCallSDK-README.md
