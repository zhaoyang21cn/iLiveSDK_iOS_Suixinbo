//
//  TCAVFrameDispatcher.h
//  TCShow
//
//  Created by AlexiChen on 16/4/27.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AVFrameDispatcher.h"


#import <CoreMotion/CoreMotion.h>

//typedef NS_ENUM(NSInteger, ILiveRotation)
//{
//    //自动校正
//    ILiveRotation_Auto = 0,
//    //始终全屏显示
//    ILiveRotation_FullScreen,
//    //剪裁校正
//    ILiveRotation_Crop,
//};

@interface TCAVFrameDispatcher : AVFrameDispatcher
//{
//@protected
//    ILiveRotation _iLiveRotation;
//}

//@property (nonatomic, assign) ILiveRotation iLiveRotation;
@property (nonatomic, strong) AVGLBaseView *imageView;

- (void)dispatchVideoFrame:(QAVVideoFrame *)frame roomEngine:(TCAVBaseRoomEngine *)engine isLocal:(BOOL)isLocal isFull:(BOOL)isFull;

//- (void)dispatchVideoFrame:(QAVVideoFrame *)frame isLocal:(BOOL)isLocal isFront:(BOOL)frontCamera isFull:(BOOL)isFull;

//- (void)dispatchVideoFrame:(QAVVideoFrame *)frame isHost:(BOOL)isHost isLocal:(BOOL)isLocal isFront:(BOOL)frontCamera isFull:(BOOL)isFull;

// Protected Method
- (float)calcRotateAngle:(int)peerFrameAngle selfAngle:(int)frameAngle;

- (BOOL)calcFullScr:(int)peerFrameAngle selfAngle:(int)frameAngle;

@end
