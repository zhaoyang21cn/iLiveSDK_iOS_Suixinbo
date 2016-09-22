//
//  AVIMCache.h
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

// 单种消息的缓存
// 固定capacity容量，不会自动增大
@interface AVIMCache : NSObject
{
@protected
    NSUInteger          _capacity;      // cache的容量
    NSMutableArray      *_cahceQueue;   // 缓存队列
}

- (instancetype)initWith:(NSUInteger)capacity;

- (NSUInteger)count;

// 当超过capacity会把lastobject移除，并insert obj到0位置
- (void)enCache:(id)obj;

- (id)deCache;

- (void)clear;

@end

// 会自动增长
@interface AVIMMutableCache : AVIMCache

@end
