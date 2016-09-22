//
//  MenuAbleItem.h
//  CommonLibrary
//
//  Created by Alexi on 14-1-16.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MenuAbleItem;

typedef void (^MenuAction)(id<MenuAbleItem> menu);

@protocol MenuAbleItem <NSObject>


- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon action:(MenuAction)action;

@optional
- (NSString *)title;
- (UIImage *)icon;
- (void)menuAction;
- (NSInteger)tag;
- (void)setTag:(NSInteger)tag;

@optional
- (UIColor *)foreColor;

@end
