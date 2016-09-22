//
//  IMAPlatform+TCAVLive.m
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAPlatform+TCAVLive.h"



@implementation IMAPlatform (TCAVLive)


- (void)asyncExitHistoryAVChatRoom
{
    [[TIMGroupManager sharedInstance] GetGroupList:^(NSArray *list) {
        for(int index = 0; index < list.count; index++)
        {
            // AVChatRoom 使用longpoll
            TIMGroupInfo* info = list[index];
            if ([info.groupType isEqualToString:kAVChatRoomType])
            {
                // 不用处理返回码，会删除自己创建的群
                DebugLog(@"解散或退出历史直播房间:%@", info.group);
                [[TIMGroupManager sharedInstance] DeleteGroup:info.group succ:nil fail:nil];
            }
        }
    } fail:nil];
}


// 主播 : 主播创建直播聊天室
// 观众 : 观众加入直播聊天室
- (void)asyncEnterAVChatRoom:(id<AVRoomAble>)room succ:(TCAVLiveChatRoomCompletion)succ fail:(TIMFail)fail
{
    if (!room)
    {
        DebugLog(@"直播房房间信息不正确");
        if (fail)
        {
            fail(-1, @"直播房房间信息不正确");
        }
        return;
    }
    
    
    NSString *title = [room liveTitle];
    if (!title || title.length == 0)
    {
        DebugLog(@"直播房房间信息liveTitle不正确");
        if (fail)
        {
            fail(-1, @"直播房房间信息liveTitle不正确");
        }
        return;
    }
    
    
    id<IMUserAble> roomHost = [room liveHost];
    // 外部保证聊天室ID是正确的
    NSString *roomid = [room liveIMChatRoomId];
    BOOL isHost = [self.host isEqual:roomHost];
    
    if (isHost)
    {
        
#if kSupportFixLiveChatRoomID
        // 如果roomid不为空，说明使用roomid作标题来创建直播群
        // 否则使用room liveTitle来作群名创建群
        if (roomid && roomid.length != 0)
        {
            DebugLog(@"----->>>>>主播开始创建直播聊天室:%@ title = %@", roomid, title);
            [[TIMGroupManager sharedInstance] CreateGroup:kAVChatRoomType members:nil groupName:title groupId:roomid succ:^(NSString *groupId) {
                [room setLiveIMChatRoomId:groupId];
                if (succ)
                {
                    succ(room);
                }
                
            } fail:^(int code, NSString *error) {
                // 返回10025，group id has be used，
                // 10025无法区分当前是操作者是否是原群的操作者（目前业务逻辑不存在拿别人的uid创建聊天室逻辑），
                // 为简化逻辑，暂定创建聊天室时返回10025，就直接等同于创建成功
                if (code == 10025)
                {
                    DebugLog(@"----->>>>>主播开始创建直播聊天室成功");
                    [room setLiveIMChatRoomId:roomid];
                    if (succ)
                    {
                        succ(room);
                    }
                }
                else
                {
                    DebugLog(@"----->>>>>主播开始创建直播聊天室失败 code: %d , msg = %@", code, error);
                    if (fail)
                    {
                        fail(code, error);
                    }
                }
            }];
        }
        else
#endif
        {
#if kSupportAVChatRoom
            [[TIMGroupManager sharedInstance] CreateAVChatRoomGroup:title succ:^(NSString *chatRoomID) {
#else
                [[TIMGroupManager sharedInstance] CreateChatRoomGroup:@[[self.host imUserId]] groupName:title succ:^(NSString *chatRoomID) {
#endif
                DebugLog(@"----->>>>>主播开始创建IM聊天室成功");
                [room setLiveIMChatRoomId:chatRoomID];
                if (succ)
                {
                    succ(room);
                }
                
            } fail:^(int code, NSString *error) {
                
                DebugLog(@"----->>>>>主播开始创建IM聊天室失败 code: %d , msg = %@", code, error);
                if (fail)
                {
                    fail(code, error);
                }
            }];
        }
    }
    else
    {
        
        if (roomid.length == 0)
        {
            DebugLog(@"----->>>>>观众加入直播聊天室ID为空");
            if (fail)
            {
                fail(-1, @"直播聊天室ID为空");
            }
            return;
        }
        
        // 观众加群
        [[TIMGroupManager sharedInstance] JoinGroup:roomid msg:nil succ:^{
            DebugLog(@"----->>>>>观众加入直播聊天室成功");
            TCAVLog(([NSString stringWithFormat:@"*** clogs.viewer.enterRoom|%@|join im chat room|room id %@|SUCCEED",self.host.imUserId, roomid]));
            if (succ)
            {
                succ(room);
            }
            
            
        } fail:^(int code, NSString *error) {
            
            if (code == 10013)
            {
                DebugLog(@"----->>>>>观众加入直播聊天室成功");
                TCAVLog(([NSString stringWithFormat:@"*** clogs.viewer.enterRoom|%@|join im chat room|room id %@|SUCCEED(code=10013)",self.host.imUserId, roomid]));
                if (succ)
                {
                    succ(room);
                }
            }
            else
            {
                DebugLog(@"----->>>>>观众加入直播聊天室失败 code: %d , msg = %@", code, error);
                TCAVLog(([NSString stringWithFormat:@"*** clogs.viewer.enterRoom|%@|join im chat room|room id %@|FAIL|code=%d,msg=%@",self.host.imUserId, roomid, code, error]));
                // 作已在群的处的处理
                if (fail)
                {
                    fail(code, error);
                }
            }
            
        }];
    }
    
    
}


- (void)asyncEnterAVChatRoomWithAVRoomID:(id<AVRoomAble>)room succ:(TCAVLiveChatRoomCompletion)succ fail:(TIMFail)fail
{
    if (!room)
    {
        DebugLog(@"直播房房间信息不正确");
        if (fail)
        {
            fail(-1, @"直播房房间信息不正确");
        }
        return;
    }
    
    NSString *title = [[NSDate date] description];
    if (!title || title.length == 0)
    {
        DebugLog(@"直播房房间信息liveTitle不正确");
        if (fail)
        {
            fail(-1, @"直播房房间信息liveTitle不正确");
        }
        return;
    }
    
    
    id<IMUserAble> roomHost = [room liveHost];
    // 外部保证聊天室ID是正确的
    BOOL isHost = [self.host isEqual:roomHost];
    
    if (isHost )
    {
#if kSupportFixLiveChatRoomID
        int avRoomId = [room liveAVRoomId];
        if (avRoomId != 0)
        {
            // 如果roomid不为空，说明使用roomid作标题来创建直播群
            // 否则使用room liveTitle来作群名创建群
            NSString *chatRoomId = [NSString stringWithFormat:@"%d", avRoomId];
            DebugLog(@"----->>>>>主播开始创建直播聊天室:%@ title = %@", chatRoomId, title);
            [[TIMGroupManager sharedInstance] CreateGroup:kAVChatRoomType members:nil groupName:title groupId:chatRoomId succ:^(NSString *groupId) {
                [room setLiveIMChatRoomId:groupId];
                if (succ)
                {
                    TCAVLog(([NSString stringWithFormat:@" *** clogs.host.createRoom|%@|create live im group|group id %@", [IMAPlatform sharedInstance].host.imUserId, groupId]));
                    
                    TCAVLog(([NSString stringWithFormat:@" *** CreateGroup|tinyid = %llu", [[IMSdkInt sharedInstance] getTinyId]]));
                    succ(room);
                }
                
            } fail:^(int code, NSString *error) {
                // 返回10025，group id has be used，
                // 10025无法区分当前是操作者是否是原群的操作者（目前业务逻辑不存在拿别人的uid创建聊天室逻辑），
                // 为简化逻辑，暂定创建聊天室时返回10025，就直接等同于创建成功
                if (code == 10025)
                {
                    TCAVLog(([NSString stringWithFormat:@" *** clogs.host.createRoom|%@|create live im group|group id %@(code=10025,msg=group id has be ysed)", [IMAPlatform sharedInstance].host.imUserId, chatRoomId]));

                    TCAVLog(([NSString stringWithFormat:@" *** CreateGroup|tinyid = %llu", [[IMSdkInt sharedInstance] getTinyId]]));
                    
                    [room setLiveIMChatRoomId:chatRoomId];
                    if (succ)
                    {
                        succ(room);
                    }
                }
                else
                {
                    TCAVLog(([NSString stringWithFormat:@" *** clogs.host.createRoom|%@|create live im group FAIL,code=%d,msg=%@", [IMAPlatform sharedInstance].host.imUserId, code ,error]));
                    
                    if (fail)
                    {
                        fail(code, error);
                    }
                }
            }];
        }
        else
#endif
        {
            [self asyncEnterAVChatRoom:room succ:succ fail:fail];
        }
    }
    else
    {
        [self asyncEnterAVChatRoom:room succ:succ fail:fail];
    }
}

// 主播 : 主播删除直播聊天室
// 观众 : 观众退出直播聊天室
- (void)asyncExitAVChatRoom:(id<AVRoomAble>)room succ:(TIMSucc)succ fail:(TIMFail)fail
{
    if (!room)
    {
        DebugLog(@"直播房房间信息不正确");
        if (fail)
        {
            fail(-1, @"直播房房间信息不正确");
        }
        return;
    }
    
    id<IMUserAble> roomHost = [room liveHost];
    NSString *roomid = [room liveIMChatRoomId];
    
    if (roomid.length == 0)
    {
        DebugLog(@"----->>>>>观众退出的直播聊天室ID为空");
        if (fail)
        {
            fail(-1, @"直播聊天室ID为空");
        }
        return;
    }
    
    
    BOOL isHost = [self.host isEqual:roomHost];
    if (isHost)
    {
        // 主播删群
        [[TIMGroupManager sharedInstance] DeleteGroup:roomid succ:succ fail:fail];
    }
    else
    {
        // 观众退群
        [[TIMGroupManager sharedInstance] QuitGroup:roomid succ:succ fail:fail];
    }
    TCAVLog(([NSString stringWithFormat:@" *** clogs.%@.quitRoom|%@|quit im group|group id %@", isHost ? @"host" : @"viewer", self.host.imUserId, roomid]));
}
@end
