//
//  CreateRoomRequest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "CreateRoomRequest.h"

@implementation CreateRoomRequest

- (NSString *)url
{
//    return @"https://sxb.qcloud.com/sxb/index.php?svc=live&cmd=create";
    NSString *host = [self hostUrl];
    return [NSString stringWithFormat:@"%@svc=live&cmd=create",host];
}

- (NSDictionary *)packageParams
{
    NSDictionary *paramDic = @{@"token"  : _token,
                               @"type" : _type,
                               };
    return paramDic;
}

- (Class)responseDataClass
{
    return [CreateRoomResponceData class];
}

@end

@implementation CreateRoomResponceData


@end
