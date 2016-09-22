//
//  TCAVMultiLiveViewController.m
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVMultiLiveViewController.h"

@interface TCAVMultiLiveViewController ()

@end

@implementation TCAVMultiLiveViewController


+ (void)checkInitParam:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    if (![user conformsToProtocol:@protocol(AVMultiUserAble)])
    {
        DebugLog(@"因此类中要使用TCAVMultiLiveRoomEngine，为保证其能正常使用，其传入的Host[%@ : %p]必须要实现AVMultiUserAble", [user class], user);
        NSString *reason = [NSString stringWithFormat:@"[%@ : %p]必须实现AVMultiUserAble协议", [user class], user];
        NSException *e = [NSException exceptionWithName:@"TCAVMultiLiveRoomEngineHostInVailed" reason:reason userInfo:nil];
        @throw e;
    }
}

- (instancetype)initWith:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    [TCAVMultiLiveViewController checkInitParam:info user:user];
    if (self = [super initWith:info user:user])
    {
        [self addMultiManager];
    }
    return self;
}




- (void)prepareIMMsgHandler
{
    if (!_msgHandler)
    {
        _msgHandler = [[MultiAVIMMsgHandler alloc] initWith:_roomInfo];
        _multiManager.msgHandler = (MultiAVIMMsgHandler *)_msgHandler;
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

- (void)createRoomEngine
{
    if (!_roomEngine)
    {
        id<AVMultiUserAble> ah = (id<AVMultiUserAble>)_currentUser;
        [ah setAvMultiUserState:_isHost ? AVMultiUser_Host : AVMultiUser_Guest];
        [ah setAvCtrlState:[self defaultAVHostConfig]];
        _roomEngine = [[TCAVMultiLiveRoomEngine alloc] initWith:(id<IMHostAble, AVMultiUserAble>)_currentUser enableChat:_enableIM];
        _roomEngine.delegate = self;
        
        if (!_isHost)
        {
            [_liveView setRoomEngine:_roomEngine];
        }
    }
}

// 外部分配user窗口位置，此处可在界面显示相应的小窗口
- (void)onAVIMMIMManager:(TCAVIMMIManager *)mgr assignWindowResourceTo:(id<AVMultiUserAble>)user isInvite:(BOOL)inviteOrAuto
{
    // TODO:子类去分去配置
}

- (void)onAVIMMIMManager:(TCAVIMMIManager *)mgr requestViewComplete:(BOOL)succ
{
    // TODO:子类去分去配置
}

// 外部回收user窗口资源信息
- (void)onAVIMMIMManager:(TCAVIMMIManager *)mgr recycleWindowResourceOf:(id<AVMultiUserAble>)user
{
    // TODO:子类去分去配置
}

// 外部界面切换到请求画面操作
- (void)onAVIMMIMManagerRequestHostViewFailed:(TCAVIMMIManager *)mgr
{
    // TODO:子类去分去配置
}

- (void)addRenderInPreview:(id<AVMultiUserAble>)user
{
    [_livePreview addRenderFor:user];
}

- (void)removeRenderInPreview:(id<AVMultiUserAble>)user
{
    [_livePreview removeRenderOf:user];
}

- (void)switchToMainInPreview:(id<AVMultiUserAble>)user completion:(TCAVCompletion)completion
{
    [_multiManager switchAsMainUser:user completion:completion];
}

- (void)exitLive
{
    [_multiManager initiativeCancelInteractUser:(id<AVMultiUserAble>)_currentUser];
    [super exitLive];
}


@end


@implementation TCAVMultiLiveViewController (ProtectedMethod)

- (void)addLivePreview
{
    TCAVMultiLivePreview *preview = [[TCAVMultiLivePreview alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:preview];
    _livePreview = preview;
    [_livePreview registLeaveView:[TCAVMultiLeaveView class]];
    
    _multiManager.preview = preview;
    [_livePreview addRenderFor:[_roomInfo liveHost]];
}

- (void)addMultiManager
{
    _multiManager = [[TCAVIMMIManager alloc] init];
    _multiManager.multiDelegate = self;
}

- (void)requestHostViewOnEnterLiveSucc
{
    id<AVMultiUserAble> host = (id<AVMultiUserAble>)[_roomInfo liveHost];
    _multiManager.roomEngine = (TCAVMultiLiveRoomEngine *)_roomEngine;
    [_multiManager registAsMainUser:host isHost:_isHost];
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine videoFrame:(QAVVideoFrame *)frame
{
    NSString *fid = frame.identifier;
    if (fid.length == 0)
    {
        fid = [_currentUser imUserId];
    }
    
//    TCAVMultiLivePreview *preview = (TCAVMultiLivePreview *)_livePreview;
//    [_livePreview render:frame isHost:[engine isHostLive] mirrorReverse:[engine isFrontCamera] isFullScreen:[_multiManager isMainUserByID:fid]];
    [_livePreview render:frame roomEngine:engine fullScreen:[_multiManager isMainUserByID:fid]];
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users exitRoom:(id<AVRoomAble>)room
{
    // 此处，根据具体业务来处理：比如的业务下，支持主播可以退出再进，这样观众可以在线等待就不用退出了
    NSString *roomHostId = [[room liveHost] imUserId];
    for (id<AVMultiUserAble> iu in users)
    {
        NSString *iuid = [iu imUserId];
        if ([iuid isEqualToString:roomHostId])
        {
            if (!self.isExiting)
            {
                [self willExitLiving];
                // 说明主播退出
                UIAlertView *alert =  [UIAlertView bk_showAlertViewWithTitle:nil message:@"主播已退出当前直播" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self exitLive];
                }];
                [alert show];
                break;
            }
        }
        else
        {
            // 检查是否是互动观众退出了
            id<AVMultiUserAble> iiu = [_multiManager interactUserOf:iu];
            if (iiu)
            {
                NSString *tip = [NSString stringWithFormat:@"互动观众(%@)退出直播", iuid];
                [self tipMessage:tip delay:2 completion:^{
                    [_multiManager forcedCancelInteractUser:iiu];
                }];
            }
        }
    }
}

- (void)onHasCameraUserBack:(NSArray *)users
{
    NSString *roomHostId = [[[_roomEngine getRoomInfo] liveHost] imUserId];
    NSMutableArray *hasCamera = [NSMutableArray array];
    NSMutableArray *hasCameraUser = [NSMutableArray array];
    BOOL mainBack = NO;
    for (id<AVMultiUserAble> iu in users)
    {
        NSString *iuid = [iu imUserId];
        TCAVIMEndpoint *p = [[TCAVIMEndpoint alloc] initWith:(QAVEndpoint *)iu];
        if (![iuid isEqualToString:roomHostId])
        {
            [hasCamera addObject:p];
        }
        [hasCameraUser addObject:p];
        [_multiManager enableInteractUser:iu ctrlState:EAVCtrlState_Camera];
        
        if ([[_multiManager.mainUser imUserId] isEqualToString:[p imUserId]])
        {
            mainBack = YES;
        }
    }
    if (hasCamera.count)
    {
        DebugLog(@"%@", hasCamera);
        // 改成请求多人的
        [_multiManager requestMultipleViewOf:hasCamera];
    }
    if (mainBack)
    {
        [_livePreview onUserBack:_multiManager.mainUser];
    }

}
- (void)onNoCameraUserLeave:(NSArray *)users
{
    NSMutableArray *noCameraUser = [NSMutableArray array];
    BOOL mainLeave = NO;
    for (id<AVMultiUserAble> iu in users)
    {
        TCAVIMEndpoint *p = [[TCAVIMEndpoint alloc] initWith:(QAVEndpoint *)iu];
        [_multiManager disableInteractUser:p ctrlState:EAVCtrlState_Camera];
        [noCameraUser addObject:p];
        
        if ([[_multiManager.mainUser imUserId] isEqualToString:[p imUserId]])
        {
            mainLeave = YES;
        }
        
    }
    
    if (mainLeave)
    {
        [_livePreview onUserLeave:_multiManager.mainUser];
    }
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users event:(QAVUpdateEvent)event
{
    
    // 是否是主播收到的
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
        case QAV_EVENT_ID_ENDPOINT_HAS_AUDIO:
        {
            for (id<AVMultiUserAble> iu in users)
            {
                [_multiManager enableInteractUser:iu ctrlState:EAVCtrlState_Mic];
            }
        }
            break;
        case QAV_EVENT_ID_ENDPOINT_NO_AUDIO:
        {
            for (id<AVMultiUserAble> iu in users)
            {
                [_multiManager disableInteractUser:iu ctrlState:EAVCtrlState_Mic];
            }
        }
            break;
        default:
            break;
    }
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine recvSemiAutoVideo:(NSArray *)users
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


// 切换直播间
- (BOOL)switchToLive:(id<AVRoomAble>)room
{
    BOOL succ = [super switchToLive:room];
    if (succ)
    {
        // 界面停止渲染
        [_multiManager clearAllOnSwitchRoom];
        
    }
    return succ;
}


// iOS在App运行中，修改Mic以及相机权限，App会退出
// 检查Camera权限，没有权限时，执行noauthBlock
- (NSString *)cameraAuthorizationTip;
{
    return _isHost ? @"没有权限访问您的相机，无法进行直播，请在“设置－隐私－相机”中允许使用。" : @"没有权限访问您的相机，无法与主播进行互动，请在“设置－隐私－相机”中允许使用。";
}

// 无麦克风权限时的提示语
- (NSString *)micPermissionTip
{
    return _isHost ? @"没有权限访问您的麦克风，无法进行直播，请在“设置-隐私-麦克风”中允许访问麦克风。" : @"没有权限访问您的麦克风，无法与主播进行互动，请在“设置-隐私-麦克风”中允许访问麦克风。";
}

// 主播离开直播间
- (void)onHostLeaveLiveRoom
{
    if ([_multiManager isInteractUser:_currentUser])
    {
        AVIMCMD *lc = [[AVIMCMD alloc] initWith:AVIMCMD_Host_Leave];
        [_msgHandler sendCustomGroupMsg:lc succ:nil fail:nil];
    }
    
}

// 主播返回直播间
- (void)onHostBackLiveRoom
{
    if ([_multiManager isInteractUser:_currentUser])
    {
        AVIMCMD *lc = [[AVIMCMD alloc] initWith:AVIMCMD_Host_Back];
        [_msgHandler sendCustomGroupMsg:lc succ:nil fail:nil];
    }
    
}

@end