//
//  AVIMCache.m
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AVIMCache.h"

@implementation AVIMCache

- (instancetype)initWith:(NSUInteger)capacity
{
    if (self = [super init])
    {
        _capacity = capacity;
        _cahceQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)count
{
    return [_cahceQueue count];
}

- (void)enCache:(id)obj
{
    if (obj)
    {    
        if ([_cahceQueue count] == _capacity)
        {
            [_cahceQueue removeObjectAtIndex:0];
        }
        [_cahceQueue addObject:obj];
    }
}

- (id)deCache
{
    if (_cahceQueue.count)
    {
        id obj = [_cahceQueue objectAtIndex:0];
        [_cahceQueue removeObjectAtIndex:0];
        return obj;
    }
    return nil;
}

- (void)clear
{
    [_cahceQueue removeAllObjects];
}
@end

// 会自动增长
@implementation AVIMMutableCache

- (void)enCache:(id)obj
{
    if (obj)
    {
        [_cahceQueue addObject:obj];
    }
}

- (void)clear
{
    [_cahceQueue removeAllObjects];
}

@end
