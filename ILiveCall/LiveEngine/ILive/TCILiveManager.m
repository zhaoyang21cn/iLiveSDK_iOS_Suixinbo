//
//  TCILiveManager.m
//  ILiveSDK
//
//  Created by AlexiChen on 16/9/9.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCILiveManager.h"

#import "AVGLBaseView.h"
#import "AVGLRenderView.h"
#import "TCAVFrameDispatcher.h"

#import "TCAVSharedContext.h"
#import "AVGLCustomRenderView.h"
#import "TCIMemoItem.h"




@interface TCILiveManager () <QAVLocalVideoDelegate, QAVRemoteVideoDelegate, QAVRoomDelegate, TIMUserStatusListener>
{
    AVGLBaseView        *_avglView;
    TCAVFrameDispatcher *_frameDispatcher;
    
    NSMutableArray      *_avStatusList;                 //  记录当前直播中麦的信息
    
    BOOL _isLiving;
    
    BOOL _hasEnableCameraBeforeEnterBackground;
    BOOL _hasEnableMicBeforeEnterBackground;
    
    
    // 用于音频退出直播时还原现场
    NSString                        *_audioSesstionCategory;    // 进入房间时的音频类别
    NSString                        *_audioSesstionMode;        // 进入房间时的音频模式
    AVAudioSessionCategoryOptions   _audioSesstionCategoryOptions;       // 进入房间时的音频类别选项
}

@property (nonatomic, strong) TIMUserProfile *host;
@property (nonatomic, strong) QAVContext *avContext;

@property (nonatomic, strong) AVGLBaseView *avglView;
@property (nonatomic, strong) TCAVFrameDispatcher *frameDispatcher;

@property (nonatomic, copy) TCIRoomBlock enterRoomBlock;
@property (nonatomic, copy) TCIRoomBlock exitRoomBlock;

@end

@implementation TCILiveManager

static TCILiveManager *_sharedInstance = nil;

+ (void)configWithAppID:(int)sdkAppId accountType:(NSString *)accountType willInit:(TCIVoidBlock)willDo initCompleted:(TCIVoidBlock)completion
{
    if (willDo)
    {
        willDo();
    }
    
    TIMManager *manager = [TIMManager sharedInstance];
    [manager initSdk:sdkAppId accountType:accountType];
    
    if (completion)
    {
        completion();
    }
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _sharedInstance = [[TCILiveManager alloc] init];
    });
    
    return _sharedInstance;
}

- (BOOL)isHostLive
{
    return _room && [[_room liveHostID] isEqualToString:[_host identifier]];
}

- (BOOL)isLiving
{
    return _isLiving;
}

- (NSInteger)maxVideoCount
{
    return 4;
}

- (NSInteger)hasVideoCount
{
    NSInteger count = 0;
    for (TCIMemoItem *item in _avStatusList)
    {
        count += item.isCameraVideo;
        count += item.isScreenVideo;
    }
    
    return count;
}

- (NSInteger)maxMicCount
{
    return 6;
}

- (NSInteger)hasAudioCount
{
    NSInteger count = 0;
    for (TCIMemoItem *item in _avStatusList)
    {
        count += item.isAudio;
    }
    
    return count;
}

#define kEachKickErrorCode 6208
- (void)login:(TIMLoginParam *)param loginFail:(TIMFail)fail offlineKicked:(void (^)(TIMLoginParam *param, TCIRoomBlock completion, TIMFail fail))offline startContextCompletion:(TCIRoomBlock)completion
{
    if (!param)
    {
        if (fail)
        {
            fail(-1, @"登录参数不能为空");
        }
        return;
    }
    
    __weak typeof(self) ws = self;
    [[TIMManager sharedInstance] login:param succ:^{
        TCILDebugLog(@"登录成功:%@ tinyid:%llu sig:%@", param.identifier, [[IMSdkInt sharedInstance] getTinyId], param.userSig);
        [ws configHost:param];
        [ws startContextWith:param completion:completion];
    } fail:^(int code, NSString *msg) {
        
        TCILDebugLog(@"TIMLogin Failed: code=%d err=%@", code, msg);
        if (code == kEachKickErrorCode)
        {
            //互踢重联，重新再登录一次
            if (offline)
            {
                offline(param, completion, fail);
            }
        }
        else
        {
            if (fail)
            {
                fail(code, msg);
            }
        }
    }];
}

- (void)configHost:(TIMLoginParam *)param
{
    __weak typeof(self) ws = self;
    
    TIMUserProfile *up = [[TIMUserProfile alloc] init];
    up.identifier = param.identifier;
    ws.host = up;
    
    [[TIMFriendshipManager sharedInstance] GetSelfProfile:^(TIMUserProfile *selfProfile) {
        TCILDebugLog(@"Get Self Profile Succ");
        ws.host = selfProfile;
    } fail:^(int code, NSString *err) {
        TCILDebugLog(@"Get Self Profile Failed: code=%d err=%@", code, err);
    }];
}

- (void)startContextWith:(TIMLoginParam *)param completion:(TCIRoomBlock)completion
{
    [TCAVSharedContext configContextWith:param completion:completion];
}

- (void)logout:(TIMLoginSucc)succ fail:(TIMFail)fail
{
    __weak typeof(self) ws = self;
    
    [[TIMManager sharedInstance] logout:^{
        [ws onLogoutCompletion];
        if (succ)
        {
            succ();
        }
    } fail:^(int code, NSString *err) {
        [ws onLogoutCompletion];
        if (fail)
        {
            fail(code, err);
        }
    }];
}



//==================================================================

