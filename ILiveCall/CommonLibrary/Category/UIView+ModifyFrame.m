//
//  UIView+ModifyFrame.m
//  CommonLibrary
//
//  Created by Alexi on 14-2-21.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//
#if kUnSupportModifyFrame
#import "UIView+ModifyFrame.h"

@implementation UIView (ModifyFrame)

- (float)x
{
    return self.frame.origin.x;
}

- (void)setX:(float)newX
{
    CGRect frame = self.frame;
    frame.origin.x = newX;
    self.frame = frame;
}

- (float)y
{
    return self.frame.origin.y;
}

- (void)setY:(float)newY
{
    CGRect frame = self.frame;
    frame.origin.y = newY;
    self.frame = frame;
}

- (float)width
{
    return self.frame.size.width;
}

- (void)setOrigin:(CGPoint)origin
{
    self.x = origin.x;
    self.y = origin.y;
}

- (CGPoint)origin
{
    return CGPointMake(self.x, self.y);
}

- (void)setWidth:(float)newWidth
{
    CGRect frame = self.frame;
    frame.size.width = newWidth;
    self.frame = frame;
}

- (float)height
{
    return self.frame.size.height;
}

- (void)setHeight:(float)newHeight
{
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
}

- (CGSize)boundsSize
{
    return self.bounds.size;
}

- (void)setBoundsSize:(CGSize)boundsSize
{
    CGRect boundsRect = self.bounds;
    boundsRect.size.width = boundsSize.width;
    boundsRect.size.height = boundsSize.height;
    self.bounds = boundsRect;
}


- (CGPoint)originRelativeToWindow
{
    CGPoint p = self.origin;
    
    UIView *superView = self.superview;
    while (superView) {
        p.x += superView.x;
        p.y += superView.y;
        superView = superView.superview;
    }
    return p;
    
}
- (CGPoint)centerRelativeToWindow
{
    CGPoint p = CGPointMake(self.x + self.width/2, self.y + self.height/2);
    
    UIView *superView = self.superview;
    while (superView) {
        p.x += superView.x;
        p.y += superView.y;
        superView = superView.superview;
    }
    return p;
}
- (CGRect)relativeToWindow
{
    CGPoint origin = [self originRelativeToWindow];
    
    return CGRectMakeWithOriginAndSize(origin, self.bounds.size);
    
}

@end


@implementation UIViewController (ModifyFrame)

- (float)x
{
    return self.view.x;
}

- (void)setX:(float)newX
{
    self.view.x = newX;
}

- (float)y
{
    return self.view.y;
}

- (void)setY:(float)newY
{
    self.view.y = newY;
}

- (float)width
{
    return self.view.width;
}

- (void)setWidth:(float)newWidth
{
    self.view.width = newWidth;

}

- (float)height
{
    return self.view.height;
}

- (void)setHeight:(float)newHeight
{
    self.view.height = newHeight;
}

- (CGSize)boundsSize
{
    return self.view.boundsSize;
}

- (void)setBoundsSize:(CGSize)boundsSize
{
    self.view.boundsSize = boundsSize;
}

@end
#endif
