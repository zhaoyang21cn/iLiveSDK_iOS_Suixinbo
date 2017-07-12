//
//  TILLiveRoomOption.h
//  TILLiveSDK
//
//  Created by kennethmiao on 17/3/6.
//  Copyright © 2017年 kennethmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ILiveSDK/ILiveRoomOption.h>

@interface TILLiveRoomOption : ILiveRoomOption

/** 
 是否忽略内部custom消息封装格式，默认为NO
 (在不用内部custom消息封装格式时，可定义自己的custom消息封装格式，设置为YES避免内部解析。
 设置为YES，请使用sendOtherMessage发送，onOtherMessage接受。如需兼容老随心播)
 */
@property (nonatomic, assign) BOOL isCustomProtocol;

/**
 主播默认配置
 
 @return TILLiveRoomOption 实例
 */
+ (instancetype)defaultHostLiveOption;

/**
 观众默认配置
 
 @return TILLiveRoomOption 实例
 */
+ (instancetype)defaultGuestLiveOption;

/**
 互动用户默认配置
 
 @return TILLiveRoomOption 实例
 */
+ (instancetype)defaultInteractUserLiveOption;
@end
