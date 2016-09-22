//
//  IMALoginViewController.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMALoginViewController.h"

#import "IMALoginParam.h"

#define kDaysInSeconds(x)      (x * 24 * 60 * 60)

@interface IMALoginViewController ()
{
    __weak id<WXApiDelegate>    _tlsuiwx;
    TencentOAuth                *_openQQ;
    IMALoginParam               *_loginParam;
}

@end

@implementation IMALoginViewController

#define kIMAAutoLoginParam @"kIMAAutoLoginParam"

- (void)dealloc
{
    DebugLog(@"IMALoginViewController=====>>>>> release");
    _tlsuiwx = nil;
    _openQQ = nil;
    
    [_loginParam saveToLocal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [WXApi registerApp:WX_APP_ID];
    //demo暂不提供微博登录
    //[WeiboSDK registerApp:WB_APPKEY];
    
    // 因TLSSDK在IMSDK里面初始化，必须先初始化IMSDK，才能使用TLS登录
    // 导致登出然后使用相同的帐号登录，config会清掉
    
    BOOL isAutoLogin = [IMAPlatform isAutoLogin];
    if (isAutoLogin)
    {
        _loginParam = [IMALoginParam loadFromLocal];
    }
    else
    {
        _loginParam = [[IMALoginParam alloc] init];
    }
    
    [IMAPlatform configWith:_loginParam.config];
    
    if (isAutoLogin && [_loginParam isVailed])
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self autoLogin];
        });
    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self pullLoginUI];
        });
        
    }
}

- (void)autoLogin
{
    if ([_loginParam isExpired])
    {
        [[HUDHelper sharedInstance] syncLoading:@"刷新票据。。。"];
        //刷新票据
        [[TLSHelper getInstance] TLSRefreshTicket:_loginParam.identifier andTLSRefreshTicketListener:self];
    }
    else
    {
        [self loginIMSDK];
    }
}

- (void)enterMainUI
{
    _tlsuiwx = nil;
    _openQQ = nil;
    [[IMAAppDelegate sharedAppDelegate] enterMainUI];
    
    [[IMAPlatform sharedInstance] configOnLoginSucc:_loginParam completion:nil];
}

- (void)loginWith:(TLSUserInfo *)userinfo
{
    _openQQ = nil;
    _tlsuiwx = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (userinfo)
        {
            _loginParam.identifier = userinfo.identifier;
            _loginParam.userSig = [[TLSHelper getInstance] getTLSUserSig:userinfo.identifier];
            _loginParam.tokenTime = [[NSDate date] timeIntervalSince1970];
            
            // 获取本地的登录config
            [self loginIMSDK];
        }
    });
}

- (void)loginIMSDK
{
    //直接登录
    __weak IMALoginViewController *weakSelf = self;
    [[HUDHelper sharedInstance] syncLoading:@"正在登录"];
    [[IMAPlatform sharedInstance] login:_loginParam succ:^{
        [[HUDHelper sharedInstance] syncStopLoadingMessage:@"登录成功"];
        [weakSelf enterMainUI];
    } fail:^(int code, NSString *msg) {
        [[HUDHelper sharedInstance] syncStopLoadingMessage:IMALocalizedError(code, msg) delay:2 completion:^{
            [weakSelf pullLoginUI];
        }];
    }];
}


#pragma mak - delegate<TencentLoginDelegate>
-(void)tencentDidNotNetWork
{
    DebugLog(@"tencentDidNotNetWork");
}

-(void)tencentDidLogin
{
    DebugLog(@"tencentDidLogin");
}

-(void)tencentDidNotLogin:(BOOL)cancelled
{
    DebugLog(@"tencentDidNotLogin");
}

#pragma mark - delegate<WXApiDelegate>
-(void) onReq:(BaseReq *)req
{
    DebugLog(@"onReq:%@", req);
}

-(void)onResp:(BaseResp *)resp
{
    DebugLog(@"%d %@ %d",resp.errCode, resp.errStr, resp.type);
    if ([resp isKindOfClass:[SendAuthResp class]])
    {
        if(_tlsuiwx != nil)
        {
            [_tlsuiwx onResp:resp];
        }
    }
}

