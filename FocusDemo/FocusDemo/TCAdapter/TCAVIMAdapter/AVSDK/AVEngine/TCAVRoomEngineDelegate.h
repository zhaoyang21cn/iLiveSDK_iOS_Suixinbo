//
//  TCAVRoomEngineDelegate.h
//  TCShow
//
//  Created by AlexiChen on 16/4/11.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>


@class TCAVBaseRoomEngine;

@class TCAVLiveRoomPushRequest;
@class TCAVLiveRoomRecordRequest;

@protocol TCAVRoomEngineDelegate <NSObject>

@required

// 当前用户主动进入调用enterLive后进入直播AVRoom回调
// engine:
// room: 当前直播间
// succ: 进入房间是否成功
// tip: 成功或失败的提示语
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine enterRoom:(id<AVRoomAble>)room succ:(BOOL)succ tipInfo:(NSString *)tip;

// 当因无网或未传心跳包到后端
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine disConnect:(id<AVRoomAble>)room;

// 当前用户主动进入调用exitLive退出AVRoom回调
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine exitRoom:(id<AVRoomAble>)room succ:(BOOL)succ tipInfo:(NSString *)tip;

// 收到自动推送的视频
// users有视频的用户
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine recvSemiAutoVideo:(NSArray *)users;

//// 本地视频上传到服务端前的回调
//- (void)onAVEngine:(TCAVBaseRoomEngine *)engine preProcessLocaVideoFrame:(QAVVideoFrame *)frame;

// 视频数据渲染回调
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine videoFrame:(QAVVideoFrame *)frame;

// 打开相机回调
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine enableCamera:(BOOL)succ tipInfo:(NSString *)tip;

// 请求用户的user的画面成功
// 此回调只代表（QAVEndpoint requestViewList）发出的请求画面成功，不代表画面一定会显示（有异常情况：比如主播异常了，并且收到hascamera事件，一般情况下请求成功了，稍后一段时间画面即可显示）
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine requestViewOf:(id<IMUserAble>)user succ:(BOOL)succ tipInfo:(NSString *)tip;


@optional

//// 用户User的直播过程中画面丢失
//// 后面计划处理
//// user的画面是否lost(YES:没有上传, NO:连上)
//
//- (void)onAVEngine:(TCAVBaseRoomEngine *)engine user:(id<IMUserAble>)user disconnect:(BOOL)lost;

// 用户首次请求画面（QAVEndpoint requestViewList）成功后，会开始计时，在［engine maxWaitFirstFrameSec］内画面未显示，则回调请求画面超时
- (void)onAVEngineWaitFirstRemoteFrameTimeOut:(TCAVBaseRoomEngine *)engine;

// 用户请求画面成功（QAVEndpoint requestViewList）后，首帧画面到到
- (void)onAVEngineFirstRemoteFrameRender:(TCAVBaseRoomEngine *)engine;

// 修改controlRole回调
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine changeRole:(BOOL)succ tipInfo:(NSString *)tip;

@optional

// 将原- (void)OnEndpointsUpdateInfo:(QAVUpdateEvent)eventID endpointlist:(NSArray *)endpoints 拆分
// AVSDK成员变化通知，不创建IM聊天室情况下使用
// 若创建了IM聊天室，建议使用IM聊天室来来处理直播成员变化（AVSDK 里面的房间，当人数达到一定数量(>50)时，AVSDK不保证这些通知会到达）
// 本次重构中主要侧重使用IM作直播房间监听
// users为 id<IMUserAble>对像，
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users exitRoom:(id<AVRoomAble>)room;
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users enterRoom:(id<AVRoomAble>)room;
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users event:(QAVUpdateEvent)event;


@optional

// 添加推流返回
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine onStartPush:(BOOL)succ pushRequest:(TCAVLiveRoomPushRequest *)req;

// 添加录制返回
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine onRecord:(BOOL)succ recordRequest:(TCAVLiveRoomRecordRequest *)req;


@optional
- (void)onAVEngine:(TCAVBaseRoomEngine *)engine switchRoom:(id<AVRoomAble>)room succ:(BOOL)succ tipInfo:(NSString *)tip;
@end

