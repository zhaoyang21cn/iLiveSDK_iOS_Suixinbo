//
//  TCILiveManager.m
//  TCAVIMDemo
//
//  Created by AlexiChen on 16/9/5.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportILiveSDK
#import "TCILiveManager.h"

@interface TCILiveManager ()
{
@protected
    CTCallCenter                    *_callCenter;           // 电话监听
    BOOL                            _isAtForeground;        // 是否在前台
    BOOL                            _isPhoneInterupt;       // 是否是电话中断
    BOOL                            _hasHandleCall;
    
@protected
    BOOL                           _isExiting;              // 正在退出，主要是防止界面上多次弹出退出提醒框
    BOOL                           _isHost;                 // YES：当前是主播，NO：当前是观众
    
@private
    // 用于音频退出直播时还原现场
    NSString                        *_audioSesstionCategory;    // 进入房间时的音频类别
    NSString                        *_audioSesstionMode;        // 进入房间时的音频模式
    AVAudioSessionCategoryOptions   _audioSesstionCategoryOptions;       // 进入房间时的音频类别选项
    
@protected
    BOOL _hasCheckCameraAuth;
    BOOL _hasCameraAuth;
    BOOL _hasCheckMicPermission;
   BOOL _hasMicPermission;
    
@protected
    id<AVRoomAble>                 _switchingToRoom;
    
    
    
    
@protected
    __weak id<TCILiveManagerExceptionListener> _execeptionListener;
}

// 因为iOS系统限制，相机或麦克风权限中途改变，App会被杀掉，所以只用检查一次即可
@property (nonatomic, assign) BOOL hasCheckCameraAuth;
@property (nonatomic, assign) BOOL hasCameraAuth;
@property (nonatomic, assign) BOOL hasCheckMicPermission;
@property (nonatomic, assign) BOOL hasMicPermission;
@end

@implementation TCILiveManager


static TCILiveManager *_sharedInstance = nil;

//=====================================

+ (instancetype)sharedInstance
{
    // TODO:
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _sharedInstance = [[TCILiveManager alloc] init];
    });
    
    return _sharedInstance;
}

- (BOOL)isHostLive
{
    return _isHost;
}


- (TCAVLivePreview *)createLivePreviewIn:(UIViewController *)vc inConfig:(TCILiveBaseConfig *)config
{
    if (config)
    {
        if (!_livePreview)
        {
            if (config.liveScene <= ETCILiveScene_Live)
            {
                _livePreview = [[TCAVLivePreview alloc] initWithFrame:vc.view.bounds];
            }
            else
            {
                _livePreview = [[TCAVMultiLivePreview alloc] initWithFrame:vc.view.bounds];
                _multiManager.preview = (TCAVMultiLivePreview *)_livePreview;
            }
            
            [vc.view addSubview:_livePreview];
        }
        
        return _livePreview;
    }
    return nil;
}

