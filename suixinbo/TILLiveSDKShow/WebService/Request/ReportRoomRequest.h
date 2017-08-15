//
//  ReportRoomRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseRequest.h"


@class ShowRoomInfo;
@class HostLBS;

@interface ReportRoomRequest : BaseRequest

@property (nonatomic, copy) NSString * token;
@property (nonatomic, strong) ShowRoomInfo * room;
//@property (nonatomic, strong) HostLBS * lbs;
@end


