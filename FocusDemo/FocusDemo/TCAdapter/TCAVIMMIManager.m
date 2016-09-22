//
//  TCAVIMMIManager.m
//  TCShow
//
//  Created by AlexiChen on 16/5/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVIMMIManager.h"


@interface TCAVIMMIManager () <TCAVMLRERequestViewDelegate>

@end

@implementation TCAVIMMIManager

- (void)dealloc
{
    DebugLog(@"======>>>>> [%@] %@ 释放成功 <<<<======", [self class], self);
}

- (void)setRoomEngine:(TCAVMultiLiveRoomEngine *)roomEngine
{
    _roomEngine = roomEngine;
    _roomEngine.requestViewDelegate = self;
}

- (BOOL)isMainUser:(id<IMUserAble>)user
{
    return [[_mainUser imUserId] isEqualToString:[user imUserId]];
}

- (BOOL)isMainUserByID:(NSString *)userid
{
    return [[_mainUser imUserId] isEqualToString:userid];
}

- (BOOL)hasInteractUsers
{
    return _multiResource.count > 0;
}

// 是否是互动观众
- (BOOL)isInteractUser:(id<IMUserAble>)user
{
    if (user)
    {
        for (NSInteger i = 0; i < _multiResource.count; i++)
        {
            id<IMUserAble> u = [_multiResource objectAtIndex:i];
            if ([[u imUserId] isEqualToString:[user imUserId]])
            {
                return YES;
            }
        }
    }
    
    return NO;
}

// 查询互动用户

- (id<AVMultiUserAble>)interactUserOfID:(NSString *)userid
{
    if (userid.length)
    {
        for (NSInteger i = 0; i < _multiResource.count; i++)
        {
            id<AVMultiUserAble> u = [_multiResource objectAtIndex:i];
            if ([[u imUserId] isEqualToString:userid])
            {
                return u;
            }
        }
    }
    
    return nil;
}
- (id<AVMultiUserAble>)interactUserOf:(id<IMUserAble>)user
{
    if (user)
    {
        NSInteger idx = [_multiResource indexOfObject:user];
        if (idx >= 0 && idx < _multiResource.count)
        {
            return [_multiResource objectAtIndex:idx];
        }
        
        
        for (NSInteger i = 0; i < _multiResource.count; i++)
        {
            id<AVMultiUserAble> u = [_multiResource objectAtIndex:i];
            if ([[u imUserId] isEqualToString:[user imUserId]])
            {
                return u;
            }
        }
    }
    
    return nil;
}



- (id<AVMultiUserAble>)removeInteractUser:(id<AVMultiUserAble>)user
{
    // 检查是否已在互动
    id<AVMultiUserAble> iu = [self interactUserOf:user];
    if (iu)
    {
        [_multiResource removeObject:iu];
    }
    
    return iu;

}

// 与主屏幕用户进行
- (void)switchAsMainUser:(id<AVMultiUserAble>)user completion:(TCAVCompletion)completion
{
    if (!_preview)
    {
        DebugLog(@"preview不能为空");
        return;
    }
    
    if ([[_mainUser imUserId] isEqualToString:[user imUserId]])
    {
        // 当前用户已在主屏上
        DebugLog(@"user已是主屏幕用户，不需要切换");
        if (completion)
        {
            completion(NO, @"已是主屏幕");
        }
        return;
    }
    else
    {
        // 找到对应的用户
        id<AVMultiUserAble> iu = [self interactUserOf:user];
        if (iu)
        {
            BOOL succ = [_preview switchRender:iu withMainUser:_mainUser];
            
            DebugLog(@"与主窗口用户切换成功");
            if (completion)
            {
                NSString *tip = succ ? @"互换成功" : @"交换失败";
                completion(succ, tip);
            }
            
            if (succ)
            {
                // 交换显示的资源
                _mainUser = iu;
            }
        }
        else
        {
            DebugLog(@"user不在互动列表中，无法切换");
            if (completion)
            {
                completion(NO, @"不在互动中");
            }
        }
    }
}

