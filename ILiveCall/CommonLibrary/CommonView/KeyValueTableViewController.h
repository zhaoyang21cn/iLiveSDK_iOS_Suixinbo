//
//  KeyValueTableViewController.h
//  CommonLibrary
//
//  Created by Alexi on 14-7-22.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//
#if kSupportUnusedCommonView
#import "BaseViewController.h"

@class KeyValue;

@interface KeyValueTableViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>
{
@protected
    NSMutableArray *_data;
    UITableView *_tableView;
}

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;

- (void)configCell:(UITableViewCell *)cell with:(KeyValue *)kv;

@end
#endif