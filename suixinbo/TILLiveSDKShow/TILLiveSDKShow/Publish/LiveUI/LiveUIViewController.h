//
//  LiveUIViewController.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LiveUITopView.h"
#import "LiveUIParView.h"
#import "LiveUIBttomView.h"

@class MsgInputView;

@protocol LiveUIDelegate <NSObject>

- (void)onClose;

@end

@interface LiveUIViewController : UIViewController
{
    UIButton            *_closeBtn;          //关闭直播
    
    LiveUITopView       *_topView;
    LiveUIParView       *_parView;
    LiveUIBttomView     *_bottomView;
    MsgInputView        *_msgInputView;
    
    UITableView         *_msgTableView;     //消息列表视图
    NSMutableArray      *_msgDatas;         //消息列表
    
    
    UIView              *_bgAlphaView;      //用于顶部滑出房间成员列表，透明背景视图用
    UITableView         *_memberListView;   //房间成员列表
    NSMutableArray      *_members;          //房间成员
    NSMutableArray      *_upVideoMembers;   //连麦列表
    
    TCShowLiveListItem  *_liveItem;
}

@property (nonatomic, weak) id<LiveUIDelegate> delegate;

@property (nonatomic, assign) BOOL isHost; //自己是不是主播

@property (nonatomic, strong) NSMutableArray *upVideoMembers;

- (void)onMessage:(ILVLiveTextMessage *)msg;

- (instancetype)initWith:(TCShowLiveListItem *)item;

@end
