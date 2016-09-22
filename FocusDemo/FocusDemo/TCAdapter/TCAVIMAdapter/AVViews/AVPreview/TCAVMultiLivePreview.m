//
//  TCAVMultiLivePreview.m
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVMultiLivePreview.h"

@implementation TCAVMultiLeaveView

- (void)addOwnViews
{
    _lostView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_miss"]];
    [self addSubview:_lostView];
    
    _lostTip = [[UILabel alloc] init];
    _lostTip.textAlignment = NSTextAlignmentCenter;
    _lostTip.textColor = kWhiteColor;
    _lostTip.font = kCommonMiddleTextFont;
    [self addSubview:_lostTip];
}

- (void)onUserLeave:(id<IMUserAble>)user
{
    _lostTip.text = [NSString stringWithFormat:@"%@离开了...精彩稍候呈现", [user imUserName]];
    self.hidden = NO;
}


@end

@implementation TCAVMultiLivePreview

- (void)addRenderFor:(id<AVMultiUserAble>)user
{
    // 判断是否已添加
    if (user)
    {
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
        
        [glView setHasBlackEdge:NO];
        glView.nickView.hidden = YES;
        [glView setBoundsWithWidth:0];
        [glView setDisplayBlock:NO];
        [glView setCuttingEnable:YES];
        
        CGRect rect = [user avInteractArea];
        if (!CGRectIsEmpty(rect))
        {
            [glView setFrame:rect];
        }
        
        if (![_imageView isDisplay])
        {
            [_imageView startDisplay];
        }
        
    }
}

- (void)updateAllRenderOf:(NSArray *)users
{
    for (id<AVMultiUserAble> user in users)
    {
        AVGLCustomRenderView *glView = (AVGLCustomRenderView *)[_imageView getSubviewForKey:[user imUserId]];
        if (glView)
        {
            CGRect rect = [user avInteractArea];
            glView.frame = rect;
        }
    }
}


- (void)updateRenderFor:(id<AVMultiUserAble>)user
{
    AVGLCustomRenderView *view = (AVGLCustomRenderView *)[_imageView getSubviewForKey:[user imUserId]];
    if (!view)
    {
        [self addRenderFor:user];
    }
    else
    {
        CGRect rect = [user avInteractArea];
        DebugLog(@"updateRenderFor======>>>>>>>%@ %@", [user imUserId], NSStringFromCGRect(rect));
        if (!CGRectIsEmpty(rect))
        {
            [view setFrame:rect];
        }
    }
}

//- (void)render:(QAVVideoFrame *)frame ofUser:(id<AVMultiUserAble>)user mirrorReverse:(BOOL)reverse isFullScreen:(BOOL)isFullScreen
//{
//    if ([_imageView isDisplay])
//    {
//        BOOL isLocal = frame.identifier.length;
//        if (isLocal)
//        {
//            // 为多人的时候要处理
//            frame.identifier = [[IMAPlatform sharedInstance].host imUserId];
//        }
//        
//        [_frameDispatcher dispatchVideoFrame:frame isLocal:isLocal isFront:reverse isFull:isFullScreen];
//    }
//}

//- (void)render:(QAVVideoFrame *)frame isHost:(BOOL)isHost mirrorReverse:(BOOL)reverse isFullScreen:(BOOL)isFullScreen
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
//        [_frameDispatcher dispatchVideoFrame:frame isHost:isHost isLocal:isLocal isFront:reverse isFull:isFullScreen];
//    }
//}

- (BOOL)switchRender:(id<AVMultiUserAble>)user withMainUser:(id<AVMultiUserAble>)mainuser
{
    BOOL succ = [_imageView switchSubviewForKey:[user imUserId] withKey:[mainuser imUserId]];
    if (succ)
    {
        UIView *mainView = [mainuser avInvisibleInteractView];
        CGRect mainRect = [mainuser avInteractArea];
        
        UIView *iuView = [user avInvisibleInteractView];
        CGRect iuRect = [user avInteractArea];
        
        [user setAvInvisibleInteractView:mainView];
        [user setAvInteractArea:mainRect];
        
        [mainuser setAvInvisibleInteractView:iuView];
        [mainuser setAvInteractArea:iuRect];
        
        // 更新显示的位置
        [self updateRenderFor:user];
        [self updateRenderFor:mainuser];
        
    }
    return succ;
}

- (BOOL)replaceRender:(id<AVMultiUserAble>)user withUser:(id<AVMultiUserAble>)newUser
{
    // 先交换二者的位置参数
    BOOL succ = [_imageView switchSubviewForKey:[user imUserId] withKey:[newUser imUserId]];
    if (succ)
    {
        UIView *iuView = [user avInvisibleInteractView];
        CGRect iuRect = [user avInteractArea];
        
        [newUser setAvInvisibleInteractView:iuView];
        [newUser setAvInteractArea:iuRect];
        
        // 更新显示的位置
        [self updateRenderFor:newUser];
        [self removeRenderOf:user];
        
    }
    return succ;
}

@end
