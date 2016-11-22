//
//  LiveListRequest.m
//  TCShow
//
//  Created by AlexiChen on 15/11/13.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import "LiveListRequest.h"


@implementation LiveListRequest

- (NSString *)url
{
    return @"http://182.254.234.225/sxb/index.php?svc=live&cmd=list";
}

- (NSDictionary *)packageParams
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[_pageItem serializeSelfPropertyToJsonObject]];
    [dic setObject:@([ShowAppId integerValue]) forKey:@"appid"];
    return dic;
}

- (Class)responseDataClass
{
    return [TCShowLiveList class];
}

- (BaseResponseData *)parseResponseData:(NSDictionary *)dataDic
{
    return [NSObject parse:[self responseDataClass] dictionary:dataDic itemClass:[TCShowLiveListItem class]];
}

@end

@implementation TCShowLiveList

@end
