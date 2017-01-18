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
@property (nonatomic, copy) NSString *videoid;
@property (nonatomic, copy) NSString *playurl;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *cover;

@end
