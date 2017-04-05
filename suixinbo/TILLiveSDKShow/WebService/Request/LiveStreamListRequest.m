//
//  LiveStreamListRequest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/29.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LiveStreamListRequest.h"

@implementation LiveStreamListRequest

- (NSString *)url
{
//    return @"https://sxb.qcloud.com/sxb/index.php?svc=live&cmd=livestreamlist";
    NSString *host = [self hostUrl];
    return [NSString stringWithFormat:@"%@svc=live&cmd=livestreamlist",host];
}

- (NSDictionary *)packageParams
{
    NSDictionary *dic = @{@"token" : _token,
                          @"index" : [NSNumber numberWithInteger:_index],
                          @"size" : [NSNumber numberWithInteger:_size],
                          };
    return dic;
}

- (Class)responseDataClass
{
    return [LiveStreamListRspData class];
}

- (BaseResponseData *)parseResponseData:(NSDictionary *)dataDic
{
    return [NSObject parse:[self responseDataClass] dictionary:dataDic itemClass:[LiveStreamListItem class]];
}

@end

@implementation LiveStreamListRspData

@end
