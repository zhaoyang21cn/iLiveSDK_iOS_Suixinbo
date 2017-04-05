//
//  GetRoomPlayUrlRequest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/29.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "GetRoomPlayUrlRequest.h"

@implementation GetRoomPlayUrlRequest

- (NSString *)url
{
//    return @"https://sxb.qcloud.com/sxb/index.php?svc=live&cmd=getroomplayurl";
    NSString *host = [self hostUrl];
    return [NSString stringWithFormat:@"%@svc=live&cmd=getroomplayurl",host];
}

- (NSDictionary *)packageParams
{
    NSDictionary *dic = @{@"token" : _token,
                          @"roomnum" : [NSNumber numberWithInteger:_roomnum],
                          };
    return dic;
}

- (Class)responseDataClass
{
    return [GetRoomPlayUrlRspData class];
}

- (BaseResponseData *)parseResponseData:(NSDictionary *)dataDic
{
    return [NSObject parse:[self responseDataClass] dictionary:dataDic];
}
@end


@implementation GetRoomPlayUrlRspData

@end
