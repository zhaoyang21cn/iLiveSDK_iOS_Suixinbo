//
//  ConstHeader.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#ifndef ConstHeader_h
#define ConstHeader_h

#define ShowAppId       @"1400001692"
#define ShowAccountType @"884"


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

/******************** custom msg cmd **********************/
typedef NS_ENUM(NSInteger, ShowCustomCmd)
{
    ShowCustomCmd_Begin = ILVLIVE_IMCMD_CUSTOM_LOW_LIMIT,
    ShowCustomCmd_Praise,
    ShowCustomCmd_JoinRoom,
    ShowCustomCmd_DownVideo,//主播发送下麦通知
};

/******************** notification **********************/
#define kUserParise_Notification        @"kUserParise_Notification"
#define kUserJoinRoom_Notification      @"kUserJoinRoom_Notification"
#define kUserExitRoom_Notification      @"kUserExitRoom_Notification"
#define kUserUpVideo_Notification       @"kUserUpVideo_Notification"
#define kUserDownVideo_Notification     @"kUserDownVideo_Notification"

/******************** role string **********************/
#define kSxbRole_Host       @"LiveMaster"
#define kSxbRole_Guest      @"Guest"
#define kSxbRole_Interact   @"LiveGuest"

#endif /* ConstHeader_h */
