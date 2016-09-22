//
//  FocusDemoRoom.h
//  FocusDemoRoom
//
//  Created by wilderliao on 16/9/18.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FocusDemoRoom : NSObject<AVRoomAble>

@property (nonatomic, copy) NSString *liveIMChatRoomId;
@property (nonatomic, strong) id<IMUserAble> liveHost;
@property (nonatomic, assign) int liveAVRoomId;
@property (nonatomic, copy) NSString * liveTitle;

@end
