# 使用TILiveSDK只需要以下三步就可以开始直播啦。

> 1.初始化ILiveSDK
> 2.帐号登录
> 3.创建房间（进入房间）

# 1. 初始化ILiveSDK

在应用启动的时候初始化ILiveSDK。

```
[[ILiveSDK getInstance] initSdk:SDKAppID accountType:AccountType];
//SDKAppID: 在腾讯云申请的APP唯一标识
//AccountType：对应SDKAppID的帐号类型
```

# 2 帐号登录

托管模式：用户帐号系统托管到腾讯云。 独立模式：用户帐号系统由用户自己的服务器维护。独立模式需要获取sig

托管模式

```
[[ILiveLoginManager getInstance] tlsLogin:name pwd:pwd succ:^{
    NSLog(@"登录成功");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
    NSLog(@"登录失败");
}];
```

独立模式

```
[[ILiveLoginManager getInstance] iLiveLogin:name sig:sig succ:^{
    NSLog(@"登录成功");
} failed:^(NSString *moudle, int errId, NSString *errMsg) {
    NSLog(@"登录失败");
}];
```

3 创建房间（进入房间）

主播创建房间

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

观众进入房间

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
