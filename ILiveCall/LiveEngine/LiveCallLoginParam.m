//
//  LiveCallLoginParam.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/18.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "LiveCallLoginParam.h"

#define kDaysInSeconds(x)           (x * 24 * 60 * 60)

@implementation LiveCallLoginParam

- (void)updateRefreshTime
{
    _tokenTime = [[NSDate date] timeIntervalSince1970];
}

- (BOOL)needRefresh
{
    time_t curTime = [[NSDate date] timeIntervalSince1970];
    BOOL expired = curTime - self.tokenTime > kDaysInSeconds(10);
    return expired;
}

@end
