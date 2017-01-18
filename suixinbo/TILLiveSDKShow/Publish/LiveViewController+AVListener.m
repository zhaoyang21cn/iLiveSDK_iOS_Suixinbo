//
//  LiveViewController+AVListener.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveViewController+AVListener.h"

#import <objc/runtime.h>

static NSString *const kMainWindowUserId = @"kMainWindowUserId";

@implementation LiveViewController (AVListener)

- (NSString *)mainWindowUser
{
    return objc_getAssociatedObject(self, (__bridge const void *)(kMainWindowUserId));
}
- (void)setMainWindowUser:(NSString *)mainWindowUser
{
    objc_setAssociatedObject(self, (__bridge const void *)(kMainWindowUserId), mainWindowUser, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)onUserUpdateInfo:(ILVLiveAVEvent)event users:(NSArray *)users
{
    switch (event)
    {
        case ILVLIVE_AVEVENT_CAMERA_ON:
        {
            [self onVideoType:QAVVIDEO_SRC_TYPE_CAMERA users:users];
        }
            break;
        case ILVLIVE_AVEVENT_CAMERA_OFF:
        {
            [self offVideoType:QAVVIDEO_SRC_TYPE_CAMERA users:users];
        }
            break;
        case ILVLIVE_AVEVENT_SCREEN_ON:
            [self onVideoType:QAVVIDEO_SRC_TYPE_SCREEN users:users];
            break;
        case ILVLIVE_AVEVENT_SCREEN_OFF:
            [self offVideoType:QAVVIDEO_SRC_TYPE_SCREEN users:users];
            break;
        default:
            break;
    }
}
- (void)onFirstFrameRecved:(int)width height:(int)height identifier:(NSString *)identifier srcType:(avVideoSrcType)srcType;
{
    NSLog(@"%d,%d,%@",width,height,identifier);
}

- (void)onVideoType:(avVideoSrcType)type users:(NSArray *)users
{
    TILLiveManager *manager = [TILLiveManager getInstance];
    for (NSString *user in users)
    {
        TCILDebugLog(@"tilliveshow----->%s1, user = %@",__func__, user);
        NSString *codeIdentifier = [self codeUser:user type:type];
        TCILDebugLog(@"tilliveshow----->%s1, codeid = %@",__func__, codeIdentifier);
        CGRect renderFrame;
        if ([user isEqualToString:_liveItem.uid] && _count == 0)//如果是主播画面,且是第一个画面，则作为大画面显示
        {
            self.mainWindowUser = codeIdentifier;
            _bottomView.mainWindowUserId = user;
            renderFrame = self.view.bounds;
        }
        else
        {
            renderFrame = [self getRenderFrame];
        }
        
        [manager addAVRenderView:renderFrame forIdentifier:user srcType:type];
        
        if (_count != 0)//小画面添加点击事件。大画面不加。
        {
            ILiveRenderView *renderView = [[[ILiveRoomManager getInstance] getFrameDispatcher] getRenderView:user srcType:type];
            renderView.userInteractionEnabled = YES;
            MyTapGesture *tap = [[MyTapGesture alloc] initWithTarget:self action:@selector(onSwitchToMain:)];
            tap.numberOfTapsRequired = 1;
            tap.codeId = codeIdentifier;
            [renderView addGestureRecognizer:tap];
        }
        
        [self.upVideoMembers addObject:codeIdentifier];
        
        _count++;
    }
}

- (void)offVideoType:(avVideoSrcType)type users:(NSArray *)users
{
    TILLiveManager *manager = [TILLiveManager getInstance];
    for (NSString *user in users)
    {
        _count--;
        NSUInteger index = [self.upVideoMembers indexOfObject:[self codeUser:user type:type]];
        if (index != NSNotFound)
        {
            [self.upVideoMembers removeObjectAtIndex:index];
        }
        NSString *codeIdentifier = [self codeUser:user type:type];
        //如果移除的画面是大画面，则屏幕上只会显示一个或几个小画面，为了美化，将最后剩下小画面中的一个显示成大画面
        if ([codeIdentifier isEqualToString:self.mainWindowUser] && self.upVideoMembers.count > 0)
        {
            MyTapGesture *tap = [[MyTapGesture alloc] init];
            tap.codeId = self.upVideoMembers[0];
            [self onSwitchToMain:tap];
        }
        [manager removeAVRenderView:user srcType:type];
    }
    
    [self refreshRenderView];
}

- (void)refreshRenderView
{
    if (self.upVideoMembers.count < 1)
    {
        return;
    }
    _count = 1;//主窗口不刷新，所以从1开始计算
    TILLiveManager *manager = [TILLiveManager getInstance];
    for (NSString *codeId in self.upVideoMembers)
    {
        if (![codeId isEqualToString:self.mainWindowUser])
        {
            TCILDebugLog(@"tilliveshow----->%s, codeId = %@",__func__, codeId);
            NSDictionary *userDic = [self decodeUser:codeId];
            NSArray *userKeys = [userDic allKeys];
            NSString *userId = userKeys[0];
            NSNumber *userType = [userDic objectForKey:userId];
            ILiveRenderView *view = [manager getAVRenderView:userId srcType:(avVideoSrcType)[userType integerValue]];
            
            [view setFrame:[self getRenderFrame]];
            _count++;
        }
    }
}

- (void)onSwitchToMain:(MyTapGesture *)gesture
{
    NSString *codeId = gesture.codeId;
    TCILDebugLog(@"tilliveshow----->%s1, codeId = %@",__func__, codeId);
    NSDictionary *userDic = [self decodeUser:codeId];
    if (userDic)
    {
        //解析主界面identifier和type
        TCILDebugLog(@"tilliveshow----->%s2, codeId = %@",__func__, self.mainWindowUser);
        NSDictionary *mainUserDic = [self decodeUser:self.mainWindowUser];
        NSArray *mainUserKeys = [mainUserDic allKeys];
        NSString *mainUserId = mainUserKeys[0];
        NSNumber *mainUserType = [mainUserDic objectForKey:mainUserId];
        //解析小界面identifier和type
        NSArray *userKeys = [userDic allKeys];
        NSString *userId = userKeys[0];
        NSNumber *userType = [userDic objectForKey:userId];
        //切换主界面和小界面的渲染画面
        [[TILLiveManager getInstance] switchAVRenderView:userId srcType:(avVideoSrcType)[userType integerValue] with:mainUserId anotherSrcType:(avVideoSrcType)[mainUserType integerValue]];
        //交换小画面和大画面对应的id
        gesture.codeId = self.mainWindowUser;
        self.mainWindowUser = codeId;
        
        _bottomView.mainWindowUserId = userId;
        
        //大小界面切换之后，判断主窗口上是主播，连麦用户，还是普通观众，对底部的功能按钮做对应的变换
        [self relayoutBottom];
    }
}

- (void)relayoutBottom
{
    NSString *role = [self getMainWindowRole];
    
    _bottomView.mainWindowRole = role;
    [_bottomView setNeedsLayout];
}

- (NSString *)getMainWindowRole
{
    TCILDebugLog(@"tilliveshow----->%s, codeId = %@",__func__, self.mainWindowUser);
    NSDictionary *mainUserDic = [self decodeUser:self.mainWindowUser];
    NSArray *mainUserKeys = [mainUserDic allKeys];
    NSString *mainUserId = mainUserKeys[0];
    
    if ([mainUserId isEqualToString:self.liveItem.uid])//与主播id对比,不想等则是连麦者，这里有大小界面的切换，所以不可能是普通观众
    {
        return kSxbRole_Host;
    }
    else
    {
        return kSxbRole_Interact;
    }
}

@end

@implementation MyTapGesture
@end
