//
//  LogoutRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseRequest.h"

@interface LogoutRequest : BaseRequest

@property (nonatomic, copy) NSString *token;
@end
