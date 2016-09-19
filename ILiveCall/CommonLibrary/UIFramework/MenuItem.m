//
//  MenuItem.m
//  CommonLibrary
//
//  Created by Alexi on 14-1-16.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//

#import "MenuItem.h"

@implementation MenuItem

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon action:(MenuAction)action
{
    if (self = [super init]) {
        self.title = title;
        self.icon = icon;
        self.action = action;
    }
    return self;
}

- (void)menuAction
{
    if (_action)
    {
        _action(self);
    }
    
}

@end
