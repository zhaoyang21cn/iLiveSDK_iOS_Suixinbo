//
//  UIImageView+InitMethod.m
//  CommonLibrary
//
//  Created by Alexi on 14-7-21.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//
#if kSupportUIViewInitMethod
#import "UIImageView+InitMethod.h"

@implementation UIImageView (InitMethod)


+ (instancetype)imageViewWithColor:(UIColor *)color
{
    UIImageView *view = [[UIImageView alloc] init];
    view.backgroundColor = color;
    return view;
}

+ (instancetype)imageViewWithColor:(UIColor *)color size:(CGSize)size
{
    UIImage *image = [UIImage imageWithColor:color size:size];
    return [self imageViewWithImage:image];
}

+ (instancetype)imageViewWithRandomColor:(CGSize)size
{
    UIImage *image = [UIImage randomColorImageWith:size];
    return [self imageViewWithImage:image];
}

+ (instancetype)imageViewWithImage:(UIImage *)image
{
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    return view;
}

@end
#endif