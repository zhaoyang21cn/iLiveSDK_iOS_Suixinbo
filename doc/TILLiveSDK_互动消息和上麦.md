#  高级功能(互动消息和上麦)

> * 观众上麦
> * 文本互动
> * 其他个性化功能

### 1 观众上麦
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
- (void)onCustomMessage:(ILVLiveCustomMessage *)msg
{
  TILLiveManager *manager = [TILLiveManager getInstance];
  switch (msg.cmd) 
  {
    case ILVLIVE_IMCMD_INVITE:
    {
      //收到邀请调用上麦接口
      [manager upToVideoMember:ILVLIVEAUTH_INTERACT role:@"腾讯云后台配置的角色" succ:^{
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
// 4. 主播或观众添加上麦者渲染位置（主播或观众在音视频事件回调中收到摄像头打开事件时，指定上麦观众的渲染位置）
- (void)onUserUpdateInfo:(ILVLiveAVEvent)event users:(NSArray *)users
{
  TILLiveManager *manager = [TILLiveManager getInstance];
  switch (event) 
  {
    case ILVLIVE_AVEVENT_CAMERA_ON:
    {
      for (NSString *user in users) 
      {
        //因为主播的渲染位置创建或进入房间的时候已经指定，这里不需要再指定。
        //当然也可根据自己的逻辑再此处指定主播的渲染位置。
        if(![user isEqualToString:self.host])
        { 
          [manager addAVRenderView:CGRectMake(20, 20, 120, 160) forKey:user];
        }
      }	
    }
    break;
  }
}
```
到此，观众完成上麦，可以和主播以及其他观众视频互动。

###  2 文本互动
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

### 3 其他个性化功能
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
