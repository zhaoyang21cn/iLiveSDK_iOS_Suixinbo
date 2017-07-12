//
//  TILLiveCommon.h
//  ILiveSDK
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QAVSDK/QAVCommon.h>

@class TIMMessage;
@class TIMUserProfile;

/**
 * ILVLiveCustomMessage中data字段json key
 * 示例:
 * {
 *      "userAction":ILVLIVE_IMCMD_ENTER,
 *      "actionParam":@"自定义数据格式"
 * }
 */
#define kMsgCmdKey @"userAction"
#define kMsgDataKey @"actionParam"


typedef NS_ENUM(NSInteger, ILVLiveIMType){
    /**
     * C2C消息
     */
    ILVLIVE_IMTYPE_C2C         = 1,
    /**
     * Group消息
     */
    ILVLIVE_IMTYPE_GROUP,
};

typedef NS_ENUM(NSInteger, ILVLiveIMPriority) {
    /**
     *  高优先级，一般为红包或者礼物消息
     */
    ILVLIVE_IMPRIORITY_HIGH               = 1,
    /**
     *  普通优先级，普通消息
     */
    ILVLIVE_IMPRIORITY_NORMAL             = 2,
    /**
     *  低优先级，一般为点赞消息
     */
    ILVLIVE_IMPRIORITY_LOW                = 3,
    /**
     *  最低优先级，一般为后台下发的成员进退群通知
     */
    ILVLIVE_IMPRIORITY_LOWEST             = 4,
};

typedef NS_ENUM(NSInteger, ILVLiveIMCmd){
    /**
     * 无效消息
     */
    ILVLIVE_IMCMD_NONE                = 0x700,
    /**
     * 用户加入直播, Group消息
     */
    ILVLIVE_IMCMD_ENTER,
    /**
     * 用户退出直播, Group消息
     */
    ILVLIVE_IMCMD_LEAVE,
    /**
     * 邀请上麦，C2C消息
     */
    ILVLIVE_IMCMD_INVITE,
    /**
     * 取消邀请上麦，C2C消息
     */
    ILVLIVE_IMCMD_INVITE_CANCEL,
    /**
     * 关闭上麦，C2C消息
     */
    ILVLIVE_IMCMD_INVITE_CLOSE,
    /**
     * 同意上麦，C2C消息
     */
    ILVLIVE_IMCMD_INTERACT_AGREE,
    /**
     * 拒绝上麦，C2C消息
     */
    ILVLIVE_IMCMD_INTERACT_REJECT,
    /**
     * 请求跨房连麦，C2C消息
     */
    ILVLIVE_IMCMD_LINKROOM_REQ,
    /**
     * 同意跨房连麦，C2C消息
     */
    ILVLIVE_IMCMD_LINKROOM_ACCEPT,
    /**
     * 拒绝跨房连麦，C2C消息
     */
    ILVLIVE_IMCMD_LINKROOM_REFUSE,
    /**
     * 跨房连麦者达到上限，C2C消息
     */
    ILVLIVE_IMCMD_LINKROOM_LIMIT,
    /**
     * 真正连接成功
     */
    ILVLIVE_IMCMD_LINKROOM_SUCC,
    /**
     * 取消跨房连麦
     */
    ILVLIVE_IMCMD_UNLINKROOM,
    /**
     * 自定义消息段下限
     */
    ILVLIVE_IMCMD_CUSTOM_LOW_LIMIT     = 0x800,
    /**
     * 自定义消息段上限
     */
    ILVLIVE_IMCMD_CUSTOM_UP_LIMIT      = 0x900,
};


typedef NS_ENUM(NSInteger, ILVLiveAVEvent){
    /**
     * 无事件
     */
    ILVLIVE_AVEVENT_NONE          = 0x200,
    /**
     * 有成员进房
     */
    ILVLIVE_AVEVENT_MEMBER_ENTER,
    /**
     * 有成员进房
     */
    ILVLIVE_AVEVENT_MEMBER_EXIT,
    /**
     * 有成员开摄像头
     */
    ILVLIVE_AVEVENT_CAMERA_ON,
    /**
     * 有成员关摄像头
     */
    ILVLIVE_AVEVENT_CAMERA_OFF,
    /**
     * 有成员打开屏幕分享
     */
    ILVLIVE_AVEVENT_SCREEN_ON,
    /**
     * 有成员关闭屏幕分享
     */
    ILVLIVE_AVEVENT_SCREEN_OFF,
    /**
     * 有成员开启声音
     */
    ILVLIVE_AVEVENT_AUDIO_ON,
    /**
     * 有成员关闭声音
     */
    ILVLIVE_AVEVENT_AUDIO_OFF,
    /**
     * 有成员播放视频文件
     */
    ILVLIVE_AVEVENT_MEDIA_ON,
    /**
     * 有成员关闭视频文件
     */
    ILVLIVE_AVEVENT_MEDIA_OFF,
};

