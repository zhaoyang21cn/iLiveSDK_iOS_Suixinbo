//
//  LiveCallLoginViewController.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "LiveCallLoginViewController.h"
#import "EngineHeaders.h"

@interface LiveCallLoginViewController ()
{
    __weak id    _tlsuiwx;
    id           _openQQ;
}

@end

@implementation LiveCallLoginViewController
{
    LiveCallLoginParam * _loginParam;
    MBProgressHUD * _hud;
}

- (void)dealloc
{
    _openQQ = nil;
    _tlsuiwx = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[LiveCallPlatform sharedInstance] isAutoLogin]) {
        [self autoLogin];
    }
    else {
        [self pullLoginUI];
    }
}

- (void)autoLogin
{
    LiveCallLoginParam * param = [[LiveCallPlatform sharedInstance] loadLoginParam];
    if (param) {
        if ([param needRefresh]) {
            _loginParam = param;
            [[TLSHelper getInstance] TLSRefreshTicket:param.identifier andTLSRefreshTicketListener:self];
        }
        [self login:param];
    }
    else {
        [self pullLoginUI];
    }
}

- (void)enterMainUI
{
    [[AppDelegate sharedInstance] enterMainUI];
}

#pragma mark - 拉起登录界面
- (void)pullLoginUI
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TLSUILoginSetting *setting = [[TLSUILoginSetting alloc] init];
        _tlsuiwx = TLSUILogin(self, setting);
    });
}

#pragma mark - TLSUILoginListener
- (void)TLSUILoginCancel
{
    // ignore
}

- (void)TLSUILoginOK:(TLSUserInfo *)userinfo
{
    [self loginWithTLSUserInfo:userinfo];
}


#pragma mark - TLSRefreshListener
-(void)	OnRefreshTicketSuccess:(TLSUserInfo *)userInfo
{
    [self loginWithTLSUserInfo:userInfo];
}

-(void)	OnRefreshTicketFail:(TLSErrInfo *)errInfo
{
    [[LiveCallPlatform sharedInstance] setAutoLogin:NO];
    [self pullLoginUI];
}

-(void)	OnRefreshTicketTimeout:(TLSErrInfo *)errInfo
{
    [self pullLoginUI];
}

#pragma mark - some methods

- (void)loginWithTLSUserInfo:(TLSUserInfo*)userinfo
{
    _openQQ = nil;
    _tlsuiwx = nil;
    
    LiveCallLoginParam * param = [[LiveCallLoginParam alloc] init];
    param.identifier = userinfo.identifier;
    param.userSig = [[TLSHelper getInstance] getTLSUserSig:userinfo.identifier];
    param.accountType = kAccoutType;
    param.sdkAppId = kSdkAppid;
    param.appidAt3rd = kAppidAt3rd;
    [param updateRefreshTime];
    
    [[LiveCallPlatform sharedInstance] saveLoginParam:param];
    [[LiveCallPlatform sharedInstance] setAutoLogin:YES];
    
    [self login:param];
}

- (void)login:(LiveCallLoginParam*)param
{
    __weak typeof(self) ws = self;
    
    [[HUDHelper sharedInstance] syncLoading:@"正在登录"];
    
    TCICallManager * manager = [TCICallManager sharedInstance];
    [manager login:param loginFail:^(int code, NSString *msg) {
        [[HUDHelper sharedInstance] syncStopLoadingMessage:[NSString stringWithFormat:@"登录IMSDK失败:%@", msg] delay:1 completion:^{
            [ws pullLoginUI];
        }];
    } offlineKicked:^(TIMLoginParam *param, TCIRoomBlock succ, TIMFail fail) {
        [[HUDHelper sharedInstance] syncStopLoadingMessage:@"该账号在其他设备上已登录，请重新登录" delay:1 completion:^{
            [ws pullLoginUI];
        }];
    } startContextCompletion:^(BOOL succ, NSError *err) {
        if (succ) {
            [[HUDHelper sharedInstance] syncStopLoadingMessage:@"登录成功"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws enterMainUI];
            });
        }
        else {
            [[HUDHelper sharedInstance] syncStopLoadingMessage:[NSString stringWithFormat:@"启动AVSDK失败:%@", err] delay:1 completion:^{
                [ws pullLoginUI];
            }];
        }
    }];
}

@end
