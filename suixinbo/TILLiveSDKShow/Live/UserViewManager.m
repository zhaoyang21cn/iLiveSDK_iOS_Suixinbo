//
//  UserViewManager.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "UserViewManager.h"

#import "LiveCallView.h"

@implementation UserViewManager

+ (instancetype)shareInstance
{
    static UserViewManager *userViewManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userViewManager = [[UserViewManager alloc] init];
    });
    return userViewManager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _total = 0;
        _mainRenderView = nil;
        _placeholderViews = [NSMutableDictionary dictionary];
        _renderViews = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)releaseManager
{
    //移除所有的渲染视图
    NSArray *renderKes = [_renderViews allKeys];
    for (NSString *codeId in renderKes)
    {
        NSDictionary *userDic = [UserViewManager decodeUser:codeId];
        NSArray *userIds = [userDic allKeys];
        if (userIds.count > 0)
        {
            NSString *userId = userIds[0];
            if (userId && userId.length > 0)
            {
                NSNumber *numType = userDic[userId];
                [[TILLiveManager getInstance] removeAVRenderView:userId srcType:(avVideoSrcType)[numType integerValue]];
            }
        }
    }
    [_renderViews removeAllObjects];
    
    //移除所有的占位视图
    NSArray *placeholderKes = [_placeholderViews allKeys];
    for (NSString *userId in placeholderKes)
    {
        LiveCallView *callView = [_placeholderViews objectForKey:userId];
        [callView removeFromSuperview];
    }
    [_placeholderViews removeAllObjects];
    
    //重置主窗口
    NSDictionary *mainUserDic = [UserViewManager decodeUser:_mainCodeUserId];
    if (_mainUserId && _mainUserId.length > 0)
    {
        NSNumber *numType = [mainUserDic objectForKey:_mainUserId];
        [[TILLiveManager getInstance] removeAVRenderView:_mainUserId srcType:(avVideoSrcType)[numType integerValue]];
    }
    _mainRenderView = nil;
    //重置主窗口编码id
    _mainCodeUserId = nil;
    //重置主窗口id
    _mainUserId = nil;
    //总数置0
    _total = 0;
}

- (BOOL)isExistPlaceholder:(NSString *)userId
{
    NSArray *userIds = [_placeholderViews allKeys];
    NSInteger index = [userIds indexOfObject:userId];
    if (index != NSNotFound)
    {
        return YES;
    }
    return NO;
}
- (BOOL)isExistRenderView:(NSString *)userId
{
    NSArray *codeIds = [_renderViews allKeys];
    
    NSString *userCameraCodeId = [UserViewManager codeUser:userId type:QAVVIDEO_SRC_TYPE_CAMERA];
    NSInteger index1 = [codeIds indexOfObject:userCameraCodeId];
    if (index1 != NSNotFound)
    {
        return YES;
    }
    
    NSString *userScreenCodeId = [UserViewManager codeUser:userId type:QAVVIDEO_SRC_TYPE_SCREEN];
    NSInteger index2 = [codeIds indexOfObject:userScreenCodeId];
    if (index2 != NSNotFound)
    {
        return YES;
    }
    
    //判断和主视图是不是相同（如果不判断，在这种情况下会有问题：主播A创建成功后，观众B进入房间，主播与观众连麦成功后，主播杀掉进程，重新启动后进入直播页，再次向观众B可以发起连麦邀请。原因在于主播杀进程重启后，远程视频先到达本地，这样远程视频就是大窗口，不会加入_renderViews中，只判断_renderViews显然无法判断是否存在）
    if ([_mainUserId isEqualToString:userId] )
    {
        return YES;
    }
    return NO;
}

- (avVideoSrcType)getUserType:(NSString *)userId
{
    NSArray *codeIds = [_renderViews allKeys];
    
    NSString *userCameraCodeId = [UserViewManager codeUser:userId type:QAVVIDEO_SRC_TYPE_CAMERA];
    NSInteger index1 = [codeIds indexOfObject:userCameraCodeId];
    if (index1 != NSNotFound)
    {
        return QAVVIDEO_SRC_TYPE_CAMERA;
    }
    
    NSString *userScreenCodeId = [UserViewManager codeUser:userId type:QAVVIDEO_SRC_TYPE_SCREEN];
    NSInteger index2 = [codeIds indexOfObject:userScreenCodeId];
    if (index2 != NSNotFound)
    {
        return QAVVIDEO_SRC_TYPE_SCREEN;
    }
    
    return QAVVIDEO_SRC_TYPE_NONE;
}

