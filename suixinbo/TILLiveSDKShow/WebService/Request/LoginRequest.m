//
//  LoginRequest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/30.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LoginRequest.h"

@implementation LoginRequest

- (NSString *)url
{
//    return @"https://sxb.qcloud.com/sxb/index.php?svc=account&cmd=login";
    NSString *host = [self hostUrl];
    return [NSString stringWithFormat:@"%@svc=account&cmd=login",host];
}

- (NSDictionary *)packageParams
{
    NSDictionary *paramDic = @{
                               @"appid" : @([ShowAppId intValue]), 
                               @"id"  : _identifier,
                               @"pwd" : _pwd,
                               @"appid" : @([[ILiveSDK getInstance] getAppId])
                               };
    return paramDic;
}

- (Class)responseDataClass
{
    return [LoginResponceData class];
}

@end

@implementation LoginResponceData

@end
