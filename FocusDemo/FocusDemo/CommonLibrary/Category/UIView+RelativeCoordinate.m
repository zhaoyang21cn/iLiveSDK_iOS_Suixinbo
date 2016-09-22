//
//  UIView+RelativeCoordinate.m
//  CommonLibrary
//
//  Created by Alexi on 5/21/14.
//  Copyright (c) 2014 Alexi. All rights reserved.
//

#import "UIView+RelativeCoordinate.h"

@implementation UIView (RelativeCoordinate)

- (BOOL)isSubContentOf:(UIView *)aSuperView
{
    if (self == aSuperView)
    {
        return YES;
    }
    else
    {
        return [self.superview isSubContentOf:aSuperView];
    }
}


- (CGRect)relativePositionTo:(UIView *)aSuperView
{
    BOOL isSubContentOf = [self isSubContentOf:aSuperView];
    
    while (isSubContentOf)
    {
        return [self relativeTo:aSuperView];
    }
    
    return CGRectZero;
    
}

- (CGRect)relativeTo:(UIView *)aSuperView
{
    CGPoint originPoint = CGPointZero;
    UIView *view = self;
    while (!(view == aSuperView))
    {
        originPoint.x += view.frame.origin.x;
        originPoint.y += view.frame.origin.y;
        
        if ([view isKindOfClass:[UIScrollView class]])
        {
            originPoint.x -= ((UIScrollView *) view).contentOffset.x;
            originPoint.y -= ((UIScrollView *) view).contentOffset.y;
        }
        
        view = view.superview;
    }
    
    // TODO:如果SuperView是UIWindow,需要结合Transform计算
    return CGRectMake(originPoint.x, originPoint.y, self.frame.size.width, self.frame.size.height);
}

@end
