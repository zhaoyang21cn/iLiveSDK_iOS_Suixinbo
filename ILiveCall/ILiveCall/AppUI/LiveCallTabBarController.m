//
//  LiveCallTabBarController.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "LiveCallTabBarController.h"
#import "CallHistoryViewController.h"
#import "DialViewController.h"
#import "SettingViewController.h"

@implementation LiveCallTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CallHistoryViewController * historyVC = [[CallHistoryViewController alloc] init];
    NavigationViewController * historyNVC = [[NavigationViewController alloc] initWithRootViewController:historyVC];
    historyNVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"通话记录" image:kIconConversationNormal selectedImage:kIconConversationHover];
    
    
    DialViewController * dailVC = [[DialViewController alloc] init];
    NavigationViewController * dailNVC = [[NavigationViewController alloc] initWithRootViewController:dailVC];
    dailNVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"拨号" image:kIconDailNormal selectedImage:kIconDailHover];
    
    SettingViewController * setVC = [[SettingViewController alloc] init];
    NavigationViewController * setNVC = [[NavigationViewController alloc] initWithRootViewController:setVC];
    setNVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:kIconSetupNormal selectedImage:kIconSetupHover];
    
    self.tabBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    [self setViewControllers:@[historyNVC, dailNVC, setNVC]];
}

@end
