//
//  CallRecordViewController.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "CallHistoryViewController.h"
#import "ViewModelAble.h"
#import "DialListViewModel.h"
#import "DialSessionCell.h"
#import "MakeCallViewController.h"
#import "MakeCallViewModel.h"

@implementation CallHistoryViewController
{
    id<DialListAble> _dialListViewModel;
    NSArray<DialSessionAble> * _sessList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"通话记录";
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 10)];
    self.tableView.tableFooterView = footerView;
    
    _dialListViewModel = [[DialListViewModel alloc] init];
    _sessList = [_dialListViewModel getDialList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _sessList = [_dialListViewModel getDialList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sessList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseidentifier = @"dial sess list cell";
    DialSessionCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseidentifier];
    if (!cell) {
        cell = [[DialSessionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseidentifier];
    }
    
    cell.indexPath = indexPath;
    [cell setSessionInfo:[_sessList objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DialSessionCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString * userId = [[cell getSessInfo] getUserId];
    MakeCallViewController * makeCallVC = [[MakeCallViewController alloc] init];
    makeCallVC.peerId = userId;
    MakeCallViewModel * model = [[MakeCallViewModel alloc] init];
    makeCallVC.makeCallModel = model;
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    [sheet bk_addButtonWithTitle:@"语音电话" handler:^{
        makeCallVC.callType = CALL_TYPE_AUDIO;
        [self presentViewController:makeCallVC animated:YES completion:nil];
    }];
    
    [sheet bk_addButtonWithTitle:@"视频电话" handler:^{
        makeCallVC.callType = CALL_TYPE_VIDEO;
        [self presentViewController:makeCallVC animated:YES completion:nil];
    }];
    
    [sheet bk_addButtonWithTitle:@"取消" handler:nil];
    [sheet showInView:self.view];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath      //当在Cell上滑动时会调用此函数
{
    return  UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DialSessionCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString * userId = [[cell getSessInfo] getUserId];
        [_dialListViewModel deleteSession:userId];
        [self reloadData];
    }
}

- (void)reloadData
{
    _sessList = [_dialListViewModel getDialList];
    [self.tableView reloadData];
}

@end
