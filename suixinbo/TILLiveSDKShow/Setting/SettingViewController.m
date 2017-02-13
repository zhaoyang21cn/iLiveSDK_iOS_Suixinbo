//
//  SettingViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "SettingViewController.h"

#import "LoginViewController.h"

#import "RecListTableViewController.h"

#define kSettingTitle @"title"
#define kSettingMethod @"method"

@interface SettingViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation SettingViewController

- (instancetype)init
{
    if (self = [super init])
    {
        [[ILiveSDK getInstance] setUserStatusListener:self];
    }
    return self;
}

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
- (void)onRecordList
{
    RecListTableViewController *recList = [[RecListTableViewController alloc] init];
    
    [[AppDelegate sharedAppDelegate] pushViewController:recList];
}

- (void)onSetTestEnv:(id)param
{
    [AppDelegate showAlert:self title:nil message:@"设置之后需要下次启动才生效" okTitle:@"设置" cancelTitle:@"取消" ok:^(UIAlertAction * _Nonnull action) {
        
        NSIndexPath *path = (NSIndexPath *)param;
        UITableViewCell *cell =  [_tableView cellForRowAtIndexPath:path];
        if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
        {
            [[[ILiveSDK getInstance] getTIMManager] setEnv:1];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:kEnvParam];
        }
        else
        {
            [[[ILiveSDK getInstance] getTIMManager] setEnv:0];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:kEnvParam];
        }
    } cancel:nil];
}

- (void)setupData{
    _dataArray = [[NSMutableArray alloc] init];
    NSString *infoTitle = [NSString stringWithFormat:@"当前用户：%@",[[ILiveLoginManager getInstance] getLoginId]];
    NSDictionary *info = @{kSettingTitle:infoTitle,kSettingMethod:@""};
    [_dataArray addObject:info];
    NSDictionary *version = @{kSettingTitle:@"SDK版本号",kSettingMethod:@"onVersion"};
    [_dataArray addObject:version];
    NSDictionary *recDic = @{kSettingTitle:@"录制列表", kSettingMethod:@"onRecordList"};
    [_dataArray addObject:recDic];
    
#if kIsAppstoreVersion
    
#else
    NSDictionary *testEnvDic = @{kSettingTitle:@"测试环境", kSettingMethod:@"onSetTestEnv:"};
    [_dataArray addObject:testEnvDic];
#endif
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
        if ([method isEqualToString:@"onSetTestEnv:"])
        {
            NSNumber *numEnv = [[NSUserDefaults standardUserDefaults] objectForKey:kEnvParam];
            if ([numEnv intValue] == 1)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
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
        [self performSelector:NSSelectorFromString(methodStr) withObject:indexPath];
    }
}

- (void)onVersion
{
    UIAlertController *version = [UIAlertController alertControllerWithTitle:@"SDK版本号" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    
//    NSString *tlsSDKVer = [NSString stringWithFormat:@"tlssdk: %@",[[TLSHelper getInstance] getSDKVersion]];
//    [version addAction:[UIAlertAction actionWithTitle:tlsSDKVer style:UIAlertActionStyleDefault handler:nil]];
    
    NSString *iliveSDKVer = [NSString stringWithFormat:@"ilivesdk: %@",[[ILiveSDK getInstance] getVersion]];
    [version addAction:[UIAlertAction actionWithTitle:iliveSDKVer style:UIAlertActionStyleDefault handler:nil]];
    
    NSString *tilliveSDKVer = [NSString stringWithFormat:@"tillivesdk: %@",[[TILLiveManager getInstance] getVersion]];
    [version addAction:[UIAlertAction actionWithTitle:tilliveSDKVer style:UIAlertActionStyleDefault handler:nil]];
    
    NSString *imSDKVer = [NSString stringWithFormat:@"imsdk: %@",[[TIMManager sharedInstance] GetVersion]];
    [version addAction:[UIAlertAction actionWithTitle:imSDKVer style:UIAlertActionStyleDefault handler:nil]];
    
    NSString *avSDKVer = [NSString stringWithFormat:@"avsdk: %@",[QAVContext getVersion]];
    [version addAction:[UIAlertAction actionWithTitle:avSDKVer style:UIAlertActionStyleDefault handler:nil]];
    
    [version addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:version animated:YES completion:nil];
}

- (void)onLogout:(UIButton *)button
{
    LoadView *logoutWaitView = [LoadView loadViewWith:@"正在退出"];
    [self.view addSubview:logoutWaitView];
    
    __weak typeof(self) ws = self;
    //通知业务服务器登出
    LogoutRequest *logoutReq = [[LogoutRequest alloc] initWithHandler:^(BaseRequest *request) {
        
        [[ILiveLoginManager getInstance] iLiveLogout:^{
            
            [logoutWaitView removeFromSuperview];
            
            [ws deleteLoginParamFromLocal];
            
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [AppDelegate sharedAppDelegate].window.rootViewController = nav;
            
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            
            [logoutWaitView removeFromSuperview];
            
            NSString *errinfo = [NSString stringWithFormat:@"module=%@,errid=%ld,errmsg=%@",module,(long)request.response.errorCode,request.response.errorInfo];
            NSLog(@"regist fail.%@",errinfo);
            
            [ws showAlert:@"退出失败" message:errinfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        }];
        
    } failHandler:^(BaseRequest *request) {
        
        NSString *errinfo = [NSString stringWithFormat:@"errid=%ld,errmsg=%@",(long)request.response.errorCode,request.response.errorInfo];
        NSLog(@"regist fail.%@",errinfo);
        
        [logoutWaitView removeFromSuperview];
        
        [ws showAlert:@"退出失败" message:errinfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
    }];
    
    
    logoutReq.token = [AppDelegate sharedAppDelegate].token;
    
    [[WebServiceEngine sharedEngine] asyncRequest:logoutReq];
    
//    [[ILiveLoginManager getInstance] tlsLogout:^{
//        
//        [logoutWaitView removeFromSuperview];
//        
//        LoginViewController *loginVC = [[LoginViewController alloc] init];
//        
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
//        [AppDelegate sharedAppDelegate].window.rootViewController = nav;
//        
//    } failed:^(NSString *module, int errId, NSString *errMsg) {
//        NSLog(@"---->logout fail,module=%@,errid=%d,errmsg=%@",module,errId,errMsg);
//    }];
}

- (void)deleteLoginParamFromLocal
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kLoginParam];
}

- (void)showAlert:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle ok:(ActionHandle)succ cancel:(ActionHandle)fail
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    if (okTitle)
    {
        [alert addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:succ]];
    }
    if (cancelTitle)
    {
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:fail]];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onForceOffline
{
    __weak typeof(self) ws = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"被踢下线" message:@"你的帐号在其它设备登录" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [ws deleteLoginParamFromLocal];
        
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [AppDelegate sharedAppDelegate].window.rootViewController = nav;
        [[AppDelegate sharedAppDelegate].window makeKeyAndVisible];
        
    }]];
    
    [[AppDelegate sharedAppDelegate].navigationViewController presentViewController:alert animated:YES completion:nil];
}
- (void)onReConnFailed:(int)code err:(NSString*)err
{}

- (void)onUserSigExpired
{}

@end