- (void)enterRoom:(TCILiveRoom *)room imChatRoomBlock:(TCIRoomBlock)imblock avRoomCallBack:(TCIRoomBlock)avblock
{
    [self enterRoom:room imChatRoomBlock:imblock avRoomCallBack:avblock avListener:nil];
}
- (void)enterRoom:(TCILiveRoom *)room imChatRoomBlock:(TCIRoomBlock)imblock avListener:(id<QAVRoomDelegate>)delegate
{
    [self enterRoom:room imChatRoomBlock:imblock avRoomCallBack:nil avListener:delegate];
}

- (void)addAudioInterruptListener
{
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
}

- (void)addForeBackgroundListener
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)removeForeBackgroundListener
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)onAudioInterruption:(NSNotification *)notification
{
    //DDLogInfo(@"audioInterruption%@",notification.userInfo);
    NSDictionary *interuptionDict = notification.userInfo;
    NSNumber* interuptionType = [interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
    if(interuptionType.intValue == AVAudioSessionInterruptionTypeBegan)
    {
        TCILDebugLog(@"初中断");
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
    [self exitRoom:nil];
}

- (void)removeAudioInterruptListener
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
    // [[NSNotificationCenter defaultCenter] removeObserver:self];
    AVAudioSession *aSession = [AVAudioSession sharedInstance];
    [aSession setCategory:_audioSesstionCategory withOptions:_audioSesstionCategoryOptions error:nil];
    [aSession setMode:_audioSesstionMode error:nil];
}
// 进入直播间
- (void)enterRoom:(TCILiveRoom *)room imChatRoomBlock:(TCIRoomBlock)block avRoomCallBack:(TCIRoomBlock)avblock avListener:(id<QAVRoomDelegate>)delegate
{
    if (!room || room.avRoomID <= 0)
    {
        TCILDebugLog(@"_room不能为空");
        if (avblock)
        {
            NSError *error = [NSError errorWithDomain:@"room不能为空" code:QAV_ERR_INVALID_ARGUMENT userInfo:nil];
            avblock(NO, error);
        }
        
        if ([delegate respondsToSelector:@selector(OnEnterRoomComplete:)])
        {
            [delegate OnEnterRoomComplete:QAV_ERR_INVALID_ARGUMENT];
        }
        return;
    }
    
    _isLiving = YES;
    
    _room = room;
    
    if (!_avStatusList)
    {
        _avStatusList = [NSMutableArray array];
    }
    
    
    if (delegate == nil || delegate == self)
    {
        self.enterRoomBlock = avblock;
        delegate = self;
    }
    
    if (_room.config.autoMonitorAudioInterupt)
    {
        [self addAudioInterruptListener];
    }
        
    
    if (_room.config.isSupportIM)
    {
        // 创建IM
        [self enterIMRoom:room imChatRoomBlock:block avListener:delegate];
    }
    else
    {
        [self enterAVLiveRoom:room avListener:delegate];
    }
}

- (void)enterIMRoom:(TCILiveRoom *)room imChatRoomBlock:(TCIRoomBlock)block avListener:(id<QAVRoomDelegate>)delegate
{
    BOOL isHost =  [[_host identifier] isEqualToString:[room liveHostID]];
    __weak typeof(self) ws = self;
    if (isHost)
    {
        if (room.config.isFixAVRoomIDAsChatRoomID)
        {
            NSString *roomid = [NSString stringWithFormat:@"%d", room.avRoomID];
            
            TCILDebugLog(@"----->>>>>主播开始创建直播聊天室:%@", roomid);
            [[TIMGroupManager sharedInstance] CreateGroup:room.config.imChatRoomType members:nil groupName:roomid groupId:room.config.isFixAVRoomIDAsChatRoomID ? roomid : nil succ:^(NSString *groupId) {
                TCILDebugLog(@"----->>>>>主播开始创建直播聊天室成功");
                [room setChatRoomID:groupId];
                if (block)
                {
                    block(YES, nil);
                }
                
                [ws enterAVLiveRoom:room avListener:delegate];
                
            } fail:^(int code, NSString *error) {
                // 返回10025，group id has be used，
                // 10025无法区分当前是操作者是否是原群的操作者（目前业务逻辑不存在拿别人的uid创建聊天室逻辑），
                // 为简化逻辑，暂定创建聊天室时返回10025，就直接等同于创建成功
                if (code == 10025)
                {
                    TCILDebugLog(@"----->>>>>主播开始创建直播聊天室成功");
                    [room setChatRoomID:roomid];
                    if (block)
                    {
                        block(YES, nil);
                    }
                    
                    [ws enterAVLiveRoom:room avListener:delegate];
                }
                else
                {
                    TCILDebugLog(@"----->>>>>主播开始创建直播聊天室失败 code: %d , msg = %@", code, error);
                    
                    if (block)
                    {
                        NSError *err = [NSError errorWithDomain:error code:code userInfo:nil];
                        block(NO, err);
                    }
                    
                    [ws removeAudioInterruptListener];
                }
            }];
            
        }
    }
    else
    {
        // 观众加群
        NSString *roomid = room.chatRoomID;
        if (roomid.length == 0)
        {
            TCILDebugLog(@"----->>>>>观众加入直播聊天室不成功");
            if (block)
            {
                NSError *err = [NSError errorWithDomain:@"聊天室ID为空" code:-1 userInfo:nil];
                block(NO, err);
            }
            [ws removeAudioInterruptListener];
            return;
        }
        [[TIMGroupManager sharedInstance] JoinGroup:roomid msg:nil succ:^{
            TCILDebugLog(@"----->>>>>观众加入直播聊天室成功");
            if (block)
            {
                block(YES, nil);
            }
            [ws enterAVLiveRoom:room avListener:delegate];
            
        } fail:^(int code, NSString *error) {
            
            if (code == 10013)
            {
                TCILDebugLog(@"----->>>>>观众加入直播聊天室成功");
                if (block)
                {
                    block(YES, nil);
                }
                [ws enterAVLiveRoom:room avListener:delegate];
            }
            else
            {
                TCILDebugLog(@"----->>>>>观众加入直播聊天室失败 code: %d , msg = %@", code, error);
                // 作已在群的处的处理
                if (block)
                {
                    NSError *err = [NSError errorWithDomain:error code:code userInfo:nil];
                    block(NO, err);
                }
                [ws removeAudioInterruptListener];
            }
            
        }];
    }
}

- (QAVMultiParam *)createRoomParam:(TCILiveRoom *)room
{
    BOOL isHost =  [[_host identifier] isEqualToString:[room liveHostID]];
    QAVMultiParam *param = [[QAVMultiParam alloc] init];
    param.relationId = [room avRoomID];
    param.audioCategory = isHost ? CATEGORY_MEDIA_PLAY_AND_RECORD : CATEGORY_MEDIA_PLAYBACK;
    param.controlRole = [room.config roomControlRole];
    param.authBits = isHost ? QAV_AUTH_BITS_DEFAULT : QAV_AUTH_BITS_JOIN_ROOM | QAV_AUTH_BITS_RECV_AUDIO | QAV_AUTH_BITS_RECV_VIDEO | QAV_AUTH_BITS_RECV_SUB;
    param.createRoom = isHost;
    param.videoRecvMode = VIDEO_RECV_MODE_SEMI_AUTO_RECV_CAMERA_VIDEO;
    param.enableMic = room.config.autoEnableMic;
    param.enableSpeaker = YES;
    param.enableHdAudio = YES;
    param.autoRotateVideo = YES;
    
    return param;
}

- (void)enterAVLiveRoom:(TCILiveRoom *)room avListener:(id<QAVRoomDelegate>)delegate
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    QAVMultiParam *param = [self createRoomParam:room];
    
    _avContext = [TCAVSharedContext sharedContext];
    
    if (!_avContext)
    {
        if (self.enterRoomBlock)
        {
            NSError *err = [NSError errorWithDomain:@"TCAVSharedContext未初始化" code:-1 userInfo:nil];
            self.enterRoomBlock(NO, err);
        }
        
        [self removeAudioInterruptListener];
        return;
    }
    
    // 检查当前网络
    QAVResult result = [_avContext enterRoom:param delegate:delegate];
    
    if(QAV_OK != result)
    {
        TCILDebugLog(@"进房间失败");

        if (self.enterRoomBlock)
        {
            NSError *err = [NSError errorWithDomain:@"TCAVSharedContext未初始化" code:-1 userInfo:nil];
            self.enterRoomBlock(NO, err);
        }
        
        if (delegate && [delegate respondsToSelector:@selector(OnEnterRoomComplete:)])
        {
            [delegate OnEnterRoomComplete:result];
        }
        
        [self removeAudioInterruptListener];
    }
}

