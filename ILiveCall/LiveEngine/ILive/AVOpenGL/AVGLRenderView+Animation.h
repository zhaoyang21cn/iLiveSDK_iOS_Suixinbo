////
////  AVGLRenderView+Animation.h
////  OpenGLRestruct
////
////  Created by vigoss on 14-11-14.
////  Copyright (c) 2014年 vigoss. All rights reserved.
////
//
//#import "AVGLRenderView.h"
//
//typedef enum enAnimationState
//{
//    Animation_State_None,
//    Animation_State_Prepare,
//    Animation_State_On,
//}ENAnimatioState;
//
//@interface AVGLRenderView (Animation)
//
//+ (void)registerAnimation:(AVGLRenderView *)renderView;
//+ (void)beginAnimations:(NSString *)animationID context:(void *)context;
//  // additional context info passed to will start/did stop selectors. begin/commit can be nested
//+ (void)setAnimationDuration:(NSTimeInterval)duration;              // default = 0.2
//+ (void)setAnimationCurve:(UIViewAnimationCurve)curve;              // default = UIViewAnimationCurveEaseInOut
//+ (void)setAnimationDelegate:(id)delegate;                          // delegate
//+ (void)setAnimationDidStopSelector:(SEL)selector;                  // default = NULL. 
//
//+ (void)commitAnimations;
//
//+ (ENAnimatioState)getAnimationStatus;  // starts up any animations when the top level animation is commited
//
//+ (CGFloat)getStepLengthAtIndex:(int)index;
//
//+ (void)removeAllAnimation;
//
//@end
