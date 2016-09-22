//
//  TCAVLiveRoomEngine+Record.m
//  TCShow
//
//  Created by AlexiChen on 16/5/30.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVLiveRoomEngine+Record.h"


@implementation TCAVLiveRoomRecordRequest

- (instancetype)initWith:(id<AVRoomAble>)room record:(AVRecordInfo *)info
{
    if (!info)
    {
        return nil;
    }
    
    if (self = [super init])
    {
        UInt32 roomid = (UInt32)[room liveAVRoomId];
        OMAVRoomInfo *avRoomInfo = [[OMAVRoomInfo alloc] init];
        avRoomInfo.roomId = roomid;
        avRoomInfo.relationId = roomid;
        self.roomInfo = avRoomInfo;
        self.recordInfo = info;
       
    }
    return self;
}

@end


//=======================================================================

@implementation TCAVLiveRoomEngine (Record)

static NSString *const kTCAVLiveRoomEngineRecordTryItem = @"kTCAVLiveRoomEngineRecordTryItem";

- (TCAVTryItem *)recordTryItem
{
    return objc_getAssociatedObject(self, (__bridge const void *)kTCAVLiveRoomEngineRecordTryItem);
}

- (void)setRecordTryItem:(TCAVTryItem *)recordTryItem
{
    objc_setAssociatedObject(self, (__bridge const void *)kTCAVLiveRoomEngineRecordTryItem, recordTryItem, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)hasRecord
{
    return self.recordTryItem != nil;
}

- (void)onEnterRoomCheckRecord
{
    if ([self isHostLive])
    {
        id<AVUserAble> ah = (id<AVUserAble>) _IMUser;
        NSInteger state = [ah avCtrlState];
        
        if (state & EAVCtrlState_Record)
        {
            // 只有主播才可以设置
            [self onAsyncStartRecordOnEnterRoom:YES];
        }
    }
}

#define kRecordTryIndex 100

- (BOOL)checkBeforeRecordOnEnterRoom:(BOOL)ise
{
    TCAVTryItem *item = self.recordTryItem;
    if (!item)
    {
        item =  [[TCAVTryItem alloc] initWith:kRecordTryIndex];
        self.recordTryItem = item;
    }
    else if (!ise && item)
    {
        TIMLog(@"正在进行制制，无需再开启");
        return NO;
    }
    
    
    // 检查状态
    if (!_isRoomAlive)
    {
        TIMLog(@"房间还未创建，请使用enterLive创建成功(enterRoom回调)之后再录制");
        return NO;
    }
    
    if (item.isTrying)
    {
        TIMLog(@"正在处理调用录制接口");
        return NO;
    }
    
    item.isTrying = YES;
    item.hasTryCount = 0;
    TIMLog(@"开始录制");
    return YES;
}


- (AVRecordInfo *)defaultRecordInfo
{
    NSString *tag = @"8921";
    AVRecordInfo *avRecordinfo = [[AVRecordInfo alloc] init];
    avRecordinfo.fileName = [_roomInfo liveTitle];
    avRecordinfo.tags = @[tag];
    avRecordinfo.classId = [tag intValue];
    avRecordinfo.isTransCode = NO;
    avRecordinfo.isScreenShot = NO;
    avRecordinfo.isWaterMark = NO;
    return avRecordinfo;
}

- (void)onAsyncStartRecordOnEnterRoom:(BOOL)ise
{
    if ([self checkBeforeRecordOnEnterRoom:ise])
    {
        AVRecordInfo *info = [self defaultRecordInfo];
        [self startRecord:info needCallBack:YES completion:nil];
    }
}

- (void)startRecord:(AVRecordInfo *)info needCallBack:(BOOL)cb completion:(TCAVRecordCompletion)completion
{
    if ([self beforeTryCheck:nil])
    {
        if (!self.recordTryItem)
        {
            self.recordTryItem =  [[TCAVTryItem alloc] initWith:kRecordTryIndex];
        }
        // 开始推流
        [self startLiveRecord:info needCallBack:cb completion:completion];
    }
    else
    {
        self.recordTryItem = nil;
        
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

- (void)startLiveRecord:(AVRecordInfo *)recInfo needCallBack:(BOOL)cb completion:(TCAVRecordCompletion)completion
{
    TCAVLiveRoomRecordRequest *recReq = [[TCAVLiveRoomRecordRequest alloc] initWith:_roomInfo record:recInfo];
    if (recReq)
    {
        __weak TCAVLiveRoomEngine *ws = self;

        int res = [[IMSdkInt sharedInstance] requestMultiVideoRecorderStart:recReq.roomInfo recordInfo:recReq.recordInfo okBlock: ^{

            // 推流成功
            [ws enableHostCtrlState:EAVCtrlState_Record];
            ws.recordTryItem.isTrying = NO;
            ws.recordTryItem.result = recReq;
            
            if (cb)
            {
                if ([ws.delegate respondsToSelector:@selector(onAVEngine:onRecord:recordRequest:)])
                {
                    [ws.delegate onAVEngine:ws onRecord:YES recordRequest:recReq];
                }
            }
            
            if (completion)
            {
                completion(YES, recReq);
            }
            TIMLog(@"开启录制成功");
        } errBlock:^(int code, NSString *err) {
            // 录制失败
            TIMLog(@"开启录制失败 (code = %d, err = %@)", code, err);
            ws.recordTryItem = nil;
            [ws disableHostCtrlState:EAVCtrlState_Record];
            
            if (cb)
            {
                if ([ws.delegate respondsToSelector:@selector(onAVEngine:onRecord:recordRequest:)])
                {
                    [ws.delegate onAVEngine:ws onRecord:NO recordRequest:recReq];
                }
            }
            
            if (completion)
            {
                completion(NO, recReq);
            }
            
        }];
        
        if (res != 0)
        {
            TIMLog(@"调用IMSDK推流接口出错");
            if ([ws.delegate respondsToSelector:@selector(onAVEngine:onRecord:recordRequest:)])
            {
                [ws.delegate onAVEngine:ws onRecord:NO recordRequest:nil];
            }
        }
    }
    else
    {
        TIMLog(@"recInfo参数错误");
    }
}

- (void)asyncStartRecordCompletion:(TCAVRecordCompletion)completion
{
    AVRecordInfo *info = [self defaultRecordInfo];
    [self startRecord:info needCallBack:NO completion:completion];
}

- (void)asyncStartRecord:(AVRecordInfo *)record completion:(TCAVRecordCompletion)completion
{
    [self startRecord:record needCallBack:NO completion:completion];
}

- (void)asyncStopRecordCompletion:(TCAVRecordCompletion)completion
{
    if (self.recordTryItem != nil)
    {
        __weak TCAVLiveRoomEngine *ws = self;
        TCAVLiveRoomRecordRequest *req = (TCAVLiveRoomRecordRequest *)self.recordTryItem.result;
        int ret = [[IMSdkInt sharedInstance] requestMultiVideoRecorderStop:req.roomInfo okBlock:^(NSArray *fileIds) {
            req.recordFileIds = fileIds;
            
            if (completion)
            {
                completion(YES, req);
            }
            ws.recordTryItem = nil;
        } errBlock:^(int code, NSString *err) {
            TIMLog(@"停止录制 (code = %d, err = %@)", code, err);
            if (completion)
            {
                completion(NO, req);
            }
            ws.recordTryItem = nil;
        }];
        if(ret != 0)
        {
            TIMLog(@"调用IMSDK录制接口出错:%d", ret);
        }
    }
    else
    {
        TIMLog(@"没有录制");
        if (completion)
        {
            completion(YES, nil);
        }
    }
}

- (void)onAsyncStopRecordOnExitRoom:(TCAVRecordCompletion)completion
{
    [self asyncStopRecordCompletion:completion];
}


@end

