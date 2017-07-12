//
//  ILiveCommon.h
//  ILiveSDK
//
//  Created by AlexiChen on 2016/10/24.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK/TIMManager.h>

#import "ILiveSDK.h"

//模块名 主要用于错误码区分
#define MODULE_ILIVESDK @"ILiveSDK"
#define MODULE_AVSDK    @"AVSDK"
#define MODULE_IMSDK    @"IMSDK"
#define MODULE_TLSSDK   @"TLSSDK"

typedef NS_ENUM(NSInteger, ILiveError){
    INVALID_INTETER_VALUE   = -1,      //无效的整型返回值(通用)
    NO_ERR                  = 0,       //成功
    ERR_IM_NOT_READY        = 8001,    //IM模块未就绪或未加载
    ERR_AV_NOT_READY        = 8002,    //AV模块未就绪或未加载
    ERR_NO_ROOM             = 8003,    //无有效的房间
    ERR_ALREADY_EXIST       = 8004,    //目标已存在
    ERR_NULL_POINTER        = 8005,    //空指针错误
    ERR_ENTER_AV_ROOM_FAIL  = 8006,    //进入AV房间失败
    ERR_USER_CANCEL         = 8007,    //用户取消
    ERR_WRONG_STATE         = 8008,    //状态异常(以废弃)
    ERR_NOT_LOGIN           = 8009,    //未登录
    ERR_ALREADY_IN_ROOM     = 8010,    //已在房间中
    ERR_BUSY_HERE           = 8011,    //内部忙(上一请求未完成)
    ERR_NET_UnDefine        = 8012,    //网络未识别或网络不可用
    ERR_SDK_FAILED          = 8020,    //ILiveSDK处理失败(通用)
    ERR_INVALID_PARAM       = 8021,    //无效的参数
    ERR_NOT_FOUND           = 8022,    //无法找到目标
    ERR_NOT_SUPPORT         = 8023,    //请求不支持
    ERR_ALREADY_STATE       = 8024,    //状态已到位(一般为重复调用引起)
    ERR_KICK_OUT            = 8050,    //被踢下线
    ERR_EXPIRE              = 8051,    //票据过期(需更新票据userSig)
    ERR_PARSE_FAIL          = 8052,    //解析网络请求失败
    ERR_ALLOC_FAIL          = 8053,    //内存分配失败，检查内存是否充足
};

typedef NS_ENUM(NSInteger, ILiveEvent){
    EVENT_ILIVE_LOGIN           = 10001,     //登录事件
    EVENT_ILIVE_INIT            = 10002,     //初始化事件
    EVENT_ILIVE_CREATEROOM      = 10003,     //创建房间事件
    EVENT_ILIVE_JOINROOM        = 10004,     //加入房间事件
    EVENT_SEND_GROUP_TEXT_MSG   = 10005,     //发送群文本消息事件
    EVENT_SEND_GROUP_CUSTOM_MSG = 10006,     //发送群自定义消息事件
    EVENT_SEND_C2C_CUSTOM_MSG   = 10007,     //发送C2C自定义消息事件
    EVENT_MAKE_CALL             = 10008,     //发起呼叫事件(视频通话)
    EVENT_ACCEPT_CALL           = 10009,     //接听来电事件(视频通话)
    EVENT_REJECT_CALL           = 10010,     // 拒接来电事件(视频通话)
};

typedef NS_ENUM(NSInteger, ILiveRotationType)
{
    ILiveRotation_Auto = 0,     //自动校正
    ILiveRotation_FullScreen,   //始终全屏显示
    ILiveRotation_Crop,         //剪裁校正
};

typedef void (^TCIVoidBlock)();

typedef void (^TCIErrorBlock)(NSString *module, int errId, NSString *errMsg);

typedef void (^TCIBlock)(id selfPtr);

//=========================================================
#define TCILDebugLog(fmt, ...) [[ILiveSDK getInstance] iLivelog:ILive_LOG_INFO tag:@"ILiveSDK" msg:[NSString stringWithFormat:(fmt), ##__VA_ARGS__]]



