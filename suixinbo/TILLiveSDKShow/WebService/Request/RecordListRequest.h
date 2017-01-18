//
//  RecordListRequest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/12/12.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseRequest.h"

@interface RecordListRequest : BaseRequest

@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger size;

@end


@interface RecordListResponese : BaseResponse

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSMutableArray *videos;

@end

//@interface RecordListRspData : BaseResponseData
//
//@property (nonatomic, assign) NSInteger total;
//
//@property (nonatomic, strong) NSMutableArray *videos;
//
//@end
