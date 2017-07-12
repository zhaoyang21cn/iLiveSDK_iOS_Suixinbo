//
//  ILiveQualityData.h
//  ILiveSDK
//
//  Created by wilderliao on 16/10/31.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ILiveQualityData : NSObject

/** 统计开始时间 */
@property (nonatomic, assign) NSInteger startTime;
/** 统计结束时间 */
@property (nonatomic, assign) NSInteger endTime;
/** 发包丢包率，以百分比乘以100作为返回值。（如：丢包率为23.66%，sendLossRate=2366）*/
@property (nonatomic, assign) NSInteger sendLossRate;
/** 收包丢包率，以百分比乘以100作为返回值。（如：丢包率为23.66%，recvLossRate=2366) */
@property (nonatomic, assign) NSInteger recvLossRate;
/** app占用CPU，以百分比乘以100作为返回值。（如：cpu占用率为7.66%，appCPURate=766) */
@property (nonatomic, assign) NSInteger appCPURate;
/** 系统占用CPU，以百分比乘以100作为返回值。（如：cpu占用率为7.66%，appCPURate=766) */
@property (nonatomic, assign) NSInteger sysCPURate;
/** 互动直播场景下，画面帧率，以百分比乘以10作为返回值。（如帧率为 15.4fps，interactiveSceneFPS = 154）*/
@property (nonatomic, assign) NSInteger interactiveSceneFPS;
/** 发送速率 单位: kbps*/
@property (nonatomic, assign) NSInteger sendRate;
/** 接收速率 单位: kbps*/
@property (nonatomic, assign) NSInteger recvRate;
@end
