//
//  UIView+CaptureImage.m
//  CommonLibrary
//
//  Created by AlexiChen on 15/12/5.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//
#if kSupportADTransition
#import "UIView+CaptureImage.h"

#import <QuartzCore/QuartzCore.h>



@implementation UIView (CapatureImage)

- (UIImage *)captureImage
{
	return [self captureImageAtRect:self.bounds];
}

- (UIImage *)captureImageAtRect:(CGRect)rect
{
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
	[[self layer] renderInContext:context];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

@end
#endif
