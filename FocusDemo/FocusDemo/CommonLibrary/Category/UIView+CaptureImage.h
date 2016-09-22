//
//  UIView+CaptureImage.h
//  CommonLibrary
//
//  Created by AlexiChen on 15/12/5.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//
#if kSupportADTransition
#import <UIKit/UIKit.h>


@interface UIView (CaptureImage)


- (UIImage *)captureImage;

- (UIImage *)captureImageAtRect:(CGRect)rect;

@end
#endif