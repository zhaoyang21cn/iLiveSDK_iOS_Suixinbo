//
//  UINavigationController+Transition.h
//  CommonLibrary
//
//  Created by Alexi on 3/18/14.
//  Copyright (c) 2014 Alexi. All rights reserved.
//

#import <UIKit/UIKit.h>

//@interface UINavigationBar (CustomBackgroundImage)
//
//@end

@interface UINavigationController (Transition)

- (CATransition *)pushAnimation;
- (CATransition *)popAnimation;

- (void)pushViewController:(UIViewController *)viewController withAnimation:(void (^)(void))animation duration:(CGFloat)duration;

- (void)pushViewController:(UIViewController *)viewController withTransition:(CATransition *)transition;

- (void)pushViewController:(UIViewController *)viewController withBackTitle:(NSString *)backTitle animated:(BOOL)animated;
- (void)pushViewController:(UIViewController *)viewController withBackTitle:(NSString *)backTitle action:(CommonVoidBlock)backAction animated:(BOOL)animated;

- (UIViewController *)popViewControllerTransition:(CATransition *)transition;

- (NSArray *)popToRootViewControllerTransition:(CATransition *)transition;

- (NSArray *)popToViewController:(UIViewController *)viewController withTransition:(CATransition *)transition;

@end
