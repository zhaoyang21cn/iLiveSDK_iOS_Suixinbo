//
//  SettingViewController.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<TIMUserStatusListener>

@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) UIImage *avatar;

@end