- (ILiveRenderView *)addRenderView:(NSString *)userId srcType:(avVideoSrcType)type
{
    if (!userId || userId.length <= 0 )
    {
        return nil;
    }
    
    //判断渲染视图是否已经添加(如果不判断，在这种情况下观众端有问题(小画面会被遮挡住)：主播A创建成功后，观众B进入房间，主播与观众连麦成功后，主播杀掉进程，重新启动后进入直播页，再次向观众B可以发起连麦邀请，并且看不到小画面)
    ILiveRenderView *temp = [[TILLiveManager getInstance] getAVRenderView:userId srcType:type];
    if (temp)
    {
        return temp;
    }
    ILiveRenderView *renderView;
    if (!_mainRenderView)//第一个画面当作主界面
    {
        renderView = [[TILLiveManager getInstance] addAVRenderView:[UIScreen mainScreen].bounds forIdentifier:userId srcType:type];
        [[TILLiveManager getInstance] sendAVRenderViewToBack:userId srcType:type];
        _mainRenderView = renderView;
        _mainCodeUserId = [UserViewManager codeUser:userId type:type];
        _mainUserId = userId;
    }
    else
    {
        //判断是否存在占位符，存在则用渲染视图替换占位符，不存在则创建渲染视图
        NSArray *placeholders = [_placeholderViews allKeys];
        NSInteger index = [placeholders indexOfObject:userId];
        if (index != NSNotFound)
        {
            renderView = [self renderviewReplacePlaceholderView:userId srcType:type];
        }
        else
        {
            renderView = [[TILLiveManager getInstance] addAVRenderView:[self getRect:_total] forIdentifier:userId srcType:type];
            if (renderView)
            {
                [_renderViews setObject:renderView forKey:[UserViewManager codeUser:userId type:type]];
                NSLog(@"_total addRenderView = %d",_total);
                _total++;
            }
        }
    }
    return renderView;
}

- (void)removeRenderView:(NSString *)userId srcType:(avVideoSrcType)type
{
    if (!userId || userId.length <= 0)
    {
        return;
    }
    NSString *codeUserId = [UserViewManager codeUser:userId type:type];
    NSArray *codeUserIds = [_renderViews allKeys];
    
    NSInteger index = [codeUserIds indexOfObject:codeUserId];
    if (index != NSNotFound)
    {
        [[TILLiveManager getInstance] removeAVRenderView:userId srcType:type];
        
        [_renderViews removeObjectForKey:codeUserId];
        
        _total--;
    }
}

- (LiveCallView *)addPlaceholderView:(NSString *)userId;
{
    if (!userId || userId.length <= 0)
    {
        return nil;
    }
    
    LiveCallView *callView = [[LiveCallView alloc] initWithFrame:[self getRect:_total]];
    callView.userLabel.text = userId;
    [_placeholderViews setObject:callView forKey:userId];
    
    _total++;
    
    return callView;
}

- (CGRect)removePlaceholderView:(NSString *)userId
{
    if (!userId || userId.length <= 0)
    {
        return CGRectZero;
    }
    CGRect rect;
    NSArray *userIds = [_placeholderViews allKeys];
    NSInteger index = [userIds indexOfObject:userId];
    if (index != NSNotFound)
    {
        LiveCallView *callView = [_placeholderViews objectForKey:userId];
        rect = callView.frame;
        [callView.timeoutTimer invalidate];
        callView.timeoutTimer = nil;
        [callView removeFromSuperview];
        
        [_placeholderViews removeObjectForKey:userId];
        
        _total--;
        
        return rect;
    }
    return CGRectZero;
}

- (ILiveRenderView *)renderviewReplacePlaceholderView:(NSString *)userId srcType:(avVideoSrcType)type
{
    //移除占位符
    CGRect rect = [self removePlaceholderView:userId];
    
    //添加渲染视图
    ILiveRenderView *renderView = [[TILLiveManager getInstance] addAVRenderView:rect forIdentifier:userId srcType:type];
    if (renderView)
    {
        [_renderViews setObject:renderView forKey:[UserViewManager codeUser:userId type:type]];
        _total++;
    }
    return renderView;
}

