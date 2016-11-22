//
//  LiveListRequest.h
//  TCShow
//
//  Created by AlexiChen on 15/11/13.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import "BaseRequest.h"
#import "WebModels.h"

@interface LiveListRequest : BaseRequest

@property (nonatomic, strong) RequestPageParamItem *pageItem;

@end


//[LiveListRequest] request's responseString is :
//{"totalItems":2,"items":[{"title":"测试直播","cover":"http://r.plures.net/lg/images/star/live/topbar-logo-large.png","lbs":{"longitude":1.1,"latitude":2.2,"address":"上海市"},"host":{"avatar":"http://r.plures.net/lg/images/star/live/topbar-logo-large.png","uid":1000,"username":"测试用户名","grade":1},"timeSpan":100,"watchCount":100,"watchTimeSpan":800,"admireCount":80},{"title":"测试直播2","cover":"http://r.plures.net/lg/images/star/live/topbar-logo-large.png","lbs":{"longitude":1.1,"latitude":2.2,"address":"上海市"},"host":{"avatar":"http://r.plures.net/lg/images/star/live/topbar-logo-large.png","uid":1000,"username":"测试用户名","grade":1},"timeSpan":100,"watchCount":100,"watchTimeSpan":800,"admireCount":80}]}


@interface TCShowLiveList : BaseResponseData

@property (nonatomic, assign) NSInteger totalItem;

@property (nonatomic, strong) NSMutableArray *recordList;

@end
