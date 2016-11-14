//
//  NSMutableDictionary+Json.h
//  CommonLibrary
//
//  Created by Alexi on 14-1-16.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Json)

- (void)addString:(NSString *)aValue forKey:(id<NSCopying>)aKey;

- (void)addInteger:(NSInteger)aValue forKey:(id<NSCopying>)aKey;

- (void)addCGFloat:(CGFloat)aValue forKey:(id<NSCopying>)aKey;

- (void)addBOOL:(BOOL)aValue forKey:(id<NSCopying>)aKey;

- (void)addBOOLStr:(BOOL)aValue forKey:(id<NSCopying>)aKey;

- (void)addNumber:(NSNumber *)aValue forKey:(id<NSCopying>)aKey;

- (void)addArray:(NSArray *)aValue forKey:(id<NSCopying>)aKey;

- (NSString *)convertToJSONString;

//- (id)jsonObjectForKey:(id<NSCopying>)key;

@end

@interface NSDictionary (Json)

//- (id)jsonObjectForKey:(id<NSCopying>)key;

- (NSMutableDictionary *)dictionaryForKey:(id<NSCopying>)key;
- (NSString *)stringForKey:(id<NSCopying>)key;
- (NSInteger)integerForKey:(id<NSCopying>)key;
- (BOOL)boolForKey:(id<NSCopying>)key;
- (CGFloat)floatForKey:(id<NSCopying>)key;
- (double)doubleForKey:(id<NSCopying>)key;
- (NSMutableArray *)arrayForKey:(id<NSCopying>)key;

@end


