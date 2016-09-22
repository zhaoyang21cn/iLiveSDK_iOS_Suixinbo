//
//  UIViewController+ChildViewController.m
//  CommonLibrary
//
//  Created by Alexi on 14-2-24.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//

#import "UIViewController+ChildViewController.h"

@implementation UIViewController (ChildViewController)

- (void)addChild:(UIViewController *)vc
{
    [self addChild:vc inRect:CGRectZero];
}

- (void)addChild:(UIViewController *)vc animation:(void (^)(void))inAnimation
{
    [self addChild:vc inRect:CGRectZero animation:inAnimation];
}

- (void)addChild:(UIViewController *)vc inRect:(CGRect)rect
{
    [self.view addSubview:vc.view];
    vc.view.frame = rect;
    [self addChildViewController:vc];
}

- (void)addChild:(UIViewController *)vc inRect:(CGRect)rect animation:(void (^)(void))inAnimation
{
    [self addChild:vc inRect:rect];
    if (inAnimation) {
        [UIView animateWithDuration:0.3 animations:^{
            inAnimation();
        }];
    }
}

- (void)addChild:(UIViewController *)vc container:(UIView *)view
{
    [view addSubview:vc.view];
    [self addChildViewController:vc];
}

- (void)addChild:(UIViewController *)vc container:(UIView *)view inRect:(CGRect)rect
{
    [view addSubview:vc.view];
    vc.view.frame = rect;
    [self addChildViewController:vc];
}

- (void)addChild:(UIViewController *)child container:(UIView *)view inRect:(CGRect)rect animation:(void (^)(void))inAnimation
{
    [self addChild:child container:view inRect:rect];
    if (inAnimation) {
        [UIView animateWithDuration:0.3 animations:^{
            inAnimation();
        }];
    }
}

- (void)removeChild:(UIViewController *)vc
{
    [vc.view removeFromSuperview];
    [vc willMoveToParentViewController:nil];
    [vc removeFromParentViewController];
}

- (void)removeChild:(UIViewController *)vc animation:(void (^)(void))outAnimation
{
    if (outAnimation)
    {
        [UIView animateWithDuration:0.3 animations:^{
            outAnimation();
        } completion:^(BOOL finished) {
            [self removeChild:vc];
        }];
    }
    else
    {
        [self removeChild:vc];
    }
   
}

- (void)removeChild:(UIViewController *)child inContainer:(UIView *)view
{
    [child.view removeFromSuperview];
    [child willMoveToParentViewController:nil];
    [child removeFromParentViewController];
}

- (void)removeChild:(UIViewController *)child inContainer:(UIView *)view animation:(void (^)(void))outAnimation
{
    if (outAnimation)
    {
        [UIView animateWithDuration:0.3 animations:^{
            outAnimation();
        } completion:^(BOOL finished) {
            [self removeChild:child inContainer:view];
        }];
    }
    else
    {
        [self removeChild:child inContainer:view];
    }
}

// 默认是在self.view中操作
- (void)replace:(UIViewController *)oldVC withNew:(UIViewController *)newVC animations:(void (^)(void))animations;
{
    [self replace:oldVC withNew:newVC container:self.view animations:animations];
}

- (void)replace:(UIViewController *)old withNew:(UIViewController *)newvc container:(UIView *)container animations:(void (^)(void))animations
{
    if (newvc)
    {
        [self addChild:newvc container:container inRect:old.view.frame];
        
        if (old)
        {
            [self transitionFromViewController:old toViewController:newvc duration:0.0 options:0 animations:animations completion:^(BOOL finished)
            {
                
                [newvc didMoveToParentViewController:self];
                
                [[old view] removeFromSuperview];
                [old willMoveToParentViewController:nil];
                [old removeFromParentViewController];
            }];
        }
        else
        {
            [container addSubview:[newvc view]];
            [newvc didMoveToParentViewController:self];
        }
    }
    else
    {
        [[old view] removeFromSuperview];
        [old willMoveToParentViewController:nil];
        [old removeFromParentViewController];
    }
}

@end
