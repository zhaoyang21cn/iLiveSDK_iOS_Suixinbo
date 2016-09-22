//
//  IMAPlatform+TCAVCall.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportCallScene
#import "IMAPlatform.h"

@class TCAVCallViewController;
@interface IMAPlatform (TCAVCall)

@property (nonatomic, strong) TCAVCallViewController *callViewController;

- (void)onRecvCall:(AVIMCMD *)cmd conversation:(id<AVIMCallHandlerAble>)conv isFromChatting:(BOOL)isChatting;

@end
#endif
