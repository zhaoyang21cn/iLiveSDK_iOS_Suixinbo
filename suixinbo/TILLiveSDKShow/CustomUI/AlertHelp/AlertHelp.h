//
//  AlertHelp.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/4/10.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AlertActionHandle)(UIAlertAction * _Nonnull action);

@interface AlertHelp : NSObject

+ (UIViewController *_Nullable)topViewController;
//只有一个按钮(用取消按钮代替)
+ (UIAlertController *_Nullable)alertWith:(NSString *_Nullable)title message:(NSString *_Nullable)msg cancelBtn:(NSString *_Nullable)cancelTitle  alertStyle:(UIAlertControllerStyle)style cancelAction:(AlertActionHandle _Nullable )cancelHandle;

//没有destrutive
+ (UIAlertController *_Nullable)alertWith:(NSString *_Nullable)title message:(NSString *_Nullable)msg funBtns:(NSDictionary *_Nullable)btns cancelBtn:(NSString *_Nullable)cancelTitle  alertStyle:(UIAlertControllerStyle)style cancelAction:(AlertActionHandle _Nullable )cancelHandle;

+ (UIAlertController *_Nullable)alertWith:(NSString *_Nullable)title message:(NSString *_Nullable)msg funBtns:(NSDictionary *_Nullable)btns cancelBtn:(NSString *_Nullable)cancelTitle destructiveBtn:(NSString *_Nullable)destTitle alertStyle:(UIAlertControllerStyle)style cancelAction:(AlertActionHandle _Nullable )cancelHandle destrutiveAction:(AlertActionHandle _Nullable )destHandle;

+ (void)tipWith:(NSString *_Nullable)msg wait:(NSTimeInterval)time;

@end
