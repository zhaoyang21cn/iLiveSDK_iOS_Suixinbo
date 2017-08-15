//
//  LinkRoomList.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/4/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomListConfig : NSObject

//@property (nonatomic, assign) BOOL isHost; //自己是不是主播
//@property (nonatomic, strong) NSString *curRole;//当前角色
@property (nonatomic, assign) CGRect frame;
//@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSArray *liveList;

@end

/**
 跨房连麦时，首先向业务服务器拉取房间列表，在房间列表中选择某个主播进行连麦
 */
@interface LinkRoomList : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *clearBg;      //用来做点击消失事件
@property (nonatomic, strong) UIView *alphaBg;      //透明度背景

@property (nonatomic, strong) RoomListConfig *roomListconfig;
@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) RequestPageParamItem    *pageItem;

- (void)configRoomList:(RoomListConfig *)config;

@end

@interface RoomListCell : UITableViewCell

@property (nonatomic, strong) UILabel *userInfoLabel;
@property (nonatomic, strong) UIButton *linkRommBtn;

@property (nonatomic, strong) TCShowLiveListItem *liveItem;

- (void)config:(TCShowLiveListItem *)item;

@end
