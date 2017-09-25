//
//  MsgTableViewCell.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/10.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, assign) CGFloat height;

- (void)configMsg:(NSString *)userId msg:(NSString *)text;
- (void)configTips:(NSString *)user;

@end
