//
//  IMAPlatformConfig.h
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

// IMAPlatform 参数配置
@interface IMAPlatformConfig : NSObject

@property (nonatomic, readonly) int       environment;        // 环境
@property (nonatomic, readonly) BOOL      enableConsoleLog;   // 是否支持后台打印
@property (nonatomic, readonly) NSInteger logLevel;           // 日志级别

+ (NSDictionary *)logLevelTips;

- (void)chageEnvTo:(int)env;
- (void)chageEnableConsoleTo:(BOOL)enable;
- (void)chageLogLevelTo:(NSInteger)level;

- (NSString *)getLogLevelTip;


@end
