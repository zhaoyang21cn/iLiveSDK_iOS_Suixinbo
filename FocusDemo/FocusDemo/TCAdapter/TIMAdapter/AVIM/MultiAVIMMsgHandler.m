//
//  MultiAVIMMsgHandler.m
//  TCShow
//
//  Created by AlexiChen on 16/4/21.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "MultiAVIMMsgHandler.h"

@implementation MultiAVIMMsgHandler


// 收到C2C自定义消息
- (void)onRecvC2CSender:(id<IMUserAble>)sender customMsg:(TIMCustomElem *)msg
{
    id<AVIMMsgAble> cachedMsg = [self cacheRecvC2CSender:sender customMsg:msg];
    [self enCache:cachedMsg noCache:^(id<AVIMMsgAble> msg){
        dispatch_async(dispatch_get_main_queue(), ^{
            // Demo中此类不处理C2C消息
            if (msg)
            {
                NSInteger type = [msg msgType];
                if (type > AVIMCMD_Multi && type < AVIMCMD_Multi_Custom)
                {
                    DebugLog(@"收到消息：%@", msg);
                    // 收到内部的自定义多人互动消
                    if ([_roomIMListner respondsToSelector:@selector(onIMHandler:recvCustomC2CMultiMsg:)])
                    {
                        [(id<MultiAVIMMsgListener>)_roomIMListner onIMHandler:self recvCustomC2CMultiMsg:msg];
                    }
                }
                else
                {
                    DebugLog(@"收到消息：%@", cachedMsg);
                    [_roomIMListner onIMHandler:self recvCustomC2C:msg];
                }
            }
        });
    }];
}



// 同步直播聊天室在线用户列表，对于直播间用户量较大时，不会返回所有用户列表
// 通常界面只显示最大max数量的用户
- (void)syncRoomOnlineUser:(NSInteger)max members:(TIMGroupMemberSucc)membersBlock fail:(TIMFail)fail
{
    if (!membersBlock)
    {
        return;
    }
    if ([[IMAPlatform sharedInstance].host isCurrentLiveHost:_imRoomInfo])
    {
        // TODO: 目前接口暂不支持拉取指定数量的用户
        __weak id<IMUserAble> wu = [_imRoomInfo liveHost];
        NSString *groupid = [_imRoomInfo liveIMChatRoomId];
        [[TIMGroupManager sharedInstance] GetGroupMembers:groupid succ:^(NSArray *members) {
            NSMutableArray *array = [NSMutableArray array];
            for (TIMGroupMemberInfo *mem in members)
            {
                [array addObject:[mem imUserId]];
            }
            
            [[TIMFriendshipManager sharedInstance] GetUsersProfile:array succ:^(NSArray *friends) {
                NSMutableArray *array = [NSMutableArray array];
                for (TIMUserProfile *u in friends)
                {
                    // 过滤掉主播
                    if (![[u imUserId] isEqualToString:[wu imUserId]])
                    {
                        [array addObject:u];
                    }
                    
                    if (array.count == max)
                    {
                        break;
                    }
                }
                
                membersBlock(array);
            } fail:^(int code, NSString *msg) {
                if (fail)
                {
                    fail(code, msg);
                }
            }];

        } fail:fail];
    }
}


// 收到群自定义消息处理
- (BOOL)onHandleRecvMultiGroupSender:(id<IMUserAble>)sender customMsg:(id<AVIMMsgAble>)cachedMsg
{
    
    if (cachedMsg)
    {
        BOOL hasHandle = YES;
        NSInteger type = [cachedMsg msgType];
        if (type > 0 && sender)
        {
            switch (type)
            {
                    //处理取消互动逻辑
                case AVIMCMD_Multi_CancelInteract:
                {
                    [self enCache:cachedMsg noCache:^(id<AVIMMsgAble> msg){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([_roomIMListner respondsToSelector:@selector(onIMHandler:recvCustomGroupMultiMsg:)])
                            {
                                [(id<MultiAVIMMsgListener>)_roomIMListner onIMHandler:self recvCustomGroupMultiMsg:msg];
                            }
                        });
                    }];
                }
                    break;
                    
                    
                default:
                    hasHandle = NO;
                    break;
            }
        }
        
        return hasHandle;
    }
    return NO;
}



- (void)sendC2CAction:(NSInteger)cmd to:(id<IMUserAble>)interactUser succ:(TIMSucc)succ fail:(TIMFail)fail
{
    AVIMCMD *ac = [[AVIMCMD alloc] initWith:cmd];
    [self sendCustomC2CMsg:ac toUser:interactUser succ:succ fail:fail];
}

// opUser被操作的人
- (void)sendGroupAction:(NSInteger)cmd operateUser:(id<IMUserAble>)opUser succ:(TIMSucc)succ fail:(TIMFail)fail
{
    AVIMCMD *ac = [[AVIMCMD alloc] initWith:cmd];
    ac.actionParam = [opUser imUserId];
    [self sendCustomGroupMsg:ac succ:succ fail:fail];
}


@end
