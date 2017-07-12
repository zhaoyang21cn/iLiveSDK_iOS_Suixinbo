//
//  ILiveRoomManager.h
//  ILiveSDK
//
//  Created by AlexiChen on 2016/10/24.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QAVSDK/QAVSDK.h>
#import "ILiveCommon.h"


@class ILiveRoomOption;
@class ILivePushOption;
@class ILiveRecordOption;
@class ILiveQualityData;
@class ILiveFrameDispatcher;
@class QAVMultiRoom;
@class TIMMessage;
@protocol ILiveScreenVideoDelegate;
@protocol ILiveMediaVideoDelegate;

/**
 ILiveSDK房间管理器类
 */
@interface ILiveRoomManager : NSObject

/**
 获取房间管理器单例

 @return 房间管理器单例
 */
+ (instancetype)getInstance;

/**
 创建直播间（主播端调用）

 @param roomId 直播间ID
 @param option 房间配置
 @param succ   创建直播间成功回调
 @param fail   创建直播间失败回调
 */
- (void)createRoom:(int)roomId option:(ILiveRoomOption *)option succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 加入直播间（观众端调用）

 @param roomId 直播间ID
 @param option 房间配置
 @param succ   加入直播间成功回调
 @param fail   加入直播间失败回调
 */
- (void)joinRoom:(int)roomId option:(ILiveRoomOption *)option succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 切换直播间（观众端调用）
 
 @param roomId 直播间ID
 @param option 房间配置
 @param succ   加入直播间成功回调
 @param fail   加入直播间失败回调
 */
- (void)switchRoom:(int)roomId option:(ILiveRoomOption *)option succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 退出直播间(退出im群租和音视频房间)

 @param succ  退出直播间成功回调
 @param fail 退出直播间失败回调
 */
- (void)quitRoom:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 跨房连麦

 @param roomId 对方房间号
 @param toId 对方id
 @param authBuf 跨房连麦密钥
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)linkRoom:(int)roomId identifier:(NSString *)toId authBuff:(NSString *)authBuf succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;
/**
 结束跨房连麦(将结束与所有房间的跨房连麦)

 @param succ 成功回调
 @param fail 失败回调
 */
- (void)unLinkRoom:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 设置美颜（设备支持美颜并摄像头打开）
 
 @param  value 取值范围在0-9之间，0代表关闭美颜
 @return BOOL  设置是否成功
 */
- (BOOL)setBeauty:(float)value;

/**
 设置美白（设备支持美颜并摄像头打开）
 
 @param  value  取值范围在0-9之间，0代表关闭美白
 @return BOOL   设置是否成功
 */
- (BOOL)setWhite:(float)value;

/**
 同时请求一个或多个成员的视频画面。同一时刻只能请求一次成员的画面，并且必须等待异步结果返回后，才能进行新的请求画面操作。
 
 @remark
 . requestViewList和cancelAllView不能并发执行，即同一时刻只能进行一种操作。
 . identifierList和srcTypeList的因素个数必须相等，同时每个元素是一一对应的。
 . 在请求画面前最好先检查该成员是否有对应的视频源。
 
 @param identifierList 请求的成员id列表。传递成员的identifier(NSString*)
 @param srcTypeList    视频源类型列表。传递成员的avVideoSrcType(NSNumber*)
 @param succ           请求成功回调
 @param fail           请求失败回调
 
 QAV_ERR_BUSY表示上一次操作(包括requestViewList\cancelViewList\cancelAllView)还在进行中；QAV_ERR_FAILED表示操作失败，可能是因为所请求的成员当前已经没有对应视频源的视频、所请求成员已经退出房间等。
 */
- (void)requestViewList:(NSArray*)identifierList srcTypeList:(NSArray*)srcTypeList succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 取消指定用户的画面

 @param identifierList 要取消画面的用户列表
 @param srcTypeList 要取消画面的用户列表对应的视频类型
 @param succ           成功回调
 @param fail           失败回调
 */
- (void)cancelViewList:(NSArray *)identifierList srcTypeList:(NSArray *)srcTypeList succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 取消所有请求的视频画面。

 @remark requestViewList和cancelAllView不能并发执行，即同一时刻只能进行一种操作。
 @param succ 取消成功回调
 @param fail 取消失败回调
 */
- (void)cancelAllView:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
  打开/关闭 相机

 @param cameraPos 相机位置 cameraPos
 @param bEnable   YES:打开 NO:关闭
 @param succ      成功回调
 @param fail      失败回调
 */
- (void)enableCamera:(cameraPos)cameraPos enable:(BOOL)bEnable succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 切换相机方向

 @param succ      成功回调
 @param fail      失败回调
 */
- (void)switchCamera:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 打开/关闭 麦克风

 @param bEnable YES:打开 NO:关闭
 */

/**
 打开/关闭 麦克风

 @param bEnable YES:打开 NO:关闭
 @param succ      成功回调
 @param fail      失败回调
 */
- (void)enableMic:(BOOL)bEnable succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 打开/关闭 扬声器

 @param bEnable YES:打开 NO:关闭
 @param succ      成功回调
 @param fail      失败回调
 */
