//
//  TCAVLiveViewController.m
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVLiveViewController.h"


@implementation TCAVLiveBaseViewController

- (instancetype)initWith:(TCAVBaseViewController *)controller
{
    if (self = [super init])
    {
        _liveController = controller;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kClearColor;
}

- (void)onEnterBackground
{
    
}
- (void)onEnterForeground
{
    
}

- (void)setMsgHandler:(id<AVIMMsgHandlerAble>)msgHandler
{
    _msgHandler = msgHandler;
    if ([msgHandler isKindOfClass:[AVIMMsgHandler class]])
    {
        // 防止enableIM为No时，外部用户设置消息回调，导致
        ((AVIMMsgHandler *)_msgHandler).roomIMListner = self;
    }
}


// 收到群聊天消息: (主要是文本类型)
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvGroupMsg:(id<AVIMMsgAble>)msg
{
    // do nothing
    // overwrite by the subclass
}


// 收到C2C自定义消息
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvCustomC2C:(id<AVIMMsgAble>)msg
{
    // do nothing
    // overwrite by the subclass
    
}

- (void)onRecvCustomLeave:(id<AVIMMsgAble>)msg
{
    AVIMCMD *cmd = (AVIMCMD *)msg;
    DebugLog(@"主播离开");
    TCAVLiveViewController *lvc = (TCAVLiveViewController *)_liveController;
    [lvc.livePreview onUserLeave:[cmd sender]];
}

- (void)onRecvCustomBack:(id<AVIMMsgAble>)msg
{
    DebugLog(@"主播回来了");
    AVIMCMD *cmd = (AVIMCMD *)msg;
    TCAVLiveViewController *lvc = (TCAVLiveViewController *)_liveController;
    [lvc.livePreview onUserBack:[cmd sender]];
    
    [(TCAVLiveRoomEngine *)_roomEngine asyncRequestHostView];
}

// 收到群自定义消息
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvCustomGroup:(id<AVIMMsgAble>)msg
{
    // do nothing
    // overwrite by the subclass
    switch ([msg msgType])
    {
        case AVIMCMD_Host_Leave:
        {
            [self onRecvCustomLeave:msg];
        }
            break;
        case AVIMCMD_Host_Back:
        {
            
            [self onRecvCustomBack:msg];
        }
            break;
            
        default:
            
            
            break;
    }
    
}



// 群主解散群消息，或后台自动解散
- (void)onIMHandler:(AVIMMsgHandler *)receiver deleteGroup:(id<IMUserAble>)sender
{
    // do nothing
    // overwrite by the subclass
    
    if (![_liveController isExiting])
    {
        [_liveController willExitLiving];
        // 说明主播退出
        UIAlertView *alert =  [UIAlertView bk_showAlertViewWithTitle:nil message:@"直播群已解散" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [_liveController exitLive];
        }];
        [alert show];
    }
    
}

// 有新用户进入
// senders是id<IMUserAble>类型
- (void)onIMHandler:(AVIMMsgHandler *)receiver joinGroup:(NSArray *)senders
{
    // do nothing
    // overwrite by the subclass
    
}

// 有用户退出
// senders是id<IMUserAble>类型
- (void)onIMHandler:(AVIMMsgHandler *)receiver exitGroup:(NSArray *)senders
{
    // do nothing
    // overwrite by the subclass
    
}


@end

// ==========================================================

@implementation TCAVLiveViewController

- (void)dealloc
{
    _msgHandler = nil;
    
    [_livePreview stopPreview];
    _livePreview = nil;
}

+ (void)checkInitParam:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    if (![user conformsToProtocol:@protocol(AVUserAble)])
    {
        DebugLog(@"因此类中要使用TCAVLiveRoomEngine，为保证其能正常使用，其传入的Host[%@ : %p]必须要实现AVUserAble", [user class], user);
        NSString *reason = [NSString stringWithFormat:@"[%@ : %p]必须实现AVUserAble协议", [user class], user];
        NSException *e = [NSException exceptionWithName:@"TCAVLiveRoomEngineHostInVailed" reason:reason userInfo:nil];
        @throw e;
    }
}

