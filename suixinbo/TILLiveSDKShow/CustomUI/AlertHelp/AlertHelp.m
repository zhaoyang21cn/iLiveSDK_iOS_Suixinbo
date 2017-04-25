//
//  AlertHelp.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/4/10.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "AlertHelp.h"

@implementation AlertHelp

+ (UIViewController *)topViewController
{
    UIViewController *resultVC;
    resultVC = [self selectViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController)
    {
        resultVC = [self selectViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)selectViewController:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UINavigationController class]])
    {
        return [self selectViewController:[(UINavigationController *)vc topViewController]];
    }
    else if ([vc isKindOfClass:[UITabBarController class]])
    {
        return [self selectViewController:[(UITabBarController *)vc selectedViewController]];
    }
    else
    {
        return vc;
    }
    return nil;
}

//只有一个按钮(用取消按钮代替)
+ (UIAlertController *)alertWith:(NSString *_Nullable)title message:(NSString *_Nullable)msg cancelBtn:(NSString *_Nullable)cancelTitle  alertStyle:(UIAlertControllerStyle)style cancelAction:(AlertActionHandle _Nullable )cancelHandle
{
    return [AlertHelp alertWith:title message:msg funBtns:nil cancelBtn:cancelTitle destructiveBtn:nil alertStyle:style cancelAction:cancelHandle destrutiveAction:nil];
}

//没有destrutive
+ (UIAlertController *)alertWith:(NSString *_Nullable)title message:(NSString *_Nullable)msg funBtns:(NSDictionary *_Nullable)btns cancelBtn:(NSString *_Nullable)cancelTitle  alertStyle:(UIAlertControllerStyle)style cancelAction:(AlertActionHandle _Nullable )cancelHandle
{
    return [AlertHelp alertWith:title message:msg funBtns:btns cancelBtn:cancelTitle destructiveBtn:nil alertStyle:style cancelAction:cancelHandle destrutiveAction:nil];
}

+ (UIAlertController *)alertWith:(NSString *_Nullable)title message:(NSString *_Nullable)msg funBtns:(NSDictionary *_Nullable)btns cancelBtn:(NSString *_Nullable)cancelTitle destructiveBtn:(NSString *_Nullable)destTitle alertStyle:(UIAlertControllerStyle)style cancelAction:(AlertActionHandle _Nullable )cancelHandle destrutiveAction:(AlertActionHandle _Nullable )destHandle
{
    if (style != UIAlertControllerStyleActionSheet && style != UIAlertControllerStyleAlert)
    {
        return nil;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:style];
    if (cancelTitle && cancelTitle.length > 0)
    {
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelHandle]];
    }
    NSArray *keys = btns.allKeys;
    for (NSString *key in keys)
    {
        AlertActionHandle action = [btns objectForKey:key];
        [alert addAction:[UIAlertAction actionWithTitle:key style:UIAlertActionStyleDefault handler:action]];
    }
    if (destTitle && destTitle.length > 0)
    {
        [alert addAction:[UIAlertAction actionWithTitle:destTitle style:UIAlertActionStyleDestructive handler:destHandle]];
    }
    __block UIViewController *topVC = [AlertHelp topViewController];
    if ([topVC isKindOfClass:[UIAlertController class]])
    {
        [topVC dismissViewControllerAnimated:YES completion:^{
            topVC = [AlertHelp topViewController];
            [topVC presentViewController:alert animated:YES completion:nil];
        }];
    }
    else
    {
        [topVC presentViewController:alert animated:YES completion:nil];
    }
    return alert;
}

+ (void)tipWith:(NSString *_Nullable)msg wait:(NSTimeInterval)time;
{
    __block UIAlertController *tipAlert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIViewController *topVC = [AlertHelp topViewController];
    [topVC presentViewController:tipAlert animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tipAlert dismissViewControllerAnimated:YES completion:nil];
        tipAlert = nil;
    });
}

@end
