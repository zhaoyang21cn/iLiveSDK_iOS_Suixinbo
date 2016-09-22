//
//  TCILiveManager.h
//  TCAVIMDemo
//
//  Created by AlexiChen on 16/9/5.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportILiveSDK
#import <Foundation/Foundation.h>

@interface TCILiveManager : NSObject<TCAVRoomEngineDelegate, TIMUserStatusListener>
{
@protected
    TCILiveBaseConfig                   *_liveConfig;
    
    
@protected
    id<AVRoomAble>                          _roomInfo;          // 房间信息
    id<IMHostAble>                          _IMUser;            // 当前登录IMSDK的用户
    
@protected
    id<AVIMMsgHandlerAble>              _msgHandler;            // 直播间内消息处理模块
    TCAVBaseRoomEngine                  *_roomEngine;
    
@protected
    
    TCAVIMMIManager          *_multiManager;          // 多人互动逻辑处理
    
@protected
   
    TCAVLivePreview                     *_livePreview;
}

@property (nonatomic, readonly) id<AVIMMsgHandlerAble> msgHandler;
@property (nonatomic, readonly) TCAVBaseRoomEngine *roomEngine;
@property (nonatomic, readonly) TCAVIMMIManager *multiManager;

/*
 * @brief 返回TCILiveManager单例，需要在+ (instancetype)configIMSDKWithAppID:(int)sdkAppId accountType:(NSString *)accountType config:(IMAPlatformConfig *)config withCompletion:(CommonVoidBlock)completion;之后使用
 */
+ (instancetype)sharedInstance;

- (BOOL)isHostLive;

// 单次直播时创建有效
- (TCAVLivePreview *)createLivePreviewIn:(UIViewController *)vc inConfig:(TCILiveBaseConfig *)config;

// 检查直播环境
- (void)checkLiveNetworkWith:(id<TCILiveManagerStartLiveListener>)listener inConfig:(TCILiveBaseConfig *)config;
- (void)checkCameraAuthAndMicPermission:(id<TCILiveManagerStartLiveListener>)ls inConfig:(TCILiveBaseConfig *)config;

// config, room, user, 必传
// listenter不为空，默认使用TCILiveManager进行相机，麦克风，网络检查，为空TCILiveManager内部不作检查，用户自己保证
// roomDelegate为engine回调处理，为空使用TCILiveManager默认处理，此时外部注意监听TCILiveManagerExceptionListener中的回调，不为空时，外部用户自己保证

- (void)startEnterLiveWith:(TCILiveBaseConfig *)config room:(id<AVRoomAble>)room currentUser:(id<IMHostAble>)user roomEngineDelegate:(id<TCAVRoomEngineDelegate>)roomDelegate execeptionListener:(id<TCILiveManagerExceptionListener>)ls;

// 电话场景不需要调用此方法，
- (id<AVIMMsgHandlerAble>)createMsgHandlerAfterEnterRoom:(Class)handlerCls;


// roomDelegate为空时，内部自动释放监听
// roomDelegate不为空时，退出流程外部监听
- (void)exitLiveWith:(id<TCAVRoomEngineDelegate>)roomDelegate;

- (void)releaseResource;





@end
#endif
