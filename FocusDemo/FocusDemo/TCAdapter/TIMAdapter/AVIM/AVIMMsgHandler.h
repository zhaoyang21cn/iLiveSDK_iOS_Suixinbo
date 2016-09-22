//
//  AVIMMsgHandler.h
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 修改日志
 *================================================================
 * 时间: 20160525
 * 改动项: 增加缓存模式，
 * 详细介绍:  缓存模式下，消息不再主动往UI上报，而是等UI定时来取，目前直播大群中，主要针对群文本消息，以及群点赞消息作缓存处理，其他类型消息依然使用直接上报UI，进缓存不成功的消息，也会直接上报
 *          取消息频率由外部控制，另外缓存的消息如果超长不取会自动丢掉
 *          用户如果要增加其他其他的式
 *================================================================
 *
 */

// 主要处理直播房间中的IM消息
// AVIMMsgHandler内处理的TIMMessage只包含一个Elem情况，不处理多个Elem，使用时请不要发送多个elem情况
@class AVIMMsgHandler;

@protocol AVIMMsgListener <NSObject>


@required

// 收到群聊天消息: (主要是文本类型)
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvGroupMsg:(id<AVIMMsgAble>)msg;

// 群主解散群消息，或后台自动解散
- (void)onIMHandler:(AVIMMsgHandler *)receiver deleteGroup:(id<IMUserAble>)sender;

// 有新用户进入
// senders是id<IMUserAble>类型
- (void)onIMHandler:(AVIMMsgHandler *)receiver joinGroup:(NSArray *)senders;

// 有用户退出
// senders是id<IMUserAble>类型
- (void)onIMHandler:(AVIMMsgHandler *)receiver exitGroup:(NSArray *)senders;

// 收到自定义C2C消息
// 用户自行解析
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvCustomC2C:(id<AVIMMsgAble>)msg;

// 收到自定义的Group消息
// 用户自行解析
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvCustomGroup:(id<AVIMMsgAble>)msg;

@end

// 内部收发消息会作缓存，处理成要显示的消息后，然后外部主动刷新时，再拿到缓存消息进行显示
// 本类中发消息从主线程中进入，收消息后马上进入子线程处理，处理完成后再返回主界面刷新


@interface AVIMMsgHandler : NSObject<AVIMMsgHandlerAble, TIMMessageListener, TIMGroupMemberListener>
{
@protected
    id<AVRoomAble>          _imRoomInfo;            // 房间信息
    TIMConversation         *_chatRoomConversation; // 群会话上下文
    
@protected
   __weak AVIMRunLoop      *_sharedRunLoopRef;           // 消息处理线程的引用
    
    
@protected
    BOOL                    _isCacheMode;           // 是否是缓存模式，详见修改日志时间: 20160525
    NSMutableDictionary     *_msgCache;             // 以key为id<AVIMMsgAble> msgtype的, value不AVIMCache，在runloop线程中执行
    OSSpinLock              _msgCacheLock;
    
@protected
    __weak id<AVIMMsgListener> _roomIMListner;
    
@protected
    BOOL                        _isPureMode;    // 纯净模工下，收到消息后，不作渲染计算
}

@property (nonatomic, weak) id<AVIMMsgListener> roomIMListner;
// 是否使用纯净模式
@property (nonatomic, assign) BOOL isPureMode;

// 运行过程中，如果先是YES，再置为NO，设置前使用者注意将_msgCache的取出，内部自动作清空处理
@property (nonatomic, assign) BOOL isCacheMode;     // 是否是缓存模式

// 发送点赞消息，AVIMMsgHandler里是空方法，供子类重写
// 用户可根据业务需要，使用群或C2C发送
// 另外点赞消息产生的动画，大量产生时非常耗性能，建议观众端从业务上处理，不要频繁发送，demo中是只允许1秒点一次
- (void)sendLikeMessage;

// 切换到对应的直播间
// 外部保证imRoom的正确性
- (void)switchToLiveRoom:(id<AVRoomAble>)imRoom;

@end


@interface AVIMMsgHandler (ProtectedMethod)

// 供子类重写

// C2C消息时，查不到用户的头像信息
- (id<IMUserAble>)syncGetC2CUserInfo:(NSString *)identifier;



// 收到群自定义消息处理
// 返回的是界面上待处理的消息内容，最终放入
- (void)onRecvGroupSender:(id<IMUserAble>)sender textMsg:(NSString *)msg;

// 收到群自定义消息处理
- (void)onRecvGroupSender:(id<IMUserAble>)sender customMsg:(TIMCustomElem *)msg;

// 重写多人互动时
- (BOOL)onHandleRecvMultiGroupSender:(id<IMUserAble>)sender customMsg:(id<AVIMMsgAble>)cachedMsg;

// 收到C2C自定义消息
- (void)onRecvC2CSender:(id<IMUserAble>)sender customMsg:(TIMCustomElem *)msg;

// sender进入直播间
- (id<AVIMMsgAble>)onRecvSender:(id<IMUserAble>)sender tipMessage:(NSString *)msg;
- (id<AVIMMsgAble>)onRecvSenderEnterLiveRoom:(id<IMUserAble>)sender;
- (id<AVIMMsgAble>)onRecvSenderLeaveLiveRoom:(id<IMUserAble>)sender;
- (id<AVIMMsgAble>)onRecvSenderBackLiveRoom:(id<IMUserAble>)sender;
- (id<AVIMMsgAble>)onRecvSenderExitLiveRoom:(id<IMUserAble>)sender;

// 如果delayDisplay这YES时，重写以下方法
- (id<AVIMMsgAble>)cacheRecvGroupSender:(id<IMUserAble>)sender textMsg:(NSString *)msg;
- (id<AVIMMsgAble>)cacheRecvGroupSender:(id<IMUserAble>)sender customMsg:(TIMCustomElem *)msg;
- (id<AVIMMsgAble>)cacheRecvC2CSender:(id<IMUserAble>)sender customMsg:(TIMCustomElem *)msg;




@end


typedef void (^AVIMCacheBlock)(id<AVIMMsgAble> msg);

@interface AVIMMsgHandler (CacheMode)

// 用户通过设置此方法，监听要处理的消息类型
- (void)createMsgCache;

- (void)resetMsgCache;
- (void)releaseMsgCache;

// 如果cache不成功，会继续上报
- (void)enCache:(id<AVIMMsgAble>)msg noCache:(AVIMCacheBlock)noCacheblock;


- (NSDictionary *)getMsgCache;

@end