//
//  TCILiveConst.h
//  ILiveSDK
//
//  Created by AlexiChen on 16/9/9.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

//=========================================================

typedef void (^TCIVoidBlock)();

typedef void (^TCIBlock)(id selfPtr);

typedef void (^TCICompletionBlock)(id selfPtr, BOOL isFinished);

typedef void (^TCIFinishBlock)(BOOL isFinished);

typedef void (^TCIRoomBlock)(BOOL succ, NSError *err);

//=========================================================
// 日志

#ifdef DEBUG

#ifndef TCILDebugLog
#define TCILDebugLog(fmt, ...) NSLog((@"[%s Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif

#else

#ifndef TCILDebugLog
#define TCILDebugLog(fmt, ...) // NSLog((@"[%s Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif

#define NSLog // NSLog


#endif

// =======================================================
// ILiveSDK里面所用的命令字
typedef NS_ENUM(NSInteger, AVIMCommand) {
    
    AVIMCMD_Text = -1,          // 普通的聊天消息
    
    AVIMCMD_None,               // 无事件：0
    
    // 以下事件为TCILiveSDK内部处理的通用事件
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
