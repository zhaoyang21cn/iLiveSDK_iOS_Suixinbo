//
//  ILiveRenderView.h
//  ILiveSDK
//
//  Created by kennethmiao on 16/11/5.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#import <QAVSDK/QAVSDK.h>

/**
 * 顺时针旋转角度
 */
typedef NS_ENUM(NSInteger, ILiveRotation){
    /**
     * 旋转0度
     */
    ILIVEROTATION_0     =  0,
    /**
     * 旋转90度
     */
    ILIVEROTATION_90    =  1,
    /**
     * 旋转180度
     */
    ILIVEROTATION_180   =  2,
    /**
     * 旋转270度
     */
    ILIVEROTATION_270   =  3,
};

/**
 * 具体含义与UIViewContentMode相同
 */
typedef NS_ENUM(NSInteger, ILiveRenderMode){
    /**
     * 自适应填充
     */
    ILIVERENDERMODE_SCALEASPECTFILL   =  0,
    /**
     * 黑边填充
     */
    ILIVERENDERMODE_SCALEASPECTFIT    =  1,
    /**
     * 拉伸填充
     */
    ILIVERENDERMODE_SCALETOFILL       =  2,
};



@interface ILiveRenderView : UIView

/**
 * 渲染视频的identifier
 */
@property (nonatomic, copy) NSString *identifier;

/**
 * 渲染视频源类型
 */
@property (nonatomic, assign) avVideoSrcType srcType;

/**
 * 是否开启自动旋转模式（默认YES）
 */
@property (nonatomic, assign) BOOL autoRotate;

/**
 * 旋转角度（手动旋转模式有效：autoRotate=NO）
 */
@property (nonatomic, assign) ILiveRotation rotateAngle;

/**
 * 画面角度始终旋转至和屏幕角度一致（默认：YES）（自动旋转模式有效：autoRotate=YES）
 */
@property (nonatomic, assign) BOOL isRotate;

/**
 * 是否镜像（主播前置镜像，后置非镜像，此参数设置无效）
 */
@property (nonatomic, assign) BOOL isMirror;


/**
 * 角度一致填充模式（默认：ILIVERENDERMODE_SCALEASPECTFILL）
 * (帧画面和View都是横屏或者都是竖屏)
 */
@property (nonatomic, assign) ILiveRenderMode sameDirectionRenderMode;

/**
 * 角度不一致填充模式（默认：ILIVERENDERMODE_SCALEASPECTFIT）
 */
@property (nonatomic, assign) ILiveRenderMode diffDirectionRenderMode;
- (void)renderFor_1_8_3:(QAVVideoFrame *)frame;
@end
#endif
