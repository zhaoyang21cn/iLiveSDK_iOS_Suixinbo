//
//  PopupView.m
//  HudDemo
//
//  Created by Alexi on 13-12-3.
//  Copyright (c) 2013年 Matej Bukovinski. All rights reserved.
//
#if kSupportPopupView
#import "PopupView.h"
#import "UIView+Layout.h"

@implementation PopupContentView

- (void)dealloc
{
    self.popupParent = nil;
    CommonSuperDealloc();
//    [super dealloc];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        self.outAnimation = ^(PopupContentView *view){
//            [view slideOutTo:kFTAnimationTop duration:0.3 delegate:nil];
//        };
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = kAppModalBackgroundColor;
        
    }
    return self;
}

// 在Window中时显示的大小
- (CGRect)showRect
{
//    if (CGRectEqualToRect(_showRect, CGRectZero))
//    {
        CGRect rect = self.popupParent.bounds;
//
//        if (!CGSizeEqualToSize(_showSize, CGSizeZero))
//        {
//            if (rect.size.width < _showSize.width)
//            {
//                _showSize.width = rect.size.width;
//            }
//            
//            if (rect.size.height < _showSize.height)
//            {
//                _showSize.height = rect.size.height;
//            }
    
            CGRect showRect = CGRectInset(rect, (rect.size.width - _showSize.width)/2, (rect.size.height - _showSize.height)/2);
            _showRect = showRect;
            return showRect;
//        }
//        return CGRectInset(rect, 20, 150);
//    }
    
//    return _showRect;
}

- (void)adjustShowRectOnRorate
{
    CGRect rect = self.popupParent.bounds;
    CGRect showRect = CGRectInset(rect, (rect.size.width - self.showSize.width)/2, (rect.size.height - self.showSize.height)/2);
    _showRect = showRect;
}

- (void)closePopup
{
    if (_outAnimation) {
        
        [UIView animateWithDuration:0.3 animations:^{
            _outAnimation(self);
            
        } completion:^(BOOL finished) {
            [self.popupParent hide:YES];
        }];
    }
    else
    {
        if (self.popupParent)
        {
            [self.popupParent hide:YES];
        }
    }
}


// YES：击返回空的区域
- (BOOL)isAlert
{
    return NO;
}

// 点击空白区域
- (void)onTouchBlank
{
    [self closePopup];
}

- (void)setPopupParent:(PopupView *)popupParent
{
    _popupParent = popupParent;
    CGRect showRect = [self showRect];
    [self setFrameAndLayout:showRect];
}

- (void)setShowSize:(CGSize)showSize
{
    _showSize = showSize;
    if (_popupParent)
    {
        [_popupParent relayoutFrameOfSubViews];
        [self setNeedsLayout];
    }
}

- (void)setShowRect:(CGRect)showRect
{
    _showRect = showRect;
    
    if (_popupParent)
    {
        [_popupParent relayoutFrameOfSubViews];
        [self setNeedsLayout];
    }
}

@end

@interface PopupView ()
{
    CGAffineTransform _rotationTransform;
}

@end


@implementation PopupView

+ (PopupView *)alert:(PopupContentView *)contentView inView:(UIView *)view
{
    PopupView *pop = [[PopupView alloc] initWithFrame:view.bounds];
    [pop setContentView:contentView];
    contentView.popupParent = pop;
    [view addSubview:pop];
    [pop relayoutFrameOfSubViews];
    [pop show:YES];
    return pop;
}

+ (PopupView *)alert:(PopupContentView *)contentView inView:(UIView *)view withAnimation:(void (^)(void))animation
{
    PopupView *pop = [[PopupView alloc] initWithFrame:view.bounds];
    [pop setContentView:contentView];
    contentView.popupParent = pop;
    [view addSubview:pop];
    [pop relayoutFrameOfSubViews];
    [pop showWith:animation];
    return CommonReturnAutoReleased(pop);
}

+ (PopupView *)alertInWindow:(PopupContentView *)contentView
{
    return [PopupView alert:contentView inView:[UIApplication sharedApplication].keyWindow];
//    if ([IOSDeviceConfig sharedConfig].isIPhone)
//    {
//        AppDelegate *app = [AppDelegate sharedAppDelegate];
////        app.topViewController.navigationController.view
////        return [PopupView alert:contentView inView:app.topViewController.navigationController.view];
//    }
//    else
//    {
//        return [PopupView alert:contentView inView:[UIApplication sharedApplication].keyWindow];
//    }
    
//    return nil;
    
}

+ (PopupView *)alertInWindow:(PopupContentView *)contentView withAnimation:(void (^)(void))animation
{
    return [PopupView alert:contentView inView:[UIApplication sharedApplication].keyWindow withAnimation:animation];
}


