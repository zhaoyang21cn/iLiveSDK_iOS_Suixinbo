
//
//  KeyValue.m
//  CommonLibrary
//
//  Created by Alexi on 14-7-22.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//

#import "KeyValue.h"

@implementation KeyValue

+ (instancetype)key:(NSString *)key value:(id)value
{
    return [[KeyValue alloc] initWithKey:key value:value];
}

- (instancetype)initWithKey:(NSString *)key value:(id)value
{
    return [self initWithKey:key value:value action:nil];
}

- (instancetype)initWithKey:(NSString *)key value:(id)value action:(KeyValueAction)action
{
    if (self = [super init])
    {
        self.key = key;
        self.value = value;
        self.action = action;
    }
    return self;
}
- (void)keyValueAction
{
    if (_action)
    {
        _action(self);
    }
}
@end
