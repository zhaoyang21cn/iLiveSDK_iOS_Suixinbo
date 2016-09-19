//
//  UILabel+InitMethod.h
//  CommonLibrary
//
//  Created by Alexi on 14-7-21.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (InitMethod)

+ (instancetype)labelWith:(NSString *)text;

+ (instancetype)labelWith:(NSString *)text textColor:(UIColor *)color;

+ (instancetype)labelWith:(NSString *)text textColor:(UIColor *)color backgroundColor:(UIColor *)bgColor;

+ (instancetype)centerlabelWith:(NSString *)text;

+ (instancetype)labelWith:(NSString *)text font:(CGFloat)size;

+ (instancetype)labelWith:(NSString *)text font:(CGFloat)size textColor:(UIColor *)textColor;

+ (instancetype)labelWith:(NSString *)text boldFont:(CGFloat)size;

+ (instancetype)centerlabelWith:(NSString *)text font:(CGFloat)size;

+ (instancetype)centerlabelWith:(NSString *)text font:(CGFloat)size textColor:(UIColor *)textColor;

+ (instancetype)centerlabelWith:(NSString *)text boldFont:(CGFloat)size;

@end
