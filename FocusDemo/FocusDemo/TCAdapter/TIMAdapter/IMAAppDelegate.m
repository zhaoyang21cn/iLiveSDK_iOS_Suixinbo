//
//  IMAAppDelegate.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kIsIMAAppFromBase
#import "IMAAppDelegate.h"

#import "IMALoginViewController.h"

@implementation IMAAppDelegate

// 进入登录界面
// 用户可重写
- (void)enterLoginUI
{
    IMALoginViewController *vc = [[IMALoginViewController alloc] init];
    self.window.rootViewController = vc;
}


//==================================
// URL Scheme处理
- (BOOL)application:(UIApplication*)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.scheme compare:QQ_OPEN_SCHEMA] == NSOrderedSame)
    {
        return [TencentOAuth HandleOpenURL:url];
    }
    else if([url.scheme compare:WX_APP_ID] == NSOrderedSame)
    {
        if ([self.window.rootViewController conformsToProtocol:@protocol(WXApiDelegate)])
        {
            id<WXApiDelegate> lgv = (id<WXApiDelegate>)self.window.rootViewController;
            [WXApi handleOpenURL:url delegate:lgv];
            
        }
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([url.scheme compare:QQ_OPEN_SCHEMA] == NSOrderedSame)
    {
        return [TencentOAuth HandleOpenURL:url];
    }
    else if([url.scheme compare:WX_APP_ID] == NSOrderedSame)
    {
        if ([self.window.rootViewController conformsToProtocol:@protocol(WXApiDelegate)])
        {
            id<WXApiDelegate> lgv = (id<WXApiDelegate>)self.window.rootViewController;
            [WXApi handleOpenURL:url delegate:lgv];
        }
    }
    
    return YES;
}

#if kSupportCallScene
//============================================

- (TCAVCallViewController *)presentCallViewControllerWith:(id<IMUserAble>)user type:(BOOL)isVoice callMsgHandler:(id<AVIMCallHandlerAble>)callHandler
{
    //    if ([user isC2CType] || [user isGroupType])
    //    {
    //        IMAHost *host = [IMAPlatform sharedInstance].host;
    //        IMACallRoom *callRoom = [[IMACallRoom alloc] init];
    //        callRoom.callSponsor = host;
    //        callRoom.callRoomID = [host getAVCallRoomID];
    //
    //        TCAVCallViewController *callVC = [[TCAVCallViewController alloc] initWith:callRoom user:host];
    //        callVC.enableIM = NO;
    //        [self.topViewController presentViewController:callVC animated:YES completion:nil];
    //        return callVC;
    //    }
    return nil;
}

- (TCAVCallViewController *)presentCommingCallViewControllerWith:(AVIMCMD *)callUser conversation:(id<AVIMCallHandlerAble>)conv isFromChatting:(BOOL)isChatting
{
    //    // 目前只支持好友
    //    IMAUser *user = [[IMAPlatform sharedInstance].contactMgr getUserByUserId:[callUser.sender imUserId]];
    //
    //    IMAHost *host = [IMAPlatform sharedInstance].host;
    //    // 没有获取到，去查陌生人
    ////    BOOL isVoice = [callUser isVoiceCall];
    //    TCAVCallViewController *callVC = [[TCAVCallViewController alloc] initWith:callUser user:host];
    //    callVC.enableIM = NO;
    //
    //    [self.topViewController presentViewController:callVC animated:YES completion:nil];
    //    return callVC;
    
    return nil;
    
}
#endif
@end

#else

@implementation IMAAppDelegate

+ (instancetype)sharedAppDelegate
{
    return [UIApplication sharedApplication].delegate;
}

// 进入登录界面
// 用户可重写
- (void)enterLoginUI
{
    IMALoginViewController *vc = [[IMALoginViewController alloc] init];
    self.window.rootViewController = vc;
}

