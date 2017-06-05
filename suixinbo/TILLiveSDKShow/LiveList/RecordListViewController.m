//
//  RecordListViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/5/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "RecordListViewController.h"
#import "RecordListTableViewCell.h"
#import <AVKit/AVPlayerViewController.h>

@interface RecordListViewController ()

@end

@implementation RecordListViewController
- (instancetype)init
{
    if (self = [super init])
    {
        _datas = [NSMutableArray array];
        _pageItem = [[RequestPageParamItem alloc] init];
        _pageItem.pageIndex = 1;//录制列表页号是从1开始的
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kColorLightGray;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    UIView *loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    UILabel *loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    loadMoreLabel.text = @"加载更多...";
    loadMoreLabel.textAlignment = NSTextAlignmentCenter;
    [loadMoreView addSubview:loadMoreLabel];
    self.tableView.tableFooterView = loadMoreView;
    self.tableView.tableFooterView.hidden = YES;
    
    _isCanLoadMore = YES;
    
    _refreshCtl = [[UIRefreshControl alloc] init];
    _refreshCtl.attributedTitle = [[NSAttributedString alloc] initWithString:@"刷新列表" attributes:@{NSFontAttributeName:kAppMiddleTextFont}];
    _refreshCtl.tintColor = kColorRed;
    [_refreshCtl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = _refreshCtl;
    //自动拉取一次列表
    //第一次进来会调用 scrollViewDidScroll，自动拉取一次
    
    _noLiveLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2-25, self.view.bounds.size.width, 50)];
    _noLiveLabel.text = @"暂时没有回放数据";
    _noLiveLabel.hidden = YES;
    _noLiveLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_noLiveLabel];
}

- (void)onRefresh:(UIRefreshControl *)refreshCtl
{
    __weak typeof(self) ws = self;
    [self refresh:^{
        [refreshCtl endRefreshing];
        ws.tableView.tableFooterView.hidden = YES;
    }];
}

- (void)refresh:(TCIVoidBlock)complete
{
    _pageItem.pageIndex = 1;//录制列表页号是从1开始的
    [_datas removeAllObjects];
    _isCanLoadMore = YES;
    [self loadMore:complete];
}

- (void)loadMore:(TCIVoidBlock)complete
{
    __weak typeof(self) ws = self;
    __weak RequestPageParamItem *wpi = _pageItem;
    RecordListRequest *recListReq = [[RecordListRequest alloc] initWithHandler:^(BaseRequest *request) {
        RecordListResponese *recordRsp = (RecordListResponese *)request.response;
        [ws.datas addObjectsFromArray:recordRsp.videos];
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws.tableView reloadData];
        });
        wpi.pageIndex ++;
        NSLog(@"--->%ld",(long)recordRsp.total);
        if (ws.datas.count >= recordRsp.total)
        {
            _isCanLoadMore = NO;
            ws.tableView.tableFooterView.hidden = YES;
        }
        if (complete)
        {
            complete();
        }
    } failHandler:^(BaseRequest *request) {
        NSLog(@"fail");
    }];
    recListReq.token = [AppDelegate sharedAppDelegate].token;
    recListReq.type = 1;
    recListReq.index = _pageItem.pageIndex;
    recListReq.size = _pageItem.pageSize;
    [[WebServiceEngine sharedEngine] asyncRequest:recListReq wait:NO];

}

- (void)loadListSucc:(RoomListRequest *)req
{
    RoomListRspData *respData = (RoomListRspData *)req.response.data;
    [_datas addObjectsFromArray:respData.rooms];
    _pageItem.pageIndex += respData.rooms.count;
    _isCanLoadMore = respData.total > _pageItem.pageIndex;
    [self.tableView reloadData];
    self.tableView.tableFooterView.hidden = YES;
    if (_datas.count <= 0)
    {
        _noLiveLabel.hidden = NO;
    }
    else
    {
        _noLiveLabel.hidden = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    
    RecordListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordListTableViewCell"];
    if(cell == nil)
    {
        cell = [[RecordListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RecordListTableViewCell"];
    }
    if (_datas.count > indexPath.row)
    {
        [cell configWith:_datas[indexPath.row]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = (NSInteger) (0.618 * tableView.bounds.size.width + 54 + 10);
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_datas.count > indexPath.row)
    {
        RecordVideoItem *item = _datas[indexPath.row];
        if (item.playurl.count > 0)
        {
            NSString *urlStr = item.playurl[0];
            NSURL *url = [NSURL URLWithString:urlStr];
            
            AVPlayerViewController *player = [[AVPlayerViewController alloc]init];
            player.player = [[AVPlayer alloc] initWithURL:url];
            [self presentViewController:player animated:YES completion:nil];
        }
        else
        {
            [AlertHelp tipWith:@"无效的播放地址" wait:0.5];
        }
    }
    else
    {
        [AlertHelp tipWith:@"点击无效" wait:0.5];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    /*self.refreshControl.isRefreshing == NO加这个条件是为了防止下面的情况发生：
     每次进入UITableView，表格都会沉降一段距离，这个时候就会导致currentOffsetY + scrollView.frame.size.height   > scrollView.contentSize.height 被触发，从而触发loadMore方法，而不会触发refresh方法。
     */
    if ( currentOffsetY + scrollView.frame.size.height  > scrollView.contentSize.height && self.refreshControl.isRefreshing == NO && self.tableView.tableFooterView.hidden == YES && _isCanLoadMore)
    {
        self.tableView.tableFooterView.hidden = NO;
        __weak typeof(self) ws = self;
        [self loadMore:^{
            ws.tableView.tableFooterView.hidden = YES;
        }];
    }
}

@end
