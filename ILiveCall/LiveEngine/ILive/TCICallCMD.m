//
//  TCICallCMD.m
//  ILiveSDKDemos
//
//  Created by AlexiChen on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCICallCMD.h"
#import "TCILiveConst.h"
#import "TCILiveRoom.h"
#import "TCICallManager.h"



@implementation TCICallCMD

// 语音视频通话中用到的关键字
// int 类型
#define kTCAVCall_AVRoomID          @"AVRoomID"

// NSString, 群号可为空
#define kTCAVCall_IMGroupID         @"IMGroupID"

// 群类型
#define kTCAVCall_IMGroupType       @"IMGroupType"

// NSString, 呼叫提示
#define kTCAVCall_CallTip           @"CallTip"

// BOOL，YES:语音，NO，视频
#define kTCAVCall_CallType           @"CallType"

// Double, 呼叫时间
#define kTCAVCall_CallDate          @"CallDate"

#define kTCAVCall_CallSponsor       @"CallSponsor"

#define kTCAVCALL_UserAction        @"userAction"

#define kTCAVCALL_ActionParam       @"actionParam"

- (NSDictionary *)packToSendDic
{
    NSMutableDictionary *post = [NSMutableDictionary dictionary];
    [post setObject:@(_userAction) forKey:kTCAVCALL_UserAction];
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:@(_avRoomID) forKey:kTCAVCall_AVRoomID];
    
    if (_callSponsor.length)
    {
        [dic setObject:_callSponsor forKey:kTCAVCall_CallSponsor];
    }
    
    if (_imGroupID.length)
    {
        [dic setObject:_imGroupID forKey:kTCAVCall_IMGroupID];
    }
    
    if (_imGroupType.length)
    {
        [dic setObject:_imGroupType forKey:kTCAVCall_IMGroupType];
    }
    
    if (_callTip.length)
    {
        [dic setObject:_callTip forKey:kTCAVCall_CallTip];
    }
    
    if (_callType)
    {
        [dic setObject:@(_callType) forKey:kTCAVCall_CallType];
    }
    
    [dic setObject:@([[NSDate date] timeIntervalSince1970]) forKey:kTCAVCall_CallDate];
    
    
    [post setObject:dic forKey:kTCAVCALL_ActionParam];
    
    return post;
}

- (NSData *)packToSendData
{
    
    NSDictionary *post = [self packToSendDic];
    
    if ([NSJSONSerialization isValidJSONObject:post])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:post options:NSJSONWritingPrettyPrinted error:&error];
        if(error)
        {
            TCILDebugLog(@"[%@] Post Json Error: %@", [self class], post);
            return nil;
        }
        
        TCILDebugLog(@"AVIMCMD content is %@", post);
        return data;
    }
    else
    {
        TCILDebugLog(@"[%@] AVIMCMD is not valid: %@", [self class], post);
        return nil;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self packToSendDic]];
}

- (TIMMessage *)packToSendMessage
{
    TIMMessage *msg = [[TIMMessage alloc] init];
    
    TIMCustomElem *elem = [[TIMCustomElem alloc] init];
    elem.data = [self packToSendData];
    
    [msg addElem:elem];
    
    
    
    return msg;
}



