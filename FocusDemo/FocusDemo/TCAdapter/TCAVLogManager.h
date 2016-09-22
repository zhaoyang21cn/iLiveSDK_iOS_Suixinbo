//
//  TCAVLogManager.h
//  TCShow
//
//  Created by wilderliao on 16/8/1.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#if kTCAVLogSwitch

/**
 *  随心播log管理类，只打印随心播中的log
 */

#import <Foundation/Foundation.h>

@interface TCAVLogManager : NSObject

/**
 *  获取日志管理类实例
 *
 *  @return 日志管理类实例
 */
+ (instancetype)shareInstance;

- (void)logTo:(NSString *)log;

@end

#endif



