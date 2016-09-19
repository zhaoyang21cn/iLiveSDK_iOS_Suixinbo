//
//  LiveCallPlatform.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/18.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "LiveCallPlatform.h"

@implementation LiveCallPlatform
{
    BOOL _isChat;
}

static LiveCallPlatform * g_sharedLiveCallPlatform = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_sharedLiveCallPlatform = [[LiveCallPlatform alloc] init];
        g_sharedLiveCallPlatform->_isChat = NO;
    });
    
    return g_sharedLiveCallPlatform;
}


#define kLiveCallPlatformAutoLoginKey @"LiveCallPlatformAutoLoginKey"
#define kLiveCallPlatformLoginParamKey @"LiveCallPlatformLoginParamKey"

- (BOOL)isAutoLogin
{
    NSNumber * isAuto = [[NSUserDefaults standardUserDefaults] objectForKey:kLiveCallPlatformAutoLoginKey];
    if (isAuto) {
        return [isAuto boolValue];
    }
    else {
        return NO;
    }
}

- (void)setAutoLogin:(BOOL)value
{
    NSNumber * isAuto = [NSNumber numberWithBool:value];
    [[NSUserDefaults standardUserDefaults] setObject:isAuto forKey:kLiveCallPlatformAutoLoginKey];
}

- (LiveCallLoginParam*)loadLoginParam
{
    NSString * strParam = [[NSUserDefaults standardUserDefaults] objectForKey:kLiveCallPlatformLoginParamKey];
    LiveCallLoginParam * param = [NSObject parse:[LiveCallLoginParam class] jsonString:strParam];
    return param;
}

- (void)saveLoginParam:(LiveCallLoginParam *)param
{
    id dic = [param serializeToJsonObject];
    if ([NSJSONSerialization isValidJSONObject:dic])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        if(error)
        {
            DebugLog(@"存储失败");
        }
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:kLiveCallPlatformLoginParamKey];
    }
}

- (void)setChat:(BOOL)isChat
{
    _isChat = isChat;
}

- (BOOL)isChat
{
    return _isChat;
}

@end
