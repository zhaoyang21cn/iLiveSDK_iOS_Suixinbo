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
@property (nonatomic, assign) NSInteger type;//值为0，则返回自动录制完成后回调生成的记录，值为1，则以频道模式，通过http请求，以"sxb_"前缀搜索上报的视频记录
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong) NSString *uid;//查找指定用户的录制文件

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
