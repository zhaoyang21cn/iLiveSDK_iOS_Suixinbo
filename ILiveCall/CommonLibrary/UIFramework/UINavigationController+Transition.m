//
//  UINavigationController+Transition.m
//  CommonLibrary
//
//  Created by Alexi on 3/18/14.
//  Copyright (c) 2014 Alexi. All rights reserved.
//

#import "UINavigationController+Transition.h"


@implementation UINavigationController (Transition)

- (CATransition *)pushAnimation
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromBottom;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.autoreverses = NO;
    return transition;
}

- (CATransition *)popAnimation
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.autoreverses = NO;
    return transition;
}

- (void)pushViewController:(UIViewController *)viewController withAnimation:(void (^)(void))animation duration:(CGFloat)duration
{
    if (animation)
    {
        [self pushViewController:viewController animated:NO];
        [UIView animateWithDuration:duration animations:^{
            animation();
        }];
//        [self.view.layer addAnimation:transition forKey:kCATransition];
    }
    else
    {
        [self pushViewController:viewController animated:YES];
    }
}

- (void)pushViewController:(UIViewController *)viewController withTransition:(CATransition *)transition
{
    if (transition)
    {
        [self pushViewController:viewController animated:NO];
        [self.view.layer addAnimation:transition forKey:kCATransition];
    }
    else
    {
        [self pushViewController:viewController animated:YES];
    }
}

- (void)pushViewController:(UIViewController *)viewController withBackTitle:(NSString *)backTitle animated:(BOOL)animated
{
    [self pushViewController:viewController animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController withBackTitle:(NSString *)backTitle action:(CommonVoidBlock)backAction animated:(BOOL)animated
{
    [self pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerTransition:(CATransition *)transition
{
    if (transition)
    {
        [self.view.layer addAnimation:transition forKey:kCATransition];
        return [self popViewControllerAnimated:NO];
    }
    else
    {
        return [self popViewControllerAnimated:YES];
    }
}

- (NSArray *)popToRootViewControllerTransition:(CATransition *)transition
{
    if (transition)
    {
        [self.view.layer addAnimation:transition forKey:kCATransition];
        return [self popToRootViewControllerAnimated:NO];
    }
    else
    {
        return [self popToRootViewControllerAnimated:YES];
    }
}

- (NSArray *)popToViewController:(UIViewController *)viewController withTransition:(CATransition *)transition
{
    if (transition)
    {
        [self.view.layer addAnimation:transition forKey:kCATransition];
        return [self popToViewController:viewController animated:NO];
    }
    else
    {
        return [self popToViewController:viewController animated:NO];
    }
}

@end
