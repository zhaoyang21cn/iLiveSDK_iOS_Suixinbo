//
//  RecListTableViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/4.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "RecListTableViewController.h"

#import <AVKit/AVPlayerViewController.h>

@interface RecListTableViewController ()
@end

@implementation RecListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kColorLightGray;
    self.navigationItem.title = @"录制列表";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.tableFooterView.hidden = YES;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    UIView *loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    UILabel *loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    loadMoreLabel.text = @"加载更多...";
    loadMoreLabel.textAlignment = NSTextAlignmentCenter;
    [loadMoreView addSubview:loadMoreLabel];
    self.tableView.tableFooterView = loadMoreView;
    
    _refreshCtl = [[UIRefreshControl alloc] init];
    _refreshCtl.attributedTitle = [[NSAttributedString alloc] initWithString:@"刷新列表" attributes:@{NSFontAttributeName:kAppMiddleTextFont}];
    _refreshCtl.tintColor = kColorRed;
    [_refreshCtl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = _refreshCtl;
    
    _isCanLoadMore = YES;
    _pageItem = [[RequestPageParamItem alloc] init];
    _data = [NSMutableArray array];
}

- (void)onRefresh:(UIRefreshControl *)refreshCtl
{
    [self refresh:^{
        [refreshCtl endRefreshing];
    }];
}

- (void)refresh:(TCIVoidBlock)complete
{
    _pageItem.pageIndex = 0;
    [_data removeAllObjects];
    [self.tableView reloadData];
    _isCanLoadMore = YES;
    [self loadMore:complete];
}

//拉取录制列表
- (void)loadMore:(TCIVoidBlock)complete
{
    __weak typeof(self) ws = self;
    __weak RequestPageParamItem *wpi = _pageItem;
    RecordListRequest *recListReq = [[RecordListRequest alloc] initWithHandler:^(BaseRequest *request) {
        RecordListResponese *recordRsp = (RecordListResponese *)request.response;
        [ws.data addObjectsFromArray:recordRsp.videos];
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws.tableView reloadData];
        });
        wpi.pageIndex++;
        NSLog(@"--->%ld",(long)recordRsp.total);
        if (ws.data.count >= recordRsp.total)
        {
            _isCanLoadMore = NO;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RecordVideoItem *item = _data[section];
    return item.playurl.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"RecordListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    RecordVideoItem *item = _data[indexPath.section];
    NSString *url = item.playurl[indexPath.row];
    NSArray *array = [item.name componentsSeparatedByString:@"_"];
    NSMutableAttributedString *showInfo = [[NSMutableAttributedString alloc] init];
    if (array.count > 1)
    {
        NSString *identifier = array[1];
        NSAttributedString *attriId = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",identifier] attributes:@{NSFontAttributeName:kAppSmallTextFont}];
        [showInfo appendAttributedString:attriId];
    }
    if (array.count > 2)
    {
        NSString *fileName = array[2];
        NSAttributedString *attriName = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",fileName] attributes:@{NSFontAttributeName:kAppSmallTextFont}];
        [showInfo appendAttributedString:attriName];
    }
    if (array.count > 3)
    {
        NSString *recStartTime = array[3];
        NSAttributedString *attriTime = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",recStartTime] attributes:@{NSFontAttributeName:kAppSmallTextFont}];
        [showInfo appendAttributedString:attriTime];
    }
    NSAttributedString *attriUrl = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",url] attributes:@{NSFontAttributeName:kAppSmallTextFont}];
    [showInfo appendAttributedString:attriUrl];
    
    cell.textLabel.attributedText = showInfo;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.clipsToBounds = YES;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    RecordVideoItem *item = _data[section];
    return [NSString stringWithFormat:@"%ld、VIDEO ID:%@",(long)section,item.videoId];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecordVideoItem *item = _data[indexPath.section];
    NSString *urlStr = item.playurl[indexPath.row];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    AVPlayerViewController *player = [[AVPlayerViewController alloc]init];
    player.player = [[AVPlayer alloc] initWithURL:url];
    [self presentViewController:player animated:YES completion:nil];
}

@end
