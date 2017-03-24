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
#import "ProfileTableViewCell.h"
#import "UploadImageHelper.h"

#define kSettingTitle @"title"
#define kSettingMethod @"method"

@interface SettingViewController () <UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation SettingViewController

- (instancetype)init
{
    if (self = [super init])
    {
        __weak typeof(self) ws = self;
        [[ILiveSDK getInstance] setUserStatusListener:self];
        [[TIMFriendshipManager sharedInstance] GetSelfProfile:^(TIMUserProfile *profile) {
            if (profile.nickname && profile.nickname.length > 0)
            {
                ws.nickName = profile.nickname;
            }
            if (profile.faceURL && profile.faceURL.length > 0)
            {
                NSURL *imageUrl = [NSURL URLWithString:profile.faceURL];
                NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
                ws.avatar = [UIImage imageWithData:imageData];
            }
        } fail:^(int code, NSString *msg) {
            NSLog(@"GetSelfProfile fail");
        }];
        _nickName = [[ILiveLoginManager getInstance] getLoginId];
        _avatar = [UIImage imageNamed:@"default_user"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    [self setupData];
}

- (void)setupView
{
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

- (void)setupData
{
    _dataArray = [[NSMutableArray alloc] init];
    NSDictionary *info = @{kSettingTitle:_nickName,kSettingMethod:@"onProfile"};
    [_dataArray addObject:info];
    NSDictionary *version = @{kSettingTitle:@"SDK版本号",kSettingMethod:@"onVersion"};
    [_dataArray addObject:version];
#if kIsAppstoreVersion
#else
    NSDictionary *logLevel = @{kSettingTitle:@"日志等级",kSettingMethod:@"onLogLevel"};
    [_dataArray addObject:logLevel];
    NSDictionary *testEnvDic = @{kSettingTitle:@"测试环境", kSettingMethod:@"onSetTestEnv:"};
    [_dataArray addObject:testEnvDic];
#endif
    NSDictionary *recDic = @{kSettingTitle:@"录制列表", kSettingMethod:@"onRecordList"};
    [_dataArray addObject:recDic];
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
    if(!cell)
    {
        if (indexPath.section == 0 && indexPath.row == 0)//第一行显示用户资料
        {
            cell = [[ProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            cell.textLabel.text = _nickName;
            cell.detailTextLabel.text = [[ILiveLoginManager getInstance] getLoginId];
            cell.detailTextLabel.textColor = kColorGray;
            [cell.imageView setImage:_avatar];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickAvatar:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            [cell.imageView addGestureRecognizer:tap];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.imageView.userInteractionEnabled = YES;
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        cell.textLabel.font = kAppMiddleTextFont;
    }
    NSString *title = [_dataArray[indexPath.row] objectForKey:kSettingTitle];
    NSString *method = [_dataArray[indexPath.row] objectForKey:kSettingMethod];
    if(method.length > 0)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if ([method isEqualToString:@"onSetTestEnv:"])
        {
            NSNumber *numEnv = [[NSUserDefaults standardUserDefaults] objectForKey:kEnvParam];
            if ([numEnv intValue] == 1)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        if ([method isEqualToString:@"onLogLevel"])
        {
            TIMLogLevel level = [[[ILiveSDK getInstance] getTIMManager] getLogLevel];
            cell.detailTextLabel.text = [self getLogLevelStr:level];
        }
    }
    cell.textLabel.text = title;
    [cell layoutSubviews];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)//第一行显示用户资料
    {
        return 60.0f;
    }
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *methodStr = [_dataArray[indexPath.row] objectForKey:kSettingMethod];
    if(methodStr.length > 0)
    {
        SEL sel = NSSelectorFromString(methodStr);
        [self performSelector:sel withObject:indexPath afterDelay:0];
    }
}

- (void)onProfile
{
    __weak typeof(self) ws = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = _nickName;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认修改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *nickName = alert.textFields.firstObject.text;
        if (nickName && nickName.length > 0)
        {
            [[TIMFriendshipManager sharedInstance] SetNickname:nickName succ:^{
                ws.nickName = nickName;
                NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
                UITableViewCell *cell = [ws.tableView cellForRowAtIndexPath:path];
                cell.textLabel.text = nickName;
            } fail:^(int code, NSString *msg) {
                NSLog(@"设置昵称失败%d%@",code,msg);
            }];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onClickAvatar:(UIGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateEnded)
    {
        __weak typeof(self) ws = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws openCamera];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws openPhotoLibrary];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)openCamera
{
    // 打开系统相机拍照
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        [AppDelegate showAlert:self title:nil message:@"您没有相机使用权限,请到设置->隐私中开启权限" okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        return;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *cameraIPC = [[UIImagePickerController alloc] init];
        cameraIPC.delegate = self;
        cameraIPC.allowsEditing = YES;
        cameraIPC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:cameraIPC animated:YES completion:nil];
        return;
    }
}

- (void)openPhotoLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
        return;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    __weak typeof(self)ws = self;
    LoadView *upimage = [LoadView loadViewWith:@"正在上传头像"];
    [[UploadImageHelper shareInstance] upload:image completion:^(NSString *imageSaveUrl) {
        ws.avatar = image;
        [[TIMFriendshipManager sharedInstance] SetFaceURL:imageSaveUrl succ:^{
            [upimage removeFromSuperview];
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
            UITableViewCell *cell = [ws.tableView cellForRowAtIndexPath:path];
            [cell.imageView setImage:ws.avatar];
        } fail:^(int code, NSString *msg) {
            [upimage removeFromSuperview];
        }];
    } failed:^(NSString *failTip) {
        [upimage removeFromSuperview];
        [AppDelegate showAlert:self title:@"上传头像失败" message:failTip okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
    }];
    //如果是相机拍照，则保存到相册
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
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

- (void)onLogLevel
{
    __weak typeof(self) ws = self;
    [AppDelegate showAlert:self title:@"设置日志等级" message:@"设置之后需要下次启动才生效" okTitle:@"设置" cancelTitle:@"取消" ok:^(UIAlertAction * _Nonnull action) {
        [ws setLogLevel];
    } cancel:nil];
}

- (void)setLogLevel
{
    UIAlertController *logLevel = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [logLevel addAction:[UIAlertAction actionWithTitle:@"LOG_NONE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:@(TIM_LOG_NONE) forKey:kLogLevel];
    }]];
    [logLevel addAction:[UIAlertAction actionWithTitle:@"LOG_ERROR" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:@(TIM_LOG_ERROR) forKey:kLogLevel];
    }]];
    [logLevel addAction:[UIAlertAction actionWithTitle:@"LOG_WARN" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:@(TIM_LOG_WARN) forKey:kLogLevel];
    }]];
    [logLevel addAction:[UIAlertAction actionWithTitle:@"LOG_INFO " style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:@(TIM_LOG_INFO) forKey:kLogLevel];
    }]];
    [logLevel addAction:[UIAlertAction actionWithTitle:@"LOG_DEBUG" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:@(TIM_LOG_DEBUG) forKey:kLogLevel];
    }]];
    [logLevel addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:logLevel animated:YES completion:nil];
}

- (NSString *)getLogLevelStr:(NSInteger)logLevel
{
    TIMLogLevel level = (TIMLogLevel)logLevel;
    switch (level)
    {
        case TIM_LOG_NONE:
            return @"LOG_NONE";
            break;
        case TIM_LOG_ERROR:
            return @"LOG_ERROR";
            break;
        case TIM_LOG_WARN:
            return @"LOG_WARN";
            break;
        case TIM_LOG_INFO:
            return @"LOG_INFO";
            break;
        case TIM_LOG_DEBUG:
            return @"LOG_DEBUG";
            break;
        default:
            return @"LOG_UNDEFINE";
            break;
    }
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
