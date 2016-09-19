//
//  UIImageView+InitMethod.h
//  CommonLibrary
//
//  Created by Alexi on 14-7-21.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//
#if kSupportUIViewInitMethod
#import <UIKit/UIKit.h>

@interface UIImageView (InitMethod)

+ (instancetype)imageViewWithColor:(UIColor *)color;

+ (instancetype)imageViewWithColor:(UIColor *)color size:(CGSize)size;

+ (instancetype)imageViewWithRandomColor:(CGSize)size;

+ (instancetype)imageViewWithImage:(UIImage *)image;

@end
#endif