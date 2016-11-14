//
//  MsgTableViewCell.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/10.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "MsgTableViewCell.h"

@implementation MsgTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubViews];
//        [self layout];
    }
    return self;
}

- (void)addSubViews
{
    _userIdLabel = [[UILabel alloc] init];
//    _userIdLabel.text = @"userid";
    _userIdLabel.textColor = kColorGreen;
    [self.contentView addSubview:_userIdLabel];
    
    _msgLable = [[UILabel alloc] init];
//    _msgLable.text = @"msg textdsjfkjslkf";
    _msgLable.textColor = kColorWhite;
    [self.contentView addSubview:_msgLable];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect selfRect = self.contentView.bounds;
    
    [_userIdLabel sizeWith:CGSizeMake(selfRect.size.width * 2/5, selfRect.size.height-kDefaultMargin)];
    [_userIdLabel layoutParentVerticalCenter];
    [_userIdLabel alignParentLeftWithMargin:kDefaultMargin];
//    _userIdLabel.backgroundColor = [UIColor yellowColor];
    
    [_msgLable sizeWith:CGSizeMake(selfRect.size.width-kDefaultMargin*2, selfRect.size.height-kDefaultMargin)];
    [_msgLable layoutParentVerticalCenter];
    [_msgLable layoutToRightOf:_userIdLabel];
//    _msgLable.backgroundColor = [UIColor greenColor];
}

- (void)configMsg:(NSString *)userId msg:(NSString *)text
{
    _userIdLabel.text = [NSString stringWithFormat:@"%@:",userId];
    _msgLable.text = text;
}

@end
