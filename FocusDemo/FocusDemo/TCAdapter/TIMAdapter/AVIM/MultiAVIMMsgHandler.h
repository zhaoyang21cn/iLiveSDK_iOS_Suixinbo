//
//  MultiAVIMMsgHandler.h
//  TCShow
//
//  Created by AlexiChen on 16/4/21.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AVIMMsgHandler.h"


@protocol MultiAVIMMsgListener <AVIMMsgListener>

@required

// 收到自定义的TIMAdapter内的多人互动消息
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvCustomC2CMultiMsg:(id<AVIMMsgAble>)msg;

- (void)onIMHandler:(AVIMMsgHandler *)receiver recvCustomGroupMultiMsg:(id<AVIMMsgAble>)msg;

@end

@interface MultiAVIMMsgHandler : AVIMMsgHandler

// 同步直播聊天室在线用户列表，对于直播间用户量较大时，不会返回所有用户列表
// 通常界面只显示最大max数量的用户
// 注意：此接口仅只用于Demo的业务中
- (void)syncRoomOnlineUser:(NSInteger)max members:(TIMGroupMemberSucc)members fail:(TIMFail)fail;

// 主播相关的操作
// 发送邀请操作
- (void)sendC2CAction:(NSInteger)cmd to:(id<IMUserAble>)interactUser succ:(TIMSucc)succ fail:(TIMFail)fail;

// opUser被操作的人
- (void)sendGroupAction:(NSInteger)cmd operateUser:(id<IMUserAble>)opUser succ:(TIMSucc)succ fail:(TIMFail)fail;


@end
