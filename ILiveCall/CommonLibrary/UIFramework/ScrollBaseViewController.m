//
//  ScrollBaseViewController.m
//  CommonLibrary
//
//  Created by Alexi on 3/18/14.
//  Copyright (c) 2014 Alexi. All rights reserved.
//

#if kSupportScrollController
#import "ScrollBaseViewController.h"

@interface ScrollBaseViewController ()


@end

@implementation ScrollBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isExpanded = YES;
    
    _handleTabbar = NO;
    if (self.tabBarController && !self.tabBarController.tabBar.hidden)
    {
        _handleTabbar = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_handleTabbar)
    {
        self.tabBarController.tabBar.translucent = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self backToOrignal];
}

//
//- (void)setBarTintColor
//{
//    if ([IOSDeviceConfig sharedConfig].isIOS7Later)
//    {
//        [self.overlay setBackgroundColor:self.navigationController.navigationBar.barTintColor];
//    }
//    else
//    {
//    [self.overlay setBackgroundColor:kNavBarThemeColor];
//    }
//}

- (void)followScrollView:(UIView *)scrollableView
{
    if (self.scrollableView)
    {
        [self.scrollableView removeGestureRecognizer:self.panGesture];
    }
    self.scrollableView = scrollableView;
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.panGesture setMaximumNumberOfTouches:1];
    [self.panGesture setDelegate:self];
    [self.scrollableView addGestureRecognizer:self.panGesture];
    
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin = CGPointZero;
    
    //    self.overlay = [self crateOverlay:frame];
    
    //    [self configOverlay];
}

- (UIView *)crateOverlay:(CGRect)frame
{
    return [[UIView alloc] initWithFrame:frame];
}

//- (void)configOverlay
//{
//    [self setBarTintColor];
//
//
//    [self.overlay setUserInteractionEnabled:NO];
//    [self.navigationController.navigationBar addSubview:self.overlay];
//    [self.overlay setAlpha:0];
//}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#define kNavgationBarOffset 44
#define kStatusHeight 20

- (void)onScrollUp:(CGFloat)delta
{
    CGRect frame;
    if (self.isCollapsed)
    {
        return;
    }
    
    frame = self.navigationController.navigationBar.frame;
    
    if (frame.origin.y - delta < -kNavgationBarOffset)
    {
        delta = frame.origin.y + kNavgationBarOffset;
    }
    
    frame.origin.y = MAX(-kNavgationBarOffset, frame.origin.y - delta);
    self.navigationController.navigationBar.frame = frame;
    
    if (frame.origin.y == -kNavgationBarOffset)
    {
        self.isCollapsed = YES;
        self.isExpanded = NO;
    }
    
    [self updateSizingWithDelta:delta];
    
    if ([self.scrollableView isKindOfClass:[UIScrollView class]])
    {
        [(UIScrollView *)self.scrollableView setContentOffset:CGPointMake(((UIScrollView*)self.scrollableView).contentOffset.x, ((UIScrollView*)self.scrollableView).contentOffset.y - delta)];
    }
    
    [self hideTabbar];
    
    [self layoutOnScrollUp];
}

- (void)showTabbar
{
    if (_handleTabbar && self.tabBarController.tabBar.translucent)
    {
        
        if (self.tabBarController.tabBar.hidden)
        {
            self.tabBarController.tabBar.hidden = NO;
        }
    }
}

- (void)onScrollDown:(CGFloat)delta
{
    CGRect frame;
    if (self.isExpanded)
    {
        return;
    }
    
    frame = self.navigationController.navigationBar.frame;
    
    if (frame.origin.y - delta > kStatusHeight)
    {
        delta = frame.origin.y - kStatusHeight;
    }
    frame.origin.y = MIN(kStatusHeight, frame.origin.y - delta);
    self.navigationController.navigationBar.frame = frame;
    
    if (frame.origin.y == kStatusHeight)
    {
        self.isExpanded = YES;
        self.isCollapsed = NO;
    }
    
    [self updateSizingWithDelta:delta];
    
    [self showTabbar];
    
    [self layoutOnScrollDown];
}

- (void)layoutOnScrollUp
{
    
}
- (void)layoutOnScrollDown
{
    
}

- (void)hideTabbar
{
    if (_handleTabbar && self.tabBarController.tabBar.translucent)
    {
        if (!self.tabBarController.tabBar.hidden)
        {
            self.tabBarController.tabBar.hidden = YES;
        }
    }
}

#define kScrollHorOffset 20

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state)
    {
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [gesture translationInView:[self.scrollableView superview]];
            float delta = self.lastContentOffset.y - translation.y;
            self.lastContentOffset = translation;
            
            if (delta == 0)
            {
                return;
            }
            
            if (delta > 0)
            {
                [self onScrollUp:delta];
            }
            else
            {
                [self onScrollDown:delta];
            }
        }
            
            break;
        case UIGestureRecognizerStateEnded:
        {
            self.lastContentOffset = CGPointZero;
            [self checkForPartialScroll];
        }
            break;
        default:
            break;
    }
    
}

- (void)checkForPartialScrollEnd
{
    
}

- (void)checkForPartialScroll
{
    CGFloat pos = self.navigationController.navigationBar.frame.origin.y;
    __block CGFloat delta = 0;
    // Get back down
    if (pos >= 0)
    {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame;
            frame = self.navigationController.navigationBar.frame;
            delta = frame.origin.y - kStatusHeight;
            frame.origin.y = MIN(kStatusHeight, frame.origin.y - delta);
            self.navigationController.navigationBar.frame = frame;
            
            self.isExpanded = YES;
            self.isCollapsed = NO;
        } completion:^(BOOL finished) {
            [self updateSizingWithDelta:delta];
            [self checkForPartialScrollEnd];
        }];
    }
    else
    {
        // And back up
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame;
            frame = self.navigationController.navigationBar.frame;
            CGFloat delta = frame.origin.y + kNavgationBarOffset;
            frame.origin.y = MAX(-kNavgationBarOffset, frame.origin.y - delta);
            self.navigationController.navigationBar.frame = frame;
            
            self.isExpanded = NO;
            self.isCollapsed = YES;
        } completion:^(BOOL finished) {
            [self updateSizingWithDelta:delta];
            [self checkForPartialScrollEnd];
        }];
    }
}


- (void)backToOrignal
{
    // 如果navigationbar 或 tab隐藏时进行push，会有界面乱的情况
    [self onScrollDown:-kNavgationBarOffset];
    self.lastContentOffset = CGPointZero;
    [self checkForPartialScroll];
    
}

- (void)updateSizingWithDelta:(CGFloat)delta
{
    DebugLog(@"delta = %f", delta);
    
    CGRect frame = self.navigationController.navigationBar.frame;
    
    float alpha = (frame.origin.y + kNavgationBarOffset) / frame.size.height;
    //    [self.overlay setAlpha:1 - alpha];
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
    
    
    UIView *scrollSuperView = self.scrollableView.superview;
    frame = scrollSuperView.frame;
    frame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    frame.size.height = frame.size.height + delta;
    scrollSuperView.frame = frame;
    
    frame = self.scrollableView.layer.frame;
    frame.size.height += delta;
    self.scrollableView.layer.frame = frame;
    self.scrollableView.frame = frame;
    
    
//    DebugLog(@"=====>>>>>>>>>>on scroll");
}

@end
#endif