//
//  LogoutRequest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LogoutRequest.h"

@implementation LogoutRequest

- (NSString *)url
{
    return @"https://sxb.qcloud.com/sxb/index.php?svc=account&cmd=logout";
}

- (NSDictionary *)packageParams
{
    NSDictionary *paramDic = @{@"token"  : _token,};
    return paramDic;
}


@end
