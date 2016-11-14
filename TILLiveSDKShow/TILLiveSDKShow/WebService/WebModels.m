//
//  WebModels.m
//  TCShow
//
//  Created by AlexiChen on 15/11/12.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import "WebModels.h"

#import "NSMutableDictionary+Json.h"
#import "NSObject+Json.h"

@implementation ImageSignItem

- (BOOL)isVailed
{
    if (!_imageSign.length)
    {
        return NO;
    }
    
    time_t cuetime = [[NSDate date] timeIntervalSince1970];
    // 28天内有效
    BOOL isExpired = (cuetime - _saveSignTime > (1 * 28 * 24* 60 * 60));
    
    return !isExpired;
    
}


@end


//==================================================
@implementation LocationItem

- (instancetype)init
{
    if (self = [super init])
    {
        self.address = @"";
    }
    return self;
}

- (BOOL)isVaild
{
    return _address.length != 0 && _latitude != 0 && _longitude != 0;
}

@end

//==================================================
@implementation TCShowUser : NSObject


- (BOOL)isVailed
{
    BOOL isVailed = _uid == nil || _uid.length < 1;
    
    return isVailed;
}

@end

//==================================================

//@implementation TCShowLiveCustomAction
//
//- (instancetype)init
//{
//    if (self = [super init])
//    {
//        _user = [IMAPlatform sharedInstance].host;
//    }
//    return self;
//}
//
//- (NSData *)actionData
//{
//    NSDictionary *post = [self serializeSelfPropertyToJsonObject];
//    if ([NSJSONSerialization isValidJSONObject:post])
//    {
//        NSError *error = nil;
//        NSData *data = [NSJSONSerialization dataWithJSONObject:post options:NSJSONWritingPrettyPrinted error:&error];
//        if(error)
//        {
//            DebugLog(@"[%@] Post Json Error: %@", [self class], post);
//            return nil;
//        }
//        
//        return data;
//    }
//    else
//    {
//        DebugLog(@"[%@] AV Custom Action is not valid: %@", [self class], post);
//        return nil;
//    }
//}
//
//@end


//==================================================
@implementation TCShowLiveListItem

- (void)saveToLocal
{
    NSMutableDictionary *tcShowUserDic = [NSMutableDictionary dictionary];
    [tcShowUserDic setObject:self.host.avatar ? self.host.avatar : @"" forKey:@"host_avatar"];
    [tcShowUserDic setObject:self.host.username ? self.host.username : @"" forKey:@"host_username"];
    [tcShowUserDic setObject:self.host.uid ? self.host.uid : @"" forKey:@"host_uid"];
    [tcShowUserDic setObject:[NSNumber numberWithInteger:self.host.avCtrlState] forKey:@"host_avCtrlState"];
    [tcShowUserDic setObject:[NSNumber numberWithInteger:self.host.avMultiUserState] forKey:@"host_avMultiUserState"];
    
    NSMutableDictionary *lbsDic = [NSMutableDictionary dictionary];
    [lbsDic setObject:[NSNumber numberWithInteger:self.lbs.longitude] forKey:@"lbs_longitude"];
    [lbsDic setObject:[NSNumber numberWithInteger:self.lbs.latitude] forKey:@"lbs_latitude"];
    [lbsDic setObject:self.lbs.address ? self.lbs.address : @"" forKey:@"lbs_address"];
    
    
    NSMutableDictionary *listItemDic = [NSMutableDictionary dictionary];
    [listItemDic setObject:tcShowUserDic forKey:@"host"];
    [listItemDic setObject:lbsDic forKey:@"lbs"];
    [listItemDic setObject:self.title ? self.title : @"" forKey:@"title"];
    [listItemDic setObject:self.cover ? self.cover : @"" forKey:@"cover"];
    [listItemDic setObject:[NSNumber numberWithInteger:self.createTime] forKey:@"createTime"];
    [listItemDic setObject:[NSNumber numberWithInteger:self.timeSpan] forKey:@"timeSpan"];
    [listItemDic setObject:[NSNumber numberWithInteger:self.liveAudience] forKey:@"liveAudience"];
    [listItemDic setObject:[NSNumber numberWithInteger:self.admireCount] forKey:@"admireCount"];
    [listItemDic setObject:[NSNumber numberWithInteger:self.watchCount] forKey:@"watchCount"];
    [listItemDic setObject:self.chatRoomId ? self.chatRoomId : @"" forKey:@"chatRoomId"];
    [listItemDic setObject:[NSNumber numberWithInt:self.avRoomId] forKey:@"avRoomId"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *useridKey = [NSString stringWithFormat:@"LiveListItem_%@", [[ILiveLoginManager getInstance] getLoginId]];
    
    [ud setObject:listItemDic forKey:useridKey];
}

- (void)cleanLocalData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *useridKey = [NSString stringWithFormat:@"LiveListItem_%@", [[ILiveLoginManager getInstance] getLoginId]];
    
    [ud setObject:nil forKey:useridKey];
}

