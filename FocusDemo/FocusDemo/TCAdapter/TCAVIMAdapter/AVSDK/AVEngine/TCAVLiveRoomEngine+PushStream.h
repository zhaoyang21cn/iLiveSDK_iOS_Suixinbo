//
//  TCAVLiveRoomEngine+PushStream.h
//  TCShow
//
//  Created by AlexiChen on 16/5/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVLiveRoomEngine.h"

// ================================================================
// 推流录制接口

@interface TCAVLiveRoomPushRequest : NSObject

@property (nonatomic, strong) OMAVRoomInfo *roomInfo;   // 房间信息

@property (nonatomic, strong) AVStreamInfo *pushParam;  // 推流参数

@property (nonatomic, strong) AVStreamerResp *pushResp; // 推流返回的结果

- (instancetype)initWith:(id<AVRoomAble>)room type:(AVEncodeType)type;
- (instancetype)initWith:(id<AVRoomAble>)room channelName:(NSString *)channelName type:(AVEncodeType)type;
- (instancetype)initWith:(id<AVRoomAble>)room channelName:(NSString *)channelName channelDesc:(NSString *)channelDesc type:(AVEncodeType)type;

- (NSString *)getHLSPushUrl;
- (NSString *)getRTMPPushUrl;

// type暂只支持HLS, RTMP
- (NSString *)getPushUrl:(AVEncodeType)type;

@end

typedef void (^TCAVPushCompletion)(BOOL succ, TCAVLiveRoomPushRequest *req);


@interface TCAVLiveRoomEngine (PushStream)

@property (nonatomic, strong) NSMutableDictionary *pushingMap;  //    推流记录的字典

- (void)onEnterRoomCheckPush;

- (BOOL)hasPushStream;
// 是否已在推流
- (BOOL)hasPushStream:(AVEncodeType)type;

- (TCAVLiveRoomPushRequest *)pushRequest:(AVEncodeType)type;

// 直播中使用手动方式开启
- (void)asyncStartPushStream:(AVEncodeType)type completion:(TCAVPushCompletion)completion;
- (void)asyncStartPushStream:(AVEncodeType)type channelName:(NSString *)name completion:(TCAVPushCompletion)completion;
- (void)asyncStartPushStream:(AVEncodeType)type channelName:(NSString *)name channelDesc:(NSString *)desc completion:(TCAVPushCompletion)completion;

// 直播中使用手动方式关闭
- (void)asyncStopPushStream:(AVEncodeType)type completion:(TCAVCompletion)completion;

- (void)asyncStopAllPushStreamCompletion:(TCAVCompletion)completion;


// Protected Method，外部不要调用
// 会自动开启推流
- (void)onAsyncStartPushStream:(AVEncodeType)type isEnterRoom:(BOOL)ise;

// 退出房间时，如果有推流，TCAVLiveRoomEngine默认调用
- (void)onAsyncStopPushStreamOnExitRoom:(TCAVCompletion)completion;

@end
