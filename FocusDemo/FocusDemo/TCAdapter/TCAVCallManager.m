//
//  TCAVCallManager.m
//  TIMChat
//
//  Created by AlexiChen on 16/6/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportCallScene
#import "TCAVCallManager.h"

@implementation TCAVCallManager

// 将用户添加并显示
// 如果当
- (void)addRenderAndRequest:(NSArray *)imusers
{
    if (imusers.count)
    {
        
        // main已赋值时，不能再处理
        if (!_mainUser)
        {
            id<AVMultiUserAble> user = imusers[0];
            BOOL hasAdd = [self addInteractUser:user];
            
            if (hasAdd)
            {
                _mainUser = user;
                
                // 设置界面相关
                [_mainUser setAvInvisibleInteractView:nil];
                [_mainUser setAvInteractArea:[_preview bounds]];
                [_preview addRenderFor:_mainUser];
                
            }
            
        }
        
        [self requestMultipleViewOf:imusers];
    }
    
    
}

- (void)registSelfOnRecvInteractRequest
{
    if (!_preview)
    {
        DebugLog(@"preview不能为空");
        return;
    }
    id<AVMultiUserAble> curentIMHost = (id<AVMultiUserAble>)[_roomEngine getIMUser];
    // 先检查本地是否已加
    BOOL hasAdd = [self addInteractUser:curentIMHost];
    
    if (hasAdd)
    {
        if ([_multiDelegate respondsToSelector:@selector(onAVIMMIMManager:assignWindowResourceTo:isInvite:)])
        {
            // 外部同步分配资源
            [_multiDelegate onAVIMMIMManager:self assignWindowResourceTo:curentIMHost isInvite:NO];
            [_preview addRenderFor:curentIMHost];
        }
    }
    
    [_roomEngine asyncEnableCamera:YES completion:nil];
}

- (BOOL)forcedCancelInteractUser:(id<AVMultiUserAble>)user
{
    // 检查是否有该用户在互动
    id<AVMultiUserAble> iu = [self interactUserOf:user];
    if (!iu)
    {
        DebugLog(@"%@ 没有在互动中", [user imUserId]);
        return NO;
    }
    
    id<IMUserAble> liveHost = [[_roomEngine getRoomInfo] liveHost];
    id<IMUserAble> curHost = [_roomEngine getIMUser];
    
    
    // 移除
    [_multiResource removeObject:iu];
    
    // 取消请求画面
    [_roomEngine asyncCancelRequestViewOf:iu];
    
    if ([[iu imUserId] isEqualToString:[_mainUser imUserId]])
    {
        // 如果是主界面被移移
        // 找到主播的画面
        DebugLog(@"主屏幕画面用户取消互动");
        id<AVMultiUserAble> ih = [self interactUserOfID:[liveHost imUserId]];
        
        if (!ih)
        {
            // 连主播的画面都没有
            if ([_multiResource count] >= 1)
            {
                ih = [_multiResource objectAtIndex:0];
            }
            else
            {
                // 没有画面显示
                ih = iu;
            }
        }
        
        if (ih != iu)
        {
            [_preview replaceRender:iu withUser:ih];
            // 更新mainuser
            _mainUser = ih;
        }
        else
        {
            [_preview removeRenderOf:iu];
            // TODO:下面这句有可能会有影响
            _mainUser = nil;
        }
        
        // 回收窗口
        if ([_multiDelegate respondsToSelector:@selector(onAVIMMIMManager:recycleWindowResourceOf:)])
        {
            [_multiDelegate onAVIMMIMManager:self recycleWindowResourceOf:ih];
        }
        
    }
    else
    {
        [_preview removeRenderOf:iu];
        
        // 回收窗口
        if ([_multiDelegate respondsToSelector:@selector(onAVIMMIMManager:recycleWindowResourceOf:)])
        {
            [_multiDelegate onAVIMMIMManager:self recycleWindowResourceOf:iu];
        }
        
    }
    
    if ([[iu imUserId] isEqualToString:[curHost imUserId]])
    {
        // 断开自己的资源信息
        [_roomEngine asyncEnableCamera:NO needNotify:NO];
        // [_roomEngine disableHostCtrlState:EAVCtrlState_Mic];
        
        // [_roomEngine asyncEnableMic:NO completion:nil];
        // [_roomEngine disableHostCtrlState:EAVCtrlState_Camera];
        
        // 不处理Speaker
        // [_roomEngine asyncEnableSpeaker:NO completion:nil];
        
        [self changeToNormalGuestAuthAndRole:^(id selfPtr, BOOL isFinished) {
            DebugLog(@"修改Auth以及Role到普通观众%@", isFinished ? @"成功" : @"失败");
        }];
    }
    
    
    
    
    // 更新界面上渲染的窗口位置
    DebugLog(@"取消 %@ 互动成功", [iu imUserId]);
    [_preview updateAllRenderOf:_multiResource];
    return YES;
    
}

- (BOOL)addInteractUser:(id<AVMultiUserAble>)user
{
    if (!user)
    {
        return NO;
    }
    
    BOOL hasRegMain = NO;
    if (_mainUser == nil)
    {
        _mainUser = user;
        
        // 设置界面相关
        [_mainUser setAvInvisibleInteractView:nil];
        [_mainUser setAvInteractArea:[_preview bounds]];
        
        [_preview addRenderFor:_mainUser];
        
        hasRegMain = YES;
    }
    
    // 检查是否已在互动
    id<AVMultiUserAble> iu = [self interactUserOf:user];
    if (iu)
    {
        DebugLog(@"%@ 正在互动中，不再重复添加", user);
        return NO;
    }
    
    
    NSInteger count = [_roomEngine canRequestMore];
    if (count <= 0)
    {
        DebugLog(@"已达到请求上限，不能再请求");
        [[HUDHelper sharedInstance] tipMessage:[NSString stringWithFormat:@"最多只能有%d个互动观众", (int)[_roomEngine maxRequestViewCount]]];
        return NO;
    }
    
    // 如果在不继续请求
    if (!_multiResource)
    {
        _multiResource = [[NSMutableArray alloc] init];
    }
    
    [_multiResource addObject:user];
    
    if (hasRegMain)
    {
        return NO;
    }
    
    return YES;
}


// 具体与Spear配置相关，请注意设置
- (void)changeToInteractAuthAndRole:(CommonCompletionBlock)completion
{
    // [_roomEngine changeToInteractAuthAndRole:completion];
    // do nothing
}

// 当前是互动观众时，下麦时，使用
- (void)changeToNormalGuestAuthAndRole:(CommonCompletionBlock)completion
{
    //    [_roomEngine changeToNormalGuestAuthAndRole:completion];
    // do nothing
}



@end
#endif