//
//  LiveStartRequest.m
//  TCShow
//
//  Created by AlexiChen on 16/4/27.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "LiveStartRequest.h"

@implementation LiveStartRequest

- (NSString *)url
{
    return @"http://182.254.234.225/sxb/index.php?svc=live&cmd=start";
    
}

- (NSDictionary *)packageParams
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[_liveItem toLiveStartJson]];
    [dic setObject:@([ShowAppId integerValue]) forKey:@"appid"];
    return dic;
}

@end
