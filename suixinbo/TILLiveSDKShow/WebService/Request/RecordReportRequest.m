//
//  RecordReportRequest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/12.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "RecordReportRequest.h"

@implementation RecordReportRequest

- (NSString *)url
{
//    return @"https://sxb.qcloud.com/sxb/index.php?svc=live&cmd=reportrecord";
    NSString *host = [self hostUrl];
    return [NSString stringWithFormat:@"%@svc=live&cmd=reportrecord",host];
}

- (NSDictionary *)packageParams
{
    NSDictionary *dic = @{@"token" : _token,
                          @"roomnum" : [NSNumber numberWithInteger:_roomnum],
                          @"uid" : _uid,
                          @"name" : _name,
                          @"type" : [NSNumber numberWithInteger:_type],
                          @"cover":_cover ? _cover : @"",
                          };
    return dic;
}
@end