//- (BOOL)enterAVChatRoom
//{
//    __weak typeof(self) ws = self;
//    __weak typeof(_roomInfo) wroom = _roomInfo;
//    __weak typeof(_roomEngine) wr = _roomEngine;
//
//    if ([_liveConfig isFixAVRoomIDAsAVChatRoomID])
//    {
//        [self asyncEnterAVChatRoomWithAVRoomID:_roomInfo succ:^ {
//            [ws startEnterLive];
//        } fail:^(int code, NSString *msg) {
//            NSString *tip = [NSString stringWithFormat:@"code : %d, msg : %@", code, msg];
//            [wr.delegate onAVEngine:wr enterRoom:wroom succ:NO tipInfo:tip];
//        }];
//    }
//    else
//    {
//        [self asyncEnterAVChatRoom:_roomInfo succ:^ {
//            [ws startEnterLive];
//        } fail:^(int code, NSString *msg) {
//            NSString *tip = [NSString stringWithFormat:@"code : %d, msg : %@", code, msg];
//            [wr.delegate onAVEngine:wr enterRoom:wroom succ:NO tipInfo:tip];
//        }];
//    }
//
//    return YES;
//}
//
////- (void)asyncExitHistoryAVChatRoom
////{
////    [[TIMGroupManager sharedInstance] GetGroupList:^(NSArray *list) {
////        for(int index = 0; index < list.count; index++)
////        {
////            // AVChatRoom 使用longpoll
////            TIMGroupInfo* info = list[index];
////            if ([info.groupType isEqualToString:kAVChatRoomType])
////            {
////                // 不用处理返回码，会删除自己创建的群
////                DebugLog(@"解散或退出历史直播房间:%@", info.group);
////                [[TIMGroupManager sharedInstance] DeleteGroup:info.group succ:nil fail:nil];
////            }
////        }
////    } fail:nil];
////}
//// 主播 : 主播创建直播聊天室
//// 观众 : 观众加入直播聊天室
//- (void)asyncEnterAVChatRoom:(id<AVRoomAble>)room succ:(TIMSucc)succ fail:(TIMFail)fail
//{
//    if (!room)
//    {
//        DebugLog(@"直播房房间信息不正确");
//        if (fail)
//        {
//            fail(-1, @"直播房房间信息不正确");
//        }
//        return;
//    }
//
//
//    NSString *title = [room liveTitle];
//    if (!title || title.length == 0 || [title utf8Length] > 32)
//    {
//        DebugLog(@"直播房房间信息liveTitle不正确");
//        if (fail)
//        {
//            fail(-1, @"直播房房间信息liveTitle不正确");
//        }
//        return;
//    }
//
//
//    //    id<IMUserAble> roomHost = [room liveHost];
//    // 外部保证聊天室ID是正确的
//    NSString *roomid = [room liveIMChatRoomId];
//    BOOL isHost = [self isHostLive];
//
//    if (isHost)
//    {
//
//        //#if kSupportFixLiveChatRoomID
//        // 如果roomid不为空，说明使用roomid作标题来创建直播群
//        // 否则使用room liveTitle来作群名创建群
//        if (roomid && roomid.length != 0)
//        {
//            DebugLog(@"----->>>>>主播开始创建直播聊天室:%@ title = %@", roomid, title);
//            [[TIMGroupManager sharedInstance] CreateGroup:[_liveConfig imChatRoomType] members:nil groupName:title groupId:roomid succ:^(NSString *groupId) {
//                [room setLiveIMChatRoomId:groupId];
//                if (succ)
//                {
//                    succ();
//                }
//
//            } fail:^(int code, NSString *error) {
//                // 返回10025，group id has be used，
//                // 10025无法区分当前是操作者是否是原群的操作者（目前业务逻辑不存在拿别人的uid创建聊天室逻辑），
//                // 为简化逻辑，暂定创建聊天室时返回10025，就直接等同于创建成功
//                if (code == 10025)
//                {
//                    DebugLog(@"----->>>>>主播开始创建直播聊天室成功");
//                    [room setLiveIMChatRoomId:roomid];
//                    if (succ)
//                    {
//                        succ();
//                    }
//                }
//                else
//                {
//                    DebugLog(@"----->>>>>主播开始创建直播聊天室失败 code: %d , msg = %@", code, error);
//                    if (fail)
//                    {
//                        fail(code, error);
//                    }
//                }
//            }];
//        }
//        else
//            //#endif
//        {
//            //#if kSupportAVChatRoom
//
//            if ([[_liveConfig imChatRoomType] isEqualToString:@"AVChatRoom"])
//            {
//                [[TIMGroupManager sharedInstance] CreateAVChatRoomGroup:title succ:^(NSString *chatRoomID) {
//                    //#else
//                    //  [[TIMGroupManager sharedInstance] CreateChatRoomGroup:@[[self.host imUserId]] groupName:title succ:^(NSString *chatRoomID) {
//                    //#endif
//                    DebugLog(@"----->>>>>主播开始创建IM聊天室成功");
//                    [room setLiveIMChatRoomId:chatRoomID];
//                    if (succ)
//                    {
//                        succ();
//                    }
//
//                } fail:^(int code, NSString *error) {
//
//                    DebugLog(@"----->>>>>主播开始创建IM聊天室失败 code: %d , msg = %@", code, error);
//                    if (fail)
//                    {
//                        fail(code, error);
//                    }
//                }];
//            }
//            else
//            {
//
//                [[TIMGroupManager sharedInstance] CreateChatRoomGroup:@[[[room liveHost] imUserId]] groupName:title succ:^(NSString *chatRoomID) {
//                    DebugLog(@"----->>>>>主播开始创建IM聊天室成功");
//                    [room setLiveIMChatRoomId:chatRoomID];
//                    if (succ)
//                    {
//                        succ();
//                    }
//
//                } fail:^(int code, NSString *error) {
//
//                    DebugLog(@"----->>>>>主播开始创建IM聊天室失败 code: %d , msg = %@", code, error);
//                    if (fail)
//                    {
//                        fail(code, error);
//                    }
//                }];
//            }
//
//
//        }
//    }
//    else
//    {
//
//        if (roomid.length == 0)
//        {
//            DebugLog(@"----->>>>>观众加入直播聊天室ID为空");
//            if (fail)
//            {
//                fail(-1, @"直播聊天室ID为空");
//            }
//            return;
//        }
//
//        // 观众加群
//        [[TIMGroupManager sharedInstance] JoinGroup:roomid msg:nil succ:^{
//            DebugLog(@"----->>>>>观众加入直播聊天室成功");
//            //            TCAVLog(([NSString stringWithFormat:@"*** clogs.viewer.enterRoom|%@|join im chat room|room id %@|SUCCEED",self.host.imUserId, roomid]));
//            if (succ)
//            {
//                succ();
//            }
//
//
//        } fail:^(int code, NSString *error) {
//
//            if (code == 10013)
//            {
//                DebugLog(@"----->>>>>观众加入直播聊天室成功");
//                //                TCAVLog(([NSString stringWithFormat:@"*** clogs.viewer.enterRoom|%@|join im chat room|room id %@|SUCCEED(code=10013)",self.host.imUserId, roomid]));
//                if (succ)
//                {
//                    succ();
//                }
//            }
//            else
//            {
//                DebugLog(@"----->>>>>观众加入直播聊天室失败 code: %d , msg = %@", code, error);
//                //                TCAVLog(([NSString stringWithFormat:@"*** clogs.viewer.enterRoom|%@|join im chat room|room id %@|FAIL|code=%d,msg=%@",self.host.imUserId, roomid, code, error]));
//                // 作已在群的处的处理
//                if (fail)
//                {
//                    fail(code, error);
//                }
//            }
//
//        }];
//    }
//
//
//}
//
//
//- (void)asyncEnterAVChatRoomWithAVRoomID:(id<AVRoomAble>)room succ:(TIMSucc)succ fail:(TIMFail)fail
//{
//    if (!room)
//    {
//        DebugLog(@"直播房房间信息不正确");
//        if (fail)
//        {
//            fail(-1, @"直播房房间信息不正确");
//        }
//        return;
//    }
//
//    // 外部保证聊天室ID是正确的
//    BOOL isHost = [self isHostLive];
//
//    if (isHost )
//    {
//        int avRoomId = [room liveAVRoomId];
//        if (avRoomId != 0)
//        {
//            // 如果roomid不为空，说明使用roomid作标题来创建直播群
//            // 否则使用room liveTitle来作群名创建群
//            NSString *chatRoomId = [NSString stringWithFormat:@"%d", avRoomId];
//            DebugLog(@"----->>>>>主播开始创建直播聊天室:%@ title = %@", chatRoomId, chatRoomId);
//            [[TIMGroupManager sharedInstance] CreateGroup:[_liveConfig imChatRoomType] members:nil groupName:chatRoomId groupId:chatRoomId succ:^(NSString *groupId) {
//                [room setLiveIMChatRoomId:groupId];
//                if (succ)
//                {
//                    succ();
//                }
//
//            } fail:^(int code, NSString *error) {
//                // 返回10025，group id has be used，
//                // 10025无法区分当前是操作者是否是原群的操作者（目前业务逻辑不存在拿别人的uid创建聊天室逻辑），
//                // 为简化逻辑，暂定创建聊天室时返回10025，就直接等同于创建成功
//                if (code == 10025)
//                {
//                    [room setLiveIMChatRoomId:chatRoomId];
//                    if (succ)
//                    {
//                        succ();
//                    }
//                }
//                else
//                {
//                    if (fail)
//                    {
//                        fail(code, error);
//                    }
//                }
//            }];
//        }
//        else
//        {
//            [self asyncEnterAVChatRoom:room succ:succ fail:fail];
//        }
//    }
//    else
//    {
//        [self asyncEnterAVChatRoom:room succ:succ fail:fail];
//    }
//}
//
//// 主播 : 主播删除直播聊天室
//// 观众 : 观众退出直播聊天室
//- (void)asyncExitAVChatRoom:(id<AVRoomAble>)room succ:(TIMSucc)succ fail:(TIMFail)fail
//{
//    if (!room)
//    {
//        DebugLog(@"直播房房间信息不正确");
//        if (fail)
//        {
//            fail(-1, @"直播房房间信息不正确");
//        }
//        return;
//    }
//
//
//    NSString *roomid = [room liveIMChatRoomId];
//
//    if (roomid.length == 0)
//    {
//        DebugLog(@"----->>>>>观众退出的直播聊天室ID为空");
//        if (fail)
//        {
//            fail(-1, @"直播聊天室ID为空");
//        }
//        return;
//    }
//
//
//    BOOL isHost = [self isHostLive];
//    if (isHost)
//    {
//        // 主播删群
//        [[TIMGroupManager sharedInstance] DeleteGroup:roomid succ:succ fail:fail];
//    }
//    else
//    {
//        // 观众退群
//        [[TIMGroupManager sharedInstance] QuitGroup:roomid succ:succ fail:fail];
//    }
//
//}

