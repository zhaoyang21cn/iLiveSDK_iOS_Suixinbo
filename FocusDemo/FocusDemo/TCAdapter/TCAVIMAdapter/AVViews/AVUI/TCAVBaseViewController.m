//
//  TCAVBaseViewController.m
//  TCShow
//
//  Created by AlexiChen on 15/11/16.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import "TCAVBaseViewController.h"

#import "UIAlertView+BlocksKit.h"

@implementation TCAVBaseViewController


- (void)dealloc
{
    DebugLog(@"界面[%@ : %p] 释放成功", [self class], self);
    _roomEngine = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[TIMManager sharedInstance] setUserStatusListener:[IMAPlatform sharedInstance]];
    
    AVAudioSession *aSession = [AVAudioSession sharedInstance];
    [aSession setCategory:_audioSesstionCategory withOptions:_audioSesstionCategoryOptions error:nil];
    [aSession setMode:_audioSesstionMode error:nil];
}

- (instancetype)initWith:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    if (self = [super init])
    {
        _isAtForeground = YES;
        
        _roomInfo = info;
        _currentUser = user;
        
        _isHost = [_currentUser isEqual:[_roomInfo liveHost]];
        
        // 直播时，更换监听者
        // 直播结束时，再把监听者改成IMAPlatform
        [[TIMManager sharedInstance] setUserStatusListener:self];
    }
    return self;
}


/**
 *  踢下线通知
 */
static BOOL kIsAlertingForceOfflineOnLiving = NO;
- (void)onForceOffline
{
    if (!kIsAlertingForceOfflineOnLiving)
    {
        kIsAlertingForceOfflineOnLiving = YES;
        IMAPlatform *ip = [IMAPlatform sharedInstance];
        
        
        DebugLog(@"踢下线通知");
        TCAVLog(([NSString stringWithFormat:@"*** ForceOffline|1-Recv|Succ|recv forceoffline|id = %@", ip.host.imUserId]));
        
        __weak TCAVBaseViewController *ws = self;
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"下线通知" message:@"您的帐号于另一台手机上登录，请退出直播，并重新登录" cancelButtonTitle:@"退出直播" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            // 退出
            // 待退出直播间成功后再调此方法到登录界面
            ip.offlineExitLivingBlock = ^{
                [[IMAPlatform sharedInstance] logout:^{
                    
                    TCAVLog(([NSString stringWithFormat:@"*** ForceOffline|2-Logout|Succ"]));
                    
                    [ws tipMessage:@"退出成功" delay:0.5 completion:^{
                        ws.navigationController.navigationBarHidden = NO;
                        [[IMAAppDelegate sharedAppDelegate] enterLoginUI];
                    }];
                } fail:^(int code, NSString *msg) {
                    
                    TCAVLog(([NSString stringWithFormat:@"*** ForceOffline|2-Logout|Fail(code = %d,msg = %@)",code, msg]));
                    
                    [ws tipMessage:@"退出成功" delay:0.5 completion:^{
                        ws.navigationController.navigationBarHidden = NO;
                        [[IMAAppDelegate sharedAppDelegate] enterLoginUI];
                    }];
                }];
            };
            
            _isExiting = YES;
            [ws exitLive];
            
            kIsAlertingForceOfflineOnLiving = NO;
            
        }];
        [alert show];
    }
    
}

/**
 *  断线重连失败
 */
- (void)onReConnFailed:(int)code err:(NSString *)err
{
    DebugLog(@"IM断线重连:%d %@", code, err);
}
- (void)onUserSigExpired
{
    //刷新票据
    [[IMAPlatform sharedInstance] onUserSigExpired];
}



- (void)viewDidLoad
{
    [self startEnterLiveInViewDidLoad];
    
    [super viewDidLoad];
    
    self.view.backgroundColor = kBlackColor;
    self.navigationController.navigationBarHidden = YES;
    
    
    
}




- (void)onAudioInterruption:(NSNotification *)notification
{
    //DDLogInfo(@"audioInterruption%@",notification.userInfo);
    NSDictionary *interuptionDict = notification.userInfo;
    NSNumber* interuptionType = [interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
    if(interuptionType.intValue == AVAudioSessionInterruptionTypeBegan)
    {
        DebugLog(@"初中断");
    }
    else if (interuptionType.intValue == AVAudioSessionInterruptionTypeEnded)
    {
        // siri输入
        [[AVAudioSession sharedInstance] setActive:YES error: nil];
        
    }
}

- (BOOL)isOtherAudioPlaying
{
    UInt32 otherAudioIsPlaying;
    UInt32 propertySize = sizeof (otherAudioIsPlaying);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &otherAudioIsPlaying);
#pragma clang diagnostic pop
    return otherAudioIsPlaying;
}


