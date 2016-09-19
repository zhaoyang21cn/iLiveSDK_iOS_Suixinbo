//
//  EngineListener.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK/ImSDK.h>


@interface LiveMessageListener : NSObject<TIMMessageListener>

- (void)onNewMessage:(NSArray *)msgs;

@end

@interface LiveIncomingCallListener : NSObject

- (void)onCallCmd:(TCICallCMD*)cmd;

@end

@interface LiveUserStatusListener : NSObject<TIMUserStatusListener>

/**
 *  踢下线通知
 */
- (void)onForceOffline;

/**
 *  断线重连失败
 */
- (void)onReConnFailed:(int)code err:(NSString*)err;

/**
 *  用户登录的userSig过期（用户需要重新获取userSig后登录）
 */
- (void)onUserSigExpired;

@end