//
//  TCICallCMD.h
//  ILiveSDKDemos
//
//  Created by AlexiChen on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ImSDK/TIMFriendshipManager.h>
#import <ImSDK/TIMGroupManager.h>
#import <ImSDK/TIMMessage.h>

@class TCILiveRoom;

@interface TCICallCMD : NSObject

@property (nonatomic, strong) TIMUserProfile *c2csender;        // C2C发消息者，其ID可能与callSponsor
@property (nonatomic, strong) TIMGroupMemberInfo *groupSender;  // 群电话发消息者，其ID可能与callSponsor
@property (nonatomic, assign) NSInteger userAction;             // 命令字
@property (nonatomic, assign) int avRoomID;                     // 房间号
@property (nonatomic, assign) NSString *callSponsor;            // 电话发起者，理解为创建房间的人
@property (nonatomic, copy) NSString *imGroupID;                // 群ID
@property (nonatomic, copy) NSString *imGroupType;              // 群类型
@property (nonatomic, copy) NSString *callTip;                  // 呼叫提示
@property (nonatomic, assign) BOOL callType;                    // 呼叫类型 : YES:音频通话，NO：视频通话
@property (nonatomic, assign) NSDate *callDate;                 // 呼叫时间：收到消息的时候才用

// 创建通话自定义命令
+ (instancetype)parseCustom:(TIMCustomElem *)elem inMessage:(TIMMessage *)msg;

// 主要用于本地解析,不会解析出userAction, 以及c2csender/groupSender, callTip, callDate
+ (TCICallCMD *)analysisCallCmdFrom:(TCILiveRoom *)room;
- (instancetype)initWithC2CCall:(NSInteger)command avRoomID:(int)roomid sponsor:(NSString *)sponsor type:(BOOL)isVoiceCall tip:(NSString *)tip;
- (instancetype)initWithGroupCall:(NSInteger)command avRoomID:(int)roomid sponsor:(NSString *)sponsor group:(NSString *)gid groupType:(NSString *)groupTpe type:(BOOL)isVoiceCall tip:(NSString *)tip;

- (BOOL)isVoiceCall;
- (BOOL)isTCAVCallCMD;
- (BOOL)isGroupCall;

// 是否是讨论组，讨论组才可以邀人进入
// 其他类型不支持邀请加入
- (BOOL)isChatGroup;
- (NSString *)callGroupType;

- (TIMMessage *)packToSendMessage;

// TCICallCMD为接收到的消息才行
- (TCILiveRoom *)parseRoomInfo;

- (NSString *)getSenderID;


@end