- (void)enableCamera:(cameraPos)pos isEnable:(BOOL)bEnable complete:(void (^)(BOOL succ, QAVResult result))block
{
    if (_isLiving)
    {
        __weak typeof(_room) wr = _room;
        QAVResult res = [_avContext.videoCtrl enableCamera:pos isEnable:bEnable complete:^(int result) {
            if (result == QAV_OK)
            {
                wr.config.autoEnableCamera = bEnable;
                if (block)
                {
                    block(YES, result);
                }
            }
            else
            {
                if (result == QAV_ERR_HAS_IN_THE_STATE)
                {
                    // 已是重复状态不处理
                    wr.config.autoEnableCamera = bEnable;
                    if (block)
                    {
                        block(YES, QAV_ERR_HAS_IN_THE_STATE);
                    }
                }
                else
                {
                    // 打开相机重试
                    if (block)
                    {
                        block(NO, result);
                    }
                }
            }
            
        }];
        
        if (res != QAV_OK)
        {
            if (res == QAV_ERR_EXCLUSIVE_OPERATION)
            {
                // 互斥操作时，不会走回调
                TCILDebugLog(@"互斥操作, 没有执行该操作");
                if (block)
                {
                    block(NO, QAV_ERR_EXCLUSIVE_OPERATION);
                }
            }
            else
            {
                // 其他错误
                if (block)
                {
                    block(NO, res);
                }
            }
        }
    }
    else
    {
        if (block)
        {
            TCILDebugLog(@"没有进入房间，不能操作摄像头");
            block(NO, QAV_ERR_FAILED);
        }
    }
}

/*
 * @brief 打开/关闭扬声器。
 * @param bEnable 是否打开。
 * @return YES表示操作成功，NO表示操作失败。
 */
- (BOOL)enableSpeaker:(BOOL)bEnable
{
    if (_isLiving)
    {
        BOOL succ = [_avContext.audioCtrl enableSpeaker:bEnable];
        
        if (succ)
        {
            _room.config.autoEnableSpeaker = bEnable;
        }
        return succ;
    }
    else
    {
        TCILDebugLog(@"没有进入房间，不能操作Speaker");
        return NO;
    }
    
}

/**
 @brief 打开/关闭麦克风。
 
 @param isEnable 是否打开。
 
 @return YES表示操作成功，NO表示操作失败。
 */
