//
//  IMAPlatform.m
//  TIMAdapter
//
//  Created by AlexiChen on 16/2/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAPlatform.h"

@interface IMAPlatform ()

@property (nonatomic, assign) TCQALNetwork networkType;

@end

@implementation IMAPlatform

#define kIMAPlatformConfig          @"IMAPlatformConfig"


static IMAPlatform *_sharedInstance = nil;

+ (instancetype)configWith:(IMAPlatformConfig *)cfg
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _sharedInstance = [[IMAPlatform alloc] init];
        [_sharedInstance configIMSDK:cfg];
    });
    
    return _sharedInstance;
    
}
static Class kHostClass = Nil;
+ (void)configHostClass:(Class)hostcls
{
    if (![hostcls isSubclassOfClass:[IMAHost class]])
    {
        DebugLog(@"%@ 必须是IMAHost的子类型", hostcls);
    }
    else
    {
        kHostClass = hostcls;
    }
}
+ (instancetype)sharedInstance
{
    // TODO:
    return _sharedInstance;
}

#define kIMAPlatform_AutoLogin_Key @"kIMAPlatform_AutoLogin_Key"

+ (BOOL)isAutoLogin
{
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"kIMAPlatform_AutoLogin_Key"];
    return [num boolValue];
}
+ (void)setAutoLogin:(BOOL)autologin
{
    [[NSUserDefaults standardUserDefaults] setObject:@(autologin) forKey:kIMAPlatform_AutoLogin_Key];
}



- (void)configIMSDK:(IMAPlatformConfig *)cfg
{
    TIMManager *manager = [TIMManager sharedInstance];

    [manager setEnv:cfg.environment];
    [manager initLogSettings:cfg.enableConsoleLog logPath:[manager getLogPath]];
    [manager setLogLevel:cfg.logLevel];
    [manager disableAutoReport];
    
    [manager initSdk:[kSdkAppId intValue] accountType:kSdkAccountType];
    
    [manager setConnListener:self];
    
    [manager setRefreshListener:self];
    
    [manager setUserStatusListener:self];
    
#if DEBUG
#else
    if (!kTCAVIMLogDateFormatter)
    {
        kTCAVIMLogDateFormatter = [[NSDateFormatter alloc] init];
        [kTCAVIMLogDateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [kTCAVIMLogDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [kTCAVIMLogDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    
#endif
    
    // Demo中使用了自定义字段，如果用户的App没有将这行注释// setting.userCustom
    TIMFriendshipSetting *setting =  [[TIMFriendshipSetting alloc] init];
#if kIsTCShowSupportIMCustom
    setting.userCustom = @[kIMCustomFlag];
#endif
    setting.friendFlags = 0xFFFFFFFF;
    [manager initFriendshipSetting:setting];
    [manager enableFriendshipProxy];
    
    
}



- (void)saveToLocal
{
    // 保存上一次联系人列表状态
    
    // 保存Config状态
}

- (void)onLogoutCompletion
{
    [self offlineLogin];
    
    self.offlineExitLivingBlock = nil;
    
    [IMAPlatform setAutoLogin:NO];
    _host = nil;
    
#if kIsUseAVSDKAsLiveScene
    [TCAVSharedContext destroyContextCompletion:nil];
#endif
    
}

- (void)offlineLogin
{
    // 被踢下线，则清空单例中的数据，再登录后再重新创建
    [self saveToLocal];
    
    // [[TIMManager sharedInstance] setFriendshipProxyListener:nil];
}

- (void)logout:(TIMLoginSucc)succ fail:(TIMFail)fail
{
    __weak IMAPlatform *ws = self;
    
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

- (IMAPlatformConfig *)localConfig
{
    return _host.loginParm.config;
}

- (void)configHost:(TIMLoginParam *)param completion:(CommonVoidBlock)block
{
    if (!_host)
    {
        if (kHostClass == Nil)
        {
            kHostClass = [IMAHost class];
        }
        _host = [[kHostClass alloc] init];
    }
    _host.loginParm = param;
    [_host asyncProfile];
    
#if kIsUseAVSDKAsLiveScene
    [TCAVSharedContext configWithStartedContext:_host completion:block];
#endif
}


- (void)changeToNetwork:(TCQALNetwork)work
{
    if (work > EQALNetworkType_ReachableViaWWAN)
    {
        // 不处理这些
        work = EQALNetworkType_ReachableViaWWAN;
    }
    DebugLog(@"网络切换到(-1:未知 0:无网 1:wifi 2:移动网):%d", work);
    //    if (work != _networkType)
    //    {
    self.networkType = work;
    
    //    }
}


@end



