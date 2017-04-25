//
//  EnvInfoView.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/4/13.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EnvInfoItem;
//环境信息显示视图(网络环境，设备环境)
@interface EnvInfoView : UIView

@property (nonatomic, strong) UILabel *cpuRateLabel;
@property (nonatomic, strong) UILabel *lossRateLabel;

- (void)configWith:(EnvInfoItem *)item;

@end

@interface EnvInfoItem : NSObject

@property (nonatomic, assign) NSInteger cpuRate;
@property (nonatomic, assign) NSInteger lossRate;

@end
