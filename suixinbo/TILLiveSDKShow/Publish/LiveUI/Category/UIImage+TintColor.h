//
//  UIImage+TintColor.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/6.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TintColor)

// tint只对里面的图案作更改颜色操作
- (UIImage *)imageWithTintColor:(UIColor *)tintColor;
- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;
- (UIImage *)imageWithGradientTintColor:(UIColor *)tintColor;

@end
