//
//  LinkRoomSigRequest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/4/13.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LinkRoomSigRequest.h"

@implementation LinkRoomSigRequest

- (NSString *)url
{
    NSString *host = [self hostUrl];
    return [NSString stringWithFormat:@"%@svc=live&cmd=linksig",host];
    
}

- (NSDictionary *)packageParams
{
    if (_token.length <= 0 || _identifier.length <= 0)
    {
        return nil;
    }
    NSDictionary *dic = @{@"token" : _token,
                          @"id":_identifier,
                          @"roomnum" : [NSNumber numberWithInteger:_targetRoomnum],
                          @"current_roomnum" : [NSNumber numberWithInteger:_selfRoomnum]
                          };
    return dic;
}

- (Class)responseDataClass
{
    return [LinkRoomSigResponseData class];
}

@end

@implementation LinkRoomSigResponseData
@end