- (instancetype)initWith:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    [TCAVLiveViewController checkInitParam:info user:user];
    if (self = [super initWith:info user:user])
    {
        _enableIM = YES;
    }
    return self;
}


- (void)addOwnViews
{
    [self addLivePreview];
    [self addLiveView];
}

- (void)layoutOnIPhone
{
    [_livePreview setFrameAndLayout:self.view.bounds];
    [self layoutLiveView];
}


- (void)exitLive
{
    [_livePreview stopPreview];
    if (_msgHandler)
    {
        [_msgHandler exitLiveChatRoom:^{
            [super exitLive];
        } fail:^(int code, NSString *msg) {
            [super exitLive];
        }];
        
    }
    else
    {
        [super exitLive];
    }
}

// 切换直播间
- (BOOL)switchToLive:(id<AVRoomAble>)room
{
    if (_enableIM)
    {
        [_msgHandler exitLiveChatRoom:nil fail:nil];
    }
    BOOL succ = [super switchToLive:room];
    if (succ)
    {
        // 界面停止渲染
        [_livePreview stopAndRemoveAllRender];
        
    }
    return succ;
}



- (void)onAVEngine:(TCAVBaseRoomEngine *)engine enableCamera:(BOOL)succ tipInfo:(NSString *)tip
{
    DebugLog(@"%@", tip);
    if (!succ)
    {
        DebugLog(@"----->>>>>打开相机失败");
        [self tipMessage:tip delay:2 completion:^{
            [self alertExitLive];
        }];
    }
    else
    {
        if (_isHost)
        {
            [_liveView setRoomEngine:_roomEngine];
        }
    }
    
}

