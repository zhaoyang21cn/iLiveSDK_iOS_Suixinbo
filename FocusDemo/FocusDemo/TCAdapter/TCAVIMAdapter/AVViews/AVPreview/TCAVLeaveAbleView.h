//
//  TCAVLeaveAbleView.h
//  TCShow
//
//  Created by AlexiChen on 16/6/30.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

// 主要用来提示用户
@protocol TCAVLeaveAbleView <NSObject>

- (void)onUserLeave:(id<IMUserAble>)user;
- (void)onUserBack:(id<IMUserAble>)user;

@end
