//
//  NetworkUtility.h
//  CommonLibrary
//
//  Created by Alexi on 12-11-11.
//  Copyright (c) 2012年 . All rights reserved.
//
#if kSupportNetReachablity
#import <Foundation/Foundation.h>

#import "Reachability.h"

// 网络断开通知
extern NSString *const kNetworkUtilityNotReachableNotification;
// 切换到Wifi
extern NSString *const kNetworkUtilityWifiConnectNotification;
// 切换到移动网络
extern NSString *const kNetworkUtilityMONETConnectNotification;

@interface NetworkUtility : NSObject
{
    Reachability    *_reachablity;
    NSInteger       _lastReachabilityStatus;
}

+ (NetworkUtility *)sharedNetworkUtility;

- (void)startCheckWifi;

- (void)stopCheckWifi;

- (BOOL)isReachable;

- (BOOL)isReachableViaWWAN;

- (BOOL)isReachableViaWiFi;

- (NSString *)wifiSSID;

@end
#endif
