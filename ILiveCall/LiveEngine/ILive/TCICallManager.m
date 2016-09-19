//
//  TCICallManager.m
//  ILiveSDK
//
//  Created by AlexiChen on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCICallManager.h"

#import <ImSDK/TIMMessage.h>
#import <ImSDK/TIMConversation.h>

@interface TCICallManager ()

@property (nonatomic, copy) TCICallBlock callingBlock;

@end

@implementation TCICallManager

static TCICallManager *_sharedInstance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _sharedInstance = [[TCICallManager alloc] init];
    });
    
    return _sharedInstance;
}



- (QAVMultiParam *)createRoomParam:(TCILiveRoom *)room
{
    BOOL isHost =  [[_host identifier] isEqualToString:[room liveHostID]];
    QAVMultiParam *param = [[QAVMultiParam alloc] init];
    param.relationId = [room avRoomID];
    param.audioCategory = CATEGORY_MEDIA_PLAY_AND_RECORD;
    param.controlRole = [room.config roomControlRole];
    param.authBits = QAV_AUTH_BITS_DEFAULT;
    param.createRoom = isHost;
    param.videoRecvMode = VIDEO_RECV_MODE_SEMI_AUTO_RECV_CAMERA_VIDEO;
    param.enableMic = room.config.autoEnableMic;
    param.enableSpeaker = YES;
    param.enableHdAudio = YES;
    param.autoRotateVideo = YES;
    
    return param;
}
// 进入房间后，再发送呼叫命令
- (void)makeC2CCall:(NSString *)recvID callCMD:(TCICallCMD *)callCmd completion:(TCIFinishBlock)completion
{
    if ([self isLiving])
    {
        if (callCmd && ![callCmd isGroupCall])
        {
            if (recvID.length)
            {
                TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:recvID];
                
                TIMMessage *mess = [callCmd packToSendMessage];
                if (mess)
                {
                    [conv sendMessage:mess succ:^{
                        TCILDebugLog(@"回复成功[%@]", callCmd);
                        if (completion)
                        {
                            completion(YES);
                        }
                    } fail:^(int code, NSString *msg) {
                        TCILDebugLog(@"回复失败[%@] code : %d msg : %@", callCmd, code, msg);
                        if (completion)
                        {
                            completion(NO);
                        }
                    }];
                    return;
                }
                else
                {
                    TCILDebugLog(@"C2C电话命令格式有误：%@", callCmd);
                }
            }
            else
            {
                TCILDebugLog(@"接听者帐号为空");
            }
        }
        else
        {
            TCILDebugLog(@"不是C2C电话命令：%@", callCmd);
        }
    }
    else
    {
        TCILDebugLog(@"请先进入到直播间再调用此方法");
    }
    
    if (completion)
    {
        completion(NO);
    }
}

- (void)makeGroupCall:(NSArray *)recvIDs callCMD:(TCICallCMD *)callCmd completion:(TCIFinishBlock)completion
{
    if ([self isLiving])
    {
        if (callCmd && [callCmd isGroupCall])
        {
            NSString *recvID = callCmd.imGroupID;
            if (recvID.length)
            {
                TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:recvID];
                
                TIMMessage *mess = [callCmd packToSendMessage];
                if (mess)
                {
                    [conv sendMessage:mess succ:^{
                        TCILDebugLog(@"回复成功[%@]", callCmd);
                        if (completion)
                        {
                            completion(YES);
                        }
                    } fail:^(int code, NSString *msg) {
                        TCILDebugLog(@"回复失败[%@] code : %d msg : %@", callCmd, code, msg);
                        if (completion)
                        {
                            completion(NO);
                        }
                    }];
                    return;
                }
                else
                {
                    TCILDebugLog(@"C2C电话命令格式有误：%@", callCmd);
                }
            }
            else
            {
                TCILDebugLog(@"接听者帐号为空");
            }
        }
        else
        {
            TCILDebugLog(@"不是C2C电话命令：%@", callCmd);
        }
    }
    
    if (completion)
    {
        completion(NO);
    }
}

