//
//  CommonBaseViewController.h
//  CommonLibrary
//
//  Created by Alexi Chen on 2/28/13.
//  Copyright (c) 2013 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonBaseViewController : UIViewController
{
@protected
    UIImageView *_backgroundView;
}

@property (nonatomic, strong) UIImageView           *backgroundView;

@property (nonatomic, assign) BOOL asChild;
@property (nonatomic, assign) CGSize childSize;

// 是否有背景图
- (BOOL)hasBackgroundView;

// 样式是否与iOS6之前一致
- (BOOL)sameWithIOS6;

// 配置界面的初始化的参数
- (void)configParams;

// hasBackgroundView 返回YES, 使用此方法添加背景
- (void)addBackground;

- (void)configContainer;
// 有背景时，使用此方法配置背景
- (void)configBackground;

// 有背景时，布局背景
- (void)layoutBackground;

//// 布局子控件
//- (void)layoutSubviewsFrame;

@end

@interface CommonBaseViewController (AutoLayout)

// 是否支持autoLayout
- (BOOL)isAutoLayout;

// 添加自动布局相关的constraints
- (void)autoLayoutOwnViews;

@end