#pragma mark - 拉起登陆框
- (void)pullLoginUI
{
    TLSUILoginSetting *setting = [[TLSUILoginSetting alloc] init];
    _openQQ = [[TencentOAuth alloc]initWithAppId:QQ_APP_ID andDelegate:self];
//    [setting setOpenQQ:_openQQ];
//    setting.qqScope = nil;
//    setting.wxScope = @"snsapi_userinfo";
//    setting.enableWXExchange = YES;
    setting.enableGuest = YES;
    //    _setting.needBack = YES;
    //demo暂不提供微博登录
    //    tlsSetting.wbScope = nil;
    //    tlsSetting.wbRedirectURI = @"https://api.weibo.com/oauth2/default.html";
    _tlsuiwx = TLSUILogin(self, setting);
}

#pragma mark - delegate<TLSUILoginListener>
-(void)TLSUILoginOK:(TLSUserInfo *)userinfo
{
    //回调时已结束登录流程 销毁微信回调对象
    //根据登录结果处理
    [self loginWith:userinfo];
    
}

-(void)TLSUILoginQQOK
{
    //回调时已结束登录流程 销毁微信回调对象
    
    [[TLSHelper getInstance] TLSOpenLogin:kQQAccountType andOpenId:_openQQ.openId andAppid:QQ_APP_ID andAccessToken:_openQQ.accessToken andTLSOpenLoginListener:self];
    
}
//已经废弃
-(void)TLSUILoginWXOK:(SendAuthResp*)resp
{
    DebugLog(@"TLSUILoginWXOK");
}

-(void)TLSUILoginWXOK2:(TLSTokenInfo *)tokenInfo
{
    [[TLSHelper getInstance] TLSOpenLogin:kWXAccountType andOpenId:tokenInfo.openid andAppid:WX_APP_ID andAccessToken:tokenInfo.accessToken andTLSOpenLoginListener:self];
}
//demo暂不提供微博登录

-(void)TLSUILoginWBOK:(WBAuthorizeResponse *)resp
{
    //    [GlobalData shareInstance].accountHelper = [AccountHelper sharedInstance];
    //    [GlobalData shareInstance].friendshipManager = [FriendshipManager sharedInstance];
    //    NSString *appid = [[NSString alloc] initWithFormat:@"%d",kSdkAppId ];
    //    [[TLSHelper getInstance] TLSOpenLogin:kWXAccountType andOpenId:tokenInfo.openid andAppid:appid andAccessToken:tokenInfo.accessToken andTLSOpenLoginListener:self];
    
}

-(void)TLSUILoginCancel
{
    //回调时已结束登录流程 销毁微信回调对象
}

#pragma mark - TLSOpenLoginListener

//第三方登录成功之后，再次登陆tls换取userinfo
-(void)OnOpenLoginSuccess:(TLSUserInfo *)userinfo
{
    //回调时已结束登录流程 销毁微信回调对象
    //根据登录结果处理
    [self loginWith:userinfo];
}

-(void)OnOpenLoginFail:(TLSErrInfo*)errInfo
{
    DebugLog(@"%@",errInfo);
}

-(void)OnOpenLoginTimeout:(TLSErrInfo*)errInfo
{
    DebugLog(@"%@",errInfo);
}

#pragma mark - Provate Methods


#pragma mark - 刷新票据代理

- (void)OnRefreshTicketSuccess:(TLSUserInfo *)userInfo
{
    [[HUDHelper sharedInstance] syncStopLoading];
    [self loginWith:userInfo];
}


- (void)OnRefreshTicketFail:(TLSErrInfo *)errInfo
{
    _loginParam.tokenTime = 0;
    NSString *err = [[NSString alloc] initWithFormat:@"刷新票据失败\ncode:%d, error:%@", errInfo.dwErrorCode, errInfo.sErrorTitle];
    
    __weak IMALoginViewController *ws = self;
    [[HUDHelper sharedInstance] syncStopLoadingMessage:err delay:2 completion:^{
        [ws pullLoginUI];
    }];
    
}


- (void)OnRefreshTicketTimeout:(TLSErrInfo *)errInfo
{
    [self OnRefreshTicketFail:errInfo];
}

@end