- (void)startEnterLiveWith:(TCILiveBaseConfig *)config room:(id<AVRoomAble>)room currentUser:(id<IMHostAble>)user roomEngineDelegate:(id<TCAVRoomEngineDelegate>)roomDelegate execeptionListener:(id<TCILiveManagerExceptionListener>)ls
{
    // 检查参数
    if (!config || !room || !user)
    {
        DebugLog(@"参数为空");
        return;
    }
    
    if (![IMAPlatform sharedInstance].isConnected)
    {
        DebugLog(@"当前无网络连接，不能进行直播");
        return;
    }
    
    if ([_roomEngine isRoomAlive])
    {
        DebugLog(@"当前正在直播间内，为能开启另一个直播");
        return;
    }
    
    _isAtForeground = YES;
    
    _liveConfig = config;
    
    _roomInfo = room;
    
    _IMUser = user;
    
    _execeptionListener = ls;
    
    _isHost = [_IMUser isEqual:[_roomInfo liveHost]];
    // 直播时，更换监听者
    // 直播结束时，再把监听者改成IMAPlatform
    [[TIMManager sharedInstance] setUserStatusListener:self];
    
    [self addAVSDKObservers];
    [self createRoomEngineWithDelegate:roomDelegate];
    
    //    if ([_liveConfig isEnableIM])
    //    {
    //        [self enterAVChatRoom];
    //    }
    //    else
    //    {
    [self startEnterLive];
    //    }
    
}

