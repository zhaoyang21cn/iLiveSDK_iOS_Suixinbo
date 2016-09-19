//
//  MoreTableView.h
//  
//
//  Created by Alexi on 12-11-7.
//  Copyright (c) 2012年 . All rights reserved.
//
#if kSupportUnusedCommonView
#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"


@class MoreTableView;

@protocol MoreTableViewDelegate <NSObject>
@optional
- (void)onMoreTableView:(MoreTableView *)tableView;

@end


@interface MoreTableView : UIView<UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>
{
@protected
    UITableView                     *_tableView;
    EGORefreshTableHeaderView       *_refreshHeaderView;        // 提示刷新的视图
    BOOL                            _reloading;                 // 是否正在请求数据
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, DelegateAssign)id delegate;

// 加载完所有的数据
- (void)onLoadOver;

// 加载更多
- (void)loadMore;

// 停止当前的刷新操作
- (void)stopLoadMore;

// 数据加载完成之后，调用此方法进行显示
- (void)refreshAfterLoadMore;

- (void)reloadData;

- (UITableViewCell *)createCell:(NSString *)identifier;

- (void)configCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath;

- (void)didSelect:(NSIndexPath *)indexPath;


@end
#endif
