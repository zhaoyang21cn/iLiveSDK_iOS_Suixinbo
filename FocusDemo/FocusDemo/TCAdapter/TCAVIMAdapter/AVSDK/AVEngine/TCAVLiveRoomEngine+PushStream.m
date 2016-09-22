//
//  TCAVLiveRoomEngine+PushStream.m
//  TCShow
//
//  Created by AlexiChen on 16/5/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVLiveRoomEngine+PushStream.h"


@implementation TCAVLiveRoomPushRequest

- (instancetype)initWith:(id<AVRoomAble>)room type:(AVEncodeType)type
{
    return [self initWith:room channelName:[room liveTitle] type:type];
}

- (instancetype)initWith:(id<AVRoomAble>)room channelName:(NSString *)channelName type:(AVEncodeType)type
{
    return [self initWith:room channelName:channelName channelDesc:channelName type:type];
}

- (instancetype)initWith:(id<AVRoomAble>)room channelName:(NSString *)channelName channelDesc:(NSString *)channelDesc type:(AVEncodeType)type
{
    if (self = [super init])
    {
        UInt32 roomid = (UInt32)[room liveAVRoomId];
        OMAVRoomInfo *avRoomInfo = [[OMAVRoomInfo alloc] init];
        avRoomInfo.roomId = roomid;
        avRoomInfo.relationId = roomid;
        self.roomInfo = avRoomInfo;
        
        AVStreamInfo *avStreamInfo = [[AVStreamInfo alloc] init];
        avStreamInfo.encodeType = type;
        avStreamInfo.channelInfo = [[LVBChannelInfo alloc] init];
        avStreamInfo.channelInfo.channelName = channelName;
        avStreamInfo.channelInfo.channelDescribe = channelDesc;
        self.pushParam = avStreamInfo;
    }
    return self;
}
- (NSString *)getPushUrl:(AVEncodeType)type
{
    if (type == AV_ENCODE_HLS)
    {
        return [self getHLSPushUrl];
    }
    else if (type == AV_ENCODE_RTMP)
    {
        return [self getRTMPPushUrl];
    }
    return nil;
}


- (NSString *)getHLSPushUrl
{
    if (self.pushResp.urls.count)
    {
        for (AVLiveUrl *url in self.pushResp.urls)
        {
            if ([url.playUrl hasSuffix:@"m3u8"])
            {
                return url.playUrl;
            }
        }
    }
    
    return nil;
}

- (NSString *)getRTMPPushUrl
{
    if (self.pushResp.urls.count)
    {
        for (AVLiveUrl *url in self.pushResp.urls)
        {
            if ([url.playUrl hasPrefix:@"rtmp://"])
            {
                return url.playUrl;
            }
        }
    }
    
    return nil;
}

@end


//=======================================================================

@implementation TCAVLiveRoomEngine (PushStream)

static NSString *const kTCAVLiveRoomEnginePushingMap = @"kTCAVLiveRoomEnginePushingMap";

- (NSMutableDictionary *)pushingMap
{
    NSMutableDictionary *dic = objc_getAssociatedObject(self, (__bridge const void *)kTCAVLiveRoomEnginePushingMap);
    return dic;
}

- (void)setPushingMap:(NSMutableDictionary *)pushingMap
{
    objc_setAssociatedObject(self, (__bridge const void *)kTCAVLiveRoomEnginePushingMap, pushingMap, OBJC_ASSOCIATION_RETAIN);
}

