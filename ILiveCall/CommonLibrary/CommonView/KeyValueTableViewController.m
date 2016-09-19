//
//  KeyValueTableViewController.m
//  CommonLibrary
//
//  Created by Alexi on 14-7-22.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//
#if kSupportUnusedCommonView
#import "KeyValueTableViewController.h"

#import "KeyValue.h"

@interface KeyValueTableViewController ()

@end

@implementation KeyValueTableViewController

- (void)addOwnViews
{
    _tableView = [[UITableView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self.view addSubview:_tableView];
}

- (void)layoutOnIPhone
{
    _tableView.frame = self.view.bounds;
}

#define kWTATableCellIdentifier  @"WTATableCellIdentifier"

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (void)configCell:(UITableViewCell *)cell with:(KeyValue *)kv
{
    cell.textLabel.text = kv.key;
    cell.detailTextLabel.text = [kv.value description];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWTATableCellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kWTATableCellIdentifier];
    }
    
    KeyValue *kv = _data[indexPath.row];
    [self configCell:cell with:kv];
    return cell;
}

@end
#endif
