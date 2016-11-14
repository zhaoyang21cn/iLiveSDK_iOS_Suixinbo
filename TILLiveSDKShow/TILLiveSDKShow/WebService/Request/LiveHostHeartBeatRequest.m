//
//  LiveHostHeartBeatRequest.m
//  TCShow
//
//  Created by AlexiChen on 16/4/27.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "LiveHostHeartBeatRequest.h"

@implementation LiveHostHeartBeatRequest

- (NSString *)url
{
   return @"http://182.254.234.225/sxb/index.php?svc=live&cmd=host_heartbeat";
   
}

- (NSDictionary *)packageParams
{
    return [_liveItem toHeartBeatJson];
}


@end
