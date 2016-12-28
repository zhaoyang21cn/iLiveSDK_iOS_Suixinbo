//
//  LiveViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LiveViewController.h"

#define kHeartInterval 10 //心跳间隔

@interface LiveViewController ()<ILVLiveIMListener,ILVLiveAVListener, LiveUIDelegate>

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *heartTimer;
@end

@implementation LiveViewController

- (instancetype)initWith:(TCShowLiveListItem *)item
{
    if (self = [super init])
    {
        _liveItem = item;
        
        NSString *loginId = [[ILiveLoginManager getInstance] getLoginId];
        
        _isHost = [loginId isEqualToString:item.host.uid];
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //初始化直播
    [self initLive];
    
    //创建房间
    if (_isHost)
    {
        [self createRoom:_liveItem.avRoomId groupId:_liveItem.chatRoomId];
    }
    else
    {
        [self joinRoom:_liveItem.avRoomId groupId:_liveItem.chatRoomId];
    }
    
    //上报server
    [self reportRoomInfo:_liveItem.avRoomId];
    
    //发送心跳
    [self startLiveTimer];
    
    [self addSubviews];
}

- (void)createRoom:(int)roomId groupId:(NSString *)groupid
{
    __weak typeof(self) ws = self;
    
    ILiveRoomOption *option = [ILiveRoomOption defaultHostLiveOption];
    option.controlRole = kSxbRole_Host;
    
    LoadView *createRoomWaitView = [LoadView loadViewWith:@"正在创建房间"];
    [self.view addSubview:createRoomWaitView];
    
    [[TILLiveManager getInstance] createRoom:roomId option:option succ:^{
        
        NSLog(@"createRoom succ");
        [createRoomWaitView removeFromSuperview];
        
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        
        [createRoomWaitView removeFromSuperview];
        
        NSString *errinfo = [NSString stringWithFormat:@"module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
        NSLog(@"createRoom fail.%@",errinfo);
        
        [ws showAlert:@"创建房间失败" message:errinfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
    }];
}

- (void)joinRoom:(int)roomId groupId:(NSString *)groupid
{
    ILiveRoomOption *option = [ILiveRoomOption defaultGuestLiveOption];
    option.controlRole = kSxbRole_Guest;

    __weak typeof(self) ws = self;
    [[TILLiveManager getInstance] joinRoom:roomId option:option succ:^{
        NSLog(@"join room succ");
        [ws sendJoinRoomMsg];

    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"join room fail. module=%@,errid=%d,errmsg=%@",module,errId,errMsg);
    }];
}

- (void)sendJoinRoomMsg
{
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.type = ILVLIVE_IMTYPE_GROUP;
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_EnterLive;
    //    msg.sendId = [[ILiveLoginManager getInstance] getLoginId];
    msg.recvId = [[ILiveRoomManager getInstance] getIMGroupId];
    
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        NSLog(@"succ");
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"fail");
    }];
}

