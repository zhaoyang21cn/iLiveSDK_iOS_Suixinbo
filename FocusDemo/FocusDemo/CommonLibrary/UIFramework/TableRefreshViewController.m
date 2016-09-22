//
//  TableRefreshViewController.m
//  CommonLibrary
//
//  Created by Alexi on 15-2-5.
//  Copyright (c) 2015年 Alexi Chen. All rights reserved.
//

#import "TableRefreshViewController.h"


#import "RefreshView.h"

#import "ImageTitleButton.h"


@implementation RequestPageParamItem

- (instancetype)init
{
    if (self = [super init])
    {
        _pageIndex = 0;
        _pageSize = 20;
        _canLoadMore = YES;
    }
    return self;
}

- (NSDictionary *)serializeSelfPropertyToJsonObject
{
    return @{@"pageIndex" : @(_pageIndex), @"pageSize" : @(_pageSize)};
}


@end

@implementation TableRefreshViewController

- (void)initialize
{
    [super initialize];
    _clearsSelectionOnViewWillAppear = YES;
    _pageItem = [[RequestPageParamItem alloc] init];
}

- (void)addHeaderView
{
    self.headerView = [[HeadRefreshView alloc] init];
}

- (void)pinHeaderAndRefesh
{
    [self pinHeaderView];
    [self refresh];
}

- (void)addFooterView
{
    self.footerView = [[FootRefreshView alloc] init];
}

- (void)addRefreshScrollView
{
    _tableView = [[UITableView alloc] init];
    _tableView.frame = self.view.bounds;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = kClearColor;
    _tableView.scrollsToTop = YES;
    [self.view addSubview:_tableView];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:v];
    
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.refreshScrollView = _tableView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_tableView)
    {
        NSIndexPath *selected = [_tableView indexPathForSelectedRow];
        if (selected)
        {
            [_tableView deselectRowAtIndexPath:selected animated:animated];
        }
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (BOOL)hasData
{
    BOOL has = _datas.count != 0;
    _tableView.separatorStyle = has ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    return has;
}

- (void)addNoDataView
{
    ImageTitleButton *btn = [[ImageTitleButton alloc] initWithStyle:EImageLeftTitleRightCenter];
    [btn setImage:[UIImage imageNamed:@"icon_warm"] forState:UIControlStateNormal];
    [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
    btn.titleLabel.font = kCommonMiddleTextFont;
    btn.enabled = NO;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:btn];
    _noDataView = btn;
    _noDataView.hidden = YES;
}

- (BOOL)needFollowScrollView
{
    return NO;
}

- (void)reloadData
{
    //    BOOL has = [self hasData];
    //    _noDataView.hidden = has;
    //    if (!has)
    //    {
    //        [self showNoDataView];
    //    }
    [_tableView reloadData];
    [self allLoadingCompleted];
    
    //    if ([self needFollowScrollView])
    //    {
    //        if (_tableView.contentSize.height > 2 * _tableView.bounds.size.height)
    //        {
    //            [self followScrollView:_tableView];
    //        }
    //        else
    //        {
    //            [self followScrollView:nil];
    //        }
    //    }
}

- (void)showNoDataView
{
    
}

- (void)allLoadingCompleted
{
    [super allLoadingCompleted];
    
    BOOL has = [self hasData];
    _noDataView.hidden = has;
    if (!has)
    {
        [self showNoDataView];
    }
}


@end
