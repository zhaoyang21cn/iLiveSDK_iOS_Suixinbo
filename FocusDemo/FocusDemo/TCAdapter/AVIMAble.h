//
//  AVIMAble.h
//  TCShow
//
//  Created by AlexiChen on 16/4/11.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 修改日志
 *================================================================
 * 时间: 20160526
 * 改动项: 添加推流录制
 * 描述: 详见AVCtrlState EAVCtrlState_PushStream 以及描述
 *================================================================
 *
 */
//



// 前缀解释:
// IM: IMSDK相关
// AV: AVSDK相关
// TC: Tencent Clound

typedef void (^TCAVCompletion)(BOOL succ, NSString *tip);


// ===========================================
// 直播中经常用到的IMSDK返回的User信息
// IMSDK，返回的抽像登录用户
// 实现协议的类记得重写NSObject - (BOOL)isEqual:(id)object;方法，判断的时候使用imUserId进行判断
@protocol IMUserAble <NSObject>


@required

// 两个用户是否相同，可通过比较imUserId来判断
// 用户IMSDK的identigier
- (NSString *)imUserId;

// 用户昵称
- (NSString *)imUserName;

// 用户头像地址
- (NSString *)imUserIconUrl;

@end

// ===========================================

typedef NS_ENUM(NSInteger, AVCtrlState)
{
    // 常用事件
    EAVCtrlState_Speaker = 0x01,                // 是否开启了扬声器
    EAVCtrlState_Mic = 0x01 << 1,               // 是否开启了麦克风
    EAVCtrlState_Camera = 0x01 << 2,            // 是否打开了相机
    EAVCtrlState_Beauty = 0x01 << 3,            // 是否打开了美颜：注意打开相机之后才可以设置美颜
    
    // 是否打开推流，因推流非常占用云后台资源，需要向后台申请资源，如果推流中出现问题，请到( https://www.qcloud.com/doc/product/268/旁路直播开发 )了解详细内容
    // 不建议进入时默认打开，会影响进房速度
    // 只有主播可以设置
    // 如果有推流，退出直播时，一定要将推流先关掉，再执行退房流程
    // 目前建议使用HLS,RTMP
    // 以下四个是互斥的一次只能传一个
    // 导致推流不成功的原因：推流的时候异常退出，业务后台去要强行关闭推流，如果不，则下次再使用相同的channelInfo.channelName进行推流，则会不成功，提示正在推流
    EAVCtrlState_HLSStream = 0x01 << 4,         // HLS
    EAVCtrlState_RTMPStream = 0x01 << 5,        // RTMP
    EAVCtrlState_RAWStream = 0x01 << 6,         // RAW
    EAVCtrlState_HLS_RTMP = EAVCtrlState_HLSStream | EAVCtrlState_RTMPStream,

    
    // 添加录制
    // https://www.qcloud.com/doc/product/268/%E5%BD%95%E5%88%B6%E5%8A%9F%E8%83%BD%E5%BC%80%E5%8F%91
    EAVCtrlState_Record = 0x01 << 7,            // 录制功能
    
    // AVSDK在 1.8.1.300才支持美白功能
    EAVCtrlState_White = 0x01 << 8,             // 是否开启美白
    
    EAVCtrlState_HDAudio = 0x01 << 9,             // 是否使用高品质音频
    EAVCtrlState_AutoRotateVideo = 0x01 << 10,    // 是否自动矫正视频
    
    
    // 主播进入房间时的推荐配置
    
    EAVCtrlState_All = EAVCtrlState_Mic | EAVCtrlState_Speaker | EAVCtrlState_Camera,
};

// 直播中用户的配置
// 直播中要用到的
// 简单的个人
@protocol AVUserAble <IMUserAble>

@required
@property (nonatomic, assign) NSInteger avCtrlState;

@end


// 多人互动时用户的状态
// 暂未使用到
typedef NS_ENUM(NSInteger, AVMultiUserState)
{
    AVMultiUser_Guest = 0X01,                         // 普通观众
    
    AVMultiUser_Interact_Inviting = 0X01 << 1,        // 邀请状态
    AVMultiUser_Interact_Connecting = 0X01 << 2,      // 连接状态，请求画面
    AVMultiUser_Interact = 0X01 << 3,                 // 互动成功
    AVMultiUser_Interact_Losting = 0X01 << 4,         // 互动过程中，用户黑屏，无画面
    // 用户自定状态
    AVMultiUser_Host = 0XFF,                          // 主播，最高优先级
};

@protocol AVMultiUserAble <AVUserAble>

@required

@property (nonatomic, assign) NSInteger avMultiUserState;       // 多人互动时IM配置

// 互动时，用户画面显示的屏幕上的区域（opengl相关的位置）
@property (nonatomic, assign) CGRect avInteractArea;

// 互动时，因opengl放在最底层，之上是的自定义交互层，通常会完全盖住opengl
// 用户要想与小画面进行交互的时候，必须在交互层上放一层透明的大小相同的控件，能过操作此控件来操作小窗口画面
// 全屏交互的用户该值为空
// 业务中若不存在交互逻辑，则不用填
@property (nonatomic, weak) UIView *avInvisibleInteractView;

@end


// 当前登录IMSDK的用户信息
@protocol IMHostAble <IMUserAble>

@required

// 当前App对应的AppID
- (NSString *)imSDKAppId;

// 当前App的AccountType
- (NSString *)imSDKAccountType;

@end


