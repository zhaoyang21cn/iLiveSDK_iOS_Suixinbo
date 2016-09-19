//
//  UILabel+InitMethod.m
//  CommonLibrary
//
//  Created by Alexi on 14-7-21.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//

#import "UILabel+InitMethod.h"

#import "UILabel+Common.h"

@implementation UILabel (InitMethod)

+ (instancetype)labelWith:(NSString *)text;
{
    UILabel *label = [UILabel label];
    label.text = text;
    return label;
}

+ (instancetype)labelWith:(NSString *)text textColor:(UIColor *)color
{
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = color;
    return label;
}

+ (instancetype)labelWith:(NSString *)text textColor:(UIColor *)color backgroundColor:(UIColor *)bgColor
{
    UILabel *label = [UILabel labelWith:text textColor:color];
    label.backgroundColor = bgColor;
    return label;
}

+ (instancetype)centerlabelWith:(NSString *)text
{
    UILabel *label = [UILabel labelWith:text];
    label.textColor = kMainTextColor;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}


+ (instancetype)labelWith:(NSString *)text font:(CGFloat)size
{
    UILabel *label = [UILabel labelWith:text];
    label.font = [UIFont systemFontOfSize:size];
    return label;
}

+ (instancetype)labelWith:(NSString *)text font:(CGFloat)size textColor:(UIColor *)textColor
{
    UILabel *label = [UILabel labelWith:text font:size];
    label.textColor = textColor;
    return label;
}

+ (instancetype)labelWith:(NSString *)text boldFont:(CGFloat)size
{
    UILabel *label = [UILabel labelWith:text];
    label.font = [UIFont boldSystemFontOfSize:size];
    return label;
}

+ (instancetype)centerlabelWith:(NSString *)text font:(CGFloat)size
{
    UILabel *label = [UILabel centerlabelWith:text];
    label.font = [UIFont systemFontOfSize:size];
    return label;
}

+ (instancetype)centerlabelWith:(NSString *)text font:(CGFloat)size textColor:(UIColor *)textColor
{
    UILabel *label = [UILabel centerlabelWith:text font:size];
    label.textColor = textColor;
    label.adjustsFontSizeToFitWidth = YES;
//    label.adjustsLetterSpacingToFitWidth = YES;
    return label;
}

+ (instancetype)centerlabelWith:(NSString *)text boldFont:(CGFloat)size
{
    UILabel *label = [UILabel centerlabelWith:text];
    label.font = [UIFont boldSystemFontOfSize:size];
    return label;
}
@end
