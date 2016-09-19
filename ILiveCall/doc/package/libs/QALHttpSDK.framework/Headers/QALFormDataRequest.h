//
//  QALFormDataRequest.h
//  QALHttpSDK
//
//  Created by wtlogin on 15/10/10.
//  Copyright (c) 2015年 tencent. All rights reserved.
//

#import "QALHttpRequest.h"

@interface QALFormDataRequest : QALHttpRequest

/*
 设置key-value对的字符集
 @param charSet 字符集
 */
- (void)setCharSet:(NSString *)charSet;

/*
 增加post key-value
 @param value post value
 @param key post key
 */
- (void)addPostValue:(NSData*)value forKey:(NSData *)key;

@end
