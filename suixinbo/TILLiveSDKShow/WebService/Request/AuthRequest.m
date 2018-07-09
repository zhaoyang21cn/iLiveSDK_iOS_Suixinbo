//
//  AuthRequest.m
//  TILLiveSDKShow
//
//  Created by alderzhang on 18/5/9.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "AuthRequest.h"

@implementation AuthRequest

- (NSString *)url
{
    NSString *host = [self hostUrl];
    return [NSString stringWithFormat:@"%@svc=account&cmd=authPrivMap",host];
}

- (NSDictionary *)packageParams
{
    NSDictionary *paramDic = @{@"identifier"  : _identifier,
                               @"pwd" : _pwd,
                               @"appid" : @(_appid),
                               @"accounttype": @(_accountType),
                               @"roomnum": @(_roomNum),
                               @"privMap": @(_privMap),
                               };
    return paramDic;
}

- (Class)responseDataClass
{
    return [AuthResponseData class];
}

@end

@implementation AuthResponseData

@end
