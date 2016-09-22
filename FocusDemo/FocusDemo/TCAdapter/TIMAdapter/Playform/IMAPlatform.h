//
//  IMAPlatform.h
//  TIMAdapter
//
//  Created by AlexiChen on 16/2/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

// Demo的业务逻辑入口，外部所的要使用IMSDK的地方，都间接能过IMAPlatform调用
typedef EQALNetworkType TCQALNetwork;

@interface IMAPlatform : NSObject
{
@protected
    IMAHost                     *_host;             // 当前用户
}

@property (nonatomic, readonly) IMAHost *host;
@property (nonatomic, assign) BOOL isConnected;     // 当前是否连接上，外部可用此方法判断是否有网

// 当前使用的网络类型，默认wifi，只取EQALNetworkType 中对应的 -1:未知 0:无网 1:wifi 2:移动网，用户若需要，可重写对应的方法以满足自身App需求
@property (nonatomic, readonly) TCQALNetwork networkType;

// 被踢下线时，如果当前在直播的时候，进行调用
@property (nonatomic, copy) CommonVoidBlock offlineExitLivingBlock;

+ (instancetype)configWith:(IMAPlatformConfig *)cfg;

// 配置自定义的_host，hostcls须为IMAHost的子类
+ (void)configHostClass:(Class)hostcls;

+ (instancetype)sharedInstance;

// 是否是自动登录
+ (BOOL)isAutoLogin;

+ (void)setAutoLogin:(BOOL)autologin;


- (IMAPlatformConfig *)localConfig;

- (void)saveToLocal;

// 初始化新增的缓存同步逻辑

// 退出
- (void)logout:(TIMLoginSucc)succ fail:(TIMFail)fail;

// 被踢下线后，再重新登录
- (void)offlineLogin;

- (void)configHost:(TIMLoginParam *)param completion:(CommonVoidBlock)block;

- (void)changeToNetwork:(TCQALNetwork)work;
@end


