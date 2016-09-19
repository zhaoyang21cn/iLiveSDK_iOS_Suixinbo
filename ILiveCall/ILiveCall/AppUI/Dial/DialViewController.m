//
//  DailViewController.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "DialViewController.h"
#import "DialUserCell.h"
#import "DialUserViewModel.h"
#import "MakeCallViewController.h"
#import "MakeCallViewModel.h"

@implementation DialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"拨号";
    [self initFootView];
    
    _dialCellModel = [[DialUserViewModel alloc] init];
    
    [self addTapBlankToHideKeyboardGesture];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_callBtn alignParentCenter];
}

- (void)initFootView
{
    _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
    [_footView setBackgroundColor:kClearColor];
    self.tableView.tableFooterView = _footView;
    
    _callBtn = [[UIButton alloc] init];
    [_callBtn setFrame:CGRectMake(0, 0, 40, 40)];
    [_callBtn setImage:kImageDail forState:UIControlStateNormal];
    [_callBtn setImage:kImageDail forState:UIControlStateSelected];
    [_callBtn setBackgroundColor:kClearColor];
    [_callBtn addTarget:self action:@selector(callBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_footView addSubview:_callBtn];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseidentifier = @"input user cell";
    DialUserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseidentifier];
    if (!cell)
    {
        cell = [[DialUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseidentifier];
    }
    cell.indexPath = indexPath;
    [cell setDialUserModel:_dialCellModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (void)callBtnAction:(UIButton*)sender
{
    [self hideKeyboard];
    
    NSString * userId = [_dialCellModel getDialUser];
    MakeCallViewController * makeCallVC = [[MakeCallViewController alloc] init];
    makeCallVC.peerId = userId;
    MakeCallViewModel * callModel = [[MakeCallViewModel alloc] init];
    makeCallVC.makeCallModel = callModel;
    
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

- (void)addTapBlankToHideKeyboardGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBlankToHideKeyboard:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
}

- (void)onTapBlankToHideKeyboard:(UITapGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateEnded)
    {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    }
}

- (void)hideKeyboard
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

@end
