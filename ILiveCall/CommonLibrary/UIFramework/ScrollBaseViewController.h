//
//  ScrollBaseViewController.h
//  CommonLibrary
//
//  Created by Alexi on 3/18/14.
//  Copyright (c) 2014 Alexi. All rights reserved.
//
#if kSupportScrollController

#import "BaseViewController.h"

@interface ScrollBaseViewController : BaseViewController<UIGestureRecognizerDelegate>
{
@protected
    __weak UIView               *_scrollableView;
//    UIView                      *_overlay;
    CGPoint                     _lastContentOffset;
    BOOL                        _isCollapsed;
    BOOL                        _isExpanded;
    
    BOOL                        _handleTabbar;  // 是否处理tarbar
//    UIPanGestureRecognizer      *_panGesture;
}

@property (nonatomic, weak)   UIView    *scrollableView;
//@property (nonatomic, strong) UIView    *overlay;
@property (nonatomic, assign) CGPoint   lastContentOffset;
@property (nonatomic, assign) BOOL      isCollapsed;
@property (nonatomic, assign) BOOL      isExpanded;
@property (nonatomic, assign) BOOL      isPanVailed;
@property (nonatomic, strong) UIPanGestureRecognizer* panGesture;

- (UIView *)crateOverlay:(CGRect)frame;

- (void)followScrollView:(UIView *)scrollableView;

- (void)updateSizingWithDelta:(CGFloat)delta;

- (void)checkForPartialScrollEnd;

// protected
- (void)layoutOnScrollUp;
- (void)layoutOnScrollDown;


@end
#endif