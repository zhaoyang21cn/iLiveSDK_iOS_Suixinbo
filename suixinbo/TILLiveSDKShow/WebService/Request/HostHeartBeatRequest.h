//
//  HostHeartBeatRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseRequest.h"

@interface HostHeartBeatRequest : BaseRequest

@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) NSInteger roomnum;
//1 主播 0观众 2 上麦观众
@property (nonatomic, assign) int role;
@property (nonatomic, assign) int thumbup;//点赞数

@end