- (void)registCallHandle:(TCICallBlock)handcall
{
    self.callingBlock = handcall;
}

// 收到电话命令后，根据callCmd中的参数，创建房间，并进入
- (void)acceptCall:(TCICallCMD *)callCmd completion:(TCIAcceptCallBlock)completion listener:(id<TCILiveManagerDelegate>)delegate
{
    if (callCmd)
    {
        TCILiveRoom *room = [callCmd parseRoomInfo];
        
        self.delegate = delegate;
        __weak typeof(self) ws = self;
        [self enterRoom:room imChatRoomBlock:nil avRoomCallBack:^(BOOL succ, NSError *err) {
            
            if (succ)
            {
                // 进入成功
                TCICallCMD *recmd = [[TCICallCMD alloc] initWithGroupCall:AVIMCMD_Call_Connected avRoomID:callCmd.avRoomID sponsor:room.liveHostID group:callCmd.imGroupID groupType:callCmd.imGroupType type:callCmd.callType tip:@"连线成功"];
                [ws replyCallCMD:recmd onRecv:callCmd];
            }
            else
            {
                // 进入失败
                TCICallCMD *recmd = [[TCICallCMD alloc] initWithGroupCall:AVIMCMD_Call_LineBusy avRoomID:callCmd.avRoomID sponsor:room.liveHostID group:callCmd.imGroupID groupType:callCmd.imGroupType type:callCmd.callType tip:@"连线不成功"];
                [ws replyCallCMD:recmd onRecv:callCmd];
                
            }
            
            if (completion)
            {
                completion(succ, err, succ ? room : nil);
            }
        }];
    }
    else
    {
        TCILDebugLog(@"callCmd 参数错误");
    }
}

// 收到电话命令后，根据callCmd中的参数，创建房间，并进入
- (void)rejectCallAt:(TCICallCMD *)recmd completion:(TCIFinishBlock)completion;
{
    if (recmd)
    {
        recmd.userAction = AVIMCMD_Call_Disconnected;
        recmd.callTip = @"对方已挂断";
        
        TIMMessage *mess = [recmd packToSendMessage];
        
        if (recmd.isGroupCall)
        {
            
            NSString *recvID = [recmd imGroupID];
            TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:recvID];
            [conv sendMessage:mess succ:^{
                TCILDebugLog(@"回复成功[%@]", recmd);
                if (completion)
                {
                    completion(YES);
                }

            } fail:^(int code, NSString *msg) {
                TCILDebugLog(@"回复失败[%@] code : %d msg : %@", recmd, code, msg);
                if (completion)
                {
                    completion(NO);
                }
            }];
        }
        else
        {
            
            TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:_room.liveHostID];
            [conv sendMessage:mess succ:^{
                TCILDebugLog(@"回复成功[%@]", recmd);
                if (completion)
                {
                    completion(YES);
                }
            } fail:^(int code, NSString *msg) {
                TCILDebugLog(@"回复失败[%@] code : %d msg : %@", recmd, code, msg);
                if (completion)
                {
                    completion(NO);
                }
            }];

        }
    }
}

// 挂断电话，并退出房间
- (void)endCallCompletion:(TCIRoomBlock)completion
{
    TCICallCMD *recmd = [TCICallCMD analysisCallCmdFrom:_room];
    
    if (recmd)
    {
        recmd.userAction = AVIMCMD_Call_Disconnected;
        recmd.callTip = @"对方已挂断";
        
        TIMMessage *mess = [recmd packToSendMessage];
        
        if (recmd.isGroupCall)
        {
            NSString *recvID = [recmd imGroupID];
            TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:recvID];
            [conv sendMessage:mess succ:^{
                TCILDebugLog(@"回复成功[%@]", recmd);
            } fail:^(int code, NSString *msg) {
                TCILDebugLog(@"回复失败[%@] code : %d msg : %@", recmd, code, msg);
            }];
        }
        else
        {
            TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:_room.liveHostID];
            [conv sendMessage:mess succ:^{
                TCILDebugLog(@"回复成功[%@]", recmd);
            } fail:^(int code, NSString *msg) {
                TCILDebugLog(@"回复失败[%@] code : %d msg : %@", recmd, code, msg);
            }];
            
        }
        
        [self exitRoom:completion];
    }
}

