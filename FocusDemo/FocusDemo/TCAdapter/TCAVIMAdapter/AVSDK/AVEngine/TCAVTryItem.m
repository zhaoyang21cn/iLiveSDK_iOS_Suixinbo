//
//  TCAVTryItem.m
//  TCShow
//
//  Created by AlexiChen on 16/5/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVTryItem.h"

@implementation TCAVTryItem

- (instancetype)initWith:(NSInteger)index
{
    if (self = [super init])
    {
        _tryIndex = index;
        _hasTryCount = 0;
        _maxTryCount = 1;
    }
    return self;
}


@end
