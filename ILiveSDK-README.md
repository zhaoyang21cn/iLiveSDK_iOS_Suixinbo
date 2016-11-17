
简介：ILiveSDK(全称:Interactive Live SDK)整合了互动直播SDK(AVSDK)，即时通讯SDK(IMSDK)，登录服务(TLSSDK)等几大模块，致力于提供一套完整的音视频即时通讯解决方案，提供“连麦”，“多画面特效”，打造跨平台一对多，多对多的酷炫直播场景。ILiveSDK旨在无限可能的降低用户接入成本，从用户角度考虑问题，全方位考虑用户接入体验，并提供接入服务专业定向支持，为用户应用上线保驾护航，本文档目的在于帮助用户快速接入使用ILiveSDK,达到主播端画面本地渲染，观众端可进入房间观看主播端画面的效果。

# ILiveSDK集成和使用
## 1、新建工程
### 1.1创建Single View Application
![](http://img.blog.csdn.net/20161104162329407)

命名ILiveSDKDemo
![](http://img.blog.csdn.net/20161104162412611)

此时工程目录应该是下图这样的，如果不是，请重新创建工程

![](http://img.blog.csdn.net/20161104162443849)

## 2、下载相关模块SDK解压放到目录TCILiveSDKDemo/，并导入工程
导入之后的工程目录应该是如下图所示，如果不是，请重新导入。（Framework下载在[这里](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos)）

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
## 9、[API文档](https://zhaoyang21cn.github.io/ilivesdk_help/ios_help/)
