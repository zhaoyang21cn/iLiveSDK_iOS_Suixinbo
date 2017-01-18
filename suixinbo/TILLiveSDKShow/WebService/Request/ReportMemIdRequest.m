//
//  ReportMemIdRequest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "ReportMemIdRequest.h"

@implementation ReportMemIdRequest

- (NSString *)url
{
    return @"https://sxb.qcloud.com/sxb/index.php?svc=live&cmd=reportmemid";
}

- (NSDictionary *)packageParams
{
    NSDictionary *dic = @{@"token" : _token,
                          @"id" : _userId,
                          @"roomnum" : [NSNumber numberWithInteger:_roomnum],
                          @"role" : [NSNumber numberWithInteger:_role],
                          @"operate" : [NSNumber numberWithInteger:_operate],
                          };
    return dic;
}

@end
