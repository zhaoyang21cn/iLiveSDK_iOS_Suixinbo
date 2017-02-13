//
//  UserProtocolViewController.m
//  live
//
//  Created by AlexiChen on 15/11/5.
//  Copyright © 2015年 kenneth. All rights reserved.
//

#import "UserProtocolViewController.h"

#import "TabbarController.h"

@interface UserProtocolViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation UserProtocolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"随心播用户协议";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"已阅读" style:UIBarButtonItemStylePlain target:self action:@selector(onClickDone)];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"UserProtocol" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [_webView loadRequest:request];
}

- (void)onClickDone
{
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"HasReadUserProtocol"];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    TabbarController *tabController = [[TabbarController alloc] init];
    appDelegate.window.rootViewController = tabController;
}

@end
