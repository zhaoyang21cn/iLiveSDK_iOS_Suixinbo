//
//  SettingViewController.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingViewModel.h"

@implementation SettingViewController
{
    SettingViewModel * _settingModel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    [self initHeaderView];
    [self initFooterView];
    _settingModel = [[SettingViewModel alloc] init];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_exitBtn alignParentCenter];
}

- (void)initHeaderView
{
    _headerView = [[HostInfoView alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
    [_headerView setBackgroundColor:kClearColor];
    [_headerView setHostInfo];
    self.tableView.tableHeaderView = _headerView;
}

- (void)initFooterView
{
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
    [_footerView setBackgroundColor:kClearColor];
    self.tableView.tableFooterView = _footerView;
    
    _exitBtn = [[UIButton alloc] init];
    [_exitBtn setFrame:CGRectMake(0, 0, 200, 40)];
    [_exitBtn setBackgroundColor:kRedColor];
    [_exitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [_exitBtn setTitle:@"退出登录" forState:UIControlStateSelected];
    [_exitBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [_exitBtn setTitleColor:kWhiteColor forState:UIControlStateSelected];
    [_exitBtn.layer setCornerRadius:10];
    [_exitBtn addTarget:self action:@selector(exitBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_footerView addSubview:_exitBtn];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}


- (void)exitBtnAction:(UIButton*)sender
{
    [_settingModel logout];
    [[AppDelegate sharedInstance] enterLoginUI];
}

@end
