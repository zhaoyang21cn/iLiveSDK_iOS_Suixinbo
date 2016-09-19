//
//  UIView+ModifyFrame.h
//  CommonLibrary
//
//  Created by Alexi on 14-2-21.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//


#if kUnSupportModifyFrame

#import <UIKit/UIKit.h>





@interface UIView (ModifyFrame)

@property float x;
@property float y;
@property CGPoint origin;
@property float width;
@property float height;

@property CGSize boundsSize;

- (CGPoint)originRelativeToWindow;
- (CGPoint)centerRelativeToWindow;
- (CGRect)relativeToWindow;

@end

@interface UIViewController (ModifyFrame)

@property float x;
@property float y;
@property float width;
@property float height;
@property CGSize boundsSize;


@end

#endif