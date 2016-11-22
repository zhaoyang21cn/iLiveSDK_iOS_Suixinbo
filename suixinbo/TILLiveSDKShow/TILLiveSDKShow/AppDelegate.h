//
//  AppDelegate.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


+ (instancetype)sharedAppDelegate;

- (UINavigationController *)navigationViewController;

- (void)pushViewController:(UIViewController *)viewController;

- (UIViewController *)popViewController;

- (NSArray *)popToViewController:(UIViewController *)viewController;

- (NSArray *)popToRootViewController;

@end

