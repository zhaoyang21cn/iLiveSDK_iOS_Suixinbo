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

@property (nonatomic, copy) NSString *token;


+ (instancetype)sharedAppDelegate;

- (UINavigationController *)navigationViewController;

- (void)pushViewController:(UIViewController *)viewController;

- (UIViewController *)popViewController;

- (NSArray *)popToViewController:(UIViewController *)viewController;

- (NSArray *)popToRootViewController;


+ (UIAlertController *)showAlert:(UIViewController *)rootVC title:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle ok:(ActionHandle)succ cancel:(ActionHandle)fail;

@end