- (void)onAppBecomeActive:(NSNotification *)notification
{
    if (![self isOtherAudioPlaying])
    {
        [[AVAudioSession sharedInstance] setActive:YES error: nil];
    }
}

- (void)onAppWillTeminal:(NSNotification*)notification
{
    [self exitLive];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)startEnterLive
{
    [self addPhoneListener];
    
    if (_switchingToRoom)
    {
        _roomInfo = _switchingToRoom;
        _isHost = [_currentUser isEqual:[_roomInfo liveHost]];
        
        // 观众
        [[HUDHelper sharedInstance] syncLoading:@"正在切换房间"];
        DebugLog(@"-----观众>>>>>观众开始进入直播: 主播ID:%@", [[_roomInfo liveHost] imUserId]);
        [_roomEngine switchToLive:_roomInfo];
    }
    else
    {
        if (_isHost)
        {
            // 主播
            [[HUDHelper sharedInstance] syncLoading:@"正在创建房间"];
            DebugLog(@"-----主播>>>>>主播开始直播: 主播ID:%@", [[_roomInfo liveHost] imUserId]);
            [_roomEngine enterLive:_roomInfo];
            
        }
        else
        {
            // 观众
            [[HUDHelper sharedInstance] syncLoading:@"正在加入房间"];
            
            DebugLog(@"-----观众>>>>>观众开始进入直播: 主播ID:%@", [[_roomInfo liveHost] imUserId]);
            [_roomEngine enterLive:_roomInfo];
        }
    }
    
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    //    [self onAppEnterForeground];
}


//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
////    [self onAppEnterBackground];
//}


- (void)addOwnViews
{
    
}

- (void)configOwnViews
{
    
}

- (void)layoutOnIPhone
{
    
}


// 提示要退出直播
- (void)alertExitLive
{
    if (_isExiting)
    {
        return;
    }
    _isExiting = YES;
    if (_isHost)
    {
        UIAlertView *alert =  [UIAlertView bk_showAlertViewWithTitle:nil message:@"当前正在直播，是否退出直播" cancelButtonTitle:@"继续" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1)
            {
                [self exitLive];
            }
            else
            {
                _isExiting = NO;
            }
            
        }];
        [alert show];
    }
    else
    {
        UIAlertView *alert =  [UIAlertView bk_showAlertViewWithTitle:nil message:@"退出直播" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1)
            {
                [self exitLive];
            }
            else
            {
                _isExiting = NO;
            }
            
        }];
        [alert show];
        
    }
}

- (void)forceAlertExitLive:(NSString *)forceTip
{
    if (_isExiting)
    {
        return;
    }
    _isExiting = YES;
    
    UIAlertView *alert =  [UIAlertView bk_showAlertViewWithTitle:nil message:forceTip cancelButtonTitle:@"确定"otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        [self exitLive];
    }];
    [alert show];
    
}

- (BOOL)isExiting
{
    return _isExiting;
}

- (void)willExitLiving
{
    _isExiting = YES;
}

// 切换直播间
- (BOOL)switchToLive:(id<AVRoomAble>)room
{
    if ([_roomEngine isRoomRunning] && !_isHost)
    {
        _switchingToRoom = room;
        [self checkAndEnterAVRoom];
        return YES;
    }
    DebugLog(@"当前房间状态不正确，不允许切换");
    
    
    return NO;
}

