//
//  LinkRoomSigRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/4/13.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "BaseRequest.h"

@interface LinkRoomSigRequest : BaseRequest

@property (nonatomic, copy) NSString  *token;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) NSInteger targetRoomnum;
@property (nonatomic, assign) NSInteger selfRoomnum;

@end

@interface LinkRoomSigResponseData : BaseResponseData

@property (nonatomic, copy) NSString *linksig;

@end
