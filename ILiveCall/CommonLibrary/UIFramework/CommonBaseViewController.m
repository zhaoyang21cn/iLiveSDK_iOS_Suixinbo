//
//  CommonBaseViewController.m
//  CommonLibrary
//
//  Created by Alexi Chen on 2/28/13.
//  Copyright (c) 2013 AlexiChen. All rights reserved.
//

#import "CommonBaseViewController.h"

#import "UIViewController+Layout.h"

#import "IOSDeviceConfig.h"


@implementation CommonBaseViewController

- (instancetype)init
{
    if (self = [super init])
    {
        [self configParams];
    }
    
    return  self;
}

- (void)configParams
{
    
}

#pragma mark -
#pragma Rotate Methods

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self layoutOnViewWillAppear];
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self layoutOnViewWillAppear];
}

- (BOOL)shouldAutorotate
{
    BOOL isPad = [IOSDeviceConfig sharedConfig].isIPad;

    if (isPad)
    {
        [self layoutSubviewsFrame];
    }
    
    return isPad;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self shouldAutorotate];
}

//- (NSUInteger)supportedInterfaceOrientations
//{
//    return [self.viewControllers.lastObject supportedInterfaceOrientations];
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    [self layoutSubviewsFrame];
//}



- (BOOL)sameWithIOS6
{
    return YES;
}

- (void)configContainer
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kAppBakgroundColor;
    
    
//    if ([self sameWithIOS6])
//    {
//        if ([IOSDeviceConfig sharedConfig].isIOS7)
//        {
//            self.edgesForExtendedLayout = UIRectEdgeNone;
//            self.extendedLayoutIncludesOpaqueBars = NO;
//            self.modalPresentationCapturesStatusBarAppearance = NO;
//        }
//    }
//    
    [self configContainer];
    
    if ([self isAutoLayout])
    {
        [self autoLayoutOwnViews];
    }
    else
    {
        if ([self hasBackgroundView])
        {
            [self addBackground];
            
            [self configBackground];
        }
        
        
        // 在此外添加界面的各个控件
        [self addOwnViews];
        
        // 在此设置各个控件的值
        [self configOwnViews];
        
        // 对自身的控件进行设置区域
        [self layoutSubviewsFrame];
//        _statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
//        app.isPortrait = UIInterfaceOrientationIsPortrait(intf);
    }
}

- (BOOL)hasBackgroundView
{
    return NO;
}

- (void)addBackground
{
    _backgroundView = [[UIImageView alloc] init];
    [self.view addSubview:_backgroundView];
    CommonRelease(_backgroundView);
}

- (void)configBackground
{
    IOSDeviceConfig *ios = [IOSDeviceConfig sharedConfig];
    if (ios.isIPhone5)
    {
//        UIImage *bg = UIImageNamed(kAppBgImg);
//        _backgroundView.image = bg;
    }
    else
    {
        _backgroundView.backgroundColor = [UIColor flatWhiteColor];
    }
}



#pragma mark -
#pragma Layout Methods

- (void)layoutBackground
{
    _backgroundView.frame = self.view.bounds;
}

- (void)viewWillLayoutSubviews
{
    if (![self asChild])
    {
        [super viewWillLayoutSubviews];
    }
    else
    {
        if (CGSizeEqualToSize(self.childSize, CGSizeZero))
        {
            [super viewWillLayoutSubviews];
        }
        else
        {
            CGSize size = [self childSize];
            self.view.bounds = CGRectMake(0, 0, size.width, size.height);
        }
    }
}


- (void)layoutSubviewsFrame
{
    if ([self isAutoLayout])
    {
        return;
    }
    
    if ([self hasBackgroundView])
    {
        [self layoutBackground];
    }
    [super layoutSubviewsFrame];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

@end

@implementation CommonBaseViewController (AutoLayout)

// 是否支持autoLayout
- (BOOL)isAutoLayout
{
    return NO;
}

// 添加自动布局相关的constraints
- (void)autoLayoutOwnViews
{
    // 添加自动布局相关的内容
}

@end