- (BOOL)switchToMainView:(NSString *)codeUserId;
{
    if (!codeUserId || codeUserId.length <= 0)
    {
        return NO;
    }
    if (!_mainCodeUserId || _mainCodeUserId <= 0)
    {
        return NO;
    }
    
    //解析小界面identifier和type
    NSDictionary *userDic = [UserViewManager decodeUser:codeUserId];
    NSArray *userKeys = [userDic allKeys];
    NSString *userId = userKeys[0];
    NSNumber *userType = [userDic objectForKey:userId];
    
    //解析主界面identifier和type
    NSDictionary *mainUserDic = [UserViewManager decodeUser:_mainCodeUserId];
    NSArray *mainUserKeys = [mainUserDic allKeys];
    NSString *mainUserId = mainUserKeys[0];
    NSNumber *mainUserType = [mainUserDic objectForKey:mainUserId];
    
    //切换主界面和小界面的渲染画面
    [[TILLiveManager getInstance] switchAVRenderView:userId srcType:(avVideoSrcType)[userType integerValue] with:mainUserId anotherSrcType:(avVideoSrcType)[mainUserType integerValue]];
    
    NSArray *renderViewKeys = [_renderViews allKeys];
    for (NSString *codeId in renderViewKeys)
    {
        if ([codeId isEqualToString:codeUserId])
        {
            ILiveRenderView *tempView = _mainRenderView;
            _mainRenderView = [_renderViews objectForKey:codeId];
            [_renderViews removeObjectForKey:codeId];
            [_renderViews setObject:tempView forKey:_mainCodeUserId];
            break;
        }
    }
    _mainCodeUserId = codeUserId;
    _mainUserId = userId;
    
    return YES;
}
- (void)refreshViews
{
    int index = 0;
    
    //先布局渲染视图，主视图是全屏，不用再布局了
    NSArray *renderKeys = [_renderViews allKeys];
    for (NSString * codeId in renderKeys)
    {
        ILiveRenderView *renderView = [_renderViews objectForKey:codeId];
        [renderView setFrame:[self getRect:index++]];
    }
    
    //再布局占位符视图
    NSArray *placeholderKes = [_placeholderViews allKeys];
    for (NSString *userId in placeholderKes)
    {
        LiveCallView *callView = [_placeholderViews objectForKey:userId];
        [callView setFrame:[self getRect:index++]];
    }
}

+ (NSDictionary *)decodeUser:(NSString *)identifier
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    int idLen = (int)identifier.length;
    
    NSString *user;
    NSRange rangeCamera = [identifier rangeOfString:@"_camera"];
    
    if (rangeCamera.location == NSNotFound)//screen
    {
        NSRange rangeScreen = [identifier rangeOfString:@"_screen"];
        user = [identifier substringWithRange:NSMakeRange(0, idLen-rangeScreen.length)];
        if (user)
        {
            NSNumber *type = [NSNumber numberWithInteger:QAVVIDEO_SRC_TYPE_SCREEN];
            [dic setObject:type forKey:user];
        }
    }
    else//camera
    {
        user = [identifier substringWithRange:NSMakeRange(0, idLen-rangeCamera.length)];
        
        if (user)//camera
        {
            NSNumber *type = [NSNumber numberWithInteger:QAVVIDEO_SRC_TYPE_CAMERA];
            [dic setObject:type forKey:user];
        }
    }
    return dic;
}

+ (NSString *)codeUser:(NSString *)identifier type:(avVideoSrcType)type
{
    NSString *key;
    if (type == QAVVIDEO_SRC_TYPE_CAMERA)
    {
        key = [NSString stringWithFormat:@"%@_camera",identifier];
    }
    else if (type == QAVVIDEO_SRC_TYPE_SCREEN)
    {
        key = [NSString stringWithFormat:@"%@_screen",identifier];
    }
    return key;
}

- (CGRect)getRect:(int)index
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    CGFloat topMargin = 100;
    CGFloat height = (screenRect.size.height - 200 - kDefaultMargin*4)/3;
    CGFloat width = height * 3/4;
    CGFloat x = screenRect.size.width - width - kDefaultMargin;
    CGFloat y = topMargin + index*height + index*kDefaultMargin;
    NSLog(@"getrect  index = %d, rect = {%f,%f,%f,%f}",index, x,y,width,height);
    return CGRectMake(x, y, width, height);
}

@end
