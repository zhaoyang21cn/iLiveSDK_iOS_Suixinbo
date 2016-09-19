//
//  AppDelegate.m
//  TIMChat
//
//  Created by AlexiChen on 16/1/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AppDelegate.h"
#import "LiveCallLoginViewController.h"
#import "LiveCallTabBarController.h"
#import "EngineHeaders.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

+(instancetype) sharedInstance
{
    return (AppDelegate*)[super sharedAppDelegate];
}

- (void)enterLoginUI
{
    self.window.rootViewController = [[LiveCallLoginViewController alloc] init];
}

- (void)enterMainUI
{
    self.window.rootViewController = [[LiveCallTabBarController alloc] init];
}

+ (instancetype)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initLiveSDK];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)initLiveSDK
{
//    [[TIMManager sharedInstance] setLogLevel:TIM_LOG_NONE];
    [TCICallManager configWithAppID:kSdkAppid accountType:kAccoutType willInit:nil initCompleted:nil];
    [[TIMManager sharedInstance] setMessageListener:[[LiveMessageListener alloc] init]];
    LiveIncomingCallListener * listener = [[LiveIncomingCallListener alloc] init];
    TCICallBlock block = ^(TCICallCMD * cmd) {
        [listener onCallCmd:cmd];
    };
    [[TCICallManager sharedInstance] setIncomingCallBlock:block];
    [[TIMManager sharedInstance] setUserStatusListener:[[LiveUserStatusListener alloc] init]];
    
}

@end
