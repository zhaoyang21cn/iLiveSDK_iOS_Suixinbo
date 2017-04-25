//
//  AppDelegate.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/25.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "AppDelegate.h"

//托管模式
#define SDKAppID 1400028096
#define AccountType 11851

//老随心播
//#define SDKAppID 1400001692
//#define AccountType 884

//pc
//#define SDKAppID 1104062745
//#define AccountType 107

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [[[ILiveSDK getInstance] getTIMManager] setLogLevel:TIM_LOG_NONE];
    //初始化ILiveSDK
    [[ILiveSDK getInstance] initSdk:SDKAppID accountType:AccountType];
//    [[ILiveSDK getInstance] uploadLog:@"" logDayOffset:0 uploadResult:^(int retCode, NSString *retMsg) {
//        NSLog(@"");
//    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