+ (instancetype)parseCustom:(TIMCustomElem *)elem inMessage:(TIMMessage *)msg
{
    NSData *data = elem.data;
    if (data)
    {
        
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if (json)
        {
            if ([json isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *jd = (NSDictionary *)json;
                
                TCICallCMD *cmd = [[TCICallCMD alloc] init];
                
                cmd.c2csender = [msg GetSenderProfile];
                cmd.groupSender = [msg GetSenderGroupMemberProfile];
                
                
                cmd.userAction = [(NSNumber *)[jd objectForKey:kTCAVCALL_UserAction] intValue];
                
                if (cmd.userAction >= AVIMCMD_Call && cmd.userAction <= AVIMCMD_Call_AllCount)
                {
                    NSDictionary *dic = jd[kTCAVCALL_ActionParam];
                    cmd.avRoomID = [(NSNumber *)[dic objectForKey:kTCAVCall_AVRoomID] intValue];
                    cmd.callSponsor = (NSString *)[dic objectForKey:kTCAVCall_CallSponsor];
                    cmd.imGroupID = (NSString *)[dic objectForKey:kTCAVCall_IMGroupID];
                    cmd.imGroupType = (NSString *)[dic objectForKey:kTCAVCall_IMGroupType];
                    cmd.callTip = (NSString *)[dic objectForKey:kTCAVCall_CallTip];
                    cmd.callType = [(NSNumber *)[dic objectForKey:kTCAVCall_CallType] boolValue];
                    
                    double df = [(NSNumber *)[dic objectForKey:kTCAVCall_CallDate] doubleValue];
                    cmd.callDate = [NSDate dateWithTimeIntervalSince1970:df];
                }
                
                return cmd;
            }
        }

    }
    
    TCILDebugLog(@"自定义消息不是AVIMCMD类型");
    return nil;
    
}

+ (TCICallCMD *)analysisCallCmdFrom:(TCILiveRoom *)room
{
    if (room)
    {
        TCICallCMD *cmd = [[TCICallCMD alloc] init];
        
        cmd.callSponsor = room.liveHostID;
        cmd.avRoomID = room.avRoomID;
        cmd.imGroupID = room.chatRoomID;
        cmd.imGroupType = room.config.imChatRoomType;
        cmd.callType = room.config.isVoiceCall;
        return cmd;
    }
    return nil;
}

- (TCILiveRoom *)parseRoomInfo
{
    if (self.c2csender || self.groupSender)
    {
        NSString *curid = [[TCICallManager sharedInstance].host identifier];
        if (self.c2csender)
        {
            TCILiveRoom *room = [[TCILiveRoom alloc] initC2CCallWith:self.avRoomID liveHost:self.callSponsor curUserID:curid callType:self.callType];
            return room;
        }
        else if(self.groupSender)
        {

            TCILiveRoom *room = [[TCILiveRoom alloc] initGroupCallWith:self.avRoomID liveHost:self.callSponsor groupID:self.imGroupID groupType:self.imGroupType curUserID:curid callType:self.callType];
            return room;
        }
    }
    return nil;
}

- (instancetype)initWithC2CCall:(NSInteger)command avRoomID:(int)roomid sponsor:(NSString *)sponsor type:(BOOL)isVoiceCall tip:(NSString *)tip
{
    return [self initWithGroupCall:command avRoomID:roomid sponsor:sponsor group:nil groupType:nil type:isVoiceCall tip:tip];
}

- (instancetype)initWithGroupCall:(NSInteger)command avRoomID:(int)roomid sponsor:(NSString *)sponsor group:(NSString *)gid groupType:(NSString *)groupTpe type:(BOOL)isVoiceCall tip:(NSString *)tip
{
    if (roomid < 0)
    {
        TCILDebugLog(@"房间号参数不合法");
        return nil;
    }
    
    if (!((gid.length > 0 && groupTpe.length > 0) || (groupTpe.length == 0 && groupTpe.length == 0)))
    {
        TCILDebugLog(@"群号参数不合法");
        return nil;
    }
    
    if (sponsor.length == 0)
    {
        TCILDebugLog(@"群号参数不合法");
        return nil;
    }
    
    
    if (self = [super init])
    {
        self.userAction = command;
        self.avRoomID = roomid;
        self.callSponsor = sponsor;
        self.imGroupID = gid;
        self.imGroupType = groupTpe;
        self.callType = isVoiceCall;
        self.callTip = tip;
    }
    return self;
}

- (BOOL)isVoiceCall
{
    return self.callType;
}

- (BOOL)isGroupCall
{
    return self.imGroupID.length > 0;
}

- (BOOL)isChatGroup
{
    return [self.imGroupType isEqualToString:@"Private"];
}

- (NSString *)callGroupType
{
    return self.imGroupType;
}

- (BOOL)isTCAVCallCMD
{
    return self.userAction > AVIMCMD_Call && self.userAction < AVIMCMD_Call_AllCount;
}

- (NSString *)getSenderID
{
    if (self.c2csender)
    {
        return self.c2csender.identifier;
    }
    else if (self.groupSender)
    {
        return self.groupSender.member;
    }
    else
    {
        TCILDebugLog(@"本地创建的消息，senderID为当前登录用户的帐号");
        return nil;
    }
}

@end
