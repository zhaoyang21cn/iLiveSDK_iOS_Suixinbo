//
//  TILLiveManager.h
//  ILiveSDK
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TILLiveCommon.h"

@class TIMMessage;
@class TILLiveRoomOption;
@class ILiveRenderView;


@interface TILLiveManager : NSObject

/**
 * 获取单例
 * @return 单例
 */
+ (instancetype)getInstance;

/**
 * 创建房间
 * @param  roomId   房间号
 * @param  option   房间配置
 * @param  succ     成功回调
 * @param  failed   失败回调
 */
- (void)createRoom:(int)roomId option:(TILLiveRoomOption *)option succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

/**
 * 进入房间（观众调用）
 * @param  roomId   房间号
 * @param  option   房间配置
 * @param  succ     成功回调
 * @param  failed   失败回调
 */
- (void)joinRoom:(int)roomId option:(TILLiveRoomOption *)option succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

/**
 * 切换房间（观众调用）
 * @param  roomId   房间号
 * @param  option   房间配置
 * @param  succ     成功回调
 * @param  failed   失败回调
 */
- (void)switchRoom:(int)roomId option:(TILLiveRoomOption *)option succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

/**
 * 退出房间(退出IM群组和音视频房间)
 * @param  succ     成功回调
 * @param  failed   失败回调
 */
- (void)quitRoom:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

/**
 发送跨房连接请求

 @param toId 对方id
 */
- (void)linkRoomRequest:(NSString *)toId succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 跨房连接
 一般是先发送linkRoomRequest，等对方同意，再调用linkRoom

 @param roomId 对方房间号
 @param toId 对方id
 @param authBuf 跨房连麦密钥
 */
- (void)linkRoom:(int)roomId identifier:(NSString *)toId authBuff:(NSString *)authBuf succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 获取当前跨房连麦成员列表

 @return 跨房连麦成员列表
 */
- (NSArray *)getCurrentLinkedUserArray;

/**
 结束跨房连麦(将结束与所有房间的跨房连麦)
 */
- (void)unLinkRoom:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 同意跨房连麦

 @param toId 对方id
 */
- (void)acceptLinkRoom:(NSString *)toId succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 拒绝跨房连麦
 
 @param toId 对方id
 */
- (void)refuseLinkRoom:(NSString *)toId succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 获取当前房间配置
 
 @return 当前房间配置
 */
- (TILLiveRoomOption *)getRoomOption;

/**
 * 设置承载渲染的界面
 * @param  root   承载ILiveRenderView的界面
 */
- (void)setAVRootView:(UIView *)root;

/**
 * 添加渲染界面
 * @param  frame            渲染位置
 * @param  identifier       所属者
 * @param  srcType          视频源
 * @return ILiveRenderView  渲染view
 */
- (ILiveRenderView *)addAVRenderView:(CGRect)frame forIdentifier:(NSString *)identifier srcType:(avVideoSrcType)srcType;

/**
 * 修改渲染界面
 * @param  frame 渲染位置
 * @param  identifier   所属者
 * @param  srcType      视频源
 */
- (void)modifyAVRenderView:(CGRect)frame forIdentifier:(NSString *)identifier srcType:(avVideoSrcType)srcType;

/**
 * 交换渲染界面
 * @param  identifier          所属者1
 * @param  srcType             所属者1视频源
 * @param  anotherIdentifier   所属者2
 * @param  anotherSrcType      所属者2视频源
 * @return BOOL
 */
- (BOOL)switchAVRenderView:(NSString *)identifier srcType:(avVideoSrcType)srcType with:(NSString *)anotherIdentifier anotherSrcType:(avVideoSrcType)anotherSrcType;

/**
 * 获取渲染界面
 * @param  identifier       所属者
 * @param  srcType          视频源
 * @return ILiveRenderView  渲染视图
 */
- (ILiveRenderView *)getAVRenderView:(NSString *)identifier srcType:(avVideoSrcType)srcType;

/**
 * 删除渲染界面
 * @param  identifier  所属者
 * @param  srcType     视频源
 */
- (void)removeAVRenderView:(NSString *)identifier srcType:(avVideoSrcType)srcType;

/**
 * 把渲染视图放到最前面
 * @param identifier  用户
 * @param  srcType     视频源
 */
- (void)bringAVRenderViewToFront:(NSString*)identifier srcType:(avVideoSrcType)srcType;

/**
 * 把渲染视图放到最后面
 * @param identifier  用户
 * @param  srcType     视频源
 */
- (void)sendAVRenderViewToBack:(NSString*)identifier srcType:(avVideoSrcType)srcType;

/**
 获取所有渲染窗口
 @return NSArray ILiveRenderView
 */
- (NSArray *)getAllAVRenderViews;

/**
 删除所有渲染视图
 */
- (void)removeAllAVRenderViews;

/**
 * 请求画面（自动渲染模式下不需要调用）
 * @param  endPoints 请求的用户列表（QAVEndpoint类型）
 * @param  succ      成功回调
 * @param  failed    失败回调
 */
- (void)requestView:(NSArray *)endPoints succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed
__attribute((deprecated("废弃接口，请使用removeAVRenderView:srcType")));
    
/**
 * 发送文本消息
 * @param  msg      文本消息
 * @param  succ     成功回调
 * @param  failed   失败回调
 */
- (void)sendTextMessage:(ILVLiveTextMessage *)msg succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;
//发送在线文本消息
- (void)sendOnlineTextMessage:(ILVLiveTextMessage *)msg succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

/**
 * 发送自定义消息
 * @param  msg       自定义消息
 * @param  succ      成功回调
 * @param  failed    失败回调
 */ 
- (void)sendCustomMessage:(ILVLiveCustomMessage *)msg succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;
//发送在线自定义消息
- (void)sendOnlineCustomMessage:(ILVLiveCustomMessage *)msg succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

/**
 * 发送其他消息（图片消息、声音消息等）
 * @param  msg       消息体
 * @param  recvId    接受者
 * @param  succ      成功回调
 * @param  failed    失败回调
 */
- (void)sendOtherMessage:(TIMMessage *)msg toUser:(NSString *)recvId succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;
//发送在线其它消息
- (void)sendOnlineOtherMessage:(TIMMessage *)msg toUser:(NSString *)recvId succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

/**
 * 观众上麦
 * @param  role     角色字符串 （由用户App的控制台生成）
 * @param  succ     成功回调
 * @param  failed   失败回调
 */
- (void)upToVideoMember:(NSString *)role succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

/**
 * 观众下麦
 * @param  role     角色字符串 （由用户App的控制台生成）
 * @param  succ     成功回调
 * @param  failed   失败回调
 */
- (void)downToVideoMember:(NSString *)role succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)failed;

/**
 * 设置消息监听
 * @param listener 监听对象
 */
- (void)setIMListener:(id<ILVLiveIMListener>)listener;

/**
 * 设置音视频事件监听
 * @param  listener 监听对象
 */
- (void)setAVListener:(id<ILVLiveAVListener>)listener;

/**
 * 获取版本号
 * @return NSString 版本号
 */
- (NSString *)getVersion;
@end