- (BOOL)enableMic:(BOOL)isEnable
{
    if (_isLiving)
    {
        BOOL succ = [_avContext.audioCtrl enableSpeaker:isEnable];
        
        if (succ)
        {
            _room.config.autoEnableSpeaker = isEnable;
        }
        return succ;
    }
    else
    {
        TCILDebugLog(@"没有进入房间，不能操作Mic");
        return NO;
    }
}

- (void)switchCamera:(cameraPos)pos complete:(void (^)(BOOL succ, QAVResult result))block
{
    if (_isLiving)
    {
        QAVVideoCtrl *avvc = [_avContext videoCtrl];
        
        __weak typeof(_room.config) wc = _room.config;
        QAVResult res = [avvc switchCamera:pos complete:^(int result) {
            if (QAV_OK == result)
            {
                wc.autoEnableCamera = YES;
                wc.autoCameraId = pos;
                if (block)
                {
                    block(YES, QAV_OK);
                }
            }
            else
            {
                if (result == QAV_ERR_HAS_IN_THE_STATE)
                {
                    // 已是重复状态不处理
                    wc.autoEnableCamera = YES;
                    wc.autoCameraId = pos;
                    if (block)
                    {
                        block(YES, QAV_ERR_HAS_IN_THE_STATE);
                    }
                }
                else
                {
                    if (block)
                    {
                        block(NO, QAV_ERR_HAS_IN_THE_STATE);
                    }
                }
                
            }
        }];
        
        
        if (res != QAV_OK)
        {
            if (res == QAV_ERR_EXCLUSIVE_OPERATION)
            {
                // 互斥操作时，不会走回调
                TCILDebugLog(@"互斥操作, 没有执行该操作");
                if (block)
                {
                    block(NO, QAV_ERR_EXCLUSIVE_OPERATION);
                }
            }
            else
            {
                // 其他错误
                if (block)
                {
                    block(NO, res);
                }
            }
        }
    }
    else
    {
        TCILDebugLog(@"没有进入房间，不能操作Mic");
        if (block)
        {
            block(NO, QAV_ERR_FAILED);
        }
    }
}

- (void)requestViewList:(NSArray *)identifierList srcTypeList:(NSArray *)srcTypeList ret:(RequestViewListBlock)block
{
    [_avContext.room requestViewList:identifierList srcTypeList:srcTypeList ret:block];
}


- (void)innerWillExitRoom:(TCIRoomBlock)avBlock externalExit:(BOOL)fromExternal
{
    self.exitRoomBlock = avBlock;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    if (_room.config.isSupportIM)
    {
        if (_room.config.isNeedExitIMChatRoom)
        {
            [self asyncExitAVChatRoom:_room succ:nil fail:nil];
        }
    }
    
    if (_room.config.autoMonitorNetwork)
    {
        [self removeNetworkListener];
    }
    
    if (_room.config.autoMonitorCall)
    {
        [self removeCallListener];
    }
    
    if (_room.config.autoMonitorKiekedOffline)
    {
        [[TIMManager sharedInstance] setUserStatusListener:nil];
    }
    
    if (_room.config.autoMonitorForeBackgroundSwitch)
    {
        [self addForeBackgroundListener];
    }
    
    [self releaseResource];
    
    if (fromExternal)
    {
        [_avContext exitRoom];
    }
    else
    {
        [self OnExitRoomComplete];
    }
}

/*
 * @brief 退出房间，内部统一处理
 * @param imblock:IM退群处理回调
 * @param avblock:AV出房间(-(void)OnExitRoomComplete)回调处理
 */
- (void)exitRoom:(TCIRoomBlock)avBlock
{
    [self innerWillExitRoom:avBlock externalExit:YES];
}


// 主播 : 主播删除直播聊天室
// 观众 : 观众退出直播聊天室
- (void)asyncExitAVChatRoom:(TCILiveRoom *)room succ:(TIMSucc)succ fail:(TIMFail)fail
{
    if (!room)
    {
        TCILDebugLog(@"直播房房间信息不正确");
        if (fail)
        {
            fail(-1, @"直播房房间信息不正确");
        }
        return;
    }
    
    NSString *roomid = [room chatRoomID];
    
    if (roomid.length == 0)
    {
        TCILDebugLog(@"----->>>>>观众退出的直播聊天室ID为空");
        if (fail)
        {
            fail(-1, @"直播聊天室ID为空");
        }
        return;
    }
    
    
    BOOL isHost = [self isHostLive];
    if (isHost)
    {
        // 主播删群
        [[TIMGroupManager sharedInstance] DeleteGroup:roomid succ:succ fail:fail];
    }
    else
    {
        // 观众退群
        [[TIMGroupManager sharedInstance] QuitGroup:roomid succ:succ fail:fail];
    }
}
/*
 * @brief 退出房间，外部统一处理回调，
 */
- (void)exitRoom
{
    [self exitRoom:nil];
}

- (void)releaseResource
{
    _delegate = nil;
    
    _avStatusList = nil;
    
    _frameDispatcher.imageView = nil;
    _frameDispatcher = nil;
    
    [_avglView stopDisplay];
    [_avglView destroyOpenGL];
    _avglView = nil;
    
    QAVVideoCtrl *ctrl = [_avContext videoCtrl];
    [ctrl setLocalVideoDelegate:nil];
    [ctrl setRemoteVideoDelegate:nil];
}