// 一般用户自己App都会重写该方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 用StoryBoard不需要自己创建
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = [UIColor whiteColor];
    
    // 进入登录界面
    [self enterLoginUI];
    
    [_window makeKeyAndVisible];
    return YES;
}

- (void)enterMainUI
{
    // do nothing, overwrite by subclass
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

- (UIViewController *)topViewController
{
    UINavigationController *nav = [self navigationViewController];
    return nav.topViewController;
}

- (void)pushViewController:(UIViewController *)viewController
{
    @autoreleasepool
    {
        viewController.hidesBottomBarWhenPushed = YES;
        [[self navigationViewController] pushViewController:viewController animated:NO];
    }
}

- (void)pushViewController:(UIViewController *)viewController withBackTitle:(NSString *)title
{
    @autoreleasepool
    {
        viewController.hidesBottomBarWhenPushed = YES;
        [[self navigationViewController] pushViewController:viewController withBackTitle:title animated:NO];
    }
}

//- (void)pushViewController:(UIViewController *)viewController withBackTitle:(NSString *)title backAction:(CommonVoidBlock)action
//{
//    @autoreleasepool
//    {
//        viewController.hidesBottomBarWhenPushed = YES;
//        [[self navigationViewController] pushViewController:viewController withBackTitle:title action:action animated:NO];
//    }
//}

- (UIViewController *)popViewController
{
    return [[self navigationViewController] popViewControllerAnimated:NO];
}
- (NSArray *)popToRootViewController
{
    return [[self navigationViewController] popToRootViewControllerAnimated:NO];
}

- (NSArray *)popToViewController:(UIViewController *)viewController
{
    return [[self navigationViewController] popToViewController:viewController animated:NO];
}

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)())completion
{
    UIViewController *top = [self topViewController];
    
    if (vc.navigationController == nil)
    {
        NavigationViewController *nav = [[NavigationViewController alloc] initWithRootViewController:vc];
        [top presentViewController:nav animated:animated completion:completion];
    }
    else
    {
        [top presentViewController:vc animated:animated completion:completion];
    }
}

- (void)dismissViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)())completion
{
    if (vc.navigationController != [BaseAppDelegate sharedAppDelegate].navigationViewController)
    {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self popViewController];
    }
}

#if kSupportCallScene
//============================================

- (TCAVCallViewController *)presentCallViewControllerWith:(id<IMUserAble>)user type:(BOOL)isVoice callMsgHandler:(id<AVIMCallHandlerAble>)callHandler
{
    //    if ([user isC2CType] || [user isGroupType])
    //    {
    //        IMAHost *host = [IMAPlatform sharedInstance].host;
    //        IMACallRoom *callRoom = [[IMACallRoom alloc] init];
    //        callRoom.callSponsor = host;
    //        callRoom.callRoomID = [host getAVCallRoomID];
    //
    //        TCAVCallViewController *callVC = [[TCAVCallViewController alloc] initWith:callRoom user:host];
    //        callVC.enableIM = NO;
    //        [self.topViewController presentViewController:callVC animated:YES completion:nil];
    //        return callVC;
    //    }
    return nil;
}

- (TCAVCallViewController *)presentCommingCallViewControllerWith:(AVIMCMD *)callUser conversation:(id<AVIMCallHandlerAble>)conv isFromChatting:(BOOL)isChatting
{
    //    // 目前只支持好友
    //    IMAUser *user = [[IMAPlatform sharedInstance].contactMgr getUserByUserId:[callUser.sender imUserId]];
    //
    //    IMAHost *host = [IMAPlatform sharedInstance].host;
    //    // 没有获取到，去查陌生人
    ////    BOOL isVoice = [callUser isVoiceCall];
    //    TCAVCallViewController *callVC = [[TCAVCallViewController alloc] initWith:callUser user:host];
    //    callVC.enableIM = NO;
    //
    //    [self.topViewController presentViewController:callVC animated:YES completion:nil];
    //    return callVC;
    
    return nil;
    
}
#endif
@end


#endif
