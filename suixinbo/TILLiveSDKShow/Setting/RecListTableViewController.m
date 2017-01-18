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
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
    self.tableView.tableFooterView.hidden = YES;
    
    [self requestRecordList];
}

//拉取录制列表
- (void)requestRecordList
{
    __weak typeof(self) ws = self;
    RecordListRequest *recListReq = [[RecordListRequest alloc] initWithHandler:^(BaseRequest *request) {
        RecordListResponese *recordRsp = (RecordListResponese *)request.response;
        ws.data = [NSMutableArray arrayWithArray:recordRsp.videos];
        [ws.tableView reloadData];
        
    } failHandler:^(BaseRequest *request) {
        NSLog(@"fail");
    }];
    recListReq.token = [AppDelegate sharedAppDelegate].token;
    recListReq.type = 0;//暂时没有用
    recListReq.index = _pageItem.pageIndex;
    recListReq.size = _pageItem.pageSize;
    
    [[WebServiceEngine sharedEngine] asyncRequest:recListReq wait:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return _data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    RecordVideoItem *item = _data[section];
    return item.playurl.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"RecordListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    RecordVideoItem *item = _data[indexPath.section];
    NSString *url = item.playurl[indexPath.row];
    NSArray *array = [item.uid componentsSeparatedByString:@"_"];
    NSMutableAttributedString *showInfo = [[NSMutableAttributedString alloc] init];
    if (array.count > 1)
    {
        NSString *identifier = array[1];
        
        NSAttributedString *attriId = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",identifier] attributes:@{NSFontAttributeName:kAppLargeTextFont}];
        [showInfo appendAttributedString:attriId];
    }
    if (array.count > 2)
    {
        NSString *fileName = array[2];
        NSAttributedString *attriName = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",fileName] attributes:@{NSFontAttributeName:kAppLargeTextFont}];
        [showInfo appendAttributedString:attriName];
    }
    if (array.count > 3)
    {
        NSString *recStartTime = array[3];
        NSAttributedString *attriTime = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",recStartTime] attributes:@{NSFontAttributeName:kAppLargeTextFont}];
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
    return [NSString stringWithFormat:@"VIDEO ID:%@",item.videoId];
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
