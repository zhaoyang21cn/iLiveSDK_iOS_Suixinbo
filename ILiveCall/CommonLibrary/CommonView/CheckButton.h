//
//  CheckButton.h
//  CommonLibrary
//
//  Created by Alexi on 14-1-19.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//
#if kSupportUnusedCommonView
#import <UIKit/UIKit.h>

#import "MenuButton.h"

@class CheckButton;

typedef void (^CheckButtonAction)(CheckButton *btn);

@interface CheckButton : UIControl

@property (nonatomic, strong) MenuButton *button;
@property (nonatomic, strong) UILabel *title;

@property (nonatomic, assign) BOOL isCheck;

@property (nonatomic, copy) CheckButtonAction checkAction;


- (instancetype)initNormal:(UIImage *)image selectedImage:(UIImage *)simage title:(NSString *)title checkAction:(CheckButtonAction)action;

@end
#endif