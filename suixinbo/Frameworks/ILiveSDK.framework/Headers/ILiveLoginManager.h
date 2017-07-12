//
//  ILiveLoginManager.h
//  ILiveSDK
//
//  Created by AlexiChen on 2016/10/24.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK/TIMCallback.h>
#import "ILiveCommon.h"

@interface ILiveLoginManager : NSObject

/**
 获取ILiveSDK单例

 @return ILiveSDK单例
 */
+ (instancetype)getInstance;

/**
 独立模式登录(独立模式下直接使用该接口，托管模式需先用tlsLogin登录)

 @param uid    用户id
 @param sig    用户签名
 @param succ   成功回调
 @param failed 失败回调
 */
- (void)iLiveLogin:(NSString *)uid sig:(NSString *)sig succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;


/**
 独立模式登出

 @param succ   成功回调
 @param failed 失败回调
 */
- (void)iLiveLogout:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

/**
 托管模式登录

 @param uid    用户id
 @param pwd    用户密码
 @param succ   成功回调
 @param failed 失败回调
 */
- (void)tlsLogin:(NSString *)uid pwd:(NSString *)pwd succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

/**
 托管模式登出

 @param succ   成功回调
 @param failed 失败回调
 */
- (void)tlsLogout:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

/**
 注册

 @param uid    用户id
 @param pwd    用户密码
 @param succ   成功回调
 @param failed 失败回调
 */
- (void)tlsRegister:(NSString *)uid pwd:(NSString *)pwd succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;


/**
 获取签名（只有登录成功后才能获取）

 @return 签名
 */
- (NSString *)getSig;

/**
 获取登录Id（只有登录成功后才能获取）

 @return 登录Id
 */
- (NSString *)getLoginId;

@end
