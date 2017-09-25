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

+ (UIAlertController *)showAlert:(UIViewController *)rootVC title:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle ok:(ActionHandle)succ cancel:(ActionHandle)fail;

- (UINavigationController *)navigationViewController;

- (NSArray *)popToRootViewController;
- (UIViewController *)popViewController;
- (NSArray *)popToViewController:(UIViewController *)viewController;
- (void)pushViewController:(UIViewController *)viewController;
- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)())completion;

@end

