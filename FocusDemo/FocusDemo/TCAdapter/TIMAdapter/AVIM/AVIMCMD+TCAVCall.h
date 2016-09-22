//
//  AVIMCMD+TCAVCall.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportCallScene
#import "AVIMMsg.h"

@protocol AVIMCallHandlerAble <NSObject>

- (void)sendCallMsg:(AVIMCMD *)callCmd finish:(CommonFinishBlock)block;

@end

@interface AVIMCMD (TCAVCall)<AVRoomAble>

@property (nonatomic, strong) NSMutableDictionary *callInfo;

// 创建通话自定义命令
- (instancetype)initWithCall:(NSInteger)command avRoomID:(int)roomid group:(NSString *)gid groupType:(NSString *)groupTpe type:(BOOL)isVoiceCall tip:(NSString *)tip;

- (BOOL)isVoiceCall;
- (BOOL)isTCAVCallCMD;
- (BOOL)isGroupCall;

// 是否是讨论组，讨论组才可以邀人进入
// 其他类型不支持邀请加入
- (BOOL)isChatGroup;
- (NSString *)callGroupType;

@end
#endif