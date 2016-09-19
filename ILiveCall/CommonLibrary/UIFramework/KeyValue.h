//
//  KeyValue.h
//  CommonLibrary
//
//  Created by Alexi on 14-7-22.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KeyValueAble;
typedef void (^KeyValueAction)(id<KeyValueAble> menu);

@protocol KeyValueAble <NSObject>

@property (nonatomic, copy)     NSString    *key;

@property (nonatomic, strong)   id          value;

- (void)keyValueAction;

@end


@interface KeyValue : NSObject<KeyValueAble>

@property (nonatomic, copy) NSString *key;

@property (nonatomic, strong) id value;

@property (nonatomic, copy) KeyValueAction action;

+ (instancetype)key:(NSString *)key value:(id)value;

- (instancetype)initWithKey:(NSString *)key value:(id)value;

- (instancetype)initWithKey:(NSString *)key value:(id)value action:(KeyValueAction)action;

@end
