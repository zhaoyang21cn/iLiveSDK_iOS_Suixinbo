//
//  ILiveFrameDispatcher.h
//  ILiveSDK
//
//  Created by kennethmiao on 16/11/5.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QAVSDK/QAVSDK.h>
#import "ILiveCommon.h"

#if TARGET_OS_IOS
#import "ILiveRenderView.h"
#else
#import "ILiveRenderViewForMac.h"
#endif

@interface ILiveFrameDispatcher : NSObject

/**
 在当前视图坐标系下的rect处添加id为identifier的渲染窗口，内部只能添加四路渲染窗口
 @param rect        在当前View坐标系下的区域
 @param identifier  用户id
 @param srcType     视频源
 @return ILiveRenderView 对象
 */
- (ILiveRenderView *)addRenderAt:(CGRect)rect forIdentifier:(NSString *)identifier srcType:(avVideoSrcType)srcType;

/**
 修改渲染窗口位置
 @param frame       新区域
 @param identifier  用户id
 @param srcType     视频源
 */
- (void)modifyAVRenderView:(CGRect)frame forIdentifier:(NSString *)identifier srcType:(avVideoSrcType)srcType;

/**
 删除对应的渲染窗口
 @param  identifier       用户id
 @param  srcType          视频源
 @return ILiveRenderView  视频视图
 */
- (ILiveRenderView *)removeRenderViewFor:(NSString *)identifier srcType:(avVideoSrcType)srcType;

/**
 获取渲染窗口
 @param identifier       用户id
 @param srcType          视频源
 @return ILiveRenderView 对象
 */
- (ILiveRenderView *)getRenderView:(NSString *)identifier srcType:(avVideoSrcType)srcType;

/**
 交换两个渲染窗口的位置
 @param  identifier        用户1
 @param  srcType           用户1视频源
 @param  anotherIdentifier 用户2
 @param  anotherSrcType    用户2视频源
 @return BOOL              结果
 */
- (BOOL)switchRenderViewOf:(NSString *)identifier srcType:(avVideoSrcType)srcType withRender:(NSString *)anotherIdentifier anotherSrcType:(avVideoSrcType)anotherSrcType;

/**
 获取所有渲染窗口
 @return NSArray ILiveRenderView
 */
- (NSArray *)getAllRenderViews;

/**
 删除所有渲染视图
 @return NSArray ILiveRenderView
 */
- (NSArray *)removeAllRenderViews;

/**
 分发视频帧
 @param  frame   视频帧
 */
- (void)dispatchVideoFrame:(QAVVideoFrame *)frame;

/**
 将kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange(NV12)格式的视频转为QAVVideoFrame
 @return QAVVideoFrame
 */
- (QAVVideoFrame *)getVideoFrameFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 开始渲染
 */
- (void)startDisplay;

/**
 停止渲染
 */
- (void)stopDisplay;

/**
 是否开始渲染
 @return  BOOL  是否开始渲染
 */
- (BOOL)isStartRender;
@end
