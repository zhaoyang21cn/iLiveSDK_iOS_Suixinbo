//
//  UITextField+UITextField_Tip.h
//  CommonLibrary
//
//  Created by Alexi on 15-1-7.
//  Copyright (c) 2015年 Alexi Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSObject+CommonBlock.h"

@interface UITextField (UITextField_Tip)

+ (instancetype)textFieldWithTip:(NSString *)tip size:(CGSize)tipSize;

- (void)addLeftTip:(NSString *)left;

- (void)addRightTip:(NSString *)right action:(CommonBlock)action;

- (void)addRightImage:(UIImage *)right action:(CommonBlock)action;

- (instancetype)initLeftWith:(NSString *)left;

- (instancetype)initLeftWith:(NSString *)left margin:(CGFloat)margin;

- (instancetype)initLeftIconWith:(UIImage *)left;

- (instancetype)initLeftWith:(NSString *)left rightWith:(NSString *)right;

- (instancetype)initLeftWith:(NSString *)left rightWith:(NSString *)right action:(CommonBlock)action;

- (instancetype)initLeftWith:(NSString *)left rightImageWith:(UIImage *)right action:(CommonBlock)action;


@end
