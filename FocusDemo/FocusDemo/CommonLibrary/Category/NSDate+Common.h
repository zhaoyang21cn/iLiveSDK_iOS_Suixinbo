//
//  NSDate+Common.h
//  TIMChat
//
//  Created by AlexiChen on 16/3/16.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Common)

- (BOOL)isToday;

- (BOOL)isYesterday;

- (NSString *)shortTimeTextOfDate;

- (NSString *)timeTextOfDate;

@end