//==============================================
// 进入后台时回调
- (void)onEnterBackground
{
    [_avglView stopDisplay];
    
    
    if (_isLiving)
    {
        
        if (!_hasEnableCameraBeforeEnterBackground)
        {
            _hasEnableCameraBeforeEnterBackground = _room.config.autoEnableCamera;
        }
        if (_hasEnableCameraBeforeEnterBackground)
        {
            // 到前台的时候打开摄像头，但不需要通知到处面
            [self enableCamera:_room.config.autoCameraId isEnable:NO complete:^(BOOL succ, QAVResult result) {
                TCILDebugLog(@"退后台关闭摄像头:%@", succ ? @"成功" : @"失败");
            }];
        }
        
        if (!_hasEnableMicBeforeEnterBackground)
        {
            _hasEnableMicBeforeEnterBackground = _room.config.autoEnableMic;
        }
        if (_hasEnableMicBeforeEnterBackground && _room.config.isSupportBackgroudMode)
        {
            // 有后台模式时，关mic
            // 无后台模式，系统自动关
            TCILDebugLog(@"进入关开mic");
            [self enableMic:NO];
        }
    }
    
}

// 进入前台时回调
- (void)onEnterForeground
{
    if (_isLiving)
    {
        if (_hasEnableCameraBeforeEnterBackground)
        {
            // 到前台的时候打开摄像头，但不需要通知到处面
            [self enableCamera:_room.config.autoCameraId isEnable:YES complete:^(BOOL succ, QAVResult result) {
                TCILDebugLog(@"退后台关闭摄像头:%@", succ ? @"成功" : @"失败");
            }];
        }
        
        if (_hasEnableMicBeforeEnterBackground && _room.config.isSupportBackgroudMode)
        {
            // 有后台模式时，关mic
            // 无后台模式，系统自动关
            TCILDebugLog(@"进入关开mic");
            [self enableMic:YES];
        }
    }
    [_avglView startDisplay];
}

//==============================================

- (AVGLBaseView *)createAVGLViewIn:(UIViewController *)vc
{
    if (!vc)
    {
        TCILDebugLog(@"传入的直播界面不能为空");
        return nil;
    }
    if (!_avglView)
    {
        _avglView = [[AVGLBaseView alloc] initWithFrame:vc.view.bounds];
        _avglView.backgroundColor = [UIColor blackColor];
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        [_avglView setBackGroundTransparent:YES];
        [vc.view insertSubview:_avglView atIndex:0];
        
        @try
        {
            [_avglView initOpenGL];
            [self configDispatcher];
            TCILDebugLog(@"初始化OpenGL成功");
            
        }
        @catch (NSException *exception)
        {
            TCILDebugLog(@"OpenGL 初台化异常");
        }
        @finally
        {
            return _avglView;
        }
    }
    else
    {
        if (_avglView.superview != vc.view)
        {
            [_avglView removeFromSuperview];
            [vc.view insertSubview:_avglView atIndex:0];
        }
    }
    return _avglView;
}

- (void)configDispatcher
{
    if (!_frameDispatcher)
    {
        _frameDispatcher = [[TCAVFrameDispatcher alloc] init];
        _frameDispatcher.imageView = _avglView;
    }
    else
    {
        TCILDebugLog(@"Protected方法，外部禁止调用");
    }
}

- (TCIMemoItem *)hasRenderMemo:(NSString *)uid atFrame:(CGRect)rect;
{
    if (uid.length == 0)
    {
        return nil;
    }
    
    if (!_avStatusList)
    {
        _avStatusList = [NSMutableArray array];
    }
    
    for (TCIMemoItem *item in _avStatusList)
    {
        if ([item.identifier isEqualToString:uid])
        {
            item.showRect = rect;
            return item;
        }
    }
    
    TCIMemoItem *item = [[TCIMemoItem alloc] initWith:uid showRect:rect];
    [_avStatusList addObject:item];
    
    return nil;
}

- (TCIMemoItem *)renderMemoOf:(NSString *)uid
{
    for (TCIMemoItem *item in _avStatusList)
    {
        if ([item.identifier isEqualToString:uid])
        {
            return item;
        }
    }
    
    return nil;
}

- (void)removeRenderMemoOf:(NSString *)uid
{
    TCIMemoItem *bi = nil;
    for (TCIMemoItem *item in _avStatusList)
    {
        if ([item.identifier isEqualToString:uid])
        {
            bi = item;
            break;
        }
    }
    
    [_avStatusList removeObject:bi];
}

- (AVGLCustomRenderView *)renderFor:(NSString *)uid
{
    AVGLCustomRenderView *glView = (AVGLCustomRenderView *)[_avglView getSubviewForKey:uid];
    return glView;
}

- (AVGLCustomRenderView *)addRenderFor:(NSString *)uid atFrame:(CGRect)rect
{
    if (![self renderMemoOf:uid] && [self hasVideoCount] >= [self maxVideoCount])
    {
        TCILDebugLog(@"已达到最大请求数，不能添加RenderV");
        return nil;
    }
    
    if (!_avglView)
    {
        TCILDebugLog(@"_avglView为空，添加render无用");
        return nil;
    }
    
    if (uid.length == 0 || CGRectIsEmpty(rect))
    {
        TCILDebugLog(@"参数错误");
        return nil;
    }
    
    AVGLCustomRenderView *glView = (AVGLCustomRenderView *)[_avglView getSubviewForKey:uid];
    
    if (!glView)
    {
        glView = [[AVGLCustomRenderView alloc] initWithFrame:_avglView.bounds];
        [_avglView addSubview:glView forKey:uid];
    }
    else
    {
        TCILDebugLog(@"已存在的%@渲染画面，不重复添加", uid);
    }
    
    glView.frame = rect;
    [glView setHasBlackEdge:NO];
    glView.nickView.hidden = YES;
    [glView setBoundsWithWidth:0];
    [glView setDisplayBlock:NO];
    [glView setCuttingEnable:YES];
    
    if (![_avglView isDisplay])
    {
        [_avglView startDisplay];
    }
    
    [self hasRenderMemo:uid atFrame:rect];
    
    return glView;
}

