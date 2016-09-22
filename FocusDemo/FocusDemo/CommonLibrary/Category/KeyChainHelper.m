//
//  KeyChainHelper.m
//  CommonLibrary
//
//  Created by Alexi on 14-2-19.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//
#if kSupportKeyChainHelper

#import "KeyChainHelper.h"
#import <Security/Security.h>
#import <Security/SecItem.h>


#if __has_feature(objc_arc)
#error KeyChainHelper does not support Objective-C Automatic Reference Counting (ARC)
#endif

@implementation KeyChainHelper

+ (NSMutableDictionary *)getKeyChainQuery:(NSString *)service
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassGenericPassword,(id)kSecClass, service, (id)kSecAttrService, service, (id)kSecAttrAccount, (id)kSecAttrAccessibleAfterFirstUnlock, (id)kSecAttrAccessible,
            nil];
}


+ (void)addService:(NSString *)service withKey:(NSString *)key;
{
    NSMutableDictionary *keychainQuery = [self getKeyChainQuery:key];
    SecItemDelete((CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:service] forKey:(id)kSecValueData];
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (NSString *)serviceForKey:(NSString *)key;
{
    NSString* ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeyChainQuery:key];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr)
    {
        @try
        {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)keyData];
        }
        @catch (NSException *e)
        {
            DebugLog(@"Unarchive of %@ failed: %@", key, e);
        }
        @finally
        {
        }
    }
    if (keyData)
    {
        CFRelease(keyData);
    }
    return ret;
}

@end

#endif