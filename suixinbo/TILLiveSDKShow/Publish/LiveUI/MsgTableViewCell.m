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
    _msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _msgLabel.font  = kAppMiddleTextFont;
    _msgLabel.layer.cornerRadius = 10.0;
    _msgLabel.clipsToBounds = YES;
    _msgLabel.backgroundColor = kColorWhite;
    _msgLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_msgLabel];
    
    _tipsLabel = [[UILabel alloc] init];
    _tipsLabel.textColor = kColorWhite;
    _tipsLabel.font = kAppMiddleTextFont;
    _tipsLabel.layer.cornerRadius = 10.0;
    _tipsLabel.clipsToBounds = YES;
    _tipsLabel.backgroundColor = kColorGray;
    [self.contentView addSubview:_tipsLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect selfRect = self.contentView.bounds;

    [_msgLabel layoutParentVerticalCenter];
    [_msgLabel alignParentLeftWithMargin:kDefaultMargin];
    
    [_tipsLabel sizeWith:CGSizeMake(selfRect.size.width * 2/3, selfRect.size.height-kDefaultMargin)];
    [_tipsLabel layoutParentVerticalCenter];
    [_tipsLabel alignParentLeftWithMargin:kDefaultMargin];
}

- (void)configMsg:(NSString *)userId msg:(NSString *)text
{
    CGFloat selfW = [UIScreen mainScreen].bounds.size.width * 2/3;
    CGFloat selfH = 30;
    
    NSString *showInfo = [NSString stringWithFormat:@"%@: %@",userId, text];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:showInfo];
    [attrStr addAttribute:NSForegroundColorAttributeName value:kColorGreen range:NSMakeRange(0, userId.length+1)];//+1是因为有个冒号
    [attrStr addAttribute:NSForegroundColorAttributeName value:kColorBlack range:NSMakeRange(userId.length+1, text.length+1)];//+1是因为有个空格
    
    _msgLabel.attributedText = attrStr;
    CGSize labelsize = [self textHeightSize:showInfo maxSize:CGSizeMake(selfW - kDefaultMargin*2, selfH * 3) textFont:kAppMiddleTextFont];
    [_msgLabel setFrame:CGRectMake(_msgLabel.frame.origin.x, _msgLabel.frame.origin.y, labelsize.width + kDefaultMargin, labelsize.height)];

    NSLog(@"numberOfLines = %ld",_msgLabel.numberOfLines);
    [self setFrame:CGRectMake(0, 0, selfW, labelsize.height+10)];
    _height = labelsize.height+10;
    
    _tipsLabel.hidden = YES;
}

- (void)configTips:(NSString *)tips
{
    CGFloat selfW = [UIScreen mainScreen].bounds.size.width * 2/3;
    CGFloat selfH = 30;
    
    CGSize labelsize = [self textHeightSize:tips maxSize:CGSizeMake(selfW - kDefaultMargin*2, selfH * 3) textFont:kAppMiddleTextFont];
    [_tipsLabel setFrame:CGRectMake(_tipsLabel.frame.origin.x, _tipsLabel.frame.origin.y, labelsize.width+10, labelsize.height)];
    
    [self setFrame:CGRectMake(0, 0, labelsize.width+10, labelsize.height+10)];
    _height = labelsize.height+10;
    
    _tipsLabel.text = tips;
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
