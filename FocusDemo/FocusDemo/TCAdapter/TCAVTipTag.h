//
//  TCAVTipTag.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/16.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#ifndef TCAVTipTag_h
#define TCAVTipTag_h

// 为了方便用户进行扩展，以及自定义，将代码的中提示语（只与界面显示相关的，日志中的除外）提取出来
// 同时将代码中的弹框方式以及提求语等（等抽成共用，方便用户进行重写）
// 为了与其他提示语保持一致，统一使用数字作Localizable.strings的Key
// TAVLocalizedError

typedef NS_ENUM(NSInteger, TCAVTipTag)
{
    // TCAVBaseRoomEngine中的提示语
	ETCAVBaseRoomEngine_SwitchRoom_Tip = 100, // @"开始切换房间".
    ETCAVBaseRoomEngine_ExitRoom_Succ_Tip = 101, // @"退出成功".
    ETCAVBaseRoomEngine_EnterRoom_Fail_Tip = 102, // @"进入房间失败".
    ETCAVBaseRoomEngine_Network_Invailed_Tip = 103, // @"进入房间失败".
    ETCAVBaseRoomEngine_EnterAVRoom_Fail_Tip = 104, // @"进入AV房间失败".
    ETCAVBaseRoomEngine_Host_EnterAVRoom_Succ_Tip = 105, // @"创建直播间成功".
    ETCAVBaseRoomEngine_Guest_EnterAVRoom_Succ_Tip = 106, // @"进入直播间成功".
    ETCAVBaseRoomEngine_SwitchRoom_Succ_Tip = 107, // @"切换直播间成功".
    
    // TCAVLiveRoomEngine中的提示语
    ETCAVLiveRoomEngine_RoomNotAlive_Tip = 108, // @"房间还未创建，请使用enterLive创建成功(enterRoom回调)之后再调此方法".
    ETCAVLiveRoomEngine_EnablingMic_Tip = 109, // @"正在处理Mic".
    ETCAVLiveRoomEngine_EnableMicNotTry_Format_Tip = 110, // @"当前Mic已%@，不需要重复操作".
    ETCAVLiveRoomEngine_EnableMic_Succ_Format_Tip = 111, // @"enableMic:%d成功".
    ETCAVLiveRoomEngine_EnableMic_Fail_Format_Tip = 112, // @"enableMic失败".
    ETCAVLiveRoomEngine_RoomNotRunning_Tip = 113, // @"房间不在Running状态".
    ETCAVLiveRoomEngine_AVContextNull_Tip = 114, // @"_avContext 为 空".
    
    ETCAVLiveRoomEngine_EnablingSpeaker_Tip = 115, // @"正在处理Speaker".
    ETCAVLiveRoomEngine_EnableSpeakerNotTry_Format_Tip = 116, // @"当前Speaker已%@，不需要重复操作".
    ETCAVLiveRoomEngine_EnableSpeaker_Succ_Tip = 117, // @"enableSpeaker成功".
    ETCAVLiveRoomEngine_EnableSpeaker_Fail_Tip = 118, // @"enableSpeaker成功".
    
    ETCAVLiveRoomEngine_EnablingCamera_Tip = 119, // @"正在处理Camera".
    ETCAVLiveRoomEngine_EnableCameraNotTry_Format_Tip = 120, // @"当前Camera已%@，不需要重复操作".
    ETCAVLiveRoomEngine_EnableCamera_Format_Tip = 121, // @"%@摄像头%@".
    
    ETCAVLiveRoomEngine_SwitchCamera_NotOn_Tip = 122, // @"当前相机未打开".
    
    ETCAVLiveRoomEngine_RequestHostView_Succ_Tip = 123, // @"请求画面成功".
    ETCAVLiveRoomEngine_RequestHostView_Fail_Tip = 124, // @"请求画面失败".
    
    ETCAVLiveRoomEngine_SwitchCamera_Succ_Tip = 125, // @"切换摄像头成功".
    ETCAVLiveRoomEngine_SwitchCamera_Fail_Tip = 126, // @"切换摄像头失败".
    
    ETCAVLiveRoomEngine_HostEnterIMChatRoom_Succ_Tip = 127, // @"创建直播聊天室失败".
    ETCAVLiveRoomEngine_GuestEnterIMChatRoom_Fail_Tip = 128, // @"加入直播聊天室失败".
    
    // 推流相关提示语
    ETCAVLiveRoomEngine_StopPushStream_Format_Succ_Tip = 129, // @"停止%@成功".
    ETCAVLiveRoomEngine_StopPushStream_Format_Fail_Tip = 130, // @"停止%@失败".
    ETCAVLiveRoomEngine_PushStream_ExitStop_Succ_Tip = 131, // @"停止推流成功".
    ETCAVLiveRoomEngine_ExitNoPushStream_Succ_Tip = 132, // @"当前没有推流".
    
    // TCAVMultiLiveRoomEngine中的提示语
    ETCAVMultiLiveRoomEngine_RequestHostView_Fail_Tip = 133, // @"请求主播画面失败".
    ETCAVMultiLiveRoomEngine_ChangeRole_Format_Tip = 134, // @"修改角色%@".
    
    ETCAVBaseRoomEngine_NotRightRoomInfo_Tip = 135, // @"房间信息不正确".
    
};




#endif /* TCAVTipTag_h */
