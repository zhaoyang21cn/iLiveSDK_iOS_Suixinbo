//
//  LiveViewController+AVListener.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveViewController+AVListener.h"

#import <objc/runtime.h>

@implementation LiveViewController (AVListener)

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
        case ILVLIVE_AVEVENT_MEDIA_ON:
            [self onVideoType:QAVVIDEO_SRC_TYPE_MEDIA users:users];
            break;
        case ILVLIVE_AVEVENT_MEDIA_OFF:
            [self offVideoType:QAVVIDEO_SRC_TYPE_MEDIA users:users];
            break;
        default:
            break;
    }
}
- (void)onFirstFrameRecved:(int)width height:(int)height identifier:(NSString *)identifier srcType:(avVideoSrcType)srcType;
{
    NSLog(@"%d,%d,%@",width,height,identifier);
    
    LiveUIBttomView *bottom = [self getBottomView];
    bottom.lastBeautyValue = 0.5;
    bottom.lastWhiteValue = 0.5;
    
    //首帧来时，设置美颜
    //选中当前方案,默认ILiveSDK美颜包
    NSString *beautyScheme = [[NSUserDefaults standardUserDefaults] objectForKey:kBeautyScheme];
    if (!(beautyScheme && beautyScheme.length > 0))
    {
        [[NSUserDefaults standardUserDefaults] setValue:kILiveBeauty forKey:kBeautyScheme];
        beautyScheme = kILiveBeauty;
    }
    if ([beautyScheme isEqualToString:kILiveBeauty])
    {
        //TILFilterSDK美颜效果
        [self.preProcessor setBeautyLevel:bottom.lastBeautyValue * 10];
        [self.preProcessor setWhitenessLevel:bottom.lastWhiteValue * 10];
    }
//    else if ([beautyScheme isEqualToString:kQAVSDKBeauty])
//    {
//        //QAVSDK美颜效果
//        QAVContext *context = [[ILiveSDK getInstance] getAVContext];
//        if (context && context.videoCtrl)
//        {
//            [context.videoCtrl inputBeautyParam:bottom.lastBeautyValue * 10];
//        }
//    }
}

- (void)onVideoType:(avVideoSrcType)type users:(NSArray *)users
{
    for (NSString *user in users)
    {
        ILiveRenderView *renderView = [[UserViewManager shareInstance] addRenderView:user srcType:type];
        if ([UserViewManager shareInstance].total != 0)//小画面添加点击事件。大画面不加。
        {
            renderView.userInteractionEnabled = YES;
            MyTapGesture *tap = [[MyTapGesture alloc] initWithTarget:self action:@selector(onSwitchToMain:)];
            tap.numberOfTapsRequired = 1;
            tap.codeId = [UserViewManager codeUser:user type:type];
            [renderView addGestureRecognizer:tap];
        }
        renderView.isRotate = NO;
    }
    
    NSArray *renderViews = [[TILLiveManager getInstance] getAllAVRenderViews];
    if (renderViews.count > 0)
    {
        self.noCameraDatatalabel.hidden = YES;
    }
    else
    {
        self.noCameraDatatalabel.hidden = NO;
        self.isCameraEvent = NO;
    }
    self.isCameraEvent = YES;
}

- (void)offVideoType:(avVideoSrcType)type users:(NSArray *)users
{
    for (NSString *user in users)
    {
        //如果移除的画面是大画面，则屏幕上只会显示一个或几个小画面，为了美化，将最后剩下小画面中的一个显示成大画面
        NSString *codeUserId = [UserViewManager codeUser:user type:type];
        if ([codeUserId isEqualToString:[UserViewManager shareInstance].mainCodeUserId] && [UserViewManager shareInstance].total > 0)
        {
            //将主播的画面切到大画面
            MyTapGesture *tap = [[MyTapGesture alloc] init];
            avVideoSrcType uidType = [[UserViewManager shareInstance] getUserType:_liveItem.uid];
            tap.codeId = [UserViewManager codeUser:_liveItem.uid type:uidType];
            [self onSwitchToMain:tap];
        }
        [[UserViewManager shareInstance] removeRenderView:user srcType:type];
    }
    [[UserViewManager shareInstance] refreshViews];
    
    NSArray *renderViews = [[TILLiveManager getInstance] getAllAVRenderViews];
    if (renderViews.count > 0)
    {
        self.isCameraEvent = YES;
        self.noCameraDatatalabel.hidden = YES;
    }
    else
    {
        self.isCameraEvent = NO;
        self.noCameraDatatalabel.hidden = NO;
    }
}

- (void)onSwitchToMain:(MyTapGesture *)gesture
{
    NSString *codeId = gesture.codeId;
    NSDictionary *userDic = [UserViewManager decodeUser:codeId];
    if (userDic)
    {
        gesture.codeId = [UserViewManager shareInstance].mainCodeUserId;
        [[UserViewManager shareInstance] switchToMainView:codeId];
        //大小界面切换之后，判断主窗口上是主播，连麦用户，还是普通观众，对底部的功能按钮做对应的变换
        [self relayoutBottom];
    }
}

- (void)relayoutBottom
{
    [_bottomView setNeedsLayout];
}

@end

@implementation MyTapGesture
@end
