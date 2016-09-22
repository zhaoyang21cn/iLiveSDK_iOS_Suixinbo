//
//  IMAAppDelegate.h
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#if kIsIMAAppFromBase
#import "BaseAppDelegate.h"

// 该类主要是把集成IMSDK常用的操作与App相关事件关联起来
// 方便用户继承

@class TCAVCallViewController;
@class AVIMCMD;
@protocol AVIMCallHandlerAble;
@interface IMAAppDelegate : BaseAppDelegate
- (TCAVCallViewController *)presentCallViewControllerWith:(id<IMUserAble>)user type:(BOOL)isVoice callMsgHandler:(id<AVIMCallHandlerAble>)callHandler;
- (TCAVCallViewController *)presentCommingCallViewControllerWith:(AVIMCMD *)callUser conversation:(id<AVIMCallHandlerAble>)conv isFromChatting:(BOOL)isChatting;
@end

#else

#import <UIKit/UIKit.h>

@class TCAVCallViewController;
@class AVIMCMD;
@protocol AVIMCallHandlerAble;

@interface IMAAppDelegate : UIResponder<UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (instancetype)sharedAppDelegate;

//进入登录界面
- (void)enterLoginUI;

// 进入主界面逻辑
- (void)enterMainUI;

// 代码中尽量改用以下方式去push/pop/present界面
- (UINavigationController *)navigationViewController;

- (UIViewController *)topViewController;

- (void)pushViewController:(UIViewController *)viewController;

- (NSArray *)popToViewController:(UIViewController *)viewController;

- (void)pushViewController:(UIViewController *)viewController withBackTitle:(NSString *)title;
//- (void)pushViewController:(UIViewController *)viewController withBackTitle:(NSString *)title backAction:(CommonVoidBlock)action;

- (UIViewController *)popViewController;

- (NSArray *)popToRootViewController;

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)())completion;
- (void)dismissViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)())completion;

- (TCAVCallViewController *)presentCallViewControllerWith:(id<IMUserAble>)user type:(BOOL)isVoice callMsgHandler:(id<AVIMCallHandlerAble>)callHandler;
- (TCAVCallViewController *)presentCommingCallViewControllerWith:(AVIMCMD *)callUser conversation:(id<AVIMCallHandlerAble>)conv isFromChatting:(BOOL)isChatting;

@end


#endif
