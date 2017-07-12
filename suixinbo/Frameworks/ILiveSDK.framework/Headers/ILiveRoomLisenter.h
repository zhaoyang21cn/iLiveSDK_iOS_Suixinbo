//
//  ILiveRoomLisenter.h
//  ILiveSDK
//
//  Created by AlexiChen on 2016/10/24.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QAVSDK/QAVCommon.h>


@protocol ILiveMemStatusListener <NSObject>
/**
 房间成员状态变化通知的函数，房间成员发生状态变化(如是否发音频、是否发视频等)时，会通过该函数通知业务侧。

 @param event     状态变化id，详见QAVUpdateEvent的定义
 @param endpoints 发生状态变化的成员id列表。

 @return YES 执行成功
 */
- (BOOL)onEndpointsUpdateInfo:(QAVUpdateEvent)event updateList:(NSArray *)endpoints;
@end


@protocol ILiveFirstFrameListener <NSObject>
/**
 首帧到达回调
 
 @param width       宽度
 @param height      高度
 @param identifier  id
 @param srcType     视频源
 */
- (void)onFirstFrameRecved:(int)width height:(int)height identifier:(NSString *)identifier srcType:(avVideoSrcType)srcType;
@end

@protocol ILiveRoomDisconnectListener <NSObject>
/**
 SDK主动退出房间提示。该回调方法表示SDK内部主动退出了房间。SDK内部会因为30s心跳包超时等原因主动退出房间，APP需要监听此退出房间事件并对该事件进行相应处理

 @param reason 退出房间的原因，具体值见返回码

 @return YES 执行成功
 */
- (BOOL)onRoomDisconnect:(int)reason;
@end


@protocol ILiveSemiAutoRecvCameraVideoListener <NSObject>
/**
 半自动模式接收摄像头视频的事件通知。
 半自动模式接收摄像头视频的事件通知。也就是当进入房间时，如果已经有人发送了视频，则会自动接收这些视频，不用手动去请求。当然，进入房间后，如何其他人再发送的视频，则不会自动接收。
 @param identifierList 自动接收的摄像头视频所对应的成员id列表。
 */
- (void)onSemiAutoRecvCameraVideo:(NSArray*)identifierList;
@end

@protocol ILiveScreenVideoDelegate <NSObject>
@required

/*!
 @abstract      屏幕分享画面回调
 @param         frameData       屏幕分享视频帧数据
 @see           QAVVideoFrame
 */
- (void)onScreenVideoPreview:(QAVVideoFrame *)frameData;
@end

@protocol ILiveMediaVideoDelegate <NSObject>
@required
/*!
 @abstract      播片画面回调，预留接口，暂时不建议使用
 @param         frameData       播片视频帧数据
 @see           QAVVideoFrame
 */
- (void)onMediaVideoPreview:(QAVVideoFrame *)frameData;
@end
