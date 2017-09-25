//
//  LiveStreamListRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/29.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseRequest.h"
//拉旁路直播列表
@interface LiveStreamListRequest : BaseRequest

@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger size;

@end

@interface LiveStreamListRspData : BaseResponseData

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSMutableArray *videos;

@end
