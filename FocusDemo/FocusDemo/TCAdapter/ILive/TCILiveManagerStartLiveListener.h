//
//  TCILiveManagerStartLiveListener.h
//  TCAVIMDemo
//
//  Created by AlexiChen on 16/9/5.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TCILiveManager;

@protocol TCILiveManagerStartLiveListener <NSObject>

@required
// 进入房间时，检查到没有网络
- (void)onTCILiveManagerHasNoNetwork:(TCILiveManager *)manager;

// 进入房间时，检查到不是使用的WiFi，使用的是移动网络
// 返回YES/NO,表示非wifi情况是否继续检查
- (BOOL)onTCILiveManagerNotInWifi:(TCILiveManager *)manager networkType:(TCQALNetwork)net;

// 进入房间时，检查到没有相机权限
- (void)onTCILiveManagerHasNoCameraAuth:(TCILiveManager *)manager;

// 进入房间时，检查到没有麦克风权限
- (void)onTCILiveManagerHasNoMicPermission:(TCILiveManager *)manager;

// 检查正常
- (void)onTCILiveManagerCheckSucc:(TCILiveManager *)manager;

@end


@protocol TCILiveManagerExceptionListener <NSObject>

@required
- (void)onTCILiveManagerEnterBackground:(TCILiveManager *)manager;
- (void)onTCILiveManagerEnterForeground:(TCILiveManager *)manager;

- (void)onTCILiveManager:(TCILiveManager *)manager netConnected:(BOOL)connected;
- (void)onTCILiveManager:(TCILiveManager *)manager netChangeTo:(TCQALNetwork)net;

- (void)onTCILiveManagerIMKickedOff:(TCILiveManager *)manager;
@optional

- (void)onTCILiveManagerRoomDisconnect:(TCILiveManager *)manager;

- (void)onTCILiveManagerEnableCameraFailed:(TCILiveManager *)manager;
- (void)onTCILiveManagerRequestHostVideoFailed:(TCILiveManager *)manager;
- (void)onTCILiveManagerFirstFrameTimeOut:(TCILiveManager *)manager;


// 不使用TCILiveManager作监听时，外部可不处理下面的回调
- (void)onTCILiveManagerEnterIMChatRoomFailed:(TCILiveManager *)manager;
- (void)onTCILiveManager:(TCILiveManager *)manager enterRoom:(BOOL)succ;
- (void)onTCILiveManager:(TCILiveManager *)manager exitRoom:(BOOL)succ;

@end
