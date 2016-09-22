//
//  IMAPlatform+TCAVLive.h
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAPlatform.h"


typedef void (^TCAVLiveChatRoomCompletion)(id<AVRoomAble> room);

// AVChatRoom特点: 后台会控制每秒收到的消息数在一定数量(比如5条/s)，这样界面就不会频繁有消息刷新

// 与直播相关的接口
@interface IMAPlatform (TCAVLive)

// 登录成功后，退出历史加入的AVChatRoom，不出退的话，IM会一直longpolling直播房间消息，比较占CPU
- (void)asyncExitHistoryAVChatRoom;

// 主播 : 主播创建直播聊天室
// 观众 : 观众加入直播聊天室
- (void)asyncEnterAVChatRoom:(id<AVRoomAble>)room succ:(TCAVLiveChatRoomCompletion)succ fail:(TIMFail)fail;

// 随心播逻辑：新版AVRoomID与ChatRoomID一致
// 主播使用AVRoomID作ChatRoomID创建聊天室，简化AVRoomID与ChatRoomID不一致逻辑 (前提AVRoomID不为0，若为0，与asyncEnterAVChatRoom一致)
// 各App可信照此API新增自身逻辑
// 观众端进入逻辑与asyncEnterAVChatRoom一致
- (void)asyncEnterAVChatRoomWithAVRoomID:(id<AVRoomAble>)room succ:(TCAVLiveChatRoomCompletion)succ fail:(TIMFail)fail;


// 主播 : 主播删除直播聊天室
// 观众 : 观众退出直播聊天室
- (void)asyncExitAVChatRoom:(id<AVRoomAble>)room succ:(TIMSucc)succ fail:(TIMFail)fail;


@end
