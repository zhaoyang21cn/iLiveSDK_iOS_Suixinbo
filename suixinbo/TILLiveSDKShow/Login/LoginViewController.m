//
//  LoginViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LoginViewController.h"

#import "RegistViewController.h"

#import "TabbarController.h"

#import "AppDelegate.h"

@interface LoginViewController ()

@property (nonatomic, strong) UITextField *userNameTF;
@property (nonatomic, strong) UITextField *passwordTF;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = kColorLightGray;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"登录";
    
    [self addTapBlankToHideKeyboardGesture];
    
    self.navigationItem.title = @"用户名登录";
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat screenW = screenRect.size.width;
    
    CGFloat tfHeight = 44;
    
    int index = 0;
    
    _userNameTF = [[UITextField alloc] initWithFrame:CGRectMake(kDefaultMargin*2, kDefaultMargin*(index+2) + tfHeight*index, screenW-(kDefaultMargin*4), tfHeight)];
    _userNameTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDefaultMargin, kDefaultMargin)];
    _userNameTF.leftViewMode = UITextFieldViewModeAlways;
    _userNameTF.backgroundColor = kColorWhite;
    _userNameTF.layer.borderWidth = 0.5;
    _userNameTF.layer.borderColor = kColorGray.CGColor;
    _userNameTF.layer.cornerRadius = 5.0;
    _userNameTF.placeholder = @"用户名";
    _userNameTF.text = @"sxb1";
    [self.view addSubview:_userNameTF];
    index++;
    
    _passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(kDefaultMargin*2, kDefaultMargin*(index+2) + tfHeight*index, screenW-(kDefaultMargin*4), tfHeight)];
    _passwordTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDefaultMargin, kDefaultMargin)];
    _passwordTF.leftViewMode = UITextFieldViewModeAlways;
    _passwordTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDefaultMargin, kDefaultMargin)];
    _passwordTF.backgroundColor = kColorWhite;
    _passwordTF.layer.borderWidth = 0.5;
    _passwordTF.layer.borderColor = kColorGray.CGColor;
    _passwordTF.layer.cornerRadius = 5.0;
    _passwordTF.placeholder = @"密码";
    _passwordTF.text = @"123123123";
    [self.view addSubview:_passwordTF];
    index++;
    
    UIButton *loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(kDefaultMargin*2, kDefaultMargin*(index+2) + tfHeight*index, screenW-(kDefaultMargin*4), tfHeight)];
    loginBtn.backgroundColor = kColorRed;
    loginBtn.layer.cornerRadius = 5.0;
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
    loginBtn.titleLabel.font = kAppMiddleTextFont;
    [loginBtn addTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    index++;
    
    UIButton *registBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenW - kDefaultMargin - 100, kDefaultMargin*(index+2) + tfHeight*index, 100, tfHeight)];
    registBtn.layer.cornerRadius = 5.0;
    [registBtn setTitle:@"注册新用户" forState:UIControlStateNormal];
    [registBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
    registBtn.titleLabel.font = kAppMiddleTextFont;
    [registBtn addTarget:self action:@selector(onRegist:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registBtn];
    index++;
    
    
}

- (void)addTapBlankToHideKeyboardGesture;
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBlankToHideKeyboard:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
}

- (void)onTapBlankToHideKeyboard:(UITapGestureRecognizer *)ges
{
    [_userNameTF resignFirstResponder];
    [_passwordTF resignFirstResponder];
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


- (void)onLogin:(UIButton *)button
{
    if (!_userNameTF || _userNameTF.text.length < 1)
    {
        [self showAlert:@"提示" message:@"用户名无效" okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        return;
    }
    if (!_passwordTF || _passwordTF.text.length < 1)
    {
        [self showAlert:@"提示" message:@"密码无效" okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        return;
    }
    
    LoadView *loginWaitView = [LoadView loadViewWith:@"正在登录"];
    [self.view addSubview:loginWaitView];
    
    __weak LoginViewController *ws = self;
//    [[ILiveLoginManager getInstance] iLiveLogin:_userNameTF.text sig:@"123" succ:^{
//                NSLog(@"tillivesdkshow login succ");
//        
//                [loginWaitView removeFromSuperview];
//        
//                [ws enterMainUI];
//    } failed:^(NSString *module, int errId, NSString *errMsg) {
//                NSString *errInfo = [NSString stringWithFormat:@"module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
//                NSLog(@"login fail.%@",errInfo);
//                [loginWaitView removeFromSuperview];
//                [ws showAlert:@"登录失败" message:errInfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
//    }];
    [[ILiveLoginManager getInstance] tlsLogin:_userNameTF.text pwd:_passwordTF.text succ:^{
        NSLog(@"tillivesdkshow login succ");
        
        [loginWaitView removeFromSuperview];
        
        [ws enterMainUI];
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        //errId=6208:离线被踢，此时再次登录即可
        NSString *errInfo = [NSString stringWithFormat:@"module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
        NSLog(@"login fail.%@",errInfo);
        [loginWaitView removeFromSuperview];
        [ws showAlert:@"登录失败" message:errInfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
    }];
}

- (void)onRegist:(UIButton *)button
{
    RegistViewController *registVC = [[RegistViewController alloc] init];
    [self.navigationController pushViewController:registVC animated:YES];
}

- (void)enterMainUI
{   
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    TabbarController *tabController = [[TabbarController alloc] init];
    appDelegate.window.rootViewController = tabController;
}
@end