- (void)onEnterRoomCheckPush
{
    if ([self isHostLive])
    {
        id<AVUserAble> ah = (id<AVUserAble>) _IMUser;
        NSInteger state = [ah avCtrlState];
        
        if (state & EAVCtrlState_HLS_RTMP)
        {
            // 只有主播才可以设置
            [self onAsyncStartPushStream:AV_ENCODE_HLS_AND_RTMP isEnterRoom:YES];
            return;
        }
        
        // 检查是否要HLS推流
        if (state & EAVCtrlState_HLSStream)
        {
            // 只有主播才可以设置
            [self onAsyncStartPushStream:AV_ENCODE_HLS isEnterRoom:YES];
            return;
        }
        
        if (state & EAVCtrlState_RTMPStream)
        {
            // 只有主播才可以设置
            [self onAsyncStartPushStream:AV_ENCODE_RTMP isEnterRoom:YES];
            return;
        }
        
        if (state & EAVCtrlState_RAWStream)
        {
            // 只有主播才可以设置
            [self onAsyncStartPushStream:AV_ENCODE_RTMP isEnterRoom:YES];
            return;
        }
    }
}

- (TCAVLiveRoomPushRequest *)pushRequest:(AVEncodeType)type
{
    return self.pushingMap[@(type)];
}

- (NSString *)pushTipOf:(AVEncodeType)type
{
    switch (type)
    {
        case AV_ENCODE_HLS:
            return @"HLS推流";
            break;
        case AV_ENCODE_RAW:
            return @"RAW推流";
            break;
        case AV_ENCODE_RTMP:
            return @"RTMP推流";
            break;
        case AV_ENCODE_HLS_AND_RTMP:
            return @"HLS_RTMP推流";
            break;
            
        default:
            break;
    }
}

- (void)onAsyncStartPushStream:(AVEncodeType)type isEnterRoom:(BOOL)ise
{
    if ([self checkBeforePush:type isEnterRoom:ise])
    {
        [self startPushStream:type channelName:[_roomInfo liveTitle] channelDesc:[_roomInfo liveTitle] needCallBack:YES completion:nil];
    }
    
}

- (BOOL)checkBeforePush:(AVEncodeType)type isEnterRoom:(BOOL)ise
{
    NSString *pushtip = [self pushTipOf:type];
    
    NSInteger typeState = [self getVailedPushState:type];
    
    if (typeState == 0)
    {
        DebugLog(@"不支持的推流格式:%@", pushtip);
        return NO;
    }
    
    TCAVTryItem *item = [self.pushingMap objectForKey:@(type)];
    if (!item)
    {
        item =  [[TCAVTryItem alloc] initWith:type];
        
        if (self.pushingMap == nil)
        {
            self.pushingMap = [NSMutableDictionary dictionary];
        }
        
        [self.pushingMap setObject:item forKeyedSubscript:@(type)];
    }
    else if (!ise && item)
    {
        DebugLog(@"正在进行%@，无需再开启", pushtip);
        return NO;
    }
    
    
    // 检查状态
    if (!_isRoomAlive)
    {
        DebugLog(@"房间还未创建，请使用enterLive创建成功(enterRoom回调)之后再推流");
        return NO;
    }
    
    if (item.isTrying)
    {
        DebugLog(@"正在处理%@", pushtip);
        return NO;
    }
    
    item.isTrying = YES;
    item.hasTryCount = 0;
    DebugLog(@"开始%@", pushtip);
    return YES;
}

- (BOOL)hasPushStream:(AVEncodeType)type
{
    return [self.pushingMap objectForKey:@(type)] != nil;
}

- (BOOL)hasPushStream
{
    return self.pushingMap.count;
}


- (void)startPushStream:(AVEncodeType)type channelName:(NSString *)channelName channelDesc:(NSString *)channelDesc needCallBack:(BOOL)cb completion:(TCAVPushCompletion)completion
{
    if ([self beforeTryCheck:nil])
    {
        // 开始推流
        [self pushStream:type channelName:channelName channelDesc:channelDesc needCallBack:cb completion:completion];
    }
    else
    {
        DebugLog(@"开始%@失败", [self pushTipOf:type]);
        // 移除信息
        [self.pushingMap removeObjectForKey:@(type)];
        
        if (cb)
        {
            if ([_delegate respondsToSelector:@selector(onAVEngine:onStartPush:pushRequest:)])
            {
                [_delegate onAVEngine:self onStartPush:NO pushRequest:nil];
            }
        }
        
        if (completion)
        {
            completion(NO, nil);
        }
    }
    
}


