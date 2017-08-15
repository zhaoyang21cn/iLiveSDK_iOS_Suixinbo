//
//  RecordReportRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/12.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseRequest.h"

@interface RecordReportRequest : BaseRequest

@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) NSInteger roomnum;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *cover;

@end
