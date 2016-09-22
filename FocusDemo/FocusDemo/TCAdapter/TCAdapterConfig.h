//
//  TCAdapterConfig.h
//  TCShow
//
//  Created by AlexiChen on 16/6/2.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#ifndef TCAdapterConfig_h
#define TCAdapterConfig_h


//  内部错误码转写
#define TAVLocalizedError(intCode) NSLocalizedString(([NSString stringWithFormat:@"%d", (int)intCode]), ([NSString stringWithFormat:@"%d", (int)intCode]))

//==================================================================================
// 是否是将AVSDK在直播场景下使用
// 直播场景下，不要频繁切换context（用户使用过程中会不会频繁切换房间，即kIsUseAVSDKAsLiveScene为1, 如果使用不频繁，可以在退出的时候stopContext）
// kIsUseAVSDKAsLiveScene 为 1时，如果用户注销，或被踢下线，此时要stopContext
#ifndef kIsUseAVSDKAsLiveScene
#define kIsUseAVSDKAsLiveScene 1
#endif

//==================================================================================
#ifndef kAppStoreVersion
// 是否是AppStore版本
#define kAppStoreVersion 0
#endif

//==================================================================================
// BetaVersation配置
#if DEBUG

#ifndef kBetaVersion
#define kBetaVersion        1
#endif

#else
// 上传AppStore时改为0
// 方便测试去查看房间号等相关信息，以便测试
#if kAppStoreVersion

#ifndef kBetaVersion
#define kBetaVersion        0
#endif

#else

#ifndef kBetaVersion
#define kBetaVersion        1
#endif

#endif
#endif

//==================================================================================

// 为方便测试同事进行日志查看
#if kBetaVersion

#define TIMLog(fmt, ...) [[TIMManager sharedInstance] log:TIM_LOG_INFO tag:@"TIMLog" msg:[NSString stringWithFormat:@"[%s Line %d]" fmt, __PRETTY_FUNCTION__, __LINE__,  ##__VA_ARGS__]];

#else

#if DEBUG
#define TIMLog(fmt, ...) NSLog((@"[%s Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define TIMLog(fmt, ...) //NSLog((@"[%s Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif

#endif

//==================================================================================
// 是否支持消息缓存，而不是立即显示，主要是看大消息量时，立即显示会导致界面卡顿
// 因不清楚各App的消息种类，以及消息类型（是否支持IM等），故放到业务层去处理，各App可依照此处逻辑
// 为0时，立即显示
// 为1时，会按固定频率刷新
#ifndef kSupportIMMsgCache
#define kSupportIMMsgCache  1
#endif

//==================================================================================
// 用于真机时，测试获取日志
static NSDateFormatter *kTCAVIMLogDateFormatter = nil;

#if DEBUG

// 主要用于腾讯测试同事，获取获取进行统计进房间时间，以及第一帧画面时间，外部用户使用时可改为0
#ifndef kSupportTimeStatistics
#define kSupportTimeStatistics 1
#endif

#define TCAVIMLog(fmt, ...)  {\
                                if (!kTCAVIMLogDateFormatter) \
                                {\
                                    kTCAVIMLogDateFormatter = [[NSDateFormatter alloc] init];\
                                    [kTCAVIMLogDateFormatter setDateStyle:NSDateFormatterMediumStyle];\
                                    [kTCAVIMLogDateFormatter setTimeStyle:NSDateFormatterShortStyle];\
                                    [kTCAVIMLogDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];\
                                }\
                                NSLog((@"TCAdapter时间统计 时间点:%@ [%s Line %d] ------->>>>>>\n" fmt), [kTCAVIMLogDateFormatter stringFromDate:[NSDate date]], __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);\
                            }

#else


#if kAppStoreVersion

// AppStore版本不统计
#ifndef kSupportTimeStatistics
#define kSupportTimeStatistics 0
#endif

// 用于release时，真机下面获取App关键路径日志日志
#define TCAVIMLog(fmt, ...)  /**/
#else

// 主要用于腾讯测试同事，获取获取进行统计进房间时间，以及第一帧画面时间，外部用户使用时可改为0
#ifndef kSupportTimeStatistics
#define kSupportTimeStatistics 1
#endif

