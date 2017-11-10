//
//  AppDelegate.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LoginViewController.h"
#import "LiveViewController.h"

@interface AppDelegate ()<QAVLogger>
@end

@implementation AppDelegate

+ (instancetype)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

+ (UIAlertController *)showAlert:(UIViewController *)rootVC title:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle ok:(ActionHandle)succ cancel:(ActionHandle)fail
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    if (cancelTitle)
    {
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:fail]];
    }
    if (okTitle)
    {
        [alert addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:succ]];
    }
    [rootVC presentViewController:alert animated:YES completion:nil];
    return alert;
}

- (void)pushViewController:(UIViewController *)viewController
{
    @autoreleasepool
    {
        viewController.hidesBottomBarWhenPushed = YES;
        [[self navigationViewController] pushViewController:viewController animated:NO];
    }
}

- (UIViewController *)popViewController
{
    return [[self navigationViewController] popViewControllerAnimated:YES];
}

- (NSArray *)popToRootViewController
{
    return [[self navigationViewController] popToRootViewControllerAnimated:NO];
}

- (NSArray *)popToViewController:(UIViewController *)viewController
{
    return [[self navigationViewController] popToViewController:viewController animated:YES];
}

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)())completion
{
    UINavigationController *nav = [self navigationViewController];
    UIViewController *top = nav.topViewController;
    
    if (vc.navigationController == nil)
    {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [top presentViewController:nav animated:animated completion:completion];
    }
    else
    {
        [top presentViewController:vc animated:animated completion:completion];
    }
}
// 获取当前活动的navigationcontroller
- (UINavigationController *)navigationViewController
{
    UIWindow *window = self.window;
    
    if ([window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        return (UINavigationController *)window.rootViewController;
    }
    else if ([window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        UIViewController *selectVc = [((UITabBarController *)window.rootViewController) selectedViewController];
        if ([selectVc isKindOfClass:[UINavigationController class]])
        {
            return (UINavigationController *)selectVc;
        }
    }
    return nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [self test];
    
    //注册ShareSDK
    [ShareSDK registerApp:@"1ba4e87f44fec" activePlatforms:@[@(SSDKPlatformTypeWechat)] onImport:^(SSDKPlatformType platformType){
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             default:
                 break;
         }
     }onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo){
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wx588cac36c5d302f2" appSecret:@"f1c9fed7bd2745050bc05991d4b812e1"];
                 break;
             default:
                 break;
         }
     }];
    
    TIMManager *manager = [[ILiveSDK getInstance] getTIMManager];
    
    NSNumber *evn = [[NSUserDefaults standardUserDefaults] objectForKey:kEnvParam];
    [manager setEnv:[evn intValue]];
    
    NSNumber *logLevel = [[NSUserDefaults standardUserDefaults] objectForKey:kLogLevel];
    if (!logLevel)//默认debug等级
    {
        [[NSUserDefaults standardUserDefaults] setObject:@(TIM_LOG_DEBUG) forKey:kLogLevel];
        logLevel = @(TIM_LOG_DEBUG);
    }
    [self disableLogPrint];//禁用日志控制台打印
    [manager setLogLevel:(TIMLogLevel)[logLevel integerValue]];
    
    [[ILiveSDK getInstance] initSdk:[ShowAppId intValue] accountType:[ShowAccountType intValue]];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [self configAppearance];
    return YES;
}

- (void)disableLogPrint
{
    TIMManager *manager = [[ILiveSDK getInstance] getTIMManager];
    [manager initLogSettings:NO logPath:[manager getLogPath]];
    [[ILiveSDK getInstance] setConsoleLogPrint:NO];
    [QAVAppChannelMgr setExternalLogger:self];
}

#pragma mark - avsdk日志代理
- (BOOL)isLogPrint
{
    return NO;
}

- (NSString *)getLogPath
{
    return [[TIMManager sharedInstance] getLogPath];
}

//- (void)test
//{
//    NSString *uid = @"wilderdev2";
//    int roomid = 90001;
//    NSString *sig = @"eJx1jl9PwjAUR9-3KZq*YmTdcHYmPrSzI-6dMonIS7OsBW6AWUuFbcbvLllI3Iv39Zz8zv32EEL49SE-L8ry46ty0jVGY3SFMKUjfPaHjQElCydDqzpMRv7xSBQHPUvXBqyWxcJp21nBRRwctZ4CSlcOFnASDrBR2iq978-s1Fp2wf9LO1h28FFMk1vxMp8qfk9tOnFDM2hD0taHcJCYd75qtM7ZhuzXGeMTFjEQzDSzu3FVz6NVK7I4CZ5LcJ-52zatMn6zHMPTcBYDN75I2XUv6WCrTw-R0CeX1I*w9*P9AoPxWIY_";
//    [[ILiveSDK getInstance] initSdk:[ShowAppId intValue] accountType:[ShowAccountType intValue]];
//    [[ILiveLoginManager getInstance] iLiveLogin:uid sig:sig succ:^{
//        
//        TCShowLiveListItem *item = [[TCShowLiveListItem alloc] init];
//        item.uid = @"wilderdev1";
//        ShowRoomInfo *info = [[ShowRoomInfo alloc] init];
//        info.title = @"title";
//        info.type = @"live";
//        info.roomnum = roomid;
//        info.groupid = [NSString stringWithFormat:@"%d",roomid];
//        info.cover = @"";
//        info.host = @"wilderdev1";
//        info.appid = [ShowAppId intValue];
//        info.thumbup = 0;
//        info.memsize = 0;
//        info.device = 1;
//        info.videotype = 1;
//        
//        item.info = info;
//        
//        LiveViewController *vc = [[LiveViewController alloc] initWith:item];
//        
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//        
//        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        
//        self.window.rootViewController = nav;
//        
//        [self.window makeKeyAndVisible];
//    } failed:^(NSString *module, int errId, NSString *errMsg) {
//        
//    }];
//}
- (void)configAppearance
{
    [[UINavigationBar appearance] setBarTintColor:kColorRed];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kColorWhite,NSFontAttributeName:kAppLargeTextFont}];
    [[UINavigationBar appearance] setTintColor:kColorWhite];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kColorWhite,NSFontAttributeName:kAppLargeTextFont} forState:UIControlStateNormal];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //如果在房间中，持续发送心跳包
    [[NSNotificationCenter defaultCenter] postNotificationName:kEnterBackGround_Notification object:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
