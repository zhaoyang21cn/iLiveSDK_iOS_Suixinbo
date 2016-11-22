//
//  MsgTableViewCell.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/10.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *userIdLabel;
@property (nonatomic, strong) UILabel *msgLable;

- (void)configMsg:(NSString *)userId msg:(NSString *)text;

@end