- (void)onForceOffline
{
    if ([_execeptionListener respondsToSelector:@selector(onTCILiveManagerIMKickedOff:)])
    {
        [_execeptionListener onTCILiveManagerIMKickedOff:self];
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


// 移除电话监听：退出直播后监听
- (void)removePhoneListener
{
    _callCenter.callEventHandler = nil;
    _callCenter = nil;
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
    
    if (_liveConfig.useDefaultCallListener)
    {
        [self addPhoneListener];
    }
    
    if (_liveConfig.useDefaultNetListener)
    {
        [self addNetwokChangeListner];
    }
}

- (void)addNetwokChangeListner
{
    self.KVOController = [FBKVOController controllerWithObserver:self];
    
    __weak typeof(self) ws = self;
    [self.KVOController observe:[IMAPlatform sharedInstance] keyPath:@"networkType" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld  block:^(id observer, id object, NSDictionary *change) {
        [ws onNetworkChanged];
    }];
    
    [self.KVOController observe:[IMAPlatform sharedInstance] keyPath:@"isConnected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld  block:^(id observer, id object, NSDictionary *change) {
        [ws onNetworkConnected];
    }];
}

- (void)onNetworkConnected
{
    if ([_execeptionListener respondsToSelector:@selector(onTCILiveManager:netConnected:)])
    {
        [_execeptionListener onTCILiveManager:self netConnected:[IMAPlatform sharedInstance].isConnected];
    }
}

- (void)onNetworkChanged
{
    if ([_execeptionListener respondsToSelector:@selector(onTCILiveManager:netChangeTo:)])
    {
        // 为方便集成逻辑，用户可以参考此在外部作实现逻辑
        TCQALNetwork net = [[IMAPlatform sharedInstance] networkType];
        [_execeptionListener onTCILiveManager:self netChangeTo:net];
    }
}

- (void)removeNetwokChangeListner
{
    [self.KVOController unobserveAll];
    self.KVOController = nil;
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
    [self exitLiveWith:self];
}

// 添加电话监听: 进入直播成功后监听
- (void)addPhoneListener
{
    if (!_callCenter)
    {
        _callCenter = [[CTCallCenter alloc] init];
        __weak typeof(self) ws = self;
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

- (void)onAppEnterForeground
{
    [_roomEngine onRoomEnterForeground];
    [_livePreview startPreview];
    
    if ([_execeptionListener respondsToSelector:@selector(onTCILiveManagerEnterForeground:)])
    {
        [_execeptionListener onTCILiveManagerEnterForeground:self];
    }
}

- (void)onAppEnterBackground
{
    [_livePreview stopPreview];
    [_roomEngine onRoomEnterBackground];
    
    if ([_execeptionListener respondsToSelector:@selector(onTCILiveManagerEnterBackground:)])
    {
        [_execeptionListener onTCILiveManagerEnterBackground:self];
    }
}


- (void)checkCameraAuthAndMicPermission:(id<TCILiveManagerStartLiveListener>)ls inConfig:(TCILiveBaseConfig *)config
{
    BOOL hasCamAuth = YES;
    if ([config isEnableCamera])
    {
        hasCamAuth = [self checkCameraAuth:ls inConfig:config];
    }
    
    if (hasCamAuth)
    {
        BOOL hasMic = [config isEnableMic];
        if (hasMic)
        {
            [self checkMicPermission:ls inConfig:config];
        }
        else
        {
            if ([ls respondsToSelector:@selector(onTCILiveManagerCheckSucc:)])
            {
                [ls onTCILiveManagerCheckSucc:self];
            }
        }
    }
}

// iOS在App运行中，修改Mic以及相机权限，App会退出
// 检查Camera权限，没有权限时，执行noauthBlock
- (BOOL)checkCameraAuth:(id<TCILiveManagerStartLiveListener>)ls inConfig:(TCILiveBaseConfig *)config
{
    if (_hasCheckCameraAuth)
    {
        if (!_hasCameraAuth)
        {
            if ([ls respondsToSelector:@selector(onTCILiveManagerHasNoCameraAuth:)])
            {
                [ls onTCILiveManagerHasNoCameraAuth:self];
            }
        }
        return _hasCameraAuth;
    }
    else
    {
        _hasCheckCameraAuth = YES;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        _hasCameraAuth = !(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied);
        if (!_hasCameraAuth)
        {
            // 没有权限，到设置中打开权限
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([ls respondsToSelector:@selector(onTCILiveManagerHasNoCameraAuth:)])
                {
                    [ls onTCILiveManagerHasNoCameraAuth:self];
                }
                
            });
        }
        return _hasCameraAuth;
    }
    
}
// 检查Mic权限权限，没有权限时，执行noauthBlock
- (void)checkMicPermission:(id<TCILiveManagerStartLiveListener>)ls inConfig:(TCILiveBaseConfig *)config
{
    __weak typeof(self) wm = self;
    if (wm.hasCheckMicPermission)
    {
        if (!wm.hasMicPermission)
        {
            if ([ls respondsToSelector:@selector(onTCILiveManagerHasNoMicPermission:)])
            {
                [ls onTCILiveManagerHasNoMicPermission:self];
            }
        }
        else
        {
            if ([ls respondsToSelector:@selector(onTCILiveManagerCheckSucc:)])
            {
                [ls onTCILiveManagerCheckSucc:self];
            }
        }
    }
    else
    {
        // 获取麦克风权限
        AVAudioSession *avSession = [AVAudioSession sharedInstance];
        if ([avSession respondsToSelector:@selector(requestRecordPermission:)])
        {
            [avSession requestRecordPermission:^(BOOL available) {
                wm.hasCheckMicPermission = YES;
                wm.hasMicPermission = available;
                if (!available)
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if ([ls respondsToSelector:@selector(onTCILiveManagerHasNoMicPermission:)])
                        {
                            [ls onTCILiveManagerHasNoMicPermission:self];
                        }
                    });
                }
                else
                {
                    if ([ls respondsToSelector:@selector(onTCILiveManagerCheckSucc:)])
                    {
                        [ls onTCILiveManagerCheckSucc:self];
                    }
                    
                }
            }];
        }
    }
}


