//
//  UIView+Effect.m
//  CommonLibrary
//
//  Created by AlexiChen on 15/12/24.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//
#if kSupportUIViewEffect 
#import "UIView+Effect.h"

#import "IOSDeviceConfig.h"

#import "UIImage+ImageEffect.m"

#import "UIImage+Common.h"

@implementation UIView (Effect)

- (void)blurWithColor:(UIColor *)color
{
    
    
    UIImage *image = [UIImage imageWithColor:color size:CGSizeMake(32, 32)];
    [self blurWithImage:image];
    
}

// 底层自动blur image
- (void)blurWithImage:(UIImage *)image
{
//    if ([IOSDeviceConfig sharedConfig].isIOS7Later)
//    {
//        [self blurSelfAfterIOS7];
//    }
//    else
//    {
        UIImage *blurimg = [image applyLightEffect];
        
        UIImageView *effectView = [[UIImageView alloc] init];
        effectView.image = blurimg;
        effectView.autoresizesSubviews = YES;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:effectView atIndex:0];
//    }
}

- (void)blurSelfAfterIOS7
{
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    effectView.autoresizesSubviews = YES;
    effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    effectView.alpha = 1;
    
    [self insertSubview:effectView atIndex:0];
}

- (void)blurSelfBackground
{
//    if ([IOSDeviceConfig sharedConfig].isIOS7Later)
//    {
//        [self blurSelfAfterIOS7];
//    }
//    else
//    {
        [self blurWithColor:[[UIColor flatDarkWhiteColor] colorWithAlphaComponent:0.8]];
//    }
}

@end
#endif