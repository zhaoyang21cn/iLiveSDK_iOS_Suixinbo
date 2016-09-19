//
//  KeyChainHelper.h
//  CommonLibrary
//
//  Created by Alexi on 14-2-19.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//
#if kSupportKeyChainHelper
#import <Foundation/Foundation.h>



@interface KeyChainHelper : NSObject

+ (void)addService:(NSString *)service withKey:(NSString *)key;

+ (NSString *)serviceForKey:(NSString *)key;

@end
#endif