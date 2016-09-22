//
//  CLSafeMutableArray.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "CLSafeMutableArray.h"

@implementation CLSafeMutableArray


- (void)dealloc
{
//    pthread_mutex_destroy(&_mutex);
}

- (instancetype)init
{
    if (self = [super init])
    {
//        pthread_mutex_init(&_mutex, NULL);
        _safeArray = [NSMutableArray array];
        _lock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (void)lock
{
//    pthread_mutex_lock(&_mutex);
    OSSpinLockLock(&_lock);
}

- (void)unlock
{
//    pthread_mutex_unlock(&_mutex);
     OSSpinLockUnlock(&_lock);
}

- (void)addObject:(id)anObject
{
    [self lock];
    [_safeArray addObject:anObject];
    [self unlock];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [self lock];
    [_safeArray insertObject:anObject atIndex:index];
    [self unlock];

}
- (void)removeLastObject;
{
    [self lock];
    [_safeArray removeLastObject];
    [self unlock];
}
- (void)removeObjectAtIndex:(NSUInteger)index;
{
    [self lock];
    [_safeArray removeObjectAtIndex:index];
    [self unlock];
}
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [self lock];
    [_safeArray replaceObjectAtIndex:index withObject:anObject];
    [self unlock];
}


- (void)insertObjectsFromArray:(NSArray *)otherArray atIndex:(NSInteger)index
{
    NSInteger count = _safeArray.count;
    if (count == 0)
    {
        [self lock];
        [_safeArray addObjectsFromArray:otherArray];
        [self unlock];
    }
    else
    {
    if (index >= 0 && index < count && otherArray.count > 0)
    {
        [self lock];
        
        for (NSInteger i = otherArray.count - 1; i >= 0; i--)
        {
            [_safeArray insertObject:otherArray[i] atIndex:index];
        }
        [self unlock];
    }
    }
}

- (void)addObjectsFromArray:(NSArray *)otherArray
{
    [self lock];
    [_safeArray addObjectsFromArray:otherArray];
    [self unlock];

}
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
    [self lock];
    [_safeArray exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    [self unlock];
}
- (void)removeAllObjects
{
    [self lock];
    [_safeArray removeAllObjects];
    [self unlock];
}
- (void)removeObject:(id)anObject inRange:(NSRange)range
{
    [self lock];
    [_safeArray removeObject:anObject inRange:range];
    [self unlock];
}
- (void)removeObject:(id)anObject
{
    [self lock];
    [_safeArray removeObject:anObject];
    [self unlock];
}
- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range
{
    [self lock];
    [_safeArray removeObjectIdenticalTo:anObject inRange:range];
    [self unlock];
}
- (void)removeObjectIdenticalTo:(id)anObject
{
    [self lock];
    [_safeArray removeObjectIdenticalTo:anObject];
    [self unlock];
}

- (void)removeObjectsInArray:(NSArray *)otherArray
{
    [self lock];
    [_safeArray removeObjectsInArray:otherArray];
    [self unlock];
}
- (void)removeObjectsInRange:(NSRange)range
{
    [self lock];
    [_safeArray removeObjectsInRange:range];
    [self unlock];
}
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange
{
    [self lock];
    [_safeArray replaceObjectsInRange:range withObjectsFromArray:otherArray range:range];
    [self unlock];
}
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray
{
    [self lock];
    [_safeArray replaceObjectsInRange:range withObjectsFromArray:otherArray];
    [self unlock];
}
- (void)setArray:(NSArray *)otherArray
{
    [self lock];
    [_safeArray setArray:otherArray];
    [self unlock];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    [self lock];
    [_safeArray insertObjects:objects atIndexes:indexes];
    [self unlock];
}
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    [self lock];
    [_safeArray removeObjectsAtIndexes:indexes];
    [self unlock];
}
- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    [self lock];
    [_safeArray replaceObjectsAtIndexes:indexes withObjects:objects];
    [self unlock];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0)
{
    [self lock];
    [_safeArray setObject:obj atIndexedSubscript:idx];
    [self unlock];
}

- (NSInteger)count
{
    return _safeArray.count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [_safeArray objectAtIndex:index];
}

- (NSUInteger)indexOfObject:(id)obj
{
    return [_safeArray indexOfObject:obj];
}

- (BOOL)containsObject:(id)anObject
{
    return [_safeArray containsObject:anObject];
}

@end


@implementation CLSafeSetArray

- (void)addObject:(id)anObject
{
    [self lock];
    NSUInteger idx = [_safeArray indexOfObject:anObject];
    if (idx < _safeArray.count)
    {
        [_safeArray replaceObjectAtIndex:idx withObject:anObject];
    }
    else
    {
        [_safeArray addObject:anObject];
    }
    [self unlock];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [self lock];
    
    NSUInteger idx = [_safeArray indexOfObject:anObject];
    if (idx < _safeArray.count && idx != index)
    {
        [_safeArray replaceObjectAtIndex:idx withObject:anObject];
    }
    else
    {
        [_safeArray insertObject:anObject atIndex:index];
    }

    [self unlock];
}
@end
