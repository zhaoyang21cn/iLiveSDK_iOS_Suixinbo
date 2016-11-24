//
//  DemoTableViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/11/2.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "DemoTableViewController.h"

#define kDemoName @"DemoName"
#define kDemoSegue @"DemoSegue"
#define kCellReuseId @"CellReuseId"
@interface DemoTableViewController ()
@property (nonatomic, strong) NSMutableArray *demoArray;
@end
@implementation DemoTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setDemo];
}

- (void)setDemo{
    self.demoArray = [[NSMutableArray alloc] init];
    //简单直播
    NSDictionary *liveDic = [NSDictionary dictionaryWithObjectsAndKeys:@"简单直播",kDemoName,@"toLive",kDemoSegue,nil];
    [self.demoArray addObject:liveDic];
    //双人视频
//    NSDictionary *callDic = [NSDictionary dictionaryWithObjectsAndKeys:@"双人视频",kDemoName,@"toCall",kDemoSegue,nil];
//    [self.demoArray addObject:callDic];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.demoArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseId];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseId];
    }
    cell.textLabel.text = [self.demoArray[indexPath.row] objectForKey:kDemoName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *segue = [self.demoArray[indexPath.row] objectForKey:kDemoSegue];
    [self performSegueWithIdentifier:segue sender:nil];
}

@end
