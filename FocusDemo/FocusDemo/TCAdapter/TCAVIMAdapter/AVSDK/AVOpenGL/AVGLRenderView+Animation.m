////
////  AVGLRenderView+Animation.m
////  OpenGLRestruct
////
////  Created by vigoss on 14-11-14.
////  Copyright (c) 2014年 vigoss. All rights reserved.
////
//
//#import "AVGLRenderView+Animation.h"
//
//int            g_glAnimationStep;
//NSTimeInterval g_glAnimationDuration;
//NSMutableArray * g_glAnimationListers;
//NSTimer        * g_glAnimationTimer;
//
//UIViewAnimationCurve    g_glAnimationCurve;
//BOOL                    g_glAnimationStatus;
//SEL                     g_glAnimationStopSelector;
//id                      g_glAnimationDelegate;
//
//@implementation AVGLRenderView (Animation)
//
//+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
//{
//    [AVGLRenderView beginAnimations:@"move" context:nil];
//    [AVGLRenderView setAnimationCurve:UIViewAnimationCurveEaseIn];
//    [AVGLRenderView setAnimationDuration:duration];
//    [AVGLRenderView setAnimationDelegate:self];
//    [AVGLRenderView setAnimationDidStopSelector:@selector(animationStop)];
//    animations();
//    [AVGLRenderView commitAnimations];
//
//}
//
//+ (void)animationStop
//{
//    
//}
//
//+ (void)registerAnimation:(AVGLRenderView *)renderView
//{
//    if (g_glAnimationStatus == Animation_State_None)
//    {
//        return;
//    }
//    if(g_glAnimationListers == nil)
//    {
//        g_glAnimationListers = CZ_NewMutableArray();
//    }
//    [g_glAnimationListers addObject:renderView];
//}
//
//+ (void)beginAnimations:(NSString *)animationID context:(void *)context
//{
//    NSLog(@"animationID");
//    g_glAnimationStatus = Animation_State_Prepare;
//}
//
//+ (void)setAnimationDidStopSelector:(SEL)selector
//{
//    g_glAnimationStopSelector = selector;
//}
//
//+ (void)setAnimationDelegate:(id)delegate
//{
//    g_glAnimationDelegate = delegate;
//}
//
//+ (void)setAnimationDuration:(NSTimeInterval)duration
//{
//    g_glAnimationDuration = duration;
//}
//
////暂时只支持UIViewAnimationCurveLinear。
//+ (void)setAnimationCurve:(UIViewAnimationCurve)curve
//{
//    g_glAnimationCurve = curve;
//}
//
//+ (void)commitAnimations
//{
//    g_glAnimationStatus = Animation_State_On;
//    g_glAnimationStep = 0;
//    g_glAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:g_glAnimationDuration/GL_ANIMATION_STEP_COUNT target:self selector:@selector(onRenderTimer) userInfo:nil repeats:YES];
//}
//
//+ (void)removeAllAnimation
//{
//    if (g_glAnimationTimer != nil)
//    {
//        [g_glAnimationTimer invalidate];
//        g_glAnimationTimer = nil;
//    }
//    g_glAnimationCurve = UIViewAnimationCurveEaseIn;
//    g_glAnimationDelegate = nil;
//    g_glAnimationStatus = Animation_State_None;
//    g_glAnimationStopSelector = nil;
//    g_glAnimationDuration = 0.0f;
//    g_glAnimationStep = 0;
//
//    [g_glAnimationListers removeAllObjects];
//}
//
//+ (ENAnimatioState)getAnimationStatus
//{
//    return g_glAnimationStatus;
//}
//
//+ (CGFloat)getStepLengthAtIndex:(int)index
//{
//    CGFloat stepLength;
//    switch (g_glAnimationCurve)
//    {
//        case UIViewAnimationCurveLinear:
//            stepLength = 1.0/GL_ANIMATION_STEP_COUNT;
//            break;
//            
//        default:
//            stepLength = 1.0/GL_ANIMATION_STEP_COUNT;
//            break;
//            break;
//    }
//    return stepLength;
//}
//
//+ (void)onRenderTimer
//{
//    g_glAnimationStep = g_glAnimationStep + 1;
//    if (g_glAnimationStep < GL_ANIMATION_STEP_COUNT +1)
//    {
//        for (AVGLRenderView * animationView in g_glAnimationListers)
//        {
//            [animationView animationAtStepIndex:g_glAnimationStep];
//        }
//    }
//    else
//    {
//
//        if (g_glAnimationDelegate != nil)
//        {
//            //这里的delegate 是要retain吗？否则如果 对象已经释放了，这里的timer还在走。
//            [g_glAnimationDelegate performSelector:g_glAnimationStopSelector withObject:nil afterDelay:0.0f];
////            [g_glAnimationDelegate performSelector:g_glAnimationStopSelector withObject:nil];
//            g_glAnimationDelegate = nil;
//        }
//        
//        [self removeAllAnimation];
//
//    }
//}
//@end
