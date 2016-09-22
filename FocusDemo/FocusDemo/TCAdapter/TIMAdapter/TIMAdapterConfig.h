//
//  TIMAdapterConfig.h
//  TCShow
//
//  Created by AlexiChen on 16/6/2.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#ifndef TIMAdapterConfig_h
#define TIMAdapterConfig_h


// 用户更新为自己的app配置
// 以及IMSDK相关的配置
#ifndef kSdkAppId
#define kSdkAppId       @"1400001692"
#endif

#ifndef kSdkAccountType
#define kSdkAccountType @"884"
#endif

#ifndef kQQAccountType
#define kQQAccountType  1
#endif

#ifndef kWXAccountType
#define kWXAccountType  2
#endif

/**
 * QQ和微信sdk参数配置
 */
#ifndef QQ_APP_ID
#define QQ_APP_ID @"222222"
#endif

#ifndef QQ_OPEN_SCHEMA
#define QQ_OPEN_SCHEMA @"tencent222222"
#endif

#ifndef WX_APP_ID
#define WX_APP_ID @"wx65f71c2ea2b122da"
#endif

#ifndef WX_OPEN_KEY
#define WX_OPEN_KEY @"69aed8b3fd41ed72efcfbdbca1e99a27"
#endif

// 因随心播中有自定义字段，导致集成时，更新SDK AppID后无法正常登录
// 添加宏控制该逻辑
#ifndef kIsTCShowSupportIMCustom
#define kIsTCShowSupportIMCustom 0
#endif

// IMAAppDelegate是否从BaseAppDelegate中继承
// 用处：对于已有App，其可以通过将kIsIMAAppFromBase改为0，减少AppDelegate的配置工作
// kIsIMAAppFromBase为1时，从BaseAppDelegate中继承，为0时IMAAppDelegate作为基类
// 为与之前的代码逻辑统一，默认为1
#ifndef kIsIMAAppFromBase
#define kIsIMAAppFromBase 1
#endif


// 演求个人资料里面的如何增加扩展字段
#if kIsTCShowSupportIMCustom
#define kIMCustomFlag @"Tag_Profile_Custom_1400001692_Param"
#endif

#define IMALocalizedError(intCode, enStr) NSLocalizedString(([NSString stringWithFormat:@"%d", (int)intCode]), enStr)

//==============================
// 后期此处会有修改，不使用字典方式传送
#if kSupportCallScene
// 语音视频通话中用到的关键字
// int 类型
#define kTCAVCall_AVRoomID          @"AVRoomID"

// NSString, 群号可为空
#define kTCAVCall_IMGroupID         @"IMGroupID"

// 群类型
#define kTCAVCall_IMGroupType       @"IMGroupType"

// NSString, 呼叫提示
#define kTCAVCall_CallTip           @"CallTip"

// BOOL，YES:语音，NO，视频
#define kTCAVCall_CallType           @"CallType"

// Double, 呼叫时间
#define kTCAVCall_CallDate          @"CallDate"
#endif

//==============================
// IMA内部使用的字休
//#define kIMALargeTextFont       [UIFont systemFontOfSize:16]
//#define kIMAMiddleTextFont      [UIFont systemFontOfSize:14]
//#define kIMASmallTextFont       [UIFont systemFontOfSize:12]


#endif /* TIMAdapterConfig_h */