- (void)checkLiveNetworkWith:(id<TCILiveManagerStartLiveListener>)listener inConfig:(TCILiveBaseConfig *)config;
{
    // 为方便集成逻辑，用户可以参考此在外部作实现逻辑
    TCQALNetwork net = [[IMAPlatform sharedInstance] networkType];
    switch (net)
    {
        case EQALNetworkType_ReachableViaWiFi:
        {
            // 继续检查相机麦克风权限
            [self checkCameraAuthAndMicPermission:listener inConfig:config];
        }
            break;
        case EQALNetworkType_ReachableViaWWAN:
        {
            if ([listener respondsToSelector:@selector(onTCILiveManagerNotInWifi:networkType:)])
            {
                BOOL continueCheck = [listener onTCILiveManagerNotInWifi:self networkType:EQALNetworkType_ReachableViaWWAN];
                if (continueCheck)
                {
                    [self checkCameraAuthAndMicPermission:listener inConfig:config];
                }
            }
        }
            break;
        case EQALNetworkType_Undefine:
        case EQALNetworkType_NotReachable:
            
        default:
        {
            // 当前无网络
            if ([listener respondsToSelector:@selector(onTCILiveManagerHasNoNetwork:)])
            {
                [listener onTCILiveManagerHasNoNetwork:self];
            }
        }
            break;
    }
}


