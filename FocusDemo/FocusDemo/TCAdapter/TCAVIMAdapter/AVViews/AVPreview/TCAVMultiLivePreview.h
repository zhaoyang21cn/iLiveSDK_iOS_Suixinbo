//
//  TCAVMultiLivePreview.h
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVLivePreview.h"

@interface TCAVMultiLeaveView : TCAVLeaveView

@end

@interface TCAVMultiLivePreview : TCAVLivePreview


- (void)updateAllRenderOf:(NSArray *)users;

// 交换显示的位置
// mainuser 为当前主屏幕的用户（显示在最底层）
- (BOOL)switchRender:(id<AVMultiUserAble>)user withMainUser:(id<AVMultiUserAble>)mainuser;

// 用newUser的画面显示到user上，newUser原来所占位置被移除
- (BOOL)replaceRender:(id<AVMultiUserAble>)user withUser:(id<AVMultiUserAble>)newUser;

//- (void)render:(QAVVideoFrame *)frame ofUser:(id<AVMultiUserAble>)user mirrorReverse:(BOOL)reverse isFullScreen:(BOOL)isFullScreen;

@end

