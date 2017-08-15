//
//  ReportRoomRequest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "ReportRoomRequest.h"

#import "NSMutableDictionary+Json.h"
#import "NSObject+Json.h"

@implementation ReportRoomRequest

- (NSString *)url
{
//    return @"https://sxb.qcloud.com/sxb/index.php?svc=live&cmd=reportroom";
    NSString *host = [self hostUrl];
    return [NSString stringWithFormat:@"%@svc=live&cmd=reportroom",host];
}

- (NSDictionary *)packageParams
{
    NSDictionary *dic = @{ @"token" : _token,
                           @"room"  : [_room toRoomDic],
                        };
    //@"lbs"   : [_lbs toLBSDic]
    return dic;
}
@end


