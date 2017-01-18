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
    return @"https://sxb.qcloud.com/sxb/index.php?svc=live&cmd=reportrecord";
}

- (NSDictionary *)packageParams
{
    NSDictionary *dic = @{@"token" : _token,
                          @"videoid" : _videoid,
                          @"playurl" : _playurl,
                          @"type" : [NSNumber numberWithInteger:_type],
                          @"cover" : _cover,
                          };
    return dic;
}
@end
