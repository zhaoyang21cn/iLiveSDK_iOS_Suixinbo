//
//  MenuButton.m
//  CommonLibrary
//
//  Created by AlexiChen on 14-1-17.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//

#import "MenuButton.h"

@interface MenuButton ()

@property (nonatomic, copy) MenuAction action;

@end

@implementation MenuButton

- (instancetype)initWithMenu:(MenuItem *)item
{
    return [self initWithTitle:item.title icon:item.icon action:item.action];
}

- (instancetype)initWithTitle:(NSString *)title action:(MenuAction)action
{
    return [self initWithTitle:title icon:nil action:action];
}

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon action:(MenuAction)action
{
    if (self = [super init])
    {
        self.title = title;
        self.icon = icon;
        self.action = action;
        [self setTitle:title forState:UIControlStateNormal];
//        self.titleLabel.font = [UIFont systemFontOfSize:16];
       
        [self setImage:icon forState:UIControlStateNormal];
        [self addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (instancetype)initWithBackground:(UIImage *)icon action:(MenuAction)action
{
    if (self = [super init])
    {
        self.icon = icon;
        self.action = action;
        [self setBackgroundImage:icon forState:UIControlStateNormal];
        [self addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


- (void)setClickAction:(MenuAction)action
{
    self.action = action;
    [self addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onClick:(id)sender
{
    if (_action) {
        _action(self);
    }
    
}
@end
