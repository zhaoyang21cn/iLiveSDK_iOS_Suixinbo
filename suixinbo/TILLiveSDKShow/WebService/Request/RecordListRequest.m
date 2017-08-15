//
//  RecordListRequest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/12.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "RecordListRequest.h"

@implementation RecordListRequest

- (NSString *)url
{
//    return @"https://sxb.qcloud.com/sxb/index.php?svc=live&cmd=recordlist";
    NSString *host = [self hostUrl];
    return [NSString stringWithFormat:@"%@svc=live&cmd=recordlist",host];
}

- (NSDictionary *)packageParams
{
    if (!(_token))
    {
        return nil;
    }
    if (_uid.length > 0)
    {
        NSDictionary *dic = @{@"token" : _token,
                              @"type" : [NSNumber numberWithInteger:_type],
                              @"index" : [NSNumber numberWithInteger:_index],
                              @"size" : [NSNumber numberWithInteger:_size],
                              @"s_uid" : _uid
                              };
        return dic;
    }
    else
    {
        NSDictionary *dic = @{@"token" : _token,
                              @"type" : [NSNumber numberWithInteger:_type],
                              @"index" : [NSNumber numberWithInteger:_index],
                              @"size" : [NSNumber numberWithInteger:_size],
                              };
        return dic;
    }
}

//- (Class)responseClass
//{
//    return [RecordListResponese class];
//}
//- (Class)responseDataClass
//{
//    return [RecordListRspData class];
//}

- (void)parseDictionaryResponse:(NSDictionary *)bodyDic
{
    
    NSDictionary *dataDic = [bodyDic objectForKey:@"data"];
    int total = 0;
    id totalObj = [dataDic objectForKey:@"total"];
    if ([totalObj isKindOfClass:[NSString class]])
    {
        total = [totalObj intValue];
    }
    NSArray *videos = [dataDic objectForKey:@"videos"];
    
    NSMutableArray *parseVideos = [NSMutableArray array];
    for (NSDictionary *itemDic in videos)
    {
        RecordVideoItem *item = [[RecordVideoItem alloc] init];//= [NSObject parse:[RecordVideoItem class] dictionary:itemDic];// itemClass:[NSString class]
        item.uid = [itemDic objectForKey:@"uid"];
        item.name = [itemDic objectForKey:@"name"];
        item.cover = (NSString *)[itemDic objectForKey:@"cover"];
        item.videoId = [itemDic objectForKey:@"videoId"];
        item.playurl = [itemDic objectForKey:@"playurl"];
        item.createTime = [itemDic objectForKey:@"createTime"];
        item.duration = [itemDic objectForKey:@"duration"];
        item.fileSize = [itemDic objectForKey:@"fileSize"];
        
        [parseVideos addObject:item];
    }
    
    RecordListResponese *response = [[RecordListResponese alloc] init];
    response.errorCode = [[bodyDic objectForKey:@"code"] intValue];
    response.errorInfo = [bodyDic objectForKey:@"message"];
    response.total = total;
    response.videos = parseVideos;
    
    _response = response;
}

@end

@implementation RecordListResponese
@end

//@implementation RecordListRspData
//
//@end
