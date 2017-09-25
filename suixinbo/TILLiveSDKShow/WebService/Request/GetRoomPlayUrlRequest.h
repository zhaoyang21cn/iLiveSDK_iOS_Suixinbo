//
//  GetRoomPlayUrlRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/29.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseRequest.h"

@interface GetRoomPlayUrlRequest : BaseRequest

@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) NSInteger roomnum;

@end

@interface GetRoomPlayUrlRspData : BaseResponseData

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *address2;
@property (nonatomic, copy) NSString *address3;

@end
