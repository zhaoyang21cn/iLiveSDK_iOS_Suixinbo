//
//  TCAVLivePreview.h
//  TCShow
//
//  Created by AlexiChen on 15/11/16.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TCAVLeaveView : UIView<TCAVLeaveAbleView>
{
@protected
    UIImageView     *_lostView;
    UILabel         *_lostTip;
}

@end


// 主播端的渲染
// TCAVLivePreview 处理一路画面显示的问题
@interface TCAVLivePreview : UIView
{
@protected
    AVGLBaseView                *_imageView;            // 画面
    TCAVFrameDispatcher         *_frameDispatcher;      // 分发器
@protected
    UIView<TCAVLeaveAbleView>   *_leaveView;
}

@property (nonatomic, readonly) AVGLBaseView *imageView;

- (void)registLeaveView:(Class)leaveViewClass;
// user为该画面对应的对象
// 默认全屏显示, 本地只有路画面
- (void)addRenderFor:(id<IMUserAble>)user;

- (void)updateRenderFor:(id<AVMultiUserAble>)user;

- (void)removeRenderOf:(id<IMUserAble>)user;

- (void)render:(QAVVideoFrame *)frame roomEngine:(TCAVBaseRoomEngine *)engine fullScreen:(BOOL)fullShow;
//- (void)render:(QAVVideoFrame *)frame mirrorReverse:(BOOL)reverse fullScreen:(BOOL)fullShow;
//
//- (void)render:(QAVVideoFrame *)frame isHost:(BOOL)isHost mirrorReverse:(BOOL)reverse isFullScreen:(BOOL)isFullScreen;

// 开始预览
- (void)startPreview;

- (void)stopPreview;

- (void)stopAndRemoveAllRender;

- (BOOL)isRenderUserLeave;

- (void)hiddenLeaveView;

- (void)onUserLeave:(id<IMUserAble>)user;
- (void)onUserBack:(id<IMUserAble>)user;

// protected方法，外部禁止调用
- (void)configDispatcher;

@end
