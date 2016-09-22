//
//  MenuTableViewController.h
//  CommonLibrary
//
//  Created by AlexiChen on 15/11/12.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//
//#if kSupportUnusedCommonView
#import "BaseViewController.h"

#import "MenuAbleItem.h"

@interface MenuTableViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>
{
@protected
    NSMutableArray *_data;
    UITableView *_tableView;
}

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;

- (void)configCell:(UITableViewCell *)cell with:(id<MenuAbleItem>)meun;

@end
//#endif