- (void)exitRoom:(TCIRoomBlock)avBlock
{
    [super exitRoom:avBlock];
}

- (void)replyCallCMD:(TCICallCMD *)cmd onRecv:(TCICallCMD *)fromCMD
{
    TIMMessage *msg = [cmd packToSendMessage];
    if (cmd.isGroupCall)
    {
        NSString *recvID = [cmd imGroupID];
        TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:recvID];
        [conv sendMessage:msg succ:^{
            TCILDebugLog(@"回复成功[%@]", fromCMD);
        } fail:^(int code, NSString *msg) {
            TCILDebugLog(@"回复失败[%@] code : %d msg : %@", fromCMD, code, msg);
        }];
    }
    else
    {
        NSString *recvID = [fromCMD.c2csender identifier];
        if (recvID.length)
        {
            TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:recvID];
            [conv sendMessage:msg succ:^{
                TCILDebugLog(@"回复成功[%@]", fromCMD);
            } fail:^(int code, NSString *msg) {
                TCILDebugLog(@"回复失败[%@] code : %d msg : %@", fromCMD, code, msg);
            }];
        }
    }
}

- (void)handleCallCMD:(TCICallCMD *)cmd
{
    if (!cmd)
    {
        return;
    }
    // 说明正在通话中
    if ([self isLiving])
    {
        int oldAVroomID = [_room avRoomID];
        int newAVRoomID = [cmd avRoomID];
        if (oldAVroomID != newAVRoomID)
        {
            // 不是此房间的通话命令，直接回复占线
            
            TCICallCMD *busycmd = [[TCICallCMD alloc] initWithGroupCall:AVIMCMD_Call_LineBusy avRoomID:[cmd avRoomID] sponsor:_room.liveHostID group:[cmd imGroupID] groupType:[cmd imGroupType] type:[cmd isVoiceCall] tip:@"对方占线，不方便接听"];
            [self replyCallCMD:busycmd onRecv:cmd];
            return;
        }
        else
        {
            // 同一房间的消息
            [self handleCallingCMD:cmd];
        }
    }
    else
    {
        if (cmd.userAction == AVIMCMD_Call_Dialing || cmd.userAction == AVIMCMD_Call_Invite)
        {
            if (self.incomingCallBlock)
            {
                self.incomingCallBlock(cmd);
            }
        }
        else
        {
            // TODO: 忽略其他消息
        }
        
    }
}

- (void)handleCallingCMD:(TCICallCMD *)cmd
{
    if (self.callingBlock)
    {
        self.callingBlock(cmd);
    }
}

- (void)filterCallMessageInNewMessages:(NSArray *)messages
{
    for (TIMMessage *msg in messages)
    {
        [self filterCallMessageNewMessage:msg];
    }
}

- (void)filterCallMessageNewMessage:(TIMMessage *)msg
{
    if (msg.elemCount > 0)
    {
        TIMElem *ele = [msg getElem:0];
        if ([ele isKindOfClass:[TIMCustomElem class]])
        {
            TIMCustomElem *callelem = (TIMCustomElem *)ele;
            TCICallCMD *cmd = [TCICallCMD parseCustom:callelem inMessage:msg];
            
            if (cmd && [cmd isTCAVCallCMD])
            {
                [self handleCallCMD:cmd];
            }
        }
        
    }
}


@end


@implementation TCICallManager (ProtectedMethod)

- (void)onLogoutCompletion
{
    [super onLogoutCompletion];
    self.callingBlock = nil;
    self.incomingCallBlock = nil;
}


@end