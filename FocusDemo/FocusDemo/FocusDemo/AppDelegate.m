//
//  AppDelegate.m
//  FocusDemo
//
//  Created by wilderliao on 16/9/18.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "AppDelegate.h"

#import "AppDelegate.h"

//#import "MainViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


+ (instancetype)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

// 配置App中的控件的默认属性
- (void)configAppearance
{
}

- (void)enterLoginUI
{
    NavigationViewController *nav = [[NavigationViewController alloc] init];
    self.window.rootViewController = nav;
    
    [self login];
}

//登录成功后会自动调用enterMainUI
- (void)enterMainUI
{
//    MainViewController *vc = [[MainViewController alloc] init];
//    NavigationViewController *nav = [[NavigationViewController alloc] initWithRootViewController:vc];
//    self.window.rootViewController = nav;
    
    IMAHost *host = [IMAPlatform sharedInstance].host;
//    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    
//    FocusDemoUser *user = (FocusDemoUser *)_liveRoom.liveHost;
//    user.uid = @"focusdemouser";
    FocusDemoViewController *vc = [[FocusDemoViewController alloc] initWith:_liveRoom user:host];
    [self pushViewController:vc];
}

- (void)login
{
    IMALoginParam *param = [[IMALoginParam alloc] init];
    param.tokenTime = [[NSDate date] timeIntervalSince1970];
    param.accountType = kSdkAccountType;
    param.identifier = @"focusdemouser";
    param.userSig = @"123";
    param.appidAt3rd = kSdkAppId;
    param.sdkAppId = [kSdkAppId intValue];
    
    IMAPlatformConfig *config = [[IMAPlatformConfig alloc] init];
    param.config = config;
    
    [IMAPlatform configWith:config];
    
    if (!_liveHost)
    {
        // 用户修改默认主播角色， 主要是uid
        _liveHost = [[FocusDemoUser alloc] init];
        _liveHost.uid = param.identifier;
        _liveHost.name = param.identifier;
        
        _liveRoom = [[FocusDemoRoom alloc] init];
        
        _liveRoom.liveHost = _liveHost;
        _liveRoom.liveAVRoomId = 1000003;
        _liveRoom.liveIMChatRoomId = @"1000003";
        _liveRoom.liveTitle = @"temp room";
    }
    
    __weak IMALoginParam *wp = param;
    __weak AppDelegate *weakSelf = self;
    [[HUDHelper sharedInstance] syncLoading:@"正在登录"];
    
    [[IMAPlatform sharedInstance] login:param succ:^{
        [[HUDHelper sharedInstance] syncStopLoadingMessage:@"登录成功"];
        [[IMAPlatform sharedInstance] configOnLoginSucc:wp completion:^{
            [weakSelf enterMainUI];
        }];
    } fail:^(int code, NSString *msg) {
        [[HUDHelper sharedInstance] syncStopLoadingMessage:IMALocalizedError(code, msg) delay:2 completion:^{
            DebugLog(@"login fail(code = %d,msg = %@)",code, msg);
        }];
    }];
}

@end
