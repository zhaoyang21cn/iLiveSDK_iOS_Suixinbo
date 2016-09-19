//
//  UIViewController+Layout.h
//  CommonLibrary
//
//  Created by Alexi on 3/13/14.
//  Copyright (c) 2014 Alexi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AsChild)

- (void)setAsChild:(BOOL)asChild;

- (BOOL)asChild;

- (void)setChildSize:(CGSize)childSize;

- (CGSize)childSize;

@end

@interface UIViewController (Layout)

// 界面进入时重新布局
- (void)layoutOnViewWillAppear;

- (void)layoutSubviewsFrame;

- (void)layoutOnIPhone;

- (void)layoutOnIPadInPortrait;

- (void)layoutOnIPadInLandScape;

- (void)addOwnViews;

- (void)configOwnViews;


@end

//@interface UIViewController (DeviceListChangeNotify)
//
//- (void)addDeviceListChangeObserver;
//- (void)onDeviceListChanged;
//
//@end

@interface UITabBarController (Layout)

@end

