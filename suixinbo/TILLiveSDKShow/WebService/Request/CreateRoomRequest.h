//
//  CreateRoomRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseRequest.h"

@interface CreateRoomRequest : BaseRequest

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *type;
@end

@interface CreateRoomResponceData : BaseResponseData

@property (nonatomic, assign) NSInteger roomnum;
@property (nonatomic, copy)   NSString *groupid;

@end
