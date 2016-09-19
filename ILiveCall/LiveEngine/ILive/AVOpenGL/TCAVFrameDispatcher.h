//
//  TCAVFrameDispatcher.h
//  TCShow
//
//  Created by AlexiChen on 16/4/27.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AVFrameDispatcher.h"

@interface TCAVFrameDispatcher : AVFrameDispatcher

@property (nonatomic, strong) AVGLBaseView *imageView;

- (void)dispatchVideoFrame:(QAVVideoFrame *)frame isLocal:(BOOL)isLocal isFront:(BOOL)frontCamera isFull:(BOOL)isFull;

// Protected Method
- (float)calcRotateAngle:(int)peerFrameAngle selfAngle:(int)frameAngle;

- (BOOL)calcFullScr:(int)peerFrameAngle selfAngle:(int)frameAngle;

@end
