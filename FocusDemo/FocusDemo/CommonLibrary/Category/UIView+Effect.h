//
//  UIView+Effect.h
//  CommonLibrary
//
//  Created by AlexiChen on 15/12/24.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#if kSupportUIViewEffect

#import <UIKit/UIKit.h>

@interface UIView (Effect)

- (void)blurWithColor:(UIColor *)color;

// 底层自动blur image
- (void)blurWithImage:(UIImage *)image;

// iOS8这后调才管
- (void)blurSelfBackground;

@end
#endif