//
//  LoginRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/30.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseRequest.h"

@interface LoginRequest : BaseRequest

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *pwd;

@end

@interface LoginResponceData : BaseResponseData

@property (nonatomic, copy) NSString *userSig;
@property (nonatomic, copy) NSString *token;

@end
