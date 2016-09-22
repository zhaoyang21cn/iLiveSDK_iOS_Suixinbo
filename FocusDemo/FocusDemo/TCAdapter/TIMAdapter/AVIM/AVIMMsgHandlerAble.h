//
//  AVIMMsgHandlerAble.h
//  TCShow
//
//  Created by AlexiChen on 16/7/20.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AVIMMsgHandlerAble <NSObject>

@required

// 外部逻辑保证imRoom对应的直播聊天室已经创建成功
- (instancetype)initWith:(id<AVRoomAble>)imRoom;

// 进入直播间
- (void)enterLiveChatRoom:(TIMSucc)block fail:(TIMFail)fail;

// 退出直播间
- (void)exitLiveChatRoom:(TIMSucc)block fail:(TIMFail)fail;

// 成员发群消息
- (void)sendMessage:(NSString *)msg;

// 释放相关的引用
- (void)releaseIMRef;

// 发送自定义的消息

- (void)sendCustomGroupMsg:(AVIMCMD *)elem succ:(TIMSucc)succ fail:(TIMFail)fail;

- (void)sendCustomC2CMsg:(AVIMCMD *)elem toUser:(id<IMUserAble>)recv succ:(TIMSucc)succ fail:(TIMFail)fail;



@end
