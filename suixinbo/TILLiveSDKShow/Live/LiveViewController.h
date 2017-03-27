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

@interface LiveViewController : UIViewController
{
    UIButton            *_closeBtn;          //关闭直播
    CGRect              _closeBtnRestoreRect;
    
    LiveUITopView       *_topView;
    LiveUIParView       *_parView;
    LiveUIBttomView     *_bottomView;
    
    //直播界面消息模块
    MsgInputView        *_msgInputView;
    UITableView         *_msgTableView;     //消息列表视图
    NSMutableArray      *_msgDatas;         //消息列表数据
    CGRect              _msgRestoreRect;
    
    UIView              *_bgAlphaView;      //用于顶部滑出房间成员列表，透明背景视图用
    UITableView         *_memberListView;   //房间成员列表
    NSMutableArray      *_members;          //房间成员
    
    NSMutableArray      *_upVideoMembers;   //连麦列表
    
    ReportView          *_reportView;       //举报视图
    
    BOOL _isHost; //自己是不是主播
    TCShowLiveListItem *_liveItem;
    NSInteger _count;
}

@property (nonatomic, strong) TIMUserProfile *selfProfile;//自己的信息
@property (nonatomic, strong) TCShowLiveListItem  *liveItem;
@property (nonatomic, strong) NSMutableArray *upVideoMembers;
@property (nonatomic, assign) NSInteger count;

@property (nonatomic, strong) TILFilter *tilFilter;

- (instancetype)initWith:(TCShowLiveListItem *)item;
- (void)onClose;

@end
