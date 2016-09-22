//
//  TCAVLivePreview.m
//  TCShow
//
//  Created by AlexiChen on 15/11/16.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import "TCAVLivePreview.h"


@implementation TCAVLeaveView

- (void)addOwnViews
{
    self.backgroundColor = [kBlackColor colorWithAlphaComponent:0.5];
    
    _lostView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_miss"]];
    [self addSubview:_lostView];
    
    _lostTip = [[UILabel alloc] init];
    _lostTip.textAlignment = NSTextAlignmentCenter;
    _lostTip.textColor = kWhiteColor;
    _lostTip.font = kCommonMiddleTextFont;
    [self addSubview:_lostTip];
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = [self bounds];
    CGSize imgSize = _lostView.image.size;
    [_lostView sizeWith:imgSize];
    [_lostView layoutParentCenter];
    [_lostView move:CGPointMake(0, -(imgSize.height/2 + 15))];
    
    [_lostTip sizeWith:CGSizeMake(rect.size.width, 20)];
    [_lostTip layoutBelow:_lostView margin:15];
}

- (void)onUserLeave:(id<IMUserAble>)user
{
    _lostTip.text = [NSString stringWithFormat:@"[%@]离开了...精彩稍候呈现", [user imUserName]];
    self.hidden = NO;
}
- (void)onUserBack:(id<IMUserAble>)user
{
    self.hidden = YES;
}

@end

@implementation TCAVLivePreview

- (void)dealloc
{
    DebugLog(@"[%@] : %p 释放成功", [self class], self);
    _frameDispatcher.imageView = nil;
    _frameDispatcher = nil;
    [self stopPreview];
    [_imageView destroyOpenGL];
    _imageView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _imageView = [[AVGLBaseView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = kBlackColor;
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        [_imageView setBackGroundTransparent:YES];
        [self addSubview:_imageView];
        
        @try
        {
            [_imageView initOpenGL];
            
            [self configDispatcher];
            DebugLog(@"初始化OpenGL成功");
            
        }
        @catch (NSException *exception)
        {
            DebugLog(@"OpenGL 初台化异常");
        }
        @finally
        {
            
        }
    }
    return self;
}

- (void)configDispatcher
{
    if (!_frameDispatcher)
    {
        _frameDispatcher = [[TCAVFrameDispatcher alloc] init];
        _frameDispatcher.imageView = _imageView;
    }
    else
    {
        DebugLog(@"Protected方法，外部禁止调用");
    }
}

- (void)registLeaveView:(Class)leaveViewClass
{
    if (![leaveViewClass conformsToProtocol:@protocol(TCAVLeaveAbleView)])
    {
        DebugLog(@"消失界面的类型[%@]不对", leaveViewClass);
        return;
    }
    
    _leaveView = [[leaveViewClass alloc] init];
    _leaveView.hidden = YES;
    [self addSubview:_leaveView];
    _leaveView.frame = self.bounds;
    
}

- (void)onUserBack:(id<IMUserAble>)user
{
    [_leaveView onUserBack:user];
}

- (BOOL)isRenderUserLeave
{
    return !_leaveView.hidden;
}

- (void)hiddenLeaveView
{
    _leaveView.hidden = YES;
}

- (void)onUserLeave:(id<IMUserAble>)user
{
    [_leaveView onUserLeave:user];
}

- (void)startPreview
{
    if (_imageView)
    {
        [_imageView startDisplay];
    }
    
}

- (void)stopPreview
{
    if (_imageView)
    {
        [_imageView stopDisplay];
    }
}

- (void)stopAndRemoveAllRender
{
    if (_imageView)
    {
        [_imageView stopDisplay];
    }
    [_imageView removeAllSubviewKeys];
}

- (void)removeRenderOf:(id<IMUserAble>)user
{
    if (user)
    {
        [_imageView removeSubviewForKey:[user imUserId]];
    }
}

- (void)addRenderFor:(id<IMUserAble>)user
{
    if (!user)
    {
        return;
    }
    
    _imageView.frame = self.bounds;
    
    NSString *uid = [user imUserId];
    AVGLCustomRenderView *glView = (AVGLCustomRenderView *)[_imageView getSubviewForKey:uid];
    
    if (!glView)
    {
        glView = [[AVGLCustomRenderView alloc] initWithFrame:_imageView.bounds];
        [_imageView addSubview:glView forKey:uid];
    }
    else
    {
        DebugLog(@"已存在的%@渲染画面，不重复添加", uid);
    }
    
    glView.frame = _imageView.bounds;
    [glView setHasBlackEdge:NO];
    glView.nickView.hidden = YES;
    [glView setBoundsWithWidth:0];
    [glView setDisplayBlock:NO];
    [glView setCuttingEnable:YES];
    
    if (![_imageView isDisplay])
    {
        [_imageView startDisplay];
    }
}

- (void)updateRenderFor:(id<AVMultiUserAble>)user
{
    AVGLCustomRenderView *view = (AVGLCustomRenderView *)[_imageView getSubviewForKey:[user imUserId]];
    if (!view)
    {
        [self addRenderFor:user];
    }
}

- (void)render:(QAVVideoFrame *)frame roomEngine:(TCAVBaseRoomEngine *)engine fullScreen:(BOOL)fullShow
{
    if ([_imageView isDisplay])
    {
        BOOL isLocal = frame.identifier.length == 0;
        if (isLocal)
        {
            // 为多人的时候要处理
            frame.identifier = [[IMAPlatform sharedInstance].host imUserId];
        }
        
        [_frameDispatcher dispatchVideoFrame:frame roomEngine:engine isLocal:isLocal isFull:fullShow];
    }
}

//- (void)render:(QAVVideoFrame *)frame mirrorReverse:(BOOL)reverse fullScreen:(BOOL)fullShow
//{    
//    if ([_imageView isDisplay])
//    {
//        BOOL isLocal = frame.identifier.length == 0;
//        if (isLocal)
//        {
//            // 为多人的时候要处理
//            frame.identifier = [[IMAPlatform sharedInstance].host imUserId];
//        }
//        
////        [_frameDispatcher dispatchVideoFrame:frame isLocal:isLocal isFront:reverse isFull:fullShow];
//    }
//}
//
//- (void)render:(QAVVideoFrame *)frame isHost:(BOOL)isHost mirrorReverse:(BOOL)reverse isFullScreen:(BOOL)isFullScreen
//{
//    //do nothing
//    //子类重写
//}

- (void)relayoutFrameOfSubViews
{
    _imageView.frame = self.bounds;
    [_leaveView setFrameAndLayout:self.bounds];
}

@end