/**
 * 消息
 */
@interface ILVLiveMessage : NSObject
@end

/**
 * 文本消息
 */
@interface ILVLiveTextMessage : ILVLiveMessage
/**
 * 消息类型
 */
@property (nonatomic, assign) ILVLiveIMType type;
/**
 * 消息优先级（默认普通消息）
 */
@property (nonatomic, assign) ILVLiveIMPriority priority;
/**
 * 发送者（内部赋值）
 */
@property (nonatomic, strong) NSString *sendId;
/**
 * 接收者（发送群消息无接受者）
 */
@property (nonatomic, strong) NSString *recvId;
/**
 * 消息文本
 */
@property (nonatomic, strong) NSString *text;
/**
 *  获取发送者资料（发送者为自己时可能为空）
 *
 *  @return 发送者资料，nil 表示没有获取资料，目前只有字段：identifier、nickname、faceURL、customInfo
 */
@property (nonatomic, strong) TIMUserProfile *senderProfile;
@end

/**
 * 自定义消息
 */
@interface ILVLiveCustomMessage : ILVLiveMessage
/**
 * 消息类型
 */
@property (nonatomic, assign) ILVLiveIMType type;
/**
 * 消息优先级（默认普通消息）
 */
@property (nonatomic, assign) ILVLiveIMPriority priority;
/**
 * 消息命令
 */
@property (nonatomic, assign) ILVLiveIMCmd cmd;
/**
 * 发送者（内部赋值）
 */
@property (nonatomic, strong) NSString *sendId;
/**
 * 接收者（发送群消息无接受者）
 */
@property (nonatomic, strong) NSString *recvId;
/**
 * 自定义消息
 */
@property (nonatomic, strong) NSData *data;
/**
 *  获取发送者资料（发送者为自己时可能为空）
 *
 *  @return 发送者资料，nil 表示没有获取资料，目前只有字段：identifier、nickname、faceURL、customInfo
 */
@property (nonatomic, strong) TIMUserProfile *senderProfile;
@end


@protocol ILVLiveIMListener <NSObject>
@optional
/**
 * 文本消息回调
 * @param  msg  文本消息类
 */
- (void)onTextMessage:(ILVLiveTextMessage *)msg;
/**
 * 自定义消息回调
 * @param  msg 自定义消息类
 */
- (void)onCustomMessage:(ILVLiveCustomMessage *)msg;
/**
 * 其他消息回调
 * @param  msg TIMMessage
 */
- (void)onOtherMessage:(TIMMessage *)msg;
@end

@protocol ILVLiveAVListener <NSObject>
@optional
/**
 * 音视频事件回调
 * @param  event   事件
 * @param  users   用户endpoints ,QAVEndpoint
 */
- (void)onUserUpdateInfo:(ILVLiveAVEvent)event users:(NSArray *)users;

/**
 * 首帧到达回调
 * @param width       宽度
 * @param height      高度
 * @param identifier  id
 * @param srcType     视频源类型
 */
- (void)onFirstFrameRecved:(int)width height:(int)height identifier:(NSString *)identifier srcType:(avVideoSrcType)srcType;

/**
 * SDK主动退出房间提示。该回调方法表示SDK内部主动退出了房间。SDK内部会因为30s心跳包超时等原因主动退出房间，APP需要监听此退出房间事件并对该事件进行相应处理
 * @param reason 退出房间的原因，具体值见返回码
 */
- (void)onRoomDisconnect:(int)reason;
@end

typedef void (^TCIVoidBlock)();
typedef void (^TCIErrorBlock)(NSString *module, int errId, NSString *errMsg);

