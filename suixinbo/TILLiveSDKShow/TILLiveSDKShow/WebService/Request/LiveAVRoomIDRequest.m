//
//  LiveAVRoomIDRequest.m
//  TCShow
//
//  Created by AlexiChen on 16/4/27.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "LiveAVRoomIDRequest.h"

@implementation LiveAVRoomIDRequest

- (NSString *)url
{
    return @"http://182.254.234.225/sxb/index.php?svc=user_av_room&cmd=get";
}

- (Class)responseDataClass
{
    return [LiveAVRoomIDResponseData class];
}

- (NSDictionary *)packageParams
{
    return @{@"uid" : self.uid};
}

@end


@implementation LiveAVRoomIDResponseData


@end