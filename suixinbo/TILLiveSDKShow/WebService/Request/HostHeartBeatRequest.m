//
//  HostHeartBeatRequest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "HostHeartBeatRequest.h"

@implementation HostHeartBeatRequest

- (NSString *)url
{
//    return @"https://sxb.qcloud.com/sxb/index.php?svc=live&cmd=heartbeat";
    NSString *host = [self hostUrl];
    return [NSString stringWithFormat:@"%@svc=live&cmd=heartbeat",host];
}

- (NSDictionary *)packageParams
{
    NSDictionary *dic = @{@"token" : _token,
                          @"roomnum" : [NSNumber numberWithInteger:_roomnum],
                          @"role" : [NSNumber numberWithInt:_role],
                          @"thumbup" : [NSNumber numberWithInt:_thumbup],
                          };
    return dic;
}
@end
