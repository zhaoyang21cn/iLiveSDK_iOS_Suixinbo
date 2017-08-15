//
//  RoomListRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseRequest.h"

@interface RoomListRequest : BaseRequest

@property (nonatomic, copy)   NSString  *token;
@property (nonatomic, copy)   NSString  *type;
@property (nonatomic, assign) NSInteger  index;
@property (nonatomic, assign) NSInteger  size;
@property (nonatomic, assign) NSInteger  appid;

@end

@interface RoomListRspData : BaseResponseData

@property (nonatomic, assign) NSInteger total;

@property (nonatomic, strong) NSMutableArray *rooms;

@end
