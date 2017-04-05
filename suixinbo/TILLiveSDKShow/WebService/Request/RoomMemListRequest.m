//
//  RoomMemListRequest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/13.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "RoomMemListRequest.h"

@implementation RoomMemListRequest

- (NSString *)url
{
//    return @"https://sxb.qcloud.com/sxb/index.php?svc=live&cmd=roomidlist";
    NSString *host = [self hostUrl];
    return [NSString stringWithFormat:@"%@svc=live&cmd=roomidlist",host];

}

- (NSDictionary *)packageParams
{
    NSDictionary *dic = @{@"token" : _token,
                          @"roomnum" : [NSNumber numberWithInteger:_roomnum],
                          @"index" : [NSNumber numberWithInteger:_index],
                          @"size" : [NSNumber numberWithInteger:_size],
                          };
    return dic;
}

- (Class)responseDataClass
{
    return [RoomMemListRspData class];
}

- (BaseResponseData *)parseResponseData:(NSDictionary *)dataDic
{
    return [NSObject parse:[self responseDataClass] dictionary:dataDic itemClass:[MemberListItem class]];
}

@end

@implementation RoomMemListRspData

@end