- (void)removeRenderFor:(NSString *)uid
{
    [_avglView removeSubviewForKey:uid];
    [self removeRenderFor:uid];
}

- (BOOL)switchRender:(NSString *)userid withOther:(NSString *)mainuser
{
    BOOL succ = [_avglView switchSubviewForKey:userid withKey:mainuser];
    if (succ)
    {
        AVGLRenderView *uv = [_avglView getSubviewForKey:userid];
        AVGLRenderView *mv = [_avglView getSubviewForKey:mainuser];
        
        [self hasRenderMemo:userid atFrame:uv.frame];
        [self hasRenderMemo:mainuser atFrame:mv.frame];
        
    }
    return succ;
}

- (BOOL)replaceRender:(NSString *)userid withUser:(NSString *)mainuser
{
    // 先交换二者的位置参数
    BOOL succ = [_avglView switchSubviewForKey:userid withKey:mainuser];
    if (succ)
    {
        AVGLRenderView *mv = [_avglView getSubviewForKey:mainuser];
        [self hasRenderMemo:mainuser atFrame:mv.frame];
        
        [self removeRenderFor:userid];
    }
    return succ;
}

- (void)registerRenderMemo:(NSArray *)list
{
    if (!list || list.count > 4)
    {
        TCILDebugLog(@"参数错误，不作处理");
        return;
    }
    
    
    if (!_avglView)
    {
        CGRect rect = [UIScreen mainScreen].bounds;
        _avglView = [[AVGLBaseView alloc] initWithFrame:rect];
        _avglView.backgroundColor = [UIColor blackColor];
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        [_avglView setBackGroundTransparent:YES];
        
        @try
        {
            [_avglView initOpenGL];
            [self configDispatcher];
            TCILDebugLog(@"初始化OpenGL成功");
            
        }
        @catch (NSException *exception)
        {
            TCILDebugLog(@"OpenGL 初台化异常");
        }
        @finally
        {
            
            if (!_avStatusList)
            {
                _avStatusList = [NSMutableArray array];
            }
            
            [_avStatusList removeAllObjects];
            
            for (TCIMemoItem *item in list)
            {
                if ([item isValid])
                {
                    if (![item isPlaceholder])
                    {
                        [self addRenderFor:item.identifier atFrame:item.showRect];
                    }
                    else
                    {
                        [_avStatusList addObject:item];
                    }
                    
                }
            }
        }
    }
    
}

/*
 * @brief 如果在直播界面外，采用默内内部处理的逻辑（调用该接口- (void)enterRoom:imChatRoomBlock:avRoomCallBack:listener:）, 开始enterRoom，在进入到直播界面时，需要手动查下该
 */
- (NSDictionary *)getAVStatusList
{
    return nil;
}

//=====================================

- (void)sendToC2C:(NSString *)recvID message:(TIMMessage *)message succ:(TIMSucc)succ fail:(TIMFail)fail
{
    if (!_room.config.isSupportIM)
    {
        TCILDebugLog(@"传入的房间配置不支持IM");
        return;
    }
    if (recvID.length == 0)
    {
        TCILDebugLog(@"接收者recvID不能为空");
        return;
    }
    
    if (message)
    {
        TCILDebugLog(@"发送的消息不能为空");
        return;
    }
    TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:recvID];
    [conv sendMessage:message succ:succ fail:fail];
}
- (void)sendGroupMessage:(TIMMessage *)message succ:(TIMSucc)succ fail:(TIMFail)fail
{
    if (!_room.config.isSupportIM)
    {
        TCILDebugLog(@"传入的房间配置不支持IM");
        return;
    }
    
    if (message)
    {
        TCILDebugLog(@"发送的消息不能为空");
        return;
    }
    TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:_room.chatRoomID];
    [conv sendMessage:message succ:succ fail:fail];
}

//=====================================

- (void)addNetworkListener
{
    
}

- (void)addCallListener
{
    
}

- (void)removeNetworkListener
{
    
}

- (void)removeCallListener
{
    
}

//=====================================

/**
 @brief 返回QAVContext::EnterRoom()的异步操作结果的函数。
 
 @details 此函数用来返回QAVContext::EnterRoom()的异步操作结果。
 
 @param result 返回码。SDK的各种返回码的定义和其他详细说明参考QAVError.h。
 */
-(void)OnEnterRoomComplete:(int)result
{
    // 进入AV房间
    
    if(QAV_OK == result)
    {
        //设置麦克风和扬声器（在进入房间设置才有效）
        QAVVideoCtrl *ctrl = [_avContext videoCtrl];
        if (ctrl)
        {
            [ctrl setLocalVideoDelegate:self];
            [ctrl setRemoteVideoDelegate:self];
        }
        
        if (_room.config.autoEnableCamera)
        {
            [self enableCamera:_room.config.autoCameraId isEnable:YES complete:nil];
        }
        
        if (![_room isHostLive] && _room.config.autoRequestView)
        {
            [self requestViewList:@[_room.liveHostID] srcTypeList:@[@(QAVVIDEO_SRC_TYPE_CAMERA)] ret:nil];
        }
        
        if (_room.config.autoMonitorNetwork)
        {
            [self addNetworkListener];
        }
        
        if (_room.config.autoMonitorCall)
        {
            [self addCallListener];
        }
        
        if (_room.config.autoMonitorKiekedOffline)
        {
            [[TIMManager sharedInstance] setUserStatusListener:self];
        }
        
        if (_room.config.autoMonitorForeBackgroundSwitch)
        {
            [self addForeBackgroundListener];
        }
        
        if (self.enterRoomBlock)
        {
            self.enterRoomBlock(YES, nil);
        }
    }
    else
    {
        if (self.enterRoomBlock)
        {
            NSError *err = [NSError errorWithDomain:[NSString stringWithFormat:@"错误码:%d", result] code:result userInfo:nil];
            self.enterRoomBlock(NO, err);
        }
    }
    
    self.enterRoomBlock = nil;
}

