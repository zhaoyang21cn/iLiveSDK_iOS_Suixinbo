//
//  CLSafeMutableArray.h
//  TIMChat
//
//  Created by AlexiChen on 16/2/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <pthread.h>
#import <libkern/OSAtomic.h>
#import <objc/message.h>

@interface CLSafeMutableArray : NSObject
{
@protected
//    pthread_mutex_t     _mutex;
    NSMutableArray      *_safeArray;
    OSSpinLock          _lock;
}

@property (nonatomic, strong) NSMutableArray *safeArray;

- (id)objectAtIndex:(NSUInteger)index;

- (BOOL)containsObject:(id)anObject;

- (NSUInteger)indexOfObject:(id)obj;

- (void)addObject:(id)anObject;

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;;
- (void)removeObjectAtIndex:(NSUInteger)index;;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

- (void)insertObjectsFromArray:(NSArray *)otherArray atIndex:(NSInteger)index;
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)removeAllObjects;
- (void)removeObject:(id)anObject inRange:(NSRange)range;
- (void)removeObject:(id)anObject;
- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range;
- (void)removeObjectIdenticalTo:(id)anObject;
- (void)removeObjectsInArray:(NSArray *)otherArray;
- (void)removeObjectsInRange:(NSRange)range;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray;
- (void)setArray:(NSArray *)otherArray;

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects;

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

- (NSInteger)count;

@end

// 增加去重操作
@interface CLSafeSetArray : CLSafeMutableArray

@end