- (NSInteger)getVailedPushState:(AVEncodeType)type
{
    NSInteger typeState = 0;
    if (type == AV_ENCODE_HLS)
    {
        typeState = EAVCtrlState_HLSStream;
    }
    else if (type == AV_ENCODE_RTMP)
    {
        typeState = EAVCtrlState_RTMPStream;
    }
    else if (type == AV_ENCODE_RAW)
    {
        typeState = EAVCtrlState_RAWStream;
    }
    else if (type == AV_ENCODE_HLS_AND_RTMP)
    {
        typeState = EAVCtrlState_HLS_RTMP;
    }
    return typeState;
}

- (NSString *)pushUrlOf:(TCAVLiveRoomPushRequest *)req
{
    if (req)
    {
        if (req.pushResp.urls.count)
        {
            NSMutableString *string = [NSMutableString string];
            
            for (AVLiveUrl *url in req.pushResp.urls)
            {
                [string appendString:url.playUrl];
                [string appendString:@"\n"];
            }
            
            return string;
        }
        
    }
    return nil;
}



- (void)pushStream:(AVEncodeType)type channelName:(NSString *)channelName channelDesc:(NSString *)channelDesc needCallBack:(BOOL)cb completion:(TCAVPushCompletion)completion
{
    TCAVLiveRoomPushRequest *pushRequest = [[TCAVLiveRoomPushRequest alloc] initWith:_roomInfo channelName:channelName channelDesc:channelDesc type:type];
    
    __weak TCAVLiveRoomEngine *ws = self;
    NSInteger state = [self getVailedPushState:type];
    int res = [[IMSdkInt sharedInstance] requestMultiVideoStreamerStart:pushRequest.roomInfo streamInfo:pushRequest.pushParam okBlock:^(AVStreamerResp *avstreamResp) {
        pushRequest.pushResp = avstreamResp;
        // 推流成功
        [ws enableHostCtrlState:state];
        
        TCAVTryItem *item = [ws.pushingMap objectForKey:@(type)];
        item.isTrying = NO;
        item.result = pushRequest;
        
        if (cb)
        {
            if ([ws.delegate respondsToSelector:@selector(onAVEngine:onStartPush:pushRequest:)])
            {
                [ws.delegate onAVEngine:ws onStartPush:YES pushRequest:pushRequest];
            }
        }
        
        if (completion)
        {
            completion(YES, pushRequest);
        }
        
        DebugLog(@"开启%@成功, 推流地址:%@ %@", [ws pushTipOf:type], [ws pushUrlOf:pushRequest], ws.pushingMap);
    } errBlock:^(int code, NSString *err) {
        // 推流失败
        // 导致推流不成功的原因：因上次推流的时候异常退出时，业务后台去要强行关闭推流，如果不，则下次再使用相同的channelInfo.channelName进行推流，则会不成功
        DebugLog(@"开启%@失败 (code = %d, err = %@)", [ws pushTipOf:type], code, err);
        [ws disableHostCtrlState:state];
        
        [ws.pushingMap removeObjectForKey:@(type)];
        
        if (cb)
        {
            if ([ws.delegate respondsToSelector:@selector(onAVEngine:onStartPush:pushRequest:)])
            {
                [ws.delegate onAVEngine:ws onStartPush:NO pushRequest:pushRequest];
            }
        }
        
        if (completion)
        {
            completion(NO, pushRequest);
        }
        
    }];
    
    if (res != 0)
    {
        DebugLog(@"调用IMSDK推流接口出错:%d", res);
        if ([ws.delegate respondsToSelector:@selector(onAVEngine:onStartPush:pushRequest:)])
        {
            [ws.delegate onAVEngine:ws onStartPush:NO pushRequest:nil];
        }
    }
}