- (void)createRoomEngineWithDelegate:(id<TCAVRoomEngineDelegate>)roomDelegate;
{
    if (!_roomEngine)
    {
        switch (_liveConfig.liveScene)
        {
            case ETCILiveScene_Base:
            {
                TCILiveBaseRoomEngine *re = [[TCILiveBaseRoomEngine alloc] initWith:_IMUser];
                re.runtimeConfig = _liveConfig;
                _roomEngine = re;
            }
                
                break;
            case ETCILiveScene_Live:
            {
                id<AVUserAble> ah = (id<AVUserAble>)_IMUser;
                [ah setAvCtrlState:_liveConfig.avCtrlState];
                TCILiveLiveRoomEngine *re = [[TCILiveLiveRoomEngine alloc] initWith:(id<IMHostAble, AVUserAble>)_IMUser enableChat:[_liveConfig isEnableIM]];
                re.runtimeConfig = (TCILiveLiveConfig *)_liveConfig;
                _roomEngine = re;
                
            }
            case ETCILiveScene_MultiLive:
            {
                
                id<AVUserAble> ah = (id<AVUserAble>)_IMUser;
                [ah setAvCtrlState:_liveConfig.avCtrlState];
                TCILiveMultiLiveRoomEngine *re = [[TCILiveMultiLiveRoomEngine alloc] initWith:(id<IMHostAble, AVMultiUserAble>)_IMUser enableChat:[_liveConfig isEnableIM]];
                re.runtimeConfig = (TCILiveMultiLiveConfig *)_liveConfig;
                _roomEngine = re;
                
                _multiManager = [[TCAVIMMIManager alloc] init];
                _multiManager.roomEngine = re;
                
                if (!_multiManager.preview && [_livePreview isKindOfClass:[TCAVMultiLivePreview class]])
                {
                    _multiManager.preview = (TCAVMultiLivePreview *)_livePreview;
                }
            }
                break;
#if kSupportCallScene
            case ETCILiveScene_Call:
            {
                id<AVUserAble> ah = (id<AVUserAble>)_IMUser;
                [ah setAvCtrlState:_liveConfig.avCtrlState];
                TCILiveCallRoomEngine *re = [[TCILiveCallRoomEngine alloc] initWith:(id<IMHostAble, AVMultiUserAble>)_IMUser enableChat:[_liveConfig isEnableIM]];
                re.runtimeConfig = (TCILiveMultiLiveConfig *)_liveConfig;
                _roomEngine = re;
                
                _multiManager = [[TCAVIMMIManager alloc] init];
                _multiManager.roomEngine = re;
                
            }
                break;
#endif
                
            default:
                break;
        }
        
        _roomEngine.delegate = roomDelegate ? roomDelegate : self;
    }
}


