//
//  MenuButton.h
//  CommonLibrary
//
//  Created by AlexiChen on 14-1-17.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MenuAbleItem.h"
#import "MenuItem.h"

@interface MenuButton : UIButton<MenuAbleItem>

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *title;

- (instancetype)initWithTitle:(NSString *)title action:(MenuAction)action;

- (instancetype)initWithBackground:(UIImage *)icon action:(MenuAction)action;

- (instancetype)initWithMenu:(MenuItem *)item;

- (void)setClickAction:(MenuAction)action;

// protected
- (void)onClick:(id)sender;

@end