// 直播中使用手动方式开启
- (void)asyncStartPushStream:(AVEncodeType)type completion:(TCAVPushCompletion)completion
{
    if ([self checkBeforePush:type isEnterRoom:NO])
    {
        [self startPushStream:type channelName:[_roomInfo liveTitle] channelDesc:[_roomInfo liveTitle] needCallBack:NO completion:completion];
    }
}

- (void)asyncStartPushStream:(AVEncodeType)type channelName:(NSString *)name completion:(TCAVPushCompletion)completion
{
    if ([self checkBeforePush:type isEnterRoom:NO])
    {
        [self startPushStream:type channelName:name channelDesc:name needCallBack:NO completion:completion];
    }
}
- (void)asyncStartPushStream:(AVEncodeType)type channelName:(NSString *)name channelDesc:(NSString *)desc completion:(TCAVPushCompletion)completion
{
    if ([self checkBeforePush:type isEnterRoom:NO])
    {
        [self startPushStream:type channelName:name channelDesc:desc needCallBack:NO completion:completion];
    }
}

// 直播中使用手动方式关闭
- (void)asyncStopPushStream:(AVEncodeType)type completion:(TCAVCompletion)completion
{
    TCAVTryItem *item = self.pushingMap[@(type)];
    [self stopPushStream:item completion:completion];
}

- (void)stopPushStream:(TCAVTryItem *)item completion:(TCAVCompletion)completion
{
    if (item)
    {
        TCAVLiveRoomPushRequest *req = (TCAVLiveRoomPushRequest *)item.result;
        NSString *tip = [self pushTipOf:item.tryIndex];
        // 关闭推流
        __weak TCAVLiveRoomEngine *ws = self;
        [[IMSdkInt sharedInstance] requestMultiVideoStreamerStop:req.roomInfo channelIDs:@[@(req.pushResp.channelID)] okBlock:^{
            if (completion)
            {
                NSString *tipFormat = TAVLocalizedError(ETCAVLiveRoomEngine_StopPushStream_Format_Succ_Tip);
                completion(YES, [NSString stringWithFormat:tipFormat, tip]);
            }
            [ws.pushingMap removeObjectForKey:@(item.tryIndex)];
        } errBlock:^(int code, NSString *err) {
            DebugLog(@"停止%@失败 (code = %d, err = %@)", tip, code, err);
            if (completion)
            {
                NSString *tipFormat = TAVLocalizedError(ETCAVLiveRoomEngine_StopPushStream_Format_Fail_Tip);
                completion(NO, [NSString stringWithFormat:tipFormat, tip]);
            }
            [ws.pushingMap removeObjectForKey:@(item.tryIndex)];
        }];
    }
}

- (void)asyncStopAllPushStreamCompletion:(TCAVCompletion)completion
{
    [self onAsyncStopPushStreamOnExitRoom:completion];
}

// Protected Method
// 退出房间时，如果有推流，TCAVLiveRoomEngine默认调用
- (void)onAsyncStopPushStreamOnExitRoom:(TCAVCompletion)completion
{
    NSArray *allPush = [self.pushingMap allValues];
    NSInteger allCount = allPush.count;
    if (allCount > 0)
    {
        __block NSInteger count = 0;
        for (TCAVTryItem *item in allPush)
        {
            [self stopPushStream:item completion:^(BOOL succ, NSString *tip) {
                count++;
                if (count == allCount)
                {
                    DebugLog(@"停止所有推流成功");
                    if (completion)
                    {
                        completion(YES, TAVLocalizedError(ETCAVLiveRoomEngine_PushStream_ExitStop_Succ_Tip));
                    }
                }
            }];
        }
    }
    else
    {
        DebugLog(@"没有进行推流");
        if (completion)
        {
            completion(YES, TAVLocalizedError(ETCAVLiveRoomEngine_ExitNoPushStream_Succ_Tip));
        }
    }
}

@end

