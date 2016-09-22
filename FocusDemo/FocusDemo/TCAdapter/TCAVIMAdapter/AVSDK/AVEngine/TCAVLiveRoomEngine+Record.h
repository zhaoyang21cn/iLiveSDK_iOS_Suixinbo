//
//  TCAVLiveRoomEngine+Record.h
//  TCShow
//
//  Created by AlexiChen on 16/5/30.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVLiveRoomEngine.h"


// ================================================================
// 推流录制接口

@interface TCAVLiveRoomRecordRequest : NSObject

@property (nonatomic, strong) OMAVRoomInfo *roomInfo;   // 房间信息

@property (nonatomic, strong) AVRecordInfo *recordInfo;  // 录制参数

@property (nonatomic, strong) NSArray *recordFileIds;   // 录制结束后，调用停止成功后，才会返回的fileID

- (instancetype)initWith:(id<AVRoomAble>)room record:(AVRecordInfo *)info;

@end

typedef void (^TCAVRecordCompletion)(BOOL succ, TCAVLiveRoomRecordRequest *req);


@interface TCAVLiveRoomEngine (Record)

@property (nonatomic, strong) TCAVTryItem *recordTryItem;     // 推流记录的字典

- (void)onEnterRoomCheckRecord;

- (BOOL)hasRecord;

// 直播中使用手动方式开启
- (void)asyncStartRecordCompletion:(TCAVRecordCompletion)completion;
- (void)asyncStartRecord:(AVRecordInfo *)record completion:(TCAVRecordCompletion)completion;

// 直播中使用手动方式关闭
// 回调completion会会将recordTryItem置空
- (void)asyncStopRecordCompletion:(TCAVRecordCompletion)completion;

// Protected Method，外部不要调用
// 会自动开启推流
- (void)onAsyncStartRecordOnEnterRoom:(BOOL)ise;

// 退出房间时，如果有推流，TCAVLiveRoomEngine默认调用
- (void)onAsyncStopRecordOnExitRoom:(TCAVRecordCompletion)completion;

@end

