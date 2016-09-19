//
//  UIView+Glow.h
//  
//
//  Created by James on 11/4/14.
//  Copyright (c) 2014 James. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIView (Glow)

@property (nonatomic, readonly) UIView *glowView;


- (void) glowOnce;

- (void) glowOnceAtLocation:(CGPoint)point inView:(UIView *)view;

- (void) startGlowing;

- (void) startGlowingWithColor:(UIColor *)color intensity:(CGFloat)intensity;

- (void) startGlowingWithColor:(UIColor*)color fromIntensity:(CGFloat)fromIntensity toIntensity:(CGFloat)toIntensity repeat:(BOOL)repeat;

- (void) startGlowingWithColor:(UIColor*)color fromIntensity:(CGFloat)fromIntensity toIntensity:(CGFloat)toIntensity repeat:(BOOL)repeat duration:(CGFloat)dur;

- (void) stopGlowing;

@end
