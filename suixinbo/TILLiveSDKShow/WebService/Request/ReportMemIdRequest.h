//
//  ReportMemIdRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseRequest.h"

@interface ReportMemIdRequest : BaseRequest

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) NSInteger roomnum;
@property (nonatomic, assign) NSInteger role;   //主播：1  普通观众：0 上麦观众：2
@property (nonatomic, assign) NSInteger operate;//0进房间 1退房间

@end