+ (PopupView *)tipInWindow:(PopupContentView *)contentView
{
    return [PopupView tip:contentView inView:[UIApplication sharedApplication].keyWindow];
}

+ (PopupView *)tipInWindow:(PopupContentView *)contentView withAnimation:(void (^)(void))animation
{
    return [PopupView tip:contentView inView:[UIApplication sharedApplication].keyWindow withAnimation:animation];
}

+ (PopupView *)tip:(PopupContentView *)contentView inView:(UIView *)view
{
    PopupView *pop = [[PopupView alloc] initWithFrame:view.bounds];
    pop.dimBackground = NO;
    [pop setContentView:contentView];
    contentView.popupParent = pop;
    [view addSubview:pop];
    
    
    BOOL isAlert = [contentView isAlert];
    if (!isAlert)
    {
        [pop addGestures];
    }
    [pop relayoutFrameOfSubViews];
    [pop show:YES];
    
    return CommonReturnAutoReleased(pop);
}

+ (PopupView *)tip:(PopupContentView *)contentView inView:(UIView *)view withAnimation:(void (^)(void))animation
{
    PopupView *pop = [[PopupView alloc] initWithFrame:view.bounds];
    [pop setContentView:contentView];
    contentView.popupParent = pop;
    [view addSubview:pop];
    BOOL isAlert = [contentView isAlert];
    if (!isAlert)
    {
        [pop addGestures];
    }
    [pop relayoutFrameOfSubViews];
    [pop showWith:animation];
    return CommonReturnAutoReleased(pop);
}

- (void)setContentView:(UIView<PopupContentViewDelegate> *)contentView
{
    if (_contentView)
    {
        [_contentView removeFromSuperview];
    }
    
    _contentView = contentView;
    [self addSubview:contentView];
}

- (void)dealloc
{
	[self unregisterFromNotifications];
	[self unregisterFromKVO];
    CommonSuperDealloc();
    //	[super dealloc];
}




- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
    {
		// Set default values for properties
		self.animationType = EPopupViewAnimationFade;
		self.dimBackground = NO;
        _animationDuration = 0.3;
        
//		self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
//        | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
		// Transparent background
		self.backgroundColor = kAppModalDimbackgroundColor;
		self.alpha = 0;
		_rotationTransform = CGAffineTransformIdentity;
        
        
        [self setTransformForCurrentOrientation:NO];
        
		[self registerForKVO];
		[self registerForNotifications];
	}
	return self;
}

- (void)addGestures
{
    UITapGestureRecognizer *tapget = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBlank:)];
    tapget.delegate = self;
    tapget.numberOfTapsRequired = 1;
    tapget.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapget];
    CommonRelease(tapget);
//    [tapget release];
    
//    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeBlank:)];
//    swip.delegate = self;
//    [self addGestureRecognizer:swip];
//    [swip release];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return touch.view == self;
}
- (void)onTapBlank:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        [self.contentView onTouchBlank];
    }
}

//- (void)onSwipeBlank:(UISwipeGestureRecognizer *)ges
//{
//    if (ges.state == UIGestureRecognizerStateEnded) {
//        [self.contentView onTouchBlank];
//    }
//}


#pragma mark - Show & hide

- (void)show:(BOOL)animated
{
    [self showUsingAnimation:animated];
    [self setNeedsDisplay];
	
}

- (void)hide:(BOOL)animated
{
	[self hideUsingAnimation:animated];
}

#pragma mark - View Hierrarchy

- (void)didMoveToSuperview
{
	// We need to take care of rotation ourselfs if we're adding the HUD to a window
    [self setTransformForCurrentOrientation:NO];
}

#pragma mark - Internal show & hide operations