- (void)startEnterLive
{
    if (_switchingToRoom)
    {
        _roomInfo = _switchingToRoom;
        // 观众
        DebugLog(@"-----观众>>>>>观众开始进入直播: 主播ID:%@", [[_roomInfo liveHost] imUserId]);
        [_roomEngine switchToLive:_roomInfo];
    }
    else
    {
        if (_isHost)
        {
            // 主播
            DebugLog(@"-----主播>>>>>主播开始直播: 主播ID:%@", [[_roomInfo liveHost] imUserId]);
        }
        else
        {
            // 观众
            DebugLog(@"-----观众>>>>>观众开始进入直播: 主播ID:%@", [[_roomInfo liveHost] imUserId]);
        }
        [_roomEngine enterLive:_roomInfo];
    }
}

// 内部自动释放监听
- (void)exitLiveWith:(id<TCAVRoomEngineDelegate>)roomDelegate
{
    [self removePhoneListener];
    [self removeNetwokChangeListner];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_livePreview stopPreview];
    _livePreview = nil;
    
    if ([_liveConfig isEnableIM] && _msgHandler)
    {
        __weak typeof(self) wr = self;
        [_msgHandler exitLiveChatRoom:^{
            [wr onRealExitLie:roomDelegate];
        } fail:^(int code, NSString *msg) {
            [wr onRealExitLie:roomDelegate];
        }];
    }
    else
    {
        [self onRealExitLie:roomDelegate];
    }
    
}


- (void)onRealExitLie:(id<TCAVRoomEngineDelegate>)roomDelegate
{
    if ([_liveConfig isEnableIM])
    {
        [_msgHandler releaseIMRef];
        _msgHandler = nil;
    }
    _roomEngine.delegate = roomDelegate ? roomDelegate : self;
    [_roomEngine exitLive];
    
}

- (void)releaseResource
{
    [_livePreview stopPreview];
    _livePreview = nil;
    
    [_msgHandler releaseIMRef];
    _msgHandler = nil;
    
    
    _roomEngine = nil;
    
    _multiManager = nil;
    
    AVAudioSession *aSession = [AVAudioSession sharedInstance];
    [aSession setCategory:_audioSesstionCategory withOptions:_audioSesstionCategoryOptions error:nil];
    [aSession setMode:_audioSesstionMode error:nil];
}

//===========================

- (id<AVIMMsgHandlerAble>)createMsgHandlerAfterEnterRoom:(Class)handlerCls
{
    if ([_liveConfig isEnableIM])
    {
        
#if kSupportCallScene
        if (_liveConfig.liveScene != ETCILiveScene_Call)
#endif
        {
            if (![handlerCls isSubclassOfClass:[AVIMMsgHandler class]] || ![handlerCls conformsToProtocol:@protocol(AVIMMsgHandlerAble)])
            {
                handlerCls = Nil;
                DebugLog(@"必须是AVIMMsgHandler的子类，或自行实现了AVIMMsgHandlerAble协议");
            }
            
            if (handlerCls == Nil)
            {
                if (_liveConfig.liveScene == ETCILiveScene_Live)
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
                else
                {
                    if (!_msgHandler)
                    {
                        _msgHandler = [[MultiAVIMMsgHandler alloc] initWith:_roomInfo];
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
                    
                    _multiManager.msgHandler = (MultiAVIMMsgHandler *)_msgHandler;
                }
            }
            else
            {
                if (!_msgHandler)
                {
                    AVIMMsgHandler *handler = [handlerCls alloc];
                    _msgHandler = [handler initWith:_roomInfo];
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
                
                if (_liveConfig.liveScene > ETCILiveScene_Live)
                {
                    _multiManager.msgHandler = (MultiAVIMMsgHandler *)_msgHandler;
                }
            }
            
        }
        
    }
    
    return _msgHandler;
}

// HOST/Guest进入直播回调
- (void)onAVEngine:(TCAVBaseRoomEngine *)avEngine enterRoom:(id<AVRoomAble>)room succ:(BOOL)succ tipInfo:(NSString *)tip
{
    DebugLog(@"enterroom succ:%d tip:%@", succ, tip);
    
    if (succ)
    {
        if ([_liveConfig isEnableIM])
        {
            [self createMsgHandlerAfterEnterRoom:Nil];
        }
        
        if (!_isHost)
        {
            if (_liveConfig.liveScene >= ETCILiveScene_Live)
            {
                [(TCAVLiveRoomEngine *)_roomEngine asyncRequestHostView];
            }
        }
        
        [_livePreview startPreview];
    }
    
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine disConnect:(id<AVRoomAble>)room
{
    if ([_execeptionListener respondsToSelector:@selector(onTCILiveManagerRoomDisconnect:)])
    {
        [_execeptionListener onTCILiveManagerRoomDisconnect:self];
    }
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine switchRoom:(id<AVRoomAble>)room succ:(BOOL)succ tipInfo:(NSString *)tip
{
    // TODO:暂不处理
    //    if (!succ)
    //    {
    //        _switchingToRoom = nil;
    //    }
    //    DebugLog(@"切换房间%@", succ ? @"成功" : @"失败");
    //    [self onEnterLiveSucc:succ tipInfo:tip];
    //    _switchingToRoom = nil;
    
}


// HOST/Guest退出直播回调
- (void)onAVEngine:(TCAVBaseRoomEngine *)avEngine exitRoom:(id<AVRoomAble>)room succ:(BOOL)succ tipInfo:(NSString *)tip
{
    //    [[HUDHelper sharedInstance] syncStopLoading];
    if ([IMAPlatform sharedInstance].offlineExitLivingBlock)
    {
        [IMAPlatform sharedInstance].offlineExitLivingBlock();
    }
    else
    {
        [[TIMManager sharedInstance] setUserStatusListener:[IMAPlatform sharedInstance]];
    }
    
    if (_roomEngine.delegate == self)
    {
        _roomEngine.delegate = nil;
        [self releaseResource];
    }
    _roomEngine = nil;
}



- (void)onAVEngine:(TCAVBaseRoomEngine *)avEngine videoFrame:(QAVVideoFrame *)frameData
{
    if (_liveConfig.liveScene != ETCILiveScene_Base)
    {
        [_livePreview render:frameData roomEngine:_roomEngine fullScreen:YES];
    }
}

//- (void)onAVEngine:(TCAVBaseRoomEngine *)engine preProcessLocaVideoFrame:(QAVVideoFrame *)frame
//{
//}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine recvSemiAutoVideo:(NSArray *)users
{
    // do nothing in this class
    // overwrite by the subclass
    
    if (_liveConfig.liveScene <= ETCILiveScene_Live)
    {
        [_livePreview addRenderFor:[_roomInfo liveHost]];
    }
    else
    {
        NSMutableArray *hasCamera = [NSMutableArray array];
        for (NSString *iu in users)
        {
            TCAVIMEndpoint *p = [[TCAVIMEndpoint alloc] initWithID:iu];
            if (p)
            {
                [hasCamera addObject:p];
            }
        }
        [_multiManager addInteractUserOnRecvSemiAutoVideo:hasCamera];
    }
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine enableCamera:(BOOL)succ tipInfo:(NSString *)tip
{
    // do nothing in this class
    // overwrite by the subclass
    DebugLog(@"enableCamera:%d tipInfo:%@", succ, tip);
    if (!succ)
    {
        if ([_execeptionListener respondsToSelector:@selector(onTCILiveManagerEnableCameraFailed:)])
        {
            [_execeptionListener onTCILiveManagerEnableCameraFailed:self];
        }
    }
    else
    {
        [_livePreview addRenderFor:_IMUser];
    }
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
            //            [[HUDHelper sharedInstance] tipMessage:tip delay:2 completion:^{
            //                [self exitLive];
            //            }];
            
            if ([_execeptionListener respondsToSelector:@selector(onTCILiveManagerRequestHostVideoFailed:)])
            {
                [_execeptionListener onTCILiveManagerRequestHostVideoFailed:self];
            }
        }
    }
}

// 用户首次请求画面（QAVEndpoint requestViewList）成功后，会开始计时，在［engine maxWaitFirstFrameSec］内画面未显示，则回调请求画面超时
- (void)onAVEngineWaitFirstRemoteFrameTimeOut:(TCAVBaseRoomEngine *)engine
{
    // do nothing
    //    [self tipMessage:@"请求画面超时" delay:1 completion:^{
    //        [self exitLive];
    //    }];
    if ([_execeptionListener respondsToSelector:@selector(onTCILiveManagerFirstFrameTimeOut:)])
    {
        [_execeptionListener onTCILiveManagerFirstFrameTimeOut:self];
    }
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

//- (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion
//{
//    [[HUDHelper sharedInstance] tipMessage:msg delay:seconds completion:completion];
//}

@end

#endif
