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
    }
    return self;
}

- (void)addSubViews
{
    _msgLabel = [[UILabel alloc] init];
    _msgLabel.numberOfLines = 0;
    _msgLabel.clipsToBounds = YES;
    _msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _msgLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_msgLabel];
    
    _tipsLabel = [[UILabel alloc] init];
    _tipsLabel.numberOfLines = 0;
    _tipsLabel.clipsToBounds = YES;
    _tipsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _tipsLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_tipsLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [_msgLabel layoutParentVerticalCenter];
    [_msgLabel alignParentLeftWithMargin:kDefaultMargin];
    
    [_tipsLabel layoutParentVerticalCenter];
    [_tipsLabel alignParentLeftWithMargin:kDefaultMargin];
}

- (void)configMsg:(NSString *)userId msg:(NSString *)text
{
    CGFloat selfW = [UIScreen mainScreen].bounds.size.width * 4/5;
    CGFloat selfH = 30;
    
    UIFont *msgFont = [UIFont fontWithName:@"Superclarendon" size:17];//Helvetica-Bold
    
    NSString *showInfo = [NSString stringWithFormat:@"%@: %@",userId, text];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:showInfo];
    [attrStr addAttribute:NSForegroundColorAttributeName value:kColorGreen range:NSMakeRange(0, userId.length+1)];//+1是因为有个冒号
    [attrStr addAttribute:NSForegroundColorAttributeName value:kColorWhite range:NSMakeRange(userId.length+1, text.length+1)];//+1是因为有个空格
    [attrStr addAttribute:NSFontAttributeName value:msgFont range:NSMakeRange(0, showInfo.length)];//加粗
    
    _msgLabel.attributedText = attrStr;
    CGSize labelsize = [self textHeightSize:showInfo maxSize:CGSizeMake(selfW - kDefaultMargin*2, selfH * 3) textFont:msgFont];
    [_msgLabel setFrame:CGRectMake(_msgLabel.frame.origin.x, _msgLabel.frame.origin.y, labelsize.width + kDefaultMargin, labelsize.height)];

    [self setFrame:CGRectMake(0, 0, selfW, labelsize.height)];
    _height = labelsize.height;
    
    _msgLabel.hidden = NO;
    _tipsLabel.hidden = YES;
}

- (void)configTips:(NSString *)user
{
    CGFloat selfW = [UIScreen mainScreen].bounds.size.width * 4/5;
    CGFloat selfH = 30;
    
    NSString *title = @"直播消息:";
    int random = arc4random() % 2;
    NSString *tips;
    if (random == 0)//方案一
    {
        tips = [NSString stringWithFormat:@"%@金光闪现,%@进房",title,user];
    }
    if (random == 1)//方案二
    {
        tips = [NSString stringWithFormat:@"%@%@炫酷登场",title,user];
    }
    UIFont *tipFont = [UIFont fontWithName:@"Superclarendon" size:17];//Helvetica-Bold

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:tips];
    [attrStr addAttribute:NSForegroundColorAttributeName value:kColorWhite range:NSMakeRange(0, title.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:kColorYellow range:NSMakeRange(title.length, tips.length-title.length)];
    [attrStr addAttribute:NSFontAttributeName value:tipFont range:NSMakeRange(0, tips.length)];
    _tipsLabel.attributedText = attrStr;
    
    CGSize labelsize = [self textHeightSize:tips maxSize:CGSizeMake(selfW - kDefaultMargin*2, selfH * 3) textFont:tipFont];
    [_tipsLabel setFrame:CGRectMake(_tipsLabel.frame.origin.x, _tipsLabel.frame.origin.y, labelsize.width + kDefaultMargin, labelsize.height)];
    [self setFrame:CGRectMake(0, 0, selfW, labelsize.height)];
    
    _height = labelsize.height+5;
    _tipsLabel.hidden = NO;
    _msgLabel.hidden = YES;
}

- (CGSize)textHeightSize:(NSString *)text maxSize:(CGSize)maxSize textFont:(UIFont *)font
{
    NSDictionary *dic = @{NSFontAttributeName : font};
    CGSize labelSize = [text boundingRectWithSize:maxSize
                                          options:NSStringDrawingTruncatesLastVisibleLine |
                        NSStringDrawingUsesLineFragmentOrigin |
                        NSStringDrawingUsesFontLeading
                                       attributes:dic context:nil].size;
    return labelSize;
}

@end