- (void)showWith:(void (^)(void))animations
{
    if (self.animationType == EPopupViewAnimationZoomIn)
    {
		self.transform = CGAffineTransformConcat(_rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
	}
    else if (_animationType == EPopupViewAnimationZoomOut)
    {
		self.transform = CGAffineTransformConcat(_rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
	}
    
    if (animations)
    {
        [UIView animateWithDuration:self.animationDuration animations:^{
            self.alpha = 1.0f;
            if (_animationType == EPopupViewAnimationZoomIn || _animationType == EPopupViewAnimationZoomOut)
            {
                self.transform = _rotationTransform;
            }
            animations();
        } completion:nil];
    }
    else
    {
        self.alpha = 1.0f;
		if (_animationType == EPopupViewAnimationZoomIn || _animationType == EPopupViewAnimationZoomOut)
        {
			self.transform = _rotationTransform;
		}
    }

}

- (void)setTransform:(CGAffineTransform)transform
{
    if ([self.superview isKindOfClass:[UIWindow class]]) {
        [super setTransform:transform];
    }
}


- (void)showUsingAnimation:(BOOL)animated
{
	if (animated && self.animationType == EPopupViewAnimationZoomIn)
    {
		self.transform = CGAffineTransformConcat(_rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
	}
    else if (animated && _animationType == EPopupViewAnimationZoomOut)
    {
		self.transform = CGAffineTransformConcat(_rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
	}
    
	// Fade in
	if (animated)
    {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:self.animationDuration];
		self.alpha = 1.0f;
		if (_animationType == EPopupViewAnimationZoomIn || _animationType == EPopupViewAnimationZoomOut)
        {
			self.transform = _rotationTransform;
		}
		[UIView commitAnimations];
	}
	else
    {
		self.alpha = 1.0f;
		if (_animationType == EPopupViewAnimationZoomIn || _animationType == EPopupViewAnimationZoomOut)
        {
			self.transform = _rotationTransform;
		}
	}
    [self setNeedsDisplay];

}

- (void)hideUsingAnimation:(BOOL)animated
{
	// Fade out
	if (animated)
    {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:self.animationDuration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideRemove)];
		// 0.02 prevents the hud from passing through touches during the animation the hud will get completely hidden
		// in the done method
		if (_animationType == EPopupViewAnimationZoomIn)
        {
			self.transform = CGAffineTransformConcat(_rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
		}
        else if (_animationType == EPopupViewAnimationZoomOut)
        {
			self.transform = CGAffineTransformConcat(_rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
		}
        
		self.alpha = 0.02f;
		[UIView commitAnimations];
	}
	else
    {
		self.alpha = 0.0f;
		[self removeFromSuperview];
	}
}

- (void)hideRemove
{
    [self removeFromSuperview];
}

#pragma mark - Layout

- (void)relayoutFrameOfSubViews
{
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	// Entirely cover the parent view
	UIView *parent = self.superview;
	if (parent)
    {
		self.frame = parent.bounds;
	}
    
    CGRect rect = [self.contentView showRect];
//    _contentView.transform = _rotationTransform;
    [self.contentView setFrameAndLayout:rect];
}

#pragma mark BG Drawing

- (void)drawRect:(CGRect)rect
{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
    
	if (self.dimBackground)
    {
		//Gradient colours
		size_t gradLocationsNum = 2;
		CGFloat gradLocations[2] = {0.0f, 1.0f};
        
		CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
        
		CGColorSpaceRelease(colorSpace);
		//Gradient center
		CGPoint gradCenter= CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		//Gradient radius
		float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
		//Gradient draw
		CGContextDrawRadialGradient (context, gradient, gradCenter, 0, gradCenter, gradRadius, kCGGradientDrawsAfterEndLocation);
		CGGradientRelease(gradient);
	}
	UIGraphicsPopContext();
}

#pragma mark - KVO

- (void)registerForKVO
{
	for (NSString *keyPath in [self observableKeypaths])
    {
		[self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)unregisterFromKVO
{
	for (NSString *keyPath in [self observableKeypaths]) {
		[self removeObserver:self forKeyPath:keyPath];
	}
}

- (NSArray *)observableKeypaths
{
	return @[@"contentView"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (![NSThread isMainThread])
    {
		[self performSelectorOnMainThread:@selector(updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
	}
    else
    {
		[self updateUIForKeypath:keyPath];
	}
}

- (void)updateUIForKeypath:(NSString *)keyPath
{
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

#pragma mark - Notifications

- (void)registerForNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceOrientationDidChange:)
			   name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)unregisterFromNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
	UIView *superview = self.superview;
	if (!superview)
    {
		return;
	}
    else if([superview isKindOfClass:[UIWindow class]])
    {
		[self setTransformForCurrentOrientation:YES];
	}
    else
    {
		self.frame = self.superview.bounds;
		[self setNeedsDisplay];
	}
}

- (void)setTransformForCurrentOrientation:(BOOL)animated
{
	// Stay in sync with the superview
	if (self.superview)
    {
		self.bounds = self.superview.bounds;
		[self setNeedsDisplay];
	}
	
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationUnknown || orientation == UIDeviceOrientationFaceUp ||
        orientation == UIDeviceOrientationFaceDown)
    {
        orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    }
	CGFloat radians = 0;
	if (UIDeviceOrientationIsLandscape(orientation))
    {
		if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            radians = -(CGFloat)M_PI_2;
        }
		else
        {
            radians = (CGFloat)M_PI_2;
        }
		// Window coordinates differ!
		self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
	}
    else
    {
		if (orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            radians = (CGFloat)M_PI;
        }
		else
        {
            radians = 0;
        }
        self.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
	}
	_rotationTransform = CGAffineTransformMakeRotation(radians);
	
	if (animated)
    {
		[UIView beginAnimations:nil context:nil];
	}
    
	[self setTransform:_rotationTransform];
    [self setNeedsDisplay];
	
    if (animated)
    {
		[UIView commitAnimations];
	}
}

@end
#endif