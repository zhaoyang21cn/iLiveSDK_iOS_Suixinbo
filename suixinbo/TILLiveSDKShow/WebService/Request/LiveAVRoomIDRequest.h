//
//  LiveAVRoomIDRequest.h
//  TCShow
//
//  Created by AlexiChen on 16/4/27.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "BaseRequest.h"

@interface LiveAVRoomIDRequest : BaseRequest

@property (nonatomic, copy) NSString *uid;

@end

@interface LiveAVRoomIDResponseData : BaseResponseData

@property (nonatomic, assign) int avRoomId;
@end
