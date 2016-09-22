//
//  TableRefreshViewController.h
//  CommonLibrary
//
//  Created by Alexi on 15-2-5.
//  Copyright (c) 2015年 Alexi Chen. All rights reserved.
//

#import "ScrollRefreshViewController.h"


@interface RequestPageParamItem : NSObject

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger pageSize;

@property (nonatomic, assign) BOOL canLoadMore;

@end

@interface TableRefreshViewController : ScrollRefreshViewController<UITableViewDelegate, UITableViewDataSource>
{
@protected
    UITableView                 *_tableView;
    NSMutableArray              *_datas;
@protected
    RequestPageParamItem        *_pageItem;
}

@property (nonatomic, strong) UITableView *tableView;
// Defaults to YES
@property (nonatomic)BOOL clearsSelectionOnViewWillAppear;

// 是否需要跟上下滑动时隐藏导航栏和状态栏
- (BOOL)needFollowScrollView;

// 代码下拉刷新
- (void)pinHeaderAndRefesh;

@end
