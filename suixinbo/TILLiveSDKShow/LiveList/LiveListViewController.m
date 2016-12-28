//
//  LiveListViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LiveListViewController.h"

#import "LiveListTableViewCell.h"

#import "LiveViewController.h"

@interface LiveListViewController ()

@end

@implementation LiveListViewController

- (instancetype)init
{
    if (self = [super init])
    {
        _datas = [NSMutableArray array];
        _pageItem = [[RequestPageParamItem alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kColorLightGray;
    self.navigationItem.title = @"最新直播";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    _refreshCtl = [[UIRefreshControl alloc] init];
    _refreshCtl.attributedTitle = [[NSAttributedString alloc] initWithString:@"刷新列表" attributes:@{NSFontAttributeName:kAppMiddleTextFont}];
    _refreshCtl.tintColor = kColorRed;
    
    [_refreshCtl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = _refreshCtl;
    
    //自动拉取一次列表
    [self requestList:nil];
}

- (void)onRefresh:(UIRefreshControl *)refreshCtl
{
    __weak typeof(self) ws = self;
    
    [ws requestList:^{
        [refreshCtl endRefreshing];
    }];
}

- (void)requestList:(TCIVoidBlock)complete
{
    _pageItem.pageIndex = 0;
    _pageItem.pageSize = 50;
    
    __weak typeof(self) ws = self;
    
    LiveListRequest *req = [[LiveListRequest alloc] initWithHandler:^(BaseRequest *request) {
        
        LiveListRequest *wreq = (LiveListRequest *)request;
        [ws onLoadMoreLiveRequestSucc:wreq];
        
        if (complete)
        {
            complete();
        }
    } failHandler:^(BaseRequest *request) {
        NSLog(@"fail");
        if (complete)
        {
            complete();
        }
    }];
    
    req.pageItem = _pageItem;
    [[WebServiceEngine sharedEngine] asyncRequest:req wait:NO];
}

- (void)onLoadMoreLiveRequestSucc:(LiveListRequest *)req
{
    [_datas removeAllObjects];
    TCShowLiveList *resp = (TCShowLiveList *)req.response.data;
    [_datas addObjectsFromArray:resp.recordList];
//    self.canLoadMore = resp.recordList.count >= req.pageItem.pageSize;
    _pageItem.pageIndex++;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    LiveListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveListTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    LiveListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveListTableViewCell"];
    if(cell == nil)
    {
        cell = [[LiveListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LiveListTableViewCell"];
    }
    [cell configWith:_datas[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = (NSInteger) (0.618 * tableView.bounds.size.width + 54 + 10);
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCShowLiveListItem *item = _datas[indexPath.row];
    LiveViewController *liveVC = [[LiveViewController alloc] initWith:item];
    [[AppDelegate sharedAppDelegate] pushViewController:liveVC];
}

@end