//- (void)onAVEngine:(TCAVBaseRoomEngine *)engine preProcessLocaVideoFrame:(QAVVideoFrame *)frame
//{
//
//    if ([engine isFrontCamera])
//    {
//        // 接收者通过判断是 frame.frameDesc.rotate / 4 != 0判断画面前前置摄像头取到的
//        // 当前字段未使用，暂不处理
//        //        frame.roomID += 4;
//        //        frame.frameDesc.a
//    }
//}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine recvSemiAutoVideo:(NSArray *)users
{
    // do nothing in this class
    // overwrite by the subclass
    [_livePreview addRenderFor:[_roomInfo liveHost]];
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine videoFrame:(QAVVideoFrame *)frame
{
//    [_livePreview render:frame mirrorReverse:[engine isFrontCamera] fullScreen:YES];
    [_livePreview render:frame roomEngine:engine fullScreen:YES];
}

- (void)onAppEnterForeground
{
    [super onAppEnterForeground];
    [_livePreview startPreview];
    [_liveView onEnterForeground];
    
    [self onHostBackLiveRoom];
}

- (void)onAppEnterBackground
{
    [super onAppEnterBackground];
    [_livePreview stopPreview];
    [_liveView onEnterBackground];
    
    [self onHostLeaveLiveRoom];
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users event:(QAVUpdateEvent)event
{
    
    // 检查是否是互动观众退出了
    switch (event)
    {
        case QAV_EVENT_ID_ENDPOINT_HAS_CAMERA_VIDEO:
        {
            [self onHasCameraUserBack:users];
        }
            
            break;
        case QAV_EVENT_ID_ENDPOINT_NO_CAMERA_VIDEO:
        {
            [self onNoCameraUserLeave:users];
        }
            break;
        default:
            break;
    }    
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine requestViewOf:(id<IMUserAble>)user succ:(BOOL)succ tipInfo:(NSString *)tip
{
    if (!succ)
    {
        UIAlertView *aler = [UIAlertView bk_showAlertViewWithTitle:nil message:@"请求主播画面超时，主播可能已经离开" cancelButtonTitle:@"退出" otherButtonTitles:@[@"继续等待"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0)
            {
                [self exitLive];
            }
            else
            {
                [_livePreview onUserLeave:user];
            }
        }];
        [aler show];
    }
}


- (void)onAVEngineWaitFirstRemoteFrameTimeOut:(TCAVBaseRoomEngine *)engine
{
//    // do nothing
//    [self tipMessage:@"请求画面超时" delay:1 completion:^{
//        [self exitLive];
//    }];
    
    UIAlertView *aler = [UIAlertView bk_showAlertViewWithTitle:nil message:@"请求主播画面超时，主播可能已经离开" cancelButtonTitle:@"退出" otherButtonTitles:@[@"继续等待"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0)
        {
            [self exitLive];
        }
        else
        {
            [_livePreview onUserLeave:[_roomInfo liveHost]];
        }
    }];
    [aler show];
}


@end



@implementation TCAVLiveViewController (ProtectedMethod)

- (void)addLivePreview
{
    _livePreview = [[TCAVLivePreview alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_livePreview];
    [_livePreview registLeaveView:[TCAVLeaveView class]];
    
    [_livePreview addRenderFor:[_roomInfo liveHost]];
}


- (void)addLiveView
{
    // 子类重写
    TCAVLiveBaseViewController *uivc = [[TCAVLiveBaseViewController alloc] initWith:self];
    [self addChild:uivc inRect:self.view.bounds];
    
    _liveView = uivc;
}

- (void)layoutLiveView
{
    // 子类重写
}

- (NSInteger)defaultAVHostConfig
{
    
    // 添加推荐配置
    if (_isHost)
    {
        return EAVCtrlState_Mic | EAVCtrlState_Speaker | EAVCtrlState_Camera | EAVCtrlState_AutoRotateVideo;
    }
    else
    {
        return EAVCtrlState_Speaker;
    }
}


- (void)prepareIMMsgHandler
{
    if (!_msgHandler)
    {
        _msgHandler = [[AVIMMsgHandler alloc] initWith:_roomInfo];
        [_msgHandler enterLiveChatRoom:nil fail:nil];
    }
    else
    {
        __weak AVIMMsgHandler *wav = (AVIMMsgHandler *)_msgHandler;
        __weak id<AVRoomAble> wr = _roomInfo;
        [_msgHandler exitLiveChatRoom:^{
            [wav switchToLiveRoom:wr];
            [wav enterLiveChatRoom:nil fail:nil];
        } fail:^(int code, NSString *msg) {
            [wav switchToLiveRoom:wr];
            [wav enterLiveChatRoom:nil fail:nil];
        }];
    }
}

- (void)releaseIMMsgHandler
{
    ((AVIMMsgHandler *)_msgHandler).roomIMListner = nil;
    [_msgHandler releaseIMRef];
}

- (void)createRoomEngine
{
    if (!_roomEngine)
    {
        id<AVUserAble> ah = (id<AVUserAble>)_currentUser;
        [ah setAvCtrlState:[self defaultAVHostConfig]];
        _roomEngine = [[TCAVLiveRoomEngine alloc] initWith:(id<IMHostAble, AVUserAble>)_currentUser enableChat:_enableIM];
        _roomEngine.delegate = self;
        if (!_isHost)
        {
            [_liveView setRoomEngine:_roomEngine];
        }
    }
}

- (void)onExitLiveSucc:(BOOL)succ tipInfo:(NSString *)tip
{
    [self releaseIMMsgHandler];
    
    [_liveView setMsgHandler:nil];
    
    [super onExitLiveSucc:succ tipInfo:tip];
}


- (void)onEnterLiveSucc:(BOOL)succ tipInfo:(NSString *)tip
{
    [super onEnterLiveSucc:succ tipInfo:tip];
    
    [self onAVLiveEnterLiveSucc:succ tipInfo:tip];
}

- (void)onAVLiveEnterLiveSucc:(BOOL)succ tipInfo:(NSString *)tip
{
    if (succ)
    {
        if (_enableIM)
        {
            [self prepareIMMsgHandler];
            [_liveView setMsgHandler:(AVIMMsgHandler *)_msgHandler];
        }
        else if (_msgHandler)
        {
            // 说明是外部设置的消息处理者
            [_liveView setMsgHandler:(AVIMMsgHandler *)_msgHandler];
        }
        
        if (!_isHost)
        {
            _liveView.roomEngine = (TCAVLiveRoomEngine *)_roomEngine;
        }
        
        [self requestHostViewOnEnterLiveSucc];
    }
}

- (void)requestHostViewOnEnterLiveSucc
{
    if (!_isHost)
    {
        // 观人进入后房间后，请求主播画面，主播不做事情
        // 请求主播画面
        [(TCAVLiveRoomEngine *)_roomEngine asyncRequestHostView];
    }
}

- (NSString *)cameraAuthorizationTip
{
    return @"没有权限访问您的相机，无法进行直播，请在“设置－隐私－相机”中允许使用。";
}

- (void)checkPermission:(CommonVoidBlock)noBlock permissed:(CommonVoidBlock)hasBlock
{
    BOOL hasCamAuth = [self checkCameraAuth:noBlock];
    
    if (hasCamAuth)
    {
        [self checkMicPermission:noBlock permissed:hasBlock];
    }
    else
    {
        // 无相机权限时，进入到noBlock
    }
    
}

- (void)checkAndEnterAVRoom
{
    if (_isHost)
    {
        __weak TCAVLiveViewController *ws = self;
        [self checkPermission:^{
            [ws exitOnNotPermitted];
        } permissed:^{
            [super checkAndEnterAVRoom];
        }];
    }
    else
    {
        [super checkAndEnterAVRoom];
    }
}

// iOS在App运行中，修改Mic以及相机权限，App会退出
// 检查Camera权限，没有权限时，执行noauthBlock
- (BOOL)checkCameraAuth:(CommonVoidBlock)noauthBlock
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        // 没有权限，到设置中打开权限
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertView *alterView = [UIAlertView bk_showAlertViewWithTitle:@"相机授权" message:[self cameraAuthorizationTip] cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (noauthBlock)
                {
                    noauthBlock();
                }
            }];
            [alterView show];
        });
        
        return NO;
    }
    
    return YES;
    
}