/**
 *  踢下线通知
 */
- (void)onForceOffline
{
    if ([_delegate respondsToSelector:@selector(onKickedOfflineWhenLive)])
    {
        [_delegate onKickedOfflineWhenLive];
    }
}

/**
 *  断线重连失败
 */
- (void)onReConnFailed:(int)code err:(NSString*)err
{
    TCILDebugLog(@"IM断线重连:%d %@", code, err);
    
    if ([_delegate respondsToSelector:@selector(onReConnFailedWhenLiveWithError:)])
    {
        NSError *error = [NSError errorWithDomain:err code:code userInfo:nil];
        [_delegate onReConnFailedWhenLiveWithError:error];
    }
}

/**
 *  用户登录的userSig过期（用户需要重新获取userSig后登录）
 */
- (void)onUserSigExpired
{
    TCILDebugLog(@"IM票据过期");
    if ([_delegate respondsToSelector:@selector(onCurrentUserSigExpiredWhenLive)])
    {
        [_delegate onCurrentUserSigExpiredWhenLive];
    }
}

/**
 @brief 本地画面预览回调
 @param frameData : 本地视频帧数据
 */
-(void)OnLocalVideoPreview:(QAVVideoFrame*)frameData
{
    [self onAVRecvVideoFrame:frameData];
}

- (void)onAVRecvVideoFrame:(QAVVideoFrame *)frame
{
    if ([_avglView isDisplay])
    {
        BOOL isLocal = frame.identifier.length == 0;
        if (isLocal)
        {
            // 为多人的时候要处理
            frame.identifier = _host.identifier;
        }
        
        [_frameDispatcher dispatchVideoFrame:frame isLocal:isLocal isFront:[_avContext.videoCtrl isFrontcamera] isFull:YES];
    }
}


-(void)OnLocalVideoPreProcess:(QAVVideoFrame*)frameData
{
    // do nothing
}

-(void)OnLocalVideoRawSampleBuf:(CMSampleBufferRef)buf result:(CMSampleBufferRef*)ret
{
    // do nothing
}


-(void)OnVideoPreview:(QAVVideoFrame*)frameData
{
    [self onAVRecvVideoFrame:frameData];
}
/**
 @brief 退出房间完成回调。
 
 @details APP调用ExitRoom()后，SDK通过此回调通知APP成功退出了房间。
 */
-(void)OnExitRoomComplete
{
    _isLiving = NO;
    [self releaseResource];
    if (self.exitRoomBlock)
    {
        self.exitRoomBlock(YES, nil);
    }
    self.exitRoomBlock = nil;
    
    if (_room.config.autoMonitorAudioInterupt)
    {
        [self removeAudioInterruptListener];
    }
}

/**
 @brief SDK主动退出房间提示。
 
 @details 该回调方法表示SDK内部主动退出了房间。SDK内部会因为30s心跳包超时等原因主动退出房间，APP需要监听此退出房间事件并对该事件进行相应处理
 
 @param reason 退出房间的原因，具体值见返回码。SDK的各种返回码的定义和其他详细说明参考QAVError.h。
 */

// 底层已退房
-(void)OnRoomDisconnect:(int)reason
{
    [self innerWillExitRoom:nil externalExit:NO];
    //    [_delegate onAVExitRoom:_liveOption succ:YES];
    TCILDebugLog(@"QAVSDK主动退出房间提示 : %d", reason);
    if ([_delegate respondsToSelector:@selector(onRoomDisconnected:)])
    {
        [_delegate onRoomDisconnected:reason];
    }
}


- (NSString *)eventTip:(QAVUpdateEvent)event
{
    switch (event)
    {
        case QAV_EVENT_ID_NONE:
            return @"no thing";
            break;
        case QAV_EVENT_ID_ENDPOINT_ENTER:
            return @"进入房间";
        case QAV_EVENT_ID_ENDPOINT_EXIT:
            return @"退出房间";
        case QAV_EVENT_ID_ENDPOINT_HAS_CAMERA_VIDEO:
            return @"打开摄像头";
        case QAV_EVENT_ID_ENDPOINT_NO_CAMERA_VIDEO:
            return @"关闭摄像头";
        case QAV_EVENT_ID_ENDPOINT_HAS_AUDIO:
            return @"打开麦克风";
        case QAV_EVENT_ID_ENDPOINT_NO_AUDIO:
            return @"关闭麦克风";
        case QAV_EVENT_ID_ENDPOINT_HAS_SCREEN_VIDEO:
            return @"发屏幕";
        case QAV_EVENT_ID_ENDPOINT_NO_SCREEN_VIDEO:
            return @"不发屏幕";
            
        default:
            return nil;
            break;
    }
}

