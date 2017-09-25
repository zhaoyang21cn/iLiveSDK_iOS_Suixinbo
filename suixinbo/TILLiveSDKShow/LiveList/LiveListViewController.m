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
    _noLiveLabel.text = @"暂时没有直播";
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
    _pageItem.pageIndex = 0;
    [_datas removeAllObjects];
    _isCanLoadMore = YES;
    [self loadMore:complete];
}
    
- (void)loadMore:(TCIVoidBlock)complete
{
    __weak typeof(self) ws = self;
    //向业务后台请求直播间列表
    RoomListRequest *listReq = [[RoomListRequest alloc] initWithHandler:^(BaseRequest *request) {
        RoomListRequest *wreq = (RoomListRequest *)request;
        [ws loadListSucc:wreq];
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
    listReq.token = [AppDelegate sharedAppDelegate].token;
    listReq.type = @"live";
    listReq.index = _pageItem.pageIndex;
    listReq.size = _pageItem.pageSize;
    listReq.appid = [ShowAppId intValue];
    [[WebServiceEngine sharedEngine] asyncRequest:listReq wait:YES];
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
    
    LiveListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveListTableViewCell"];
    if(cell == nil)
    {
        cell = [[LiveListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LiveListTableViewCell"];
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
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *guestRole = [user objectForKey:kSxbRole_GuestValue];
    if (!(guestRole && guestRole.length > 0))
    {
        __weak typeof(self) ws = self;
        AlertActionHandle guestHD = ^(UIAlertAction *_Nonnull action){
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setValue:kSxbRole_GuestHD forKey:kSxbRole_GuestValue];
            [ws pushToLiveVC:indexPath role:kSxbRole_GuestHD];
        };
        AlertActionHandle guestLD = ^(UIAlertAction *_Nonnull action){
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setValue:kSxbRole_GuestLD forKey:kSxbRole_GuestValue];
            [ws pushToLiveVC:indexPath role:kSxbRole_GuestLD];
        };
        [AlertHelp alertWith:@"观众端角色选择" message:nil funBtns:@{kSxbRole_GuestHDTitle:guestHD, kSxbRole_GuestLDTitle:guestLD} cancelBtn:@"取消" alertStyle:UIAlertControllerStyleActionSheet cancelAction:nil];
    }
    else
    {
        [self pushToLiveVC:indexPath role:guestRole];
    }
}

- (void)pushToLiveVC:(NSIndexPath *)indexPath role:(NSString *)roleName
{
    if (_datas.count <= indexPath.row)
    {
        [AlertHelp tipWith:@"无效的直播间" wait:1.5];
        return;
    }
    TCShowLiveListItem *item = _datas[indexPath.row];
    item.info.roleName = roleName;
    LiveViewController *liveVC = [[LiveViewController alloc] initWith:item roomOptionType:RoomOptionType_JoinRoom];
    [[AppDelegate sharedAppDelegate] presentViewController:liveVC animated:YES completion:nil];
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