- (void)registAsMainUser:(id<AVMultiUserAble>)user
{
    // main已赋值时，不能再处理
    if (_mainUser)
    {
        DebugLog(@"主屏幕用户已存在，不能再注册");
        return;
    }
    
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

- (void)registAsMainUser:(id<AVMultiUserAble>)user isHost:(BOOL)host
{
    // main已赋值时，不能再处理
    if (_mainUser)
    {
        DebugLog(@"主屏幕用户已存在，不能再注册");
        [self changeMainUser:user isHost:host];
        return;
    }
    
    
    BOOL hasAdd = [self addInteractUser:user];
    
    if (hasAdd)
    {
        _mainUser = user;
        
        if (!host)
        {
            // 请求画面
            [_roomEngine asyncRequestViewOf:_mainUser];
        }
       
        // 设置界面相关
        [_mainUser setAvInvisibleInteractView:nil];
        [_mainUser setAvInteractArea:[_preview bounds]];
        
        
        [_preview addRenderFor:_mainUser];
        
    }

}

- (void)changeMainUser:(id<AVMultiUserAble>)user isHost:(BOOL)host
{
    // main已赋值时，不能再处理
    if (_mainUser == nil)
    {
        [self registAsMainUser:user isHost:host];
        return;
    }
    
    BOOL hasAdd = [self addInteractUser:user];
    
    if (hasAdd)
    {
        _mainUser = user;
        
        if (!host)
        {
            // 请求画面
            [_roomEngine asyncRequestViewOf:_mainUser];
        }
        
        // 设置界面相关
        [_mainUser setAvInvisibleInteractView:nil];
        [_mainUser setAvInteractArea:[_preview bounds]];
        
        
        [_preview addRenderFor:_mainUser];
        
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
    [_roomEngine asyncEnableMic:YES completion:nil];
    [_roomEngine asyncEnableSpeaker:YES completion:nil];
}

// for Host
// 邀请用户加入互动
- (void)inviteUserJoinInteraction:(id<AVMultiUserAble>)user
{
    BOOL hasAdd = [self addInteractUser:user];
    
    if (hasAdd)
    {
        __weak TCAVIMMIManager *ws = self;
        __weak id<TCAVIMMIManagerDelegate> wd = _multiDelegate;
        // 发送邀请
        __weak TCAVMultiLivePreview *wp = _preview;
        [(MultiAVIMMsgHandler *)_msgHandler sendC2CAction:AVIMCMD_Multi_Host_Invite to:user succ:^{
            // 分配资源
            if ([wd respondsToSelector:@selector(onAVIMMIMManager:assignWindowResourceTo:isInvite:)])
            {
                [wd onAVIMMIMManager:ws assignWindowResourceTo:user isInvite:YES];
                [wp addRenderFor:user];
            }
            
        } fail:^(int code, NSString *msg) {
            DebugLog(@"发送动互邀请失败");
            [ws removeInteractUser:user];
        }];
    }
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
    
    // 主播收到
    if ([[iu imUserId] isEqualToString:[liveHost imUserId]])
    {
        // 主播不能自己取消自己的互动
        DebugLog(@"逻辑错误：主播收到取消互动的消息，而且操作的是自己");
        return NO;
    }
    // 当前用户收到
    else
    {
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
//            [_roomEngine disableHostCtrlState:EAVCtrlState_Mic];
            
            [_roomEngine asyncEnableMic:NO completion:nil];
//            [_roomEngine disableHostCtrlState:EAVCtrlState_Camera];
            
            // 不处理Speaker
            // [_roomEngine asyncEnableSpeaker:NO completion:nil];
            
            [self changeToNormalGuestAuthAndRole:^(id selfPtr, BOOL isFinished) {
                DebugLog(@"修改Auth以及Role到普通观众%@", isFinished ? @"成功" : @"失败");
            }];
        }
        
        
    }
    
    // 更新界面上渲染的窗口位置
    DebugLog(@"取消 %@ 互动成功", [iu imUserId]);
    [_preview updateAllRenderOf:_multiResource];
    return YES;

}

- (BOOL)initiativeCancelInteractUser:(id<AVMultiUserAble>)user
{
    BOOL succ = [self forcedCancelInteractUser:user];
    if (succ)
    {
        // 发送取消互动
        [(MultiAVIMMsgHandler *)_msgHandler sendGroupAction:AVIMCMD_Multi_CancelInteract operateUser:user succ:^{
            DebugLog(@"发送消息取消与(%@)互动消息成功", [user imUserId]);
        } fail:^(int code, NSString *msg) {
            DebugLog(@"发送消息取消与(%@)互动消息失败", [user imUserId]);
        }];
    }
    return succ;
}

// 主动取消邀请的观众，用户超时不回复邀请或邀请时挂断
- (BOOL)initiativeCancelInviteUser:(id<AVMultiUserAble>)user
{
    BOOL succ = [self forcedCancelInteractUser:user];
    if (succ)
    {
        // 发送取消互动
        [(MultiAVIMMsgHandler *)_msgHandler sendC2CAction:AVIMCMD_Multi_Host_CancelInvite to:user succ:^{
            DebugLog(@"发送取消邀请与(%@)互动消息成功", [user imUserId]);
        } fail:^(int code, NSString *msg) {
            DebugLog(@"发送取消邀请与(%@)互动消息失败", [user imUserId]);

        }];
    }
    return succ;
}

// 请求某个人的视频画面
- (void)requestViewOf:(id<AVMultiUserAble>)user
{
    BOOL hasAdd = [self addInteractUser:user];
    
    if (hasAdd)
    {
        // 没有就添加窗口
        if ([_multiDelegate respondsToSelector:@selector(onAVIMMIMManager:assignWindowResourceTo:isInvite:)])
        {
            // 外部同步分配资源
            [_multiDelegate onAVIMMIMManager:self assignWindowResourceTo:user isInvite:NO];
            [_preview addRenderFor:user];
        }
    }
    
    [_roomEngine asyncRequestViewOf:user];
    
}

// 请求多个人（id<AVUserAble>）的视频画面
- (void)requestMultipleViewOf:(NSArray *)users
{
    [self addInteractUserOnRecvSemiAutoVideo:users];
    [_roomEngine asyncRequestMultiViewsOf:users];
}


// 收到半自动推送时，在界面上添加对应的小窗口进行显示
- (void)addInteractUserOnRecvSemiAutoVideo:(NSArray *)users
{
    for (id<AVMultiUserAble> user in users)
    {
        BOOL hasAdd = [self addInteractUser:user];
        
        if (hasAdd)
        {
            // 没有就添加窗口
            if ([_multiDelegate respondsToSelector:@selector(onAVIMMIMManager:assignWindowResourceTo:isInvite:)])
            {
                // 外部同步分配资源
                [_multiDelegate onAVIMMIMManager:self assignWindowResourceTo:user isInvite:NO];
                [_preview addRenderFor:user];
            }
        }
    }

}


// succ：返回最后一次请求QAVEndpoint requestViewList的成功或失败
// 外部通过engine.multiUser 来判断
- (void)onAVMLRoomEngine:(TCAVMultiLiveRoomEngine *)engine requestView:(BOOL)succ
{
    if ([_multiDelegate respondsToSelector:@selector(onAVIMMIMManager:requestViewComplete:)])
    {
        [_multiDelegate onAVIMMIMManager:self requestViewComplete:succ];
    }
}

- (void)enableInteractUser:(id<AVMultiUserAble>)user ctrlState:(AVCtrlState)state
{
    id<AVMultiUserAble> iu = [self interactUserOf:user];
    if (iu)
    {
        NSInteger astate = [iu avCtrlState];
        NSInteger newstate = (astate | state);
        if (astate != newstate)
        {
            [iu setAvMultiUserState: newstate];
            
            // TODO: 通知外部界面进行更新
            if ([_multiDelegate respondsToSelector:@selector(onAVIMMIMManager:updateCtrlState:)])
            {
                [_multiDelegate onAVIMMIMManager:self updateCtrlState:iu];
            }
        }
        
    }
}
- (void)disableInteractUser:(id<AVMultiUserAble>)user ctrlState:(AVCtrlState)state
{
    id<AVMultiUserAble> iu = [self interactUserOf:user];
    if (iu)
    {
        NSInteger astate = [iu avCtrlState];
        NSInteger newstate = (astate & !state);
        if (astate != newstate)
        {
            [iu setAvMultiUserState: newstate];
            
            // TODO: 通知外部界面进行更新
            // TODO: 通知外部界面进行更新
            if ([_multiDelegate respondsToSelector:@selector(onAVIMMIMManager:updateCtrlState:)])
            {
                [_multiDelegate onAVIMMIMManager:self updateCtrlState:iu];
            }
        }
        
    }
}

- (void)clearAllOnSwitchRoom
{
    _mainUser = nil;
    _multiResource = nil;
//    [_roomEngine asyncCancelAllRequestView];
}

@end


@implementation TCAVIMMIManager (ProtectedMethod)

- (BOOL)addInteractUser:(id<AVMultiUserAble>)user
{
    if (!user)
    {
        return NO;
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
    return YES;
}

@end



@implementation TCAVIMMIManager (RoleAndAuth)

// 具体与Spear配置相关，请注意设置
- (void)changeToInteractAuthAndRole:(CommonCompletionBlock)completion
{
    [_roomEngine changeToInteractAuthAndRole:completion];
}

// 当前是互动观众时，下麦时，使用
- (void)changeToNormalGuestAuthAndRole:(CommonCompletionBlock)completion
{
    [_roomEngine changeToNormalGuestAuthAndRole:completion];
}

@end
