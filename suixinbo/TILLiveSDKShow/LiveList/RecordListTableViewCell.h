//
//  RecordListTableViewCell.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/5/18.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordListTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView     *recordCover;
@property (nonatomic, strong) UIButton        *recordUserHead;
@property (nonatomic, strong) UILabel         *recordTitle;
@property (nonatomic, strong) UILabel         *recordUser;
@property (nonatomic, strong) UILabel         *recordTime;
@property (nonatomic, strong) UILabel         *recordDuration;
@property (nonatomic, strong) UILabel         *recordFileSize;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) RecordVideoItem *item;

- (void)configWith:(RecordVideoItem *)item;
- (void)setCoverImage:(NSString *)path;

@end
