//
//  RegistViewController.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RegistViewControllerDelegate <NSObject>

- (void)showRegistUserIdentifier:(NSString *)identifier;
- (void)showRegistUserPwd:(NSString *)passward;

@end

@interface RegistViewController : UIViewController

@property (nonatomic, weak) id<RegistViewControllerDelegate> delegate;
@end
