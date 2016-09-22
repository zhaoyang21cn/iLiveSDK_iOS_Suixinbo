//
//  MenuTableViewController.m
//  CommonLibrary
//
//  Created by AlexiChen on 15/11/12.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//
//#if kSupportUnusedCommonView
#import "MenuTableViewController.h"

#import "MenuItem.h"

@implementation MenuTableViewController
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

- (void)configCell:(UITableViewCell *)cell with:(id<MenuAbleItem>)meun
{
    cell.textLabel.text = [meun title];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWTATableCellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kWTATableCellIdentifier];
    }
    
    MenuItem *kv = _data[indexPath.row];
    [self configCell:cell with:kv];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuItem *kv = _data[indexPath.row];
    [kv menuAction];
}
@end
//#endif