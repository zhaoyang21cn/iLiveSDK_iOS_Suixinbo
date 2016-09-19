//
//  QALHTTPRequestDelegate.h
//  QALHttpSDK
//
//  Created by wtlogin on 15/10/10.
//  Copyright (c) 2015年 tencent. All rights reserved.
//


#import <Foundation/Foundation.h>


@class QALHttpRequest;


@protocol QALHTTPRequestDelegate <NSObject>

@optional

/*
 请求完成回调
 */
- (void)requestFinished:(QALHttpRequest *)request;

/*
 请求失败回调
 */
- (void)requestFailed:(int)errCode andErrMsg:(NSString*)errMsg;


@end
