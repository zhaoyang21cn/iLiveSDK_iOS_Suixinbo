//
//  LiveMainViewController.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/5/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LiveListViewController.h"
#import "RecordListViewController.h"

@interface LiveMainViewController : UIViewController

@property (nonatomic, strong) LiveListViewController    *liveListVC;
@property (nonatomic, strong) RecordListViewController  *recordListVC;

@end
