//
//  AuthRequest.h
//  TILLiveSDKShow
//
//  Created by alderzhang on 18/5/9.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "BaseRequest.h"

@interface AuthRequest : BaseRequest

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *pwd;
@property (nonatomic, assign) NSInteger appid;
@property (nonatomic, assign) NSInteger accountType;
@property (nonatomic, assign) NSInteger roomNum;
@property (nonatomic, assign) NSInteger privMap;//255 所有权限

@end

@interface AuthResponseData : BaseResponseData

@property (nonatomic, copy) NSString *userSig;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) NSInteger privMap;
@property (nonatomic, copy) NSString *privMapEncrypt;

@end
