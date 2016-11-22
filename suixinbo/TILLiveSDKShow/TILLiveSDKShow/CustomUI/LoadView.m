//
//  LoadView.m
//  iOS9Demo
//
//  Created by wilderliao on 16/11/10.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LoadView.h"

#import "AppDelegate.h"

@interface LoadView ()
{
    UIActivityIndicatorView *_activity;
    UILabel *_label;
}

@end

@implementation LoadView

+ (instancetype)loadViewWith:(NSString *)msg
{
    LoadView *loadView = [[LoadView alloc] init];
    [loadView relayout:msg];
    return loadView;
}

- (instancetype)init
{
    if (self = [super init])
    {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        [self setFrame:screenRect];
        self.backgroundColor = [UIColor clearColor];
        [self alertView];
    }
    return self;
}

- (UIView *)alertView
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat screenW = screenRect.size.width;
    CGFloat screenH = screenRect.size.height;
    
    CGFloat alertViewSide = 90;
    
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake((screenW-alertViewSide)/2, (screenH-alertViewSide)/2, alertViewSide, alertViewSide)];
    alertView.backgroundColor = [UIColor lightGrayColor];
    alertView.layer.cornerRadius = 10;
    
    [self addSubview:alertView];
    
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activity.center = alertView.center;
    [alertView addSubview:_activity];
    
    _label = [[UILabel alloc] init];
    _label.font = [UIFont systemFontOfSize:12];
    _label.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:_label];
    
    return self;
}

- (void)relayout:(NSString *)msg
{
    CGFloat alertViewSide = 90;
    
    CGFloat activitySide = 50;
    CGFloat labelH = 30;
    
    CGFloat activityY;
    if (msg && msg.length > 0)
    {
        activityY = (alertViewSide-labelH-activitySide)/2;
    }
    else
    {
        activityY = (alertViewSide-activitySide)/2;
    }
    [_activity setFrame:CGRectMake((alertViewSide-activitySide)/2, activityY, activitySide, activitySide)];
    
    if (msg && msg.length > 0)
    {
        [_label setFrame:CGRectMake(0, activityY+activitySide, alertViewSide, labelH)];
        _label.text = msg;
    }
    else
    {
        [_label setFrame:CGRectZero];
        _label.text = nil;
    }
    
    [_activity startAnimating];
}

@end
