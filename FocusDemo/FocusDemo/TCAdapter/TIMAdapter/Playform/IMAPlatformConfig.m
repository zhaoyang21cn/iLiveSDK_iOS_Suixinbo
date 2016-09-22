//
//  IMAPlatformConfig.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAPlatformConfig.h"

@implementation IMAPlatformConfig

- (instancetype)init
{
    if (self = [super init])
    {
#if kAppStoreVersion
        // 默认正式环境
        _environment = 0;
        
        // 默认开起后台打印
        _enableConsoleLog = NO;
        
        //默认debug等级
        _logLevel = TIM_LOG_NONE;
#else
        // 默认正式环境
        _environment = 0;
        
#if DEBUG
        // 默认开起后台打印
        _enableConsoleLog = NO;

#else
        // 默认不起后台打印
        _enableConsoleLog = NO;
#endif
        
        //默认debug等级
        _logLevel = TIM_LOG_NONE;
#endif
    }
    return self;
}

- (void)chageEnvTo:(int)env
{
    if (_environment != env)
    {
        _environment = env;
        // 保存本地
        [self saveToLocal];
    }
}

- (void)chageEnableConsoleTo:(BOOL)enable
{
    if (_enableConsoleLog != enable)
    {
        _enableConsoleLog = enable;
        // 保存本地
        [self saveToLocal];
    }
}
- (void)chageLogLevelTo:(NSInteger)level
{
    if (_logLevel != level)
    {
        _logLevel = level;
        // 保存本地
        [self saveToLocal];
    }
}

- (NSString *)getLogLevelTip
{
    switch (_logLevel)
    {
        case TIM_LOG_NONE:
            return @"None";
            break;
        case TIM_LOG_ERROR:
            return @"Error";
            break;
        case TIM_LOG_WARN:
            return @"Warn";
            break;
        case TIM_LOG_INFO:
            return @"Info";
            break;
        case TIM_LOG_DEBUG:
            return @"Debug";
            break;
            
        default:
            return nil;
            break;
    }
}

+ (NSDictionary *)logLevelTips
{
    return @{@"None" : @(TIM_LOG_NONE), @"Error" : @(TIM_LOG_ERROR), @"Warn" : @(TIM_LOG_WARN), @"Info" : @(TIM_LOG_INFO), @"Debug" : @(TIM_LOG_DEBUG)};
}

+ (NSString *)configSaveKey:(NSString *)userid
{
    return [NSString stringWithFormat:@"%@_Config", userid];
}

- (void)saveToLocal
{
    IMAHost *host = [IMAPlatform sharedInstance].host;
    if (host)
    {
        [host.loginParm saveToLocal];
    }
}

@end
