//
//  RecordListViewController.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/5/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    RequestPageParamItem    *_pageItem;
    BOOL _isCanLoadMore;
    UILabel *_noLiveLabel;
}

@property (nonatomic, strong) NSMutableArray    *datas;
@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) UIRefreshControl  *refreshCtl;

@property (nonatomic, strong) UITextField       *accountIdTF;//查找用户的id
@property (nonatomic, strong) UIView *accountIdLine;
@property (nonatomic, strong) UITextField       *searchNumTF;//查找的数量
@property (nonatomic, strong) UIView *searchNumLine;

@property (nonatomic, strong) UIView *alphaBgView;//在输入文本时，会弹出键盘，点击空白处，键盘收起，添加一个透明视图，用来响应点击空白处事件

- (void)loadMore:(TCIVoidBlock)complete;
@end