- (void)autoRequestCameraViewOf:(NSArray *)endpoints
{
    for (QAVEndpoint *point in endpoints)
    {
        TCIMemoItem *item = [self renderMemoOf:[point identifier]];
        
        if (!item)
        {
            item = [[TCIMemoItem alloc] init];
            item.identifier = [point identifier];
            [_avStatusList addObject:item];
        }
    }
    
    NSMutableArray *ids = [NSMutableArray array];
    NSMutableArray *tds = [NSMutableArray array];
    
    for (TCIMemoItem *item in _avStatusList)
    {
        if (item.identifier && ![item.identifier isEqualToString:_host.identifier])
        {
            [ids addObject:item.identifier];
            [tds addObject:@(QAVVIDEO_SRC_TYPE_CAMERA)];
        }
    }
    
    [self requestViewList:ids srcTypeList:tds ret:nil];
}

/**
 @brief 房间成员状态变化通知的函数。
 
 @details 当房间成员发生状态变化(如是否发音频、是否发视频等)时，会通过该函数通知业务侧。
 
 @param eventID 状态变化id，详见QAVUpdateEvent的定义。
 @param endpoints 发生状态变化的成员id列表。
 */
-(void)OnEndpointsUpdateInfo:(QAVUpdateEvent)eventID endpointlist:(NSArray *)endpoints
{
    TCILDebugLog(@"endpoints = %@ evenId = %d %@", endpoints, (int)eventID, [self eventTip:eventID]);
    
    switch (eventID)
    {
        case QAV_EVENT_ID_ENDPOINT_ENTER:// = 1,             ///< 进入房间事件。
        {
            
        }
            break;
        case QAV_EVENT_ID_ENDPOINT_EXIT:// = 2,              ///< 退出房间事件。
        {
            
        }
            break;
        case QAV_EVENT_ID_ENDPOINT_HAS_CAMERA_VIDEO:// 3,  ///< 有发摄像头视频事件。
        {
            if (_room.config.autoRequestView)
            {
                [self autoRequestCameraViewOf:endpoints];
            }
        
            for (QAVEndpoint *point in endpoints)
            {
                TCIMemoItem *item = [self renderMemoOf:point.identifier];
                item.isCameraVideo = YES;
            }
            
        }
            
            break;
            
        case QAV_EVENT_ID_ENDPOINT_NO_CAMERA_VIDEO:// 4,  ///< 无发摄像头视频事件。
        {
            for (QAVEndpoint *point in endpoints)
            {
                TCIMemoItem *item = [self renderMemoOf:point.identifier];
                item.isCameraVideo = NO;
            }
        }
            break;
            
        case QAV_EVENT_ID_ENDPOINT_HAS_AUDIO:// = 5,        ///< 有发语音事件。
        {
            for (QAVEndpoint *point in endpoints)
            {
                TCIMemoItem *item = [self renderMemoOf:point.identifier];
                item.isAudio = YES;
            }
        }
            break;
        case QAV_EVENT_ID_ENDPOINT_NO_AUDIO:// = 6,         ///< 无发语音事件。
        {
            for (QAVEndpoint *point in endpoints)
            {
                TCIMemoItem *item = [self renderMemoOf:point.identifier];
                item.isAudio = NO;
            }
        }
            break;
            
        case QAV_EVENT_ID_ENDPOINT_HAS_SCREEN_VIDEO:// = 7,  ///< 有发屏幕视频事件。
        {
            for (QAVEndpoint *point in endpoints)
            {
                TCIMemoItem *item = [self renderMemoOf:point.identifier];
                item.isScreenVideo = YES;
            }
        }
            break;
        case QAV_EVENT_ID_ENDPOINT_NO_SCREEN_VIDEO:// = 8,   ///< 无发屏幕视频事件。
        {
            for (QAVEndpoint *point in endpoints)
            {
                TCIMemoItem *item = [self renderMemoOf:point.identifier];
                item.isScreenVideo = NO;
            }
        }
            break;
        default:
            break;
    }
    
    if ([_delegate respondsToSelector:@selector(onEndpointsUpdateInfo:endpointlist:)])
    {
        [_delegate onEndpointsUpdateInfo:eventID endpointlist:endpoints];
    }
}

- (void)handleSemiCameraVideoList:(NSArray *)identifierList
{
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *uid in identifierList)
    {
        TCIMemoItem *item = [self renderMemoOf:uid];
        if ([item isPlaceholder] && [item isValid])
        {
            item.identifier = uid;
            [self addRenderFor:uid atFrame:item.showRect];
        }
        else
        {
            [array addObject:uid];
        }
    }
    
    if (array.count)
    {
        if ([_delegate respondsToSelector:@selector(onRecvSemiAutoCameraVideo:)])
        {
            [_delegate onRecvSemiAutoCameraVideo:array];
        }
    }
}

- (void)OnSemiAutoRecvCameraVideo:(NSArray *)identifierList
{
    // 内部自动接收
    //    [_delegate onAVRecvSemiAutoVideo:identifierList];
    
    [self handleSemiCameraVideoList:identifierList];
}




-(void)OnPrivilegeDiffNotify:(int)privilege
{
    
}

-(void)OnCameraSettingNotify:(int)width Height:(int)height Fps:(int)fps
{
    // do nothing
}

-(void)OnRoomEvent:(int)type subtype:(int)subtype data:(void*)data
{
    // do nothing
}

@end


@implementation TCILiveManager (ProtectedMethod)

- (void)onLogoutCompletion
{
    [TCAVSharedContext destroyContextCompletion:nil];
    self.avContext = nil;
    
    self.host = nil;
}

@end