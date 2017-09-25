//
//  ProfileTableViewCell.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/3/15.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "ProfileTableViewCell.h"

@implementation ProfileTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.bounds = CGRectMake(0,0,60,60);
    self.imageView.frame = CGRectMake(8,0,60,60);
    self.imageView.contentMode =UIViewContentModeScaleAspectFit;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 30;
}
@end
