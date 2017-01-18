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
    
    LiveUITopView       *_topView;
    LiveUIParView       *_parView;
    LiveUIBttomView     *_bottomView;
    
    MsgInputView        *_msgInputView;
    
    UITableView         *_msgTableView;     //消息列表视图
    NSMutableArray      *_msgDatas;         //消息列表数据
    
    UIView              *_bgAlphaView;      //用于顶部滑出房间成员列表，透明背景视图用
    UITableView         *_memberListView;   //房间成员列表
    NSMutableArray      *_members;          //房间成员
    
    NSMutableArray      *_upVideoMembers;   //连麦列表
    
    BOOL _isHost; //自己是不是主播
    TCShowLiveListItem *_liveItem;
    NSInteger _count;
}

@property (nonatomic, strong) TCShowLiveListItem  *liveItem;
@property (nonatomic, strong) NSMutableArray *upVideoMembers;
@property (nonatomic, assign) NSInteger count;

- (instancetype)initWith:(TCShowLiveListItem *)item;
- (void)onClose;
- (CGRect)getRenderFrame;
- (NSString *)codeUser:(NSString *)identifier type:(avVideoSrcType)type;
- (NSDictionary *)decodeUser:(NSString *)identifier;

@end