// 真正退出房间
- (void)exitLive
{
    // 释放电话监听
    [self removePhoneListener];
    
    [self removeNetwokChangeListner];
    _isExiting = YES;
    if (_isHost)
    {
        DebugLog(@"-----主播>>>>>主播开始退出");
    }
    else
    {
        DebugLog(@"-----观众>>>>>观众退出");
    }
#if TARGET_IPHONE_SIMULATOR
    [self onExitLiveSucc:YES tipInfo:@"退出成功"];
#else
    if (_roomEngine)
    {
        [_roomEngine exitLive];
    }
    else
    {
        DebugLog(@"还未启动RoonRngine");
        [self onAVEngine:_roomEngine exitRoom:_roomInfo succ:YES tipInfo:@"退出成功"];
    }
#endif
}
// HOST/Guest进入直播回调
- (void)onAVEngine:(TCAVBaseRoomEngine *)avEngine enterRoom:(id<AVRoomAble>)room succ:(BOOL)succ tipInfo:(NSString *)tip
{
    if (succ)
    {
        [self addNetwokChangeListner];
    }
    [self onEnterLiveSucc:succ tipInfo:tip];
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine disConnect:(id<AVRoomAble>)room
{
    // do nothing
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine switchRoom:(id<AVRoomAble>)room succ:(BOOL)succ tipInfo:(NSString *)tip
{
    if (!succ)
    {
        _switchingToRoom = nil;
    }
    DebugLog(@"切换房间%@", succ ? @"成功" : @"失败");
    [self onEnterLiveSucc:succ tipInfo:tip];
    _switchingToRoom = nil;
    
}


// HOST/Guest退出直播回调
- (void)onAVEngine:(TCAVBaseRoomEngine *)avEngine exitRoom:(id<AVRoomAble>)room succ:(BOOL)succ tipInfo:(NSString *)tip
{
    [[HUDHelper sharedInstance] syncStopLoading];
    if ([IMAPlatform sharedInstance].offlineExitLivingBlock)
    {
        [IMAPlatform sharedInstance].offlineExitLivingBlock();
    }
    else
    {
        
        [[TIMManager sharedInstance] setUserStatusListener:[IMAPlatform sharedInstance]];
        [self onExitLiveSucc:succ tipInfo:tip];
    }
}


- (void)onAVEngine:(TCAVBaseRoomEngine *)avEngine videoFrame:(QAVVideoFrame *)frameData
{
    // do nothing in this class
    // overwrite by the subclass
}

//- (void)onAVEngine:(TCAVBaseRoomEngine *)engine preProcessLocaVideoFrame:(QAVVideoFrame *)frame
//{
//}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine recvSemiAutoVideo:(NSArray *)users
{
    // do nothing in this class
    // overwrite by the subclass
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine enableCamera:(BOOL)succ tipInfo:(NSString *)tip
{
    // do nothing in this class
    // overwrite by the subclass
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine requestViewOf:(id<IMUserAble>)user succ:(BOOL)succ tipInfo:(NSString *)tip
{
    if (!succ)
    {
        // 一般是请求主播画面失败
        NSString *uid = [user imUserId];
        NSString *lHuid = [[[engine getRoomInfo] liveHost] imUserId];
        if ([uid isEqualToString:lHuid])
        {
            // 说明请求主播的画面失败
            // 可能原因：主播异常退出未再进，后台没有清理掉僵尸房间，观众刚好进入
            [[HUDHelper sharedInstance] tipMessage:tip delay:2 completion:^{
                [self exitLive];
            }];
        }
    }
}

// 用户首次请求画面（QAVEndpoint requestViewList）成功后，会开始计时，在［engine maxWaitFirstFrameSec］内画面未显示，则回调请求画面超时
- (void)onAVEngineWaitFirstRemoteFrameTimeOut:(TCAVBaseRoomEngine *)engine
{
    // do nothing
    [self tipMessage:@"请求画面超时" delay:1 completion:^{
        [self exitLive];
    }];
}

// 用户请求画面成功（QAVEndpoint requestViewList）后，首帧画面到到
- (void)onAVEngineFirstRemoteFrameRender:(TCAVBaseRoomEngine *)engine
{
    // do nothing
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine changeRole:(BOOL)succ tipInfo:(NSString *)tip
{
    // do nothing
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine onStartPush:(BOOL)succ pushRequest:(TCAVLiveRoomPushRequest *)req
{
    // do nothing
}

@end


@implementation TCAVBaseViewController (ProtectedMethod)

- (void)startEnterLiveInViewDidLoad
{
    if ([self isImmediatelyEnterLive])
    {
        [self checkNetWorkBeforeLive];
    }
}

- (BOOL)isImmediatelyEnterLive
{
    return YES;
}

// 添加电话监听: 进入直播成功后监听
- (void)addPhoneListener
{
    if (!_callCenter)
    {
        _callCenter = [[CTCallCenter alloc] init];
        __weak TCAVBaseViewController *ws = self;
        _callCenter.callEventHandler = ^(CTCall *call) {
            // 需要在主线程执行
            [ws performSelectorOnMainThread:@selector(handlePhoneEvent:) withObject:call waitUntilDone:YES];
        };
    }
}

- (void)handlePhoneEvent:(CTCall *)call
{
    DebugLog(@"电话中断处理：电话状态为call.callState = %@", call.callState);
    if ([call.callState isEqualToString:CTCallStateDisconnected])
    {
        // 电话已结束
        
        if (_hasHandleCall)
        {
            // 说明在前台的时候接通过电话
            DebugLog(@"电话中断处理：在前如的时候处理的电话，挂断后，立即回到前台");
            // iOS8下电话来之后，如果快速挂断，直接调用会导致无法打开摄像头
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 不加延时，若挂断时，相机操作会打不开
                [self onAppEnterForeground];
            });
            
        }
        else
        {
            DebugLog(@"电话中断处理：退到后台接话：不处理");
        }
        
    }
    else
    {
        if (!_isPhoneInterupt && _isAtForeground)
        {
            DebugLog(@"电话中断处理：退到后台接话：不处理");
            // 首次收到，并且在前台
            _isPhoneInterupt = YES;
            _hasHandleCall = YES;
            [self onAppEnterBackground];
        }
        else
        {
            DebugLog(@"电话中断处理：已在后台接电话话：不处理");
        }
    }
}

// 移除电话监听：退出直播后监听
- (void)removePhoneListener
{
    _callCenter.callEventHandler = nil;
    _callCenter = nil;
}


- (void)exitOnNotPermitted
{
    // do nothing
    [self onExitLiveUI];
}

- (void)createRoomEngine
{
    if (!_roomEngine)
    {
        _roomEngine = [[TCAVBaseRoomEngine alloc] initWith:_currentUser];
        _roomEngine.delegate = self;
    }
}


- (void)checkAndEnterAVRoom
{
    [self createRoomEngine];
    [self startEnterLive];
}

- (void)onAppEnterForeground
{
    _isAtForeground = YES;
    _hasHandleCall = NO;
    _isPhoneInterupt = NO;
    DebugLog(@"返回前台");
    [_roomEngine onRoomEnterForeground];
}

- (void)onExitLiveUI
{
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onAppEnterBackground
{
    _isAtForeground = NO;
    DebugLog(@"进入后台");
    [_roomEngine onRoomEnterBackground];
}

- (void)onEnterLiveSucc:(BOOL)succ tipInfo:(NSString *)tip
{
    if (succ)
    {
        if (_isHost)
        {
            DebugLog(@"-----主播>>>>>主播创建直播房间成功");
        }
        else
        {
            DebugLog(@"-----观众>>>>>观众进入直播间成功");
        }
        
        [[HUDHelper sharedInstance] syncStopLoadingMessage:tip];
        
    }
    else
    {
        if (_isHost)
        {
            DebugLog(@"-----主播>>>>>主播创建直播房间失败");
        }
        else
        {
            DebugLog(@"-----观众>>>>>观众进入直播间失败");
        }
        [[HUDHelper sharedInstance] syncStopLoadingMessage:tip delay:0.5 completion:^{
            [self forceAlertExitLive:tip];
        }];
    }
}

- (void)onExitLiveSucc:(BOOL)succ tipInfo:(NSString *)tip
{
    [self tipMessage:tip delay:0.5 completion:^{
        [self onExitLiveUI];
    }];
}

- (void)addAVSDKObservers
{
    if (_switchingToRoom)
    {
        return;
    }
    
    NSError *error = nil;
    AVAudioSession *aSession = [AVAudioSession sharedInstance];
    
    _audioSesstionCategory = [aSession category];
    _audioSesstionMode = [aSession mode];
    _audioSesstionCategoryOptions = [aSession categoryOptions];
    
    
    
    [aSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&error];
    [aSession setMode:AVAudioSessionModeDefault error:&error];
    [aSession setActive:YES error: &error];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioInterruption:)  name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillTeminal:) name:UIApplicationWillTerminateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    
}

- (void)checkNetWorkBeforeLive
{
    // 为方便集成逻辑，用户可以参考此在外部作实现逻辑
    TCQALNetwork net = [[IMAPlatform sharedInstance] networkType];
    switch (net)
    {
        case EQALNetworkType_ReachableViaWiFi:
        {
            [self addAVSDKObservers];
            
#if TARGET_IPHONE_SIMULATOR
#else
            [self checkAndEnterAVRoom];
#endif
        }
            break;
        case EQALNetworkType_ReachableViaWWAN:
        {
            __weak TCAVBaseViewController *ws = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                
                NSString *ac = _isHost ? @"创建" : @"加入";
                NSString *tip = [NSString stringWithFormat:@"当前是移动网络，是否继续%@直播", ac];
                UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"网络提示" message:tip cancelButtonTitle:@"退出" otherButtonTitles:@[[NSString stringWithFormat:@"继续%@", ac]] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0)
                    {
                        [ws tipMessage:@"退出成功" delay:2 completion:^{
                            [ws onExitLiveUI];
                        }];
                    }
                    else if (buttonIndex == 1)
                    {
                        [ws addAVSDKObservers];
                        
#if TARGET_IPHONE_SIMULATOR
#else
                        [ws checkAndEnterAVRoom];
#endif
                    }
                    
                }];
                [alert show];
            });
        }
            break;
        case EQALNetworkType_Undefine:
        case EQALNetworkType_NotReachable:
            
        default:
        {
            // 当前无网络
            NSString *tip = [NSString stringWithFormat:@"当前无网络，无法%@直播", _isHost ? @"创建" : @"加入"];
            [self tipMessage:tip delay:2 completion:^{
                [self onExitLiveUI];
            }];
        }
            
            
            break;
    }
}

