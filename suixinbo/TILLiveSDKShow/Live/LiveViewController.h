//
//  LiveViewController.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "LiveUIViewController.h"
#import "LiveUITopView.h"
#import "LiveUIParView.h"
#import "LiveUIBttomView.h"
#import "MsgInputView.h"
#import "EnvInfoView.h"

@interface LiveViewController : UIViewController
{
    UIButton            *_closeBtn;          //关闭直播
    CGRect              _closeBtnRestoreRect;
    
    LiveUITopView       *_topView;
    LiveUIParView       *_parView;
    LiveUIBttomView     *_bottomView;
    
    //输入视图
    MsgInputView        *_msgInputView;
    CGRect              _oldInputFrame;
    BOOL                _isFristShow;
    
    //直播界面消息模块
    UITableView         *_msgTableView;     //消息列表视图
    NSMutableArray      *_msgDatas;         //消息列表数据
    CGRect              _msgRestoreRect;
    
    UIView              *_bgAlphaView;      //用于顶部滑出房间成员列表，透明背景视图用
    UITableView         *_memberListView;   //房间成员列表
    NSMutableArray      *_members;          //房间成员
    
    NSMutableArray      *_upVideoMembers;   //连麦列表
    
    ReportView          *_reportView;       //举报视图
    
//    EnvInfoView         *_envInfoView;      //网络环境视图
//    NSTimer             *_envInfoTimer;     //网络环境timer
    
    BOOL _isHost; //自己是不是主播
    RoomOptionType _roomOptionType;
    TCShowLiveListItem *_liveItem;
    NSInteger _count;
}

@property (nonatomic, strong) UILabel  *noCameraDatatalabel;//对方没有打开相机时的提示
@property (nonatomic, assign) BOOL  isCameraEvent;//noCameraDatatalabel需要延迟显示，isNoCameraEvent用来判断是否收到了camera事件

@property (nonatomic, strong) TIMUserProfile *selfProfile;//自己的信息
@property (nonatomic, strong) TCShowLiveListItem  *liveItem;
@property (nonatomic, strong) NSMutableArray *upVideoMembers;
@property (nonatomic, assign) NSInteger count;

//声明变量
@property (nonatomic, strong) TXCVideoPreprocessor *preProcessor;
@property (nonatomic, assign) Byte  *processorBytes;

- (instancetype)initWith:(TCShowLiveListItem *)item roomOptionType:(RoomOptionType)type;
- (void)onClose;

- (LiveUIBttomView *)getBottomView;

@end
