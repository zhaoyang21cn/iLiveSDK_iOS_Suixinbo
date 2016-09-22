//
//  TCAVFrameDispatcher.m
//  TCShow
//
//  Created by AlexiChen on 16/4/27.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVFrameDispatcher.h"

@implementation TCAVFrameDispatcher

//- (instancetype)init
//{
//    if (self = [super init])
//    {
//        //默认自动校正
//        _iLiveRotation = ILiveRotation_Auto;
//    }
//    return self;
//}

- (void)dispatchVideoFrame:(QAVVideoFrame *)frame roomEngine:(TCAVBaseRoomEngine *)engine isLocal:(BOOL)isLocal isFull:(BOOL)isFull
{
//    _iLiveRotation = ILiveRotation_Crop;
    
    BOOL isHost = [engine isHostLive];
    BOOL isFrontCamera = [engine isFrontCamera];
    
    NSString *renderKey = frame.identifier;
    
    AVGLCustomRenderView *glView = (AVGLCustomRenderView *)[self.imageView getSubviewForKey:renderKey];
    
    if (glView)
    {
        unsigned int selfFrameAngle = 1;//[self didRotate:YES];
        unsigned int peerFrameAngle = frame.frameDesc.rotate % 4;
        
        if (isLocal)
        {
            selfFrameAngle = 0;
            peerFrameAngle = 0;
            [glView setNeedMirrorReverse:isFrontCamera];
        }
        else
        {
            [glView setNeedMirrorReverse:NO];
        }
        
        glView.isFloat = !isFull;
        
        float degree = 0;
        BOOL isFullScreenShow = YES;
        BOOL isCropFullScreen = NO;
        
        ILiveRotationType rotationType = glView.iLiveRotationType;
        switch (rotationType)
        {
            case ILiveRotation_Auto:
                //计算旋转角度
                degree = [self calcRotateAngle:peerFrameAngle selfAngle:selfFrameAngle];
                degree = isLocal ? degree + 180.0f : degree;
                //计算是否全屏显示
                isFullScreenShow = [self calcFullScr:peerFrameAngle selfAngle:selfFrameAngle];
                break;
            case ILiveRotation_FullScreen:
                //计算旋转角度
                //sdk目前不支持采集时设置angle，所以有互动小视图时，无法旋转到合适的方向，随心播中在观众无法切换到后置摄像头的前提下，可做如下判断，
                //在主播端，当是远程画面，且主播端开启的是后置摄像头，且观众端的画面角度peerFrameAngle为0/2（观众端手机横屏）时，主播端手动增加旋转180度，以调整画面
                if (!isLocal && isHost && !isFrontCamera)
                {
                    if ( (peerFrameAngle == 2 && selfFrameAngle == 1) ||
                         (peerFrameAngle == 0 && selfFrameAngle == 1)  )
                    {
                        degree = 180;
                    }
                }
                if (peerFrameAngle == 1 || peerFrameAngle == 3)
                {
                    degree = [self calcRotateAngle:peerFrameAngle selfAngle:selfFrameAngle];
                }
                else
                {
                    degree = 270+degree;
                }
                
                //始终全屏显示
                isFullScreenShow = YES;
                break;
            case ILiveRotation_Crop:
                //计算旋转角度
                degree = [self calcRotateAngle:peerFrameAngle selfAngle:selfFrameAngle];
                degree = isLocal ? degree + 180.0f : degree;
                
                //始终全屏显示
                isFullScreenShow = YES;
                isCropFullScreen = YES;
                break;
            default:
                break;
        }
        
        
        AVGLImage * image = [[AVGLImage alloc] init];
        image.angle = degree;
        image.data = (Byte *)frame.data;
        image.width = (int)frame.frameDesc.width;
        image.height = (int)frame.frameDesc.height;
        image.isFullScreenShow = isFullScreenShow;
        image.viewStatus = VIDEO_VIEW_DRAWING;
        image.dataFormat = isLocal ?  Data_Format_NV12  : Data_Format_I420;
        
        [glView setImage:image];
    }
}

- (float)calcRotateAngle:(int)peerFrameAngle selfAngle:(int)frameAngle
{
    float degree = 0.0f;
    
    frameAngle = (frameAngle+peerFrameAngle+3)%4;
    
    // 调整显示角度
    switch (frameAngle)
    {
        case 0:
        {
            degree = -180.0f;
        }
            break;
        case 1:
        {
            degree = -90.0f;
        }
            break;
        case 2:
        {
            degree = 0.0f;
        }
            break;
        case 3:
        {
            degree = 90.0f;
        }
            break;
        default:
        {
            degree = 0.0f;
        }
            break;
    }
    
    return degree;
}

- (BOOL)calcFullScr:(int)peerFrameAngle selfAngle:(int)frameAngle
{
    if ((peerFrameAngle & 1) == 0 && (frameAngle & 1) == 0)
    {
        // 对方和自己都是横屏
        return YES;
    }
    else if ((peerFrameAngle & 1) && (frameAngle & 1))
    {
        // 对方和自己都是竖屏
        return YES;
    }
    else if ((peerFrameAngle & 1) == 0 && (frameAngle & 1))
    {
        // 对方横屏，自己竖屏
        return NO;
    }
    else if ((peerFrameAngle & 1) && (frameAngle & 1) == 0)
    {
        // 对方竖屏，自己横屏
        return NO;
    }
    return YES;
}

- (BOOL)calcFullScr2{
    return YES;
}
@end