- (void)reportRoomInfo:(int)roomId
{
    LoadView *uploadToServerWaitView = [LoadView loadViewWith:@"上传房间信息"];
    [self.view addSubview:uploadToServerWaitView];
    
    __weak typeof(self) ws = self;
    //上传直播信息到随心播业务后台
    LiveStartRequest *req = [[LiveStartRequest alloc] initWithHandler:^(BaseRequest *request) {
        
        [uploadToServerWaitView removeFromSuperview];
        NSLog(@"-----> 上传成功");
        
        [ws dismissViewControllerAnimated:NO completion:nil];
        
//        TCShowLiveListItem *item = [[TCShowLiveListItem alloc] init];
//        TCShowUser *user = [[TCShowUser alloc] init];
//        user.uid = [[ILiveLoginManager getInstance] getLoginId];
//        item.host = user;
//        
//        LiveViewController *liveVC = [[LiveViewController alloc] initWith:item];
//        [[AppDelegate sharedAppDelegate] pushViewController:liveVC];
        
    } failHandler:^(BaseRequest *request) {
        
        [uploadToServerWaitView removeFromSuperview];
        // 上传失败
        NSLog(@"-----> 上传失败");
        
        NSString *errinfo = [NSString stringWithFormat:@"code=%ld,msg=%@",(long)request.response.errorCode,request.response.errorInfo];
        [ws showAlert:@"上传RoomInfo失败" message:errinfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
    }];
    
    req.liveItem = [[TCShowLiveListItem alloc] init]; //(TCShowLiveListItem *)self.liveController.roomInfo;
    req.liveItem.title = _liveItem.title;
    req.liveItem.avRoomId = roomId;
    req.liveItem.chatRoomId = [[ILiveRoomManager getInstance] getIMGroupId];
    
    TCShowUser *host = [[TCShowUser alloc] init];
    host.uid = [[ILiveLoginManager getInstance] getLoginId];
    host.username = host.uid;
    req.liveItem.host = host;
    
    [[WebServiceEngine sharedEngine] asyncRequest:req wait:NO];
}

- (void)addSubviews
{
    _liveUI = [[LiveUIViewController alloc] initWith:_liveItem];
    _liveUI.isHost = _isHost;
    [self.view addSubview:_liveUI.view];
    [_liveUI.view bringSubviewToFront:self.view];
    
    [self addChildViewController:_liveUI];
    
    _liveUI.delegate = self;
}

- (void)initLive
{
    TILLiveManager *manager = [TILLiveManager getInstance];
    [manager setAVListener:self];
    [manager setIMListener:self];
    [manager setAVRootView:self.view];
//    [manager addAVRenderView:self.view.bounds forIdentifier:_liveItem.uid srcType:QAVVIDEO_SRC_TYPE_CAMERA];
}

- (void)showAlert:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle ok:(ActionHandle)succ cancel:(ActionHandle)fail
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    if (okTitle)
    {
        [alert addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:succ]];
    }
    if (cancelTitle)
    {
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:fail]];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

//上麦
- (void)upToVideo:(id)sender
{
//    [[TILLiveManager getInstance] upToVideoMember:ILVLIVEAUTH_INTERACT role:kSxbRole_Interact succ:^{
//        NSLog(@"up video succ");
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kUserUpVideo_Notification object:nil];
//    } failed:^(NSString *module, int errId, NSString *errMsg) {
//        NSLog(@"up video  fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg);
//    }];
    
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.type = ILVLIVE_IMTYPE_C2C;
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_Multi_Interact_Join;
    msg.recvId = _liveItem.host.uid;
    
    __weak typeof(self) ws = self;
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        
        NSString *loginId = [[ILiveLoginManager getInstance] getLoginId];
        
        TILLiveManager *manager = [TILLiveManager getInstance];
//        [manager addAVRenderView:[ws getRenderFrame] forKey:loginId];
        [manager addAVRenderView:[ws getRenderFrame] forIdentifier:loginId srcType:QAVVIDEO_SRC_TYPE_CAMERA];
        
        ILiveRoomManager *roomManager = [ILiveRoomManager getInstance];
        
            [roomManager changeRole:kSxbRole_Interact succ:^{
                
                NSLog(@"changeRole");
                
                [roomManager enableCamera:CameraPosFront enable:YES succ:^{
                    
                    NSLog(@"enable camera YES");
                    
                    [roomManager enableMic:YES succ:^{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kUserUpVideo_Notification object:nil];
                        
                    } failed:^(NSString *module, int errId, NSString *errMsg) {
                    NSLog(@"enable mic fail");
                    }];
                    
                } failed:^(NSString *module, int errId, NSString *errMsg) {
                NSLog(@"enable camera fail");
                }];

            } failed:^(NSString *module, int errId, NSString *errMsg) {
            NSLog(@"change role fail");
            }];
            
        } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"fail");
    }];
}

