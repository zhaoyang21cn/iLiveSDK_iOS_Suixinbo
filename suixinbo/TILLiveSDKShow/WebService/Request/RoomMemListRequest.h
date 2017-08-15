//
//  RoomMemListRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/13.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseRequest.h"

@interface RoomMemListRequest : BaseRequest

@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) NSInteger roomnum;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger size;

@end

@interface RoomMemListRspData : BaseResponseData

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSMutableArray   *idlist;

@end