- (void)addNetwokChangeListner
{
    self.KVOController = [FBKVOController controllerWithObserver:self];
    
    __weak TCAVBaseViewController *ws = self;
    [self.KVOController observe:[IMAPlatform sharedInstance] keyPath:@"networkType" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld  block:^(id observer, id object, NSDictionary *change) {
        [ws onNetworkChanged];
    }];
    
    [self.KVOController observe:[IMAPlatform sharedInstance] keyPath:@"isConnected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld  block:^(id observer, id object, NSDictionary *change) {
        [ws onNetworkConnected];
    }];
}

- (void)onNetworkConnected
{
    if ([IMAPlatform sharedInstance].isConnected)
    {
        // 网络已重联
        // [[HUDHelper sharedInstance] tipMessage:@"网络已连上"];
        DebugLog(@"网络已连上");
    }
    else
    {
        // 网络已断开
        [[HUDHelper sharedInstance] tipMessage:@"网络已断开"];
    }
}

- (void)onNetworkChanged
{
    // 为方便集成逻辑，用户可以参考此在外部作实现逻辑
    TCQALNetwork net = [[IMAPlatform sharedInstance] networkType];
    switch (net)
    {
        case EQALNetworkType_ReachableViaWiFi:
        {
            // 网络变好，不处理
            // do nothing here
        }
            break;
        case EQALNetworkType_ReachableViaWWAN:
        {
            if (_isHost)
            {
                // 变成移动网络
                UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:nil message:@"当前网络是移动网络，是否继续直播" cancelButtonTitle:@"结束直播" otherButtonTitles:@[@"继续直播"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0)
                    {
                        [self exitLive];
                    }
                    else if (buttonIndex == 1)
                    {
                        // do nothing
                    }
                }];
                [alert show];
            }
            else
            {
                // 网络变差
                UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:nil message:@"当前网络是移动网络，是否继续观看直播" cancelButtonTitle:@"结束观看" otherButtonTitles:@[@"继续观看"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0)
                    {
                        [self exitLive];
                    }
                    else if (buttonIndex == 1)
                    {
                        // do nothing
                    }
                }];
                [alert show];
            }
        }
            break;
        case EQALNetworkType_Undefine:
        case EQALNetworkType_NotReachable:
            
        default:
        {
            // 网络不可用
            // 变成移动网络
            NSString *tip = [NSString stringWithFormat:@"当前无网络，无法继续%@直播！", _isHost ? @"" : @"观看"];
            UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:nil message:tip cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self exitLive];
            }];
            [alert show];
        }
            
            
            break;
    }
}

- (void)removeNetwokChangeListner
{
    [self.KVOController unobserveAll];
    self.KVOController = nil;
}


- (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion
{
    [[HUDHelper sharedInstance] tipMessage:msg delay:seconds completion:completion];
}

@end


