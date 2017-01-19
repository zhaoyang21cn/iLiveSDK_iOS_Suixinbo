//
//  ConstHeader.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#ifndef ConstHeader_h
#define ConstHeader_h

//#define ShowAppId       @"1400001692"
//#define ShowAccountType @"884"

//#define ShowAppId       @"1400019301"
//#define ShowAccountType @"8871"

#define ShowAppId       @"1400019352"
#define ShowAccountType @"8970"

/******************** color ******************************/
// 取色值相关的方法
#define RGB(r,g,b)          [UIColor colorWithRed:(r)/255.f \
green:(g)/255.f \
blue:(b)/255.f \
alpha:1.f]

#define RGBA(r,g,b,a)       [UIColor colorWithRed:(r)/255.f \
green:(g)/255.f \
blue:(b)/255.f \
alpha:(a)]

#define RGBOF(rgbValue)     [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define RGBA_OF(rgbValue)   [UIColor colorWithRed:((float)(((rgbValue) & 0xFF000000) >> 24))/255.0 \
green:((float)(((rgbValue) & 0x00FF0000) >> 16))/255.0 \
blue:((float)(rgbValue & 0x0000FF00) >> 8)/255.0 \
alpha:((float)(rgbValue & 0x000000FF))/255.0]

#define RGBAOF(v, a)        [UIColor colorWithRed:((float)(((v) & 0xFF0000) >> 16))/255.0 \
green:((float)(((v) & 0x00FF00) >> 8))/255.0 \
blue:((float)(v & 0x0000FF))/255.0 \
alpha:a]

#define kColorWhite      [UIColor whiteColor]
#define kColorGray       RGBOF(0xF0E0F0)
#define kColorBlue       RGBOF(0x718CED)
#define kColorRed        RGBOF(0xF4515E)
#define kColorLightGray  RGBOF(0xF3F3F3)
#define kColorGreen      [UIColor greenColor]

#define kColorPurple     [UIColor purpleColor]

#define kColorBlack      [UIColor blackColor]

/******************** font ********************************/
#define kAppLargeTextFont       [UIFont systemFontOfSize:17]
#define kAppMiddleTextFont      [UIFont systemFontOfSize:15]
#define kAppSmallTextFont       [UIFont systemFontOfSize:13]

/******************** icon ********************************/
#define kDefaultUserIcon            [UIImage imageNamed:@"default_head@2x.jpg"]
#define kDefaultCoverIcon           [UIImage imageNamed:@"default_cover@2x.jpg"]

/******************** default *****************************/
static const int kDefaultCellHeight = 44;

static const int kDefaultMargin = 8;

/******************** block *******************************/
typedef void (^ActionHandle)(UIAlertAction * _Nonnull action);
typedef void (^EditAlertHandle)(NSString * _Nonnull editString);

/******************** custom msg cmd **********************/
typedef NS_ENUM(NSInteger, ShowCustomCmd)
{
    AVIMCMD_Text = -1,          // 普通的聊天消息
    
    AVIMCMD_None,               // 无事件：0
    
    // 以下事件为TCAdapter内部处理的通用事件
    AVIMCMD_EnterLive,          // 用户加入直播, Group消息 ： 1
    AVIMCMD_ExitLive,           // 用户退出直播, Group消息 ： 2
    AVIMCMD_Praise,             // 点赞消息, Demo中使用Group消息 ： 3
    AVIMCMD_Host_Leave,         // 主播或互动观众离开, Group消息 ： 4
    AVIMCMD_Host_Back,          // 主播或互动观众回来, Group消息 ： 5
    
//    ShowCustomCmd_Begin = ILVLIVE_IMCMD_CUSTOM_LOW_LIMIT,
//    ShowCustomCmd_Praise,
//    ShowCustomCmd_JoinRoom,
//    ShowCustomCmd_DownVideo,//主播发送下麦通知
    
    AVIMCMD_Multi = ILVLIVE_IMCMD_CUSTOM_LOW_LIMIT,              // 多人互动消息类型 ： 2048
    
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
};

/******************** notification **********************/
#define kUserParise_Notification        @"kUserParise_Notification"
//#define kUserJoinRoom_Notification      @"kUserJoinRoom_Notification"
//#define kUserExitRoom_Notification      @"kUserExitRoom_Notification"
#define kUserMemChange_Notification      @"kUserMemChange_Notification"
#define kUserUpVideo_Notification       @"kUserUpVideo_Notification"
#define kUserDownVideo_Notification     @"kUserDownVideo_Notification"
#define kUserSwitchRoom_Notification    @"kUserSwitchRoom_Notification"
#define kGroupDelete_Notification       @"kGroupDelete_Notification"
#define kPureDelete_Notification        @"kPureDelete_Notification"
#define kNoPureDelete_Notification      @"kNoPureDelete_Notification"
#define kClickConnect_Notification      @"kClickConnect_Notification"
#define kCancelConnect_Notification     @"kCancelConnect_Notification"

/******************** role string **********************/
#define kSxbRole_Host       @"LiveMaster"
#define kSxbRole_Guest      @"Guest"
#define kSxbRole_Interact   @"LiveGuest"

/******************** local param **********************/
#define kLoginParam         @"kLoginParam"
#define kLoginIdentifier    @"kLoginIdentifier"
#define kLoginPassward      @"kLoginPassward"
#define kEnvParam           @"kEnvParam"




#endif /* ConstHeader_h */
