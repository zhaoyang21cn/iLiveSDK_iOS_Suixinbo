//
//  UITextField+UITextField_Tip.m
//  CommonLibrary
//
//  Created by Alexi on 15-1-7.
//  Copyright (c) 2015年 Alexi Chen. All rights reserved.
//

#import "UITextField+UITextField_Tip.h"
#import "FontHelper.h"

#import "UILabel+InitMethod.h"
#import "UILabel+Common.h"


#import "MenuButton.h"

@implementation UITextField (UITextField_Tip)

+ (instancetype)textFieldWithTip:(NSString *)tip size:(CGSize)tipSize;
{
    UITextField *input = [[UITextField alloc] init];
    input.backgroundColor = [UIColor clearColor];
    input.textAlignment = NSTextAlignmentLeft;
    input.keyboardType = UIKeyboardTypeDefault;
    input.returnKeyType = UIReturnKeyDone;
    input.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    input.borderStyle = UITextBorderStyleNone;
    input.font = [[FontHelper shareHelper] textFont];
    
    input.leftViewMode = UITextFieldViewModeAlways;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tipSize.width, tipSize.height)];
    label.text = tip;
    label.backgroundColor = [UIColor clearColor];
    input.leftView = label;
    label.textAlignment = NSTextAlignmentRight;
    label.font = [[FontHelper shareHelper] textFont];
    CommonRelease(label);
    
    return CommonReturnAutoReleased(input);
    
}


- (void)addLeftTip:(NSString *)left
{
    self.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *lb= [UILabel labelWith:left];
    lb.textColor = kMainTextColor;
    lb.font = kCommonMiddleTextFont;
    CGSize size = [lb textSizeIn:CGSizeMake(320, 320)];
    lb.frame = CGRectMake(0, 0, size.width, size.height);
    self.leftView = lb;
}


- (void)addLeftIcon:(UIImage *)left
{
    self.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *lb= [[UIImageView alloc] init];
    lb.image = left;
    lb.frame = CGRectMake(0, 0, left.size.width, left.size.height);
    self.leftView = lb;
}

- (void)addRightTip:(NSString *)right action:(CommonBlock)action
{
    self.rightViewMode = UITextFieldViewModeAlways;
    
    MenuButton *btn = nil;
    
    if (action)
    {
        __weak UITextField *ws = self;
        btn = [[MenuButton alloc] initWithTitle:right action:^(id<MenuAbleItem> menu) {
            action(ws);
        }];
    }
    else
    {
        btn = [[MenuButton alloc] initWithTitle:right action:nil];
    }

    CGSize size = [btn.titleLabel textSizeIn:CGSizeMake(320, 320)];
    size.width += 16;
    btn.frame = CGRectMake(0, 0, size.width, size.height);
    self.rightView = btn;
}

- (void)addRightImage:(UIImage *)right action:(CommonBlock)action
{
    self.rightViewMode = UITextFieldViewModeAlways;
    
    MenuButton *btn = nil;

    if (action)
    {
        __weak UITextField *ws = self;
        btn = [[MenuButton alloc] initWithTitle:nil icon:right action:^(id<MenuAbleItem> menu) {
            action(ws);
        }];
    }
    else
    {
        btn = [[MenuButton alloc] initWithTitle:nil icon:right action:nil];
    }
    CGSize size = right.size;
    size.width += 16;
    btn.frame = CGRectMake(0, 0, size.width, size.height);
    self.rightView = btn;
}

- (instancetype)initLeftWith:(NSString *)left
{
    if (self = [self init])
    {
        self.font = kCommonMiddleTextFont;
        [self addLeftTip:left];
    }
    return self;
}

- (instancetype)initLeftWith:(NSString *)left margin:(CGFloat)margin
{
    if (self = [self init])
    {
        self.font = kCommonMiddleTextFont;
        self.leftViewMode = UITextFieldViewModeAlways;
        
        UILabel *lb= [UILabel labelWith:left];
        lb.textColor = kMainTextColor;
        lb.font = kCommonMiddleTextFont;
        CGSize size = [lb textSizeIn:CGSizeMake(320, 320)];
        lb.frame = CGRectMake(0, 0, size.width + 2*margin, size.height);
        self.leftView = lb;
    }
    return self;

}

- (instancetype)initLeftIconWith:(UIImage *)left
{
    if (self = [self init])
    {
        [self addLeftIcon:left];
    }
    return self;
}

- (instancetype)initLeftWith:(NSString *)left rightWith:(NSString *)right
{
    return [self initLeftWith:left rightWith:right action:nil];
}

- (instancetype)initLeftWith:(NSString *)left rightWith:(NSString *)right action:(CommonBlock)action
{
    if (self = [self initLeftWith:left])
    {
        [self addRightTip:right action:action];
    }
    return self;
}

- (instancetype)initLeftWith:(NSString *)left rightImageWith:(UIImage *)right action:(CommonBlock)action
{
    if (self = [self initLeftWith:left])
    {
        [self addRightImage:right action:action];
    }
    return self;
}

@end