@protocol AVRoomAble <NSObject>

@required

// 聊天室Id
@property (nonatomic, copy) NSString *liveIMChatRoomId;

// 当前主播信息
- (id<IMUserAble>)liveHost;

// 直播房间Id
- (int)liveAVRoomId;

// 直播标题，可用于创建直播IM聊天室（具体还需要看使用哪种方式创建）
// 另外推流以及录制时，使用默认配置时，是需要liveTitle参数
- (NSString *)liveTitle;

@end



// =======================================================

typedef NS_ENUM(NSInteger, AVIMCommand) {
    
    AVIMCMD_Text = -1,          // 普通的聊天消息
    
    AVIMCMD_None,               // 无事件：0
    
    // 以下事件为TCAdapter内部处理的通用事件
    AVIMCMD_EnterLive,          // 用户加入直播, Group消息 ： 1
    AVIMCMD_ExitLive,           // 用户退出直播, Group消息 ： 2
    AVIMCMD_Praise,             // 点赞消息, Demo中使用Group消息 ： 3
    AVIMCMD_Host_Leave,         // 主播或互动观众离开, Group消息 ： 4
    AVIMCMD_Host_Back,          // 主播或互动观众回来, Group消息 ： 5
    // 中间预留扩展
    
    
    // 添加电话场景的命令字
    AVIMCMD_Call = 0x080,       // 电话场景起始关键字
    AVIMCMD_Call_Dialing,       // 正在呼叫
    AVIMCMD_Call_Connected,     // 连接进行通话
    AVIMCMD_Call_LineBusy,      // 电话占线
    AVIMCMD_Call_Disconnected,  // 挂断
    AVIMCMD_Call_Invite,        // 通话过程中，邀请第三方进入到房间
    AVIMCMD_Call_NoAnswer,      // 无人接听
    
    // 电话内行为
    AVIMCMD_Call_EnableMic,     // 打开mic
    AVIMCMD_Call_DisableMic,    // 关闭Mic
    AVIMCMD_Call_EnableCamera,  // 打开Camera
    AVIMCMD_Call_DisableCamera, // 关闭互动者Camera
    // 中间预留其他与电话相关的命令
    AVIMCMD_Call_AllCount = 0x0B0,  // 0x080---0x0B0 这间的为电话命令
    
    AVIMCMD_Custom = 0x100,     // 用户自定义消息类型开始值
    
    /*
     * 用户在中间根据业务需要，添加自身需要的自定义字段
     *
     * AVIMCMD_Custom_Focus,        // 关注
     * AVIMCMD_Custom_UnFocus,      // 取消关注
     */
    
    
    AVIMCMD_Multi = 0x800,              // 多人互动消息类型 ： 2048
    
    AVIMCMD_Multi_Host_Invite,          // 多人主播发送邀请消息, C2C消息 ： 2049
    AVIMCMD_Multi_CancelInteract,       // 已进入互动时，断开互动，Group消息，带断开者的imUsreid参数 ： 2050
    AVIMCMD_Multi_Interact_Join,        // 多人互动方收到AVIMCMD_Multi_Host_Invite多人邀请后，同意，C2C消息 ： 2051
    AVIMCMD_Multi_Interact_Refuse,      // 多人互动方收到AVIMCMD_Multi_Invite多人邀请后，拒绝，C2C消息 ： 2052
    
    // =======================
    // 暂未处理以下
    AVIMCMD_Multi_Host_EnableInteractMic,  // 主播打开互动者Mic，C2C消息 ： 2053
    AVIMCMD_Multi_Host_DisableInteractMic, // 主播关闭互动者Mic，C2C消息 ：2054
    AVIMCMD_Multi_Host_EnableInteractCamera, // 主播打开互动者Camera，C2C消息 ：2055
    AVIMCMD_Multi_Host_DisableInteractCamera, // 主播关闭互动者Camera，C2C消息 ： 2056
    // ==========================
    
    
    AVIMCMD_Multi_Host_CancelInvite,            // 取消互动, 主播向发送AVIMCMD_Multi_Host_Invite的人，再发送取消邀请， 已发送邀请消息, C2C消息 ： 2057
    AVIMCMD_Multi_Host_ControlCamera,           // 主动控制互动观众摄像头, 主播向互动观众发送,互动观众接收时, 根据本地摄像头状态，来控制摄像头开关（即控制对方视频是否上行视频）， C2C消息 ： 2058
    AVIMCMD_Multi_Host_ControlMic,              // 主动控制互动观众Mic, 主播向互动观众发送,互动观众接收时, 根据本地MIC状态,来控制摄像头开关（即控制对方视频是否上行音频），C2C消息 ： 2059
    
    
    
    // 中间预留以备多人互动扩展
    
    AVIMCMD_Multi_Custom = 0x1000,          // 用户自定义的多人消息类型起始值 ： 4096
    
    /*
     * 用户在中间根据业务需要，添加自身需要的自定义字段
     *
     * AVIMCMD_Multi_Custom_XXX,
     * AVIMCMD_Multi_Custom_XXXX,
     */
    
};


// 直播中用到的IM消息类型
// 直播过程中只能显示简单的文本消息
// 关于消息的显示尽量做简单，以减少直播过程中IM消息量过大时直播视频不流畅
@protocol AVIMMsgAble <NSObject>

@required
// 在渲染前，先计算渲染的内容
- (void)prepareForRender;

- (NSInteger)msgType;

@end