- (void)enableSpeaker:(BOOL)bEnable succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 设置声音模式(听筒或扬声器)
 
 @param mode      声音模式
 */
- (void)setAudioMode:(QAVOutputMode)mode;

/**
 设置远程画面代理

 @param delegate 远程画面代理（主要用于预处理）
 */
- (void)setRemoteVideoDelegate:(id<QAVRemoteVideoDelegate>)delegate;

/**
 设置本地画面代理

 @param delegate 本地画面代理
 */
- (void)setLocalVideoDelegate:(id<QAVLocalVideoDelegate>)delegate;

/**
 设置屏幕画面代理

 @param delegate 屏幕画面代理
 */
- (void)setScreenVideoDelegate:(id<ILiveScreenVideoDelegate>)delegate;

/**
 设置播片画面回调，预留接口，暂时不建议使用

 @param delegate 播片代理
 */
- (void)setMediaVideoDelegate:(id<ILiveMediaVideoDelegate>)delegate;

/**
 获取当前摄像头方位,返回－1表示摄像头没打开

 @return 摄像头方位
 */
- (cameraPos)getCurCameraPos;

/**
 获取当前摄像头状态

 @return YES:打开 NO：关闭
 */
- (BOOL)getCurCameraState;

/**
 获取当前麦克风状态
 
 @return YES:打开 NO：关闭
 */
- (BOOL)getCurMicState;

/**
 获取当前扬声器状态
 
 @return YES:打开 NO：关闭
 */
- (BOOL)getCurSpeakerState;

/**
 获取当前声音模式
 */
- (QAVOutputMode)getCurAudioMode;

/**
 获取房间id

 @return 房间id。这个房间id是 创建/加入 直播时传进去的id。
 */
- (int)getRoomId;

/**
 获取IM群组ID
 
 @return IM群组ID
 */
- (NSString *)getIMGroupId;

/**
 获取直播质量参数

 @return ILiveQualityData 质量参数对象,获取失败返回nil
 */
- (ILiveQualityData *)getQualityData;

/**
 更改角色
 @discussion    此前，角色被设定为在进入房间之前指定、进入房间之后不能动态修改。这个接口的作用
             就是修改这一设定，即：在进入房间之后也能动态修改角色。业务测可以通过此接口让用
             户在房间内动态调整音视频、网络参数，如将视频模式从清晰切换成流畅。
 @param role 角色字符串 （由用户App的控制台生成）
 @param succ 成功回调
 @param fail 失败
 */
- (void)changeRole:(NSString *)role succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 绑定IM群组ID
 某些场景，业务需要单独使用IM群组，可以从房间外部绑定群组ID到房间中，IM群组由业务侧自行管理（比如创建群组，退出群组等）。如果用户希望IM群组在直播房间结束时即销毁，则不需要使用此接口
 
 @param groupId IM群组ID

 @return 0 表示绑定成功
 */
- (int)bindIMGroupId:(NSString *)groupId;

/**
 发送C2C消息

 @param dstUser 接收方ID
 @param message IM消息
 @param succ    发送成功回调
 @param fail    发送失败回调
 */
- (void)sendC2CMessage:(NSString *)dstUser message:(TIMMessage *)message succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 发送在线C2C消息

 @param dstUser 接收方ID
 @param message IM消息
 @param succ 发送成功回调
 @param fail 发送失败回调
 */
- (void)sendOnlineC2CMessage:(NSString *)dstUser message:(TIMMessage *)message succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 发送Group消息
 此处发送group，仅限于在当前直播间中发送group消息,或者绑定过IM群组id
 
 @param message IM消息
 @param succ    发送成功回调
 @param fail    发送失败回调
 */
- (void)sendGroupMessage:(TIMMessage *)message succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 发送Group消息

 @param message IM消息
 @param succ 发送成功回调
 @param fail 发送失败回调
 */
- (void)sendOnlineGroupMessage:(TIMMessage *)message succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 开始推流

 @param option 推流配置选项
 @param succ   推流成功回调(返回 AVStreamerResp 对象)
 @param fail   推流失败回调
 */
- (void)startPushStream:(ILivePushOption *)option succ:(TCIBlock)succ failed:(TCIErrorBlock)fail;

/**
 停止推流
 
 @param channelIds 要停止推流的频道ID数组
 @param succ       停止推流成功回调
 @param fail       停止推流失败回调
 */
- (void)stopPushStreams:(NSArray *)channelIds succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 开始录制

 @param option 录制配置选项
 @param succ   录制成功回调
 @param fail   录制失败回调
 */
- (void)startRecordVideo:(ILiveRecordOption *)option succ:(TCIVoidBlock)succ failed:(TCIErrorBlock)fail;

/**
 停止录制

 @param succ 停止录制成功回调，返回录制视频文件的ID数组(NSString类型)，业务侧开起自动录制时，将返回nil，用户可直接到后台查询。fileID主要目的在于兼容旧版本。
 @param fail 停止录制失败回调
 */
- (void)stopRecordVideo:(TCIBlock)succ failed:(TCIErrorBlock)fail;

/**
 视频帧分发器
 */
- (ILiveFrameDispatcher *)getFrameDispatcher;

@end