+ (instancetype)loadFromToLocal
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *useridKey = [NSString stringWithFormat:@"LiveListItem_%@", [[ILiveLoginManager getInstance] getLoginId]];
    if (useridKey)
    {
        NSDictionary *listItemDic = [ud dictionaryForKey:useridKey];
        if (!listItemDic)
        {
            return nil;
        }
        
        NSLog(@"%@", listItemDic);
        NSMutableDictionary *tcShowUserDic = [listItemDic objectForKey:@"host"];
        NSMutableDictionary *lbsDic = [listItemDic objectForKey:@"lbs"];
        
        TCShowLiveListItem *item = [[TCShowLiveListItem alloc] init];
        
        item.host = [[TCShowUser alloc] init];
        item.host.avatar = [tcShowUserDic objectForKey:@"host_avatar"];
        item.host.username = [tcShowUserDic objectForKey:@"host_username"];
        item.host.uid = [tcShowUserDic objectForKey:@"host_uid"];
        item.host.avCtrlState = [[tcShowUserDic objectForKey:@"host_avCtrlState"] integerValue];
        item.host.avMultiUserState = [[tcShowUserDic objectForKey:@"host_avMultiUserState"] integerValue];
        
        item.lbs = [[LocationItem alloc] init];
        item.lbs.longitude = [[lbsDic objectForKey:@"lbs_longitude"] integerValue];
        item.lbs.latitude = [[lbsDic objectForKey:@"lbs_latitude"] integerValue];
        item.lbs.address = [lbsDic objectForKey:@"lbs_address"];
        
        item.title = [listItemDic objectForKey:@"title"];
        item.cover = [listItemDic objectForKey:@"cover"];
        item.createTime = [[listItemDic objectForKey:@"createTime"] integerValue];
        item.timeSpan = [[listItemDic objectForKey:@"timeSpan"] integerValue];
        item.liveAudience = [[listItemDic objectForKey:@"liveAudience"] integerValue];
        item.admireCount = [[listItemDic objectForKey:@"admireCount"] integerValue];
        item.watchCount = [[listItemDic objectForKey:@"watchCount"] integerValue];
        item.chatRoomId = [listItemDic objectForKey:@"chatRoomId"];
        item.avRoomId = [[listItemDic objectForKey:@"avRoomId"] intValue];
        
        //加载之后置空
        [ud setObject:nil forKey:useridKey];
        
        return item;
    }
    else
    {
        return nil;
    }
}

- (NSString *)liveIMChatRoomId
{
    return self.chatRoomId;
}

- (void)setLiveIMChatRoomId:(NSString *)liveIMChatRoomId
{
    self.chatRoomId = liveIMChatRoomId;
}

// 当前主播信息
- (TCShowUser *)liveHost
{
    return _host;
}

// 直播房间Id
- (int)liveAVRoomId
{
    return _avRoomId;
}

// 直播标题
- (NSString *)liveTitle
{
    return self.title;
}

- (NSString *)liveCover
{
    return self.cover;
}

- (void)setLiveAudience:(NSInteger)liveAudience
{
    if (liveAudience < 0)
    {
        liveAudience = 0;
    }
    
    if (liveAudience > _liveAudience)
    {
        _watchCount += (liveAudience - _liveAudience);
    }

    _liveAudience = liveAudience;
}

- (void)setLivePraise:(NSInteger)livePraise
{
    if (livePraise < 0)
    {
        livePraise = 0;
    }
    
    _admireCount = livePraise;
}

- (NSInteger)livePraise
{
    return _admireCount;
}

- (void)setLiveDuration:(NSInteger)liveDuration
{
    self.timeSpan = liveDuration;
}

- (NSInteger)liveDuration
{
    return self.timeSpan;
}

// 点赞次数
- (NSString *)livePraiseCount
{
    return [NSString stringWithFormat:@"%d", (int)self.livePraise];
}

// 观众人数
- (NSString *)liveAudienceCount
{
    return [NSString stringWithFormat:@"%d", (int)self.liveAudience];
}


- (NSDictionary *)toLiveStartJson
{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [json addString:self.title forKey:@"title"];
    [json addString:self.cover forKey:@"cover"];
    [json addString:self.chatRoomId forKey:@"chatRoomId"];
    [json addInteger:self.avRoomId forKey:@"avRoomId"];
    
    
    NSMutableDictionary *host = [[NSMutableDictionary alloc] init];
    
    [host addString:[self.host uid] forKey:@"uid"];
    [host addString:[self.host avatar] forKey:@"avatar"];
    [host addString:[self.host username] forKey:@"username"];
    [json setObject:host forKey:@"host"];
    
    if (self.lbs)
    {
        NSDictionary *lbs = [self.lbs serializeSelfPropertyToJsonObject];
        
        [json setObject:lbs forKey:@"lbs"];
    }
    return json;
}

- (NSDictionary *)toHeartBeatJson
{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [json addString:[self.host uid] forKey:@"uid"];
    [json addInteger:self.watchCount forKey:@"watchCount"];
    [json addInteger:self.admireCount forKey:@"admireCount"];
    [json addInteger:self.timeSpan forKey:@"timeSpan"];
    return json;
}

- (NSInteger)liveWatchCount
{
    return _watchCount;
}

@end