- (NSString *)micPermissionTip
{
    return  @"没有权限访问您的麦克风，无法进行直播，请在“设置-隐私-麦克风”中允许访问麦克风。";
}

// 检查Mic权限权限，没有权限时，执行noauthBlock
- (void)checkMicPermission:(CommonVoidBlock)noPermissionBlock permissed:(CommonVoidBlock)permissedBlock
{
    // 获取麦克风权限
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)])
    {
        [avSession requestRecordPermission:^(BOOL available) {
            if (!available)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UIAlertView *alterView = [UIAlertView bk_showAlertViewWithTitle:@"录音授权" message:[self micPermissionTip] cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (noPermissionBlock)
                        {
                            noPermissionBlock();
                        }
                    }];
                    [alterView show];
                });
            }
            else
            {
                if (permissedBlock)
                {
                    
                    permissedBlock();
                }
            }
        }];
    }
}

// 主播离开直播间
- (void)onHostLeaveLiveRoom
{
    if ([_roomEngine isHostLive])
    {
        AVIMCMD *lc = [[AVIMCMD alloc] initWith:AVIMCMD_Host_Leave];
        [_msgHandler sendCustomGroupMsg:lc succ:nil fail:nil];
    }
    
}

// 主播返回直播间
- (void)onHostBackLiveRoom
{
    if ([_roomEngine isHostLive])
    {
        AVIMCMD *lc = [[AVIMCMD alloc] initWith:AVIMCMD_Host_Back];
        [_msgHandler sendCustomGroupMsg:lc succ:nil fail:nil];
    }
    
}

- (void)onHasCameraUserBack:(NSArray *)users
{
    NSString *hid = [[_roomInfo liveHost] imUserId];
    for (id<AVMultiUserAble> iu in users)
    {
        if ([hid isEqualToString:[iu imUserId]])
        {
            [_livePreview onUserBack:[_roomInfo liveHost]];
            break;
        }
    }
    
    [(TCAVLiveRoomEngine *)_roomEngine asyncRequestHostView];
}
- (void)onNoCameraUserLeave:(NSArray *)users
{
    NSString *hid = [[_roomInfo liveHost] imUserId];
    for (id<AVMultiUserAble> iu in users)
    {
        if ([hid isEqualToString:[iu imUserId]])
        {
            [_livePreview onUserLeave:[_roomInfo liveHost]];
            break;
        }
    }
}

@end