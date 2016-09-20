//
//  TCILiveManagerDelegate.h
//  ILiveSDK
//
//  Created by AlexiChen on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCILiveManagerDelegate <NSObject>

@optional

// 返回没有自动处理的无程视频处理流程identifier
- (void)onRecvSemiAutoCameraVideo:(NSArray *)identifierList;

// 将AVSDK抛出，如果
- (void)onEndpointsUpdateInfo:(QAVUpdateEvent)eventID endpointlist:(NSArray *)endpoints;

- (void)onRoomDisconnected:(int)result;


@optional

// TIMUserStatusListener 回调监听
// 直播过程中被踢下线
- (void)onKickedOfflineWhenLive;

- (void)onReConnFailedWhenLiveWithError:(NSError *)error;

- (void)onCurrentUserSigExpiredWhenLive;



@end
