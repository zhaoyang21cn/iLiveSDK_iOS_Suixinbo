
//
//  CheckButton.m
//  CommonLibrary
//
//  Created by Alexi on 14-1-19.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//
#if kSupportUnusedCommonView
#import "CheckButton.h"

#import "UILabel+Common.h"
#import "UIView+CustomAutoLayout.h"

//@interface CheckButton ()
//
//@property (nonatomic, strong) MenuButton *button;
//@property (nonatomic, strong) UILabel *title;
//
//@property (nonatomic, copy) CheckButtonAction checkAction;
//
//@end

@implementation CheckButton


- (void)setIsCheck:(BOOL)isCheck
{
    _button.selected = isCheck;
}

- (BOOL)isCheck
{
    return _button.selected;
}

- (void)onCheck
{
    _button.selected = !_button.selected;
    
    if (_checkAction) {
        _checkAction(self);
    }
}


- (instancetype)initNormal:(UIImage *)image selectedImage:(UIImage *)simage title:(NSString *)title checkAction:(CheckButtonAction)action
{
    if (self = [super init])
    {
        self.checkAction = action;
        
        __weak CheckButton *ws = self;
        self.button = [[MenuButton alloc] initWithTitle:nil icon:image action:^(id<MenuAbleItem> menu) {
            [ws onCheck];
        }];
        [self.button setImage:simage forState:UIControlStateSelected];
        [self.button setImage:simage forState:UIControlStateHighlighted];
        [self addSubview:_button];
        
//        if (title)
//        {
            self.title = [UILabel labelWithTitle:title];
            self.title.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_title];
//        }
        
        
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCheck)];
        [self addGestureRecognizer:ges];
    }
    return self;
}

- (BOOL)isSelected
{
    return _button.isSelected;
}

#define kCheckSize CGSizeMake(20, 20)

- (void)relayoutFrameOfSubViews
{
    if (self.title)
    {
        CGRect rect = self.bounds;
        
        CGRect chectRect = rect;
        chectRect.size.width = chectRect.size.height;
        
        const CGSize kSize = kCheckSize;
        _button.frame = CGRectInset(chectRect, (chectRect.size.width - kSize.width)/2, (chectRect.size.height - kSize.height)/2);
        
        rect.origin.x += chectRect.size.width;
        rect.size.width -= chectRect.size.width;
        _title.frame = rect;
    }
    else
    {
        [_button sizeWith:kCheckSize];
        [_button layoutParentCenter];
    }
}

@end
#endif