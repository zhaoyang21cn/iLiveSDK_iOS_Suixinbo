//
//  TCIMemoItem.m
//  ILiveSDK
//
//  Created by AlexiChen on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCIMemoItem.h"

@implementation TCIMemoItem


// 创建占位记录
- (instancetype)initWithShowRect:(CGRect)rect
{
    return [self initWith:nil showRect:rect];
}

// 创建真实记录
- (instancetype)initWith:(NSString *)uid showRect:(CGRect)rect
{
    if (self = [super init])
    {
        _identifier = uid;
        _showRect = rect;
    }
    return self;
}

- (BOOL)isPlaceholder
{
    return _identifier.length == 0;
}

- (BOOL)isValid
{
    return !CGRectIsEmpty(_showRect);
}

@end