//下麦
- (void)downToVideo:(id)sender
{
//    [[TILLiveManager getInstance] downToVideoMember:ILVLIVEAUTH_GUEST role:kSxbRole_Guest succ:^{
//        NSLog(@"down video succ");
//        [[NSNotificationCenter defaultCenter] postNotificationName:kUserDownVideo_Notification object:nil];
//    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
//        NSLog(@"down video fail.module=%@,errid=%d,errmsg=%@",moudle,errId,errMsg);
//    }];
    
    ILiveRoomManager *manager = [ILiveRoomManager getInstance];
    
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.type = ILVLIVE_IMTYPE_GROUP;
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_Multi_CancelInteract;
    msg.recvId = [[ILiveRoomManager getInstance] getIMGroupId];
    
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        [manager changeRole:kSxbRole_Guest succ:^ {
            TCILDebugLog(@"down to video: change role succ");
            cameraPos pos = [[ILiveRoomManager getInstance] getCurCameraPos];
            [manager enableCamera:pos enable:NO succ:^{
                TCILDebugLog(@"down to video: disable camera succ");
                [manager enableMic:NO succ:^{
                    TCILDebugLog(@"down to video: disable mic succ");
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDownVideo_Notification object:nil];
                } failed:^(NSString *module, int errId, NSString *errMsg) {
                    TCILDebugLog(@"down to video: disable mic fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
                    
                }];
            } failed:^(NSString *module, int errId, NSString *errMsg) {
                TCILDebugLog(@"down to video: disable camera fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
                
            }];
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            TCILDebugLog(@"down to video: change role fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
            
        }];
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        TCILDebugLog(@"down to video: change auth fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
    }];
}

//拒绝上麦
- (void)rejectToVideo:(id)sender
{
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_INTERACT_REJECT;
    msg.recvId = _liveItem.host.uid;
    msg.type = ILVLIVE_IMTYPE_C2C;
    
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        NSLog(@"refuse video succ");
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        NSLog(@"refuse video  fail.module=%@,errid=%d,errmsg=%@",moudle,errId,errMsg);
    }];
}

- (void)onCustomMessage:(ILVLiveCustomMessage *)msg
{
    int cmd = msg.cmd;
    if (msg.type == ILVLIVE_IMTYPE_C2C)
    {
        switch (cmd)
        {
            
            case AVIMCMD_Multi_Host_Invite:
            {
                [self showAlert:@"收到视频邀请" message:msg.sendId okTitle:@"接收" cancelTitle:@"拒绝" ok:^(UIAlertAction * _Nonnull action) {
                    [self upToVideo:nil];
                } cancel:^(UIAlertAction * _Nonnull action) {
                    [self rejectToVideo:nil];
                }];
            }
                break;
//            case AVIMCMD_Multi_Interact_Join:
//                [[NSNotificationCenter defaultCenter] postNotificationName:kUserJoinRoom_Notification object:nil];
//                break;
            default:
                break;
        }
    }
    else if (msg.type == ILVLIVE_IMTYPE_GROUP)
    {
        switch (cmd) {
            case AVIMCMD_Praise:
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserParise_Notification object:nil];
                break;
//            case ILVLIVE_IMCMD_LEAVE:
//                [[NSNotificationCenter defaultCenter] postNotificationName:kUserExitRoom_Notification object:nil];
//                break;
            case AVIMCMD_Multi_CancelInteract:
                if ([self isSendToSelf:msg])
                {
                    [self downToVideo:nil];
                }
                break;
            case AVIMCMD_EnterLive:
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserJoinRoom_Notification object:nil];
                break;
            case AVIMCMD_ExitLive:
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserExitRoom_Notification object:nil];
                break;
            default:
                break;
        }
    }
}

- (BOOL)isSendToSelf:(ILVLiveCustomMessage *)msg
{
    NSString *recvId = [[NSString alloc] initWithData:msg.data encoding:NSUTF8StringEncoding];
    NSString *selfId = [[ILiveLoginManager getInstance] getLoginId];
    
    return [recvId isEqualToString:selfId];
}

- (void)onTextMessage:(ILVLiveTextMessage *)msg
{
    if (!_liveUI)
    {
        return;
    }
    [_liveUI onMessage:msg];
}

- (void)onUserUpdateInfo:(ILVLiveAVEvent)event users:(NSArray *)users
{
    TILLiveManager *manager = [TILLiveManager getInstance];
    switch (event)
    {
        case ILVLIVE_AVEVENT_CAMERA_ON:
        {
            for (NSString *user in users)
            {
                CGRect renderFrame;
                if(![user isEqualToString:_liveItem.host.uid])
                {
                    renderFrame = [self getRenderFrame];
                }
                else
                {
                    renderFrame = self.view.bounds;
                }
                [manager addAVRenderView:renderFrame forIdentifier:user srcType:QAVVIDEO_SRC_TYPE_CAMERA];
                _count++;
                
                [_liveUI.upVideoMembers addObject:user];
            }
        }
            break;
        case ILVLIVE_AVEVENT_CAMERA_OFF:
        {
            for (NSString *user in users)
            {
                [manager removeAVRenderView:user srcType:QAVVIDEO_SRC_TYPE_CAMERA];
                _count--;
                
                NSUInteger index = [_liveUI.upVideoMembers indexOfObject:user];
                if (index != NSNotFound)
                {
                    [_liveUI.upVideoMembers removeObjectAtIndex:index];
                }
            }
        }
            break;
        case ILVLIVE_AVEVENT_SCREEN_ON:
            for (NSString *user in users)
            {
                CGRect renderFrame;
                if(![user isEqualToString:_liveItem.host.uid])
                {
                    renderFrame = [self getRenderFrame];
                }
                else
                {
                    renderFrame = self.view.bounds;
                }
                [manager addAVRenderView:renderFrame forIdentifier:user srcType:QAVVIDEO_SRC_TYPE_SCREEN];
                _count++;
                [_liveUI.upVideoMembers addObject:user];
            }
            break;
        case ILVLIVE_AVEVENT_SCREEN_OFF:
            for (NSString *user in users)
            {
                [manager removeAVRenderView:user srcType:QAVVIDEO_SRC_TYPE_SCREEN];
                _count--;
                
                NSUInteger index = [_liveUI.upVideoMembers indexOfObject:user];
                if (index != NSNotFound)
                {
                    [_liveUI.upVideoMembers removeObjectAtIndex:index];
                }
            }
            break;
        default:
            break;
    }
}

//获取渲染位置
- (CGRect)getRenderFrame
{
    if(_count == 3)
    {
        return CGRectZero;
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat height = (self.view.frame.size.height - 200 - 3 * 10)/3;
    CGFloat width = height*3/4;//宽高比3:4
    CGFloat y = _count * (height + 10);
    CGFloat x = screenRect.size.width - width - kDefaultMargin;
    return CGRectMake(x, y, width, height);
}

- (void)onClose
{
    //停止心跳
    [self stopLiveTimer];
    
    //退群消息
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_ExitLive;
    msg.type = ILVLIVE_IMTYPE_GROUP;
    msg.recvId = [[ILiveRoomManager getInstance] getIMGroupId];
    
    TILLiveManager *manager = [TILLiveManager getInstance];
    
    [manager sendCustomMessage:msg succ:^{
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        NSLog(@"exit room fail.module=%@,errid=%d,errmsg=%@",moudle,errId,errMsg);
        
    }];
    
    __weak typeof(self) ws = self;
    //退出房间
    [manager quitRoom:^{
        BOOL ismain = [NSThread isMainThread];
        NSLog(@"%d",ismain);
        [ws.navigationController setNavigationBarHidden:NO animated:YES];
        [[AppDelegate sharedAppDelegate] popToRootViewController];
        
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        NSLog(@"exit room fail.module=%@,errid=%d,errmsg=%@",moudle,errId,errMsg);
        [[AppDelegate sharedAppDelegate] popToRootViewController];
        
    }];
}

//开始发送心跳
- (void)startLiveTimer
{
    [self stopLiveTimer];
    _heartTimer = [NSTimer scheduledTimerWithTimeInterval:kHeartInterval target:self selector:@selector(onPostHeartBeat:) userInfo:nil repeats:YES];
}

//发送心跳
- (void)onPostHeartBeat:(NSTimer *)timer
{
    LiveHostHeartBeatRequest *req = [[LiveHostHeartBeatRequest alloc] initWithHandler:nil failHandler:^(BaseRequest *request) {
        // 上传心跳失败
    }];
    req.liveItem = _liveItem;
    [[WebServiceEngine sharedEngine] asyncRequest:req wait:NO];
}

//停止发送心跳
- (void)stopLiveTimer
{
    if(_heartTimer){
        [_heartTimer invalidate];
    }
}
@end
