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

@interface RecordListViewController ()<UIGestureRecognizerDelegate>

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
    _isCanLoadMore = YES;
    
    [self addSubViews];
    [self layoutSubViews];
    
    [self addTapBlankToHideKeyboardGesture];
}

- (void)addSubViews
{
    _accountIdTF = [[UITextField alloc] init];
    UILabel *leftTip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
    leftTip.text = @"用户名";
    _accountIdTF.leftView = leftTip;
    _accountIdTF.leftViewMode = UITextFieldViewModeAlways;
    _accountIdTF.text = [[ILiveLoginManager getInstance] getLoginId];
    [self.view addSubview:_accountIdTF];
    
    _accountIdLine = [[UIView alloc] init];
    _accountIdLine.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_accountIdLine];
    
    _searchNumTF = [[UITextField alloc] init];
    leftTip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    leftTip.text = @"数量";
    _searchNumTF.leftView = leftTip;
    _searchNumTF.leftViewMode = UITextFieldViewModeAlways;
    _searchNumTF.text = @"15";
    _searchNumTF.placeholder = @"0～100";
    _searchNumTF.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_searchNumTF];
    
    _searchNumLine = [[UIView alloc] init];
    _searchNumLine.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_searchNumLine];
    
    _tableView = [[UITableView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UIView *loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    UILabel *loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    loadMoreLabel.text = @"加载更多...";
    loadMoreLabel.textAlignment = NSTextAlignmentCenter;
    [loadMoreView addSubview:loadMoreLabel];
    _tableView.tableFooterView = loadMoreView;
    _tableView.tableFooterView.hidden = YES;
    
    _refreshCtl = [[UIRefreshControl alloc] init];
    _refreshCtl.attributedTitle = [[NSAttributedString alloc] initWithString:@"刷新列表" attributes:@{NSFontAttributeName:kAppMiddleTextFont}];
    _refreshCtl.tintColor = kColorRed;
    [_refreshCtl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 10.0)
    {
        _tableView.refreshControl = _refreshCtl;
    }
    else
    {
        [self.tableView addSubview:_refreshCtl];
    }

    //自动拉取一次列表
    //第一次进来会调用 scrollViewDidScroll，自动拉取一次
    
    _noLiveLabel = [[UILabel alloc] init];
    _noLiveLabel.text = @"暂时没有回放数据";
    _noLiveLabel.hidden = YES;
    _noLiveLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_noLiveLabel];
}

- (void)layoutSubViews
{
    CGSize selfSize = self.view.bounds.size;
    
    [_accountIdTF sizeWith:CGSizeMake(selfSize.width/2, 50)];
    [_accountIdTF alignParentTop];
    [_accountIdTF alignParentLeft];
    
    [_accountIdLine sizeWith:CGSizeMake(selfSize.width/2-60, 1)];
    [_accountIdLine layoutBelow:_accountIdTF margin:-10];
    [_accountIdLine alignParentLeftWithMargin:60];
    
    [_searchNumTF sizeWith:CGSizeMake(selfSize.width/2, 50)];
    [_searchNumTF alignParentTop];
    [_searchNumTF layoutToRightOf:_accountIdTF];
    
    [_searchNumLine sizeWith:CGSizeMake(selfSize.width/2-50, 1)];
    [_searchNumLine layoutBelow:_searchNumTF margin:-10];
    [_searchNumLine alignParentLeftWithMargin:selfSize.width/2+50];
    
    [_tableView sizeWith:CGSizeMake(selfSize.width, selfSize.height-50)];
    [_tableView alignParentLeft];
    [_tableView alignParentTopWithMargin:50];
    
    [_noLiveLabel sizeWith:CGSizeMake(selfSize.width, 50)];
    [_noLiveLabel layoutParentVerticalCenter];
}

- (void)addTapBlankToHideKeyboardGesture;
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBlankToHideKeyboard:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)onTapBlankToHideKeyboard:(UITapGestureRecognizer *)ges
{
    [_accountIdTF resignFirstResponder];
    [_searchNumTF resignFirstResponder];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //本函数主要处理手势和点击时间冲突问题
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        //正在编辑，则收起键盘（即不相应cell点击事件）
        if (_accountIdTF.isEditing || _searchNumTF.isEditing)
        {
            return YES;
        }
        return NO;
    }
    return  YES;
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
    _pageItem.pageSize = _searchNumTF.text.length>0 ? [_searchNumTF.text integerValue] : 15;
    if (_pageItem.pageSize > 100 || _pageItem.pageSize < 0)//后台限制在0-100之间
    {
        _pageItem.pageSize = 15;
    }
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
    recListReq.type = 0;
    recListReq.index = _pageItem.pageIndex;
    recListReq.size = _pageItem.pageSize;
    recListReq.uid = _accountIdTF.text ? _accountIdTF.text : @"";
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

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGFloat currentOffsetY = scrollView.contentOffset.y;
//    /*self.refreshControl.isRefreshing == NO加这个条件是为了防止下面的情况发生：
//     每次进入UITableView，表格都会沉降一段距离，这个时候就会导致currentOffsetY + scrollView.frame.size.height   > scrollView.contentSize.height 被触发，从而触发loadMore方法，而不会触发refresh方法。
//     */
//    if ( currentOffsetY + scrollView.frame.size.height  > scrollView.contentSize.height && _tableView.refreshControl.isRefreshing == NO && _tableView.tableFooterView.hidden == YES && _isCanLoadMore)
//    {
//        self.tableView.tableFooterView.hidden = NO;
//        __weak typeof(self) ws = self;
//        [self loadMore:^{
//            ws.tableView.tableFooterView.hidden = YES;
//        }];
//    }
//}

@end
