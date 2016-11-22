//
//  SettingViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "SettingViewController.h"

#import "LoginViewController.h"

#define kSettingTitle @"title"
#define kSettingMethod @"method"

@interface SettingViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    [self setupData];
}

- (void)setupView{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"设置";
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.backgroundColor = kColorLightGray;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 60)];
    UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(kDefaultMargin,kDefaultMargin,footView.frame.size.width - 2 * kDefaultMargin, 44)];
    logoutBtn.backgroundColor = kColorRed;
    logoutBtn.layer.cornerRadius = 5.0;
    [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
    logoutBtn.titleLabel.font = kAppMiddleTextFont;
    [logoutBtn addTarget:self action:@selector(onLogout:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:logoutBtn];
    _tableView.tableFooterView = footView;
}
- (void)setupData{
    _dataArray = [[NSMutableArray alloc] init];
    NSString *infoTitle = [NSString stringWithFormat:@"当前用户：%@",[[ILiveLoginManager getInstance] getLoginId]];
    NSDictionary *info = @{kSettingTitle:infoTitle,kSettingMethod:@""};
    [_dataArray addObject:info];
    NSDictionary *version = @{kSettingTitle:@"SDK版本号",kSettingMethod:@"onVersion"};
    [_dataArray addObject:version];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"settingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = kAppMiddleTextFont;
    }
    NSString *title = [_dataArray[indexPath.row] objectForKey:kSettingTitle];
    NSString *method = [_dataArray[indexPath.row] objectForKey:kSettingMethod];
    if(method.length > 0){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *methodStr = [_dataArray[indexPath.row] objectForKey:kSettingMethod];
    if(methodStr.length > 0){
        [self performSelector:NSSelectorFromString(methodStr)];
    }
}

- (void)onVersion
{
    UIAlertController *version = [UIAlertController alertControllerWithTitle:@"SDK版本号" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *imSDKVer = [NSString stringWithFormat:@"imsdk: %@",[[TIMManager sharedInstance] GetVersion]];
    [version addAction:[UIAlertAction actionWithTitle:imSDKVer style:UIAlertActionStyleDefault handler:nil]];
    
    NSString *avSDKVer = [NSString stringWithFormat:@"avsdk: %@",[QAVContext getVersion]];
    [version addAction:[UIAlertAction actionWithTitle:avSDKVer style:UIAlertActionStyleDefault handler:nil]];
    
    NSString *tlsSDKVer = [NSString stringWithFormat:@"tlssdk: %@",[[TLSHelper getInstance] getSDKVersion]];
    [version addAction:[UIAlertAction actionWithTitle:tlsSDKVer style:UIAlertActionStyleDefault handler:nil]];
    
    NSString *iliveSDKVer = [NSString stringWithFormat:@"ilivesdk: %@",[[ILiveSDK getInstance] getVersion]];
    [version addAction:[UIAlertAction actionWithTitle:iliveSDKVer style:UIAlertActionStyleDefault handler:nil]];
    
    [version addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:version animated:YES completion:nil];
}

- (void)onLogout:(UIButton *)button
{
    LoadView *logoutWaitView = [LoadView loadViewWith:@"正在退出"];
    [self.view addSubview:logoutWaitView];
    
    [[ILiveLoginManager getInstance] tlsLogout:^{
        
        [logoutWaitView removeFromSuperview];
        
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [AppDelegate sharedAppDelegate].window.rootViewController = nav;
        
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"---->logout fail,module=%@,errid=%d,errmsg=%@",module,errId,errMsg);
    }];
}

@end