// 用于release时，真机下面获取App关键路径日志日志
#define TCAVIMLog(fmt, ...) {\
                                if (!kTCAVIMLogDateFormatter) \
                                { \
                                    kTCAVIMLogDateFormatter = [[NSDateFormatter alloc] init];\
                                    [kTCAVIMLogDateFormatter setDateStyle:NSDateFormatterMediumStyle];\
                                    [kTCAVIMLogDateFormatter setTimeStyle:NSDateFormatterShortStyle];\
                                    [kTCAVIMLogDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];\
                                }\
                                [[TIMManager sharedInstance] log:TIM_LOG_INFO tag:@"TCAdapter时间统计" msg:[NSString stringWithFormat:(@"时间点:%@ [%s Line %d] ------->>>>>>" fmt), [kTCAVIMLogDateFormatter stringFromDate:[NSDate date]], __PRETTY_FUNCTION__, __LINE__,  ##__VA_ARGS__]];\
                            }

#endif

#endif

//==================================================================================
// 因调试的时候手机距离较近容易产生啸叫(物理现象：录音机与扬声器较近时)
// 添加开关，调试状态下不打开Mic
#if DEBUG

#ifndef kAVSDKDefaultOpenMic
#define kAVSDKDefaultOpenMic 1
#endif

#else

#ifndef kAVSDKDefaultOpenMic
#define kAVSDKDefaultOpenMic 1
#endif

#endif



//==================================================================================
// 电话场景的支持
// 是否支持电话场景
#ifndef kSupportCallScene
// 默认是不用支持电话场景
#define kSupportCallScene 1
#endif


//==================================================================================
#if DEBUG
// 调试状态下
// 是否使用AVChatRoom创建直播聊天室
// 使用聊天室主要来验证性能，直正直播时，使用AVChatRoom
#ifndef kSupportAVChatRoom
#define kSupportAVChatRoom 1
#endif

#ifndef kSupportFixLiveChatRoomID
// 是否固定群ID
#define kSupportFixLiveChatRoomID 1
#endif

#if kSupportAVChatRoom
#ifndef kAVChatRoomType
#define kAVChatRoomType @"AVChatRoom"
#endif
#else
#ifndef kAVChatRoomType
#define kAVChatRoomType @"ChatRoom"
#endif
#endif

#else

#ifndef kSupportAVChatRoom
// Release下
#define kSupportAVChatRoom 1
#endif

#ifndef kSupportFixLiveChatRoomID
#define kSupportFixLiveChatRoomID 1
#endif

#ifndef kAVChatRoomType
#define kAVChatRoomType @"AVChatRoom"
#endif

#endif

//==================================================================================
// 是否支持混音
#ifndef kSupportAudioTransmission
#define kSupportAudioTransmission 0
#endif

//==================================================================================
// 是否支持测速
// 测速功能IMSDK 2.2才开放，到时再改为1
// 是否集成网络测速功能 1:是 0:否
#ifndef kIsMeasureSpeed
#define kIsMeasureSpeed 1
#endif


//==================================================================================
// TCAdapter 关键路径Log是否输入到文件还是控制台 0:关闭日志输出 1:输出到控制台 2:输出到日志文件 3:输出到控制台和文件
#ifndef kTCAVLogSwitch
#define kTCAVLogSwitch 0
#endif

#if kTCAVLogSwitch

#define TCAVLog(log) [[TCAVLogManager shareInstance] logTo:(log)]

#else
#define TCAVLog(log)
#endif

//==================================================================================


#ifndef kTCInteractSubViewSize
#define kTCInteractSubViewSize CGSizeMake(90, 120)
#endif

//typedef enum iLiveRotationType
//{
//    //自动校正
//    ILiveRotation_Auto = 0,
//    //始终全屏显示
//    ILiveRotation_FullScreen,
//    //剪裁校正
//    ILiveRotation_Crop,
//    
//}ILiveRotationType;

#ifndef kAVGLCustomRenderViewRotateMode
#define kAVGLCustomRenderViewRotateMode 1
#endif

//==================================================================================
// 是否使用TCILiveSDK内容

#ifndef kSupportILiveSDK
#define kSupportILiveSDK 1
#endif
//==================================================================================

#endif /* TCAdapterConfig_h */



