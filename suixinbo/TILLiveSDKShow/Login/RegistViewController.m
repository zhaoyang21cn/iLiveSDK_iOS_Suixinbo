//
//  RegistViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "RegistViewController.h"

@interface RegistViewController ()

@property (nonatomic, strong) UITextField *userNameTF;
@property (nonatomic, strong) UITextField *passwordTF;
@property (nonatomic, strong) UITextField *checkPasswordTF;

@end

@implementation RegistViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"用户名注册";
    self.view.backgroundColor = kColorLightGray;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addTapBlankToHideKeyboardGesture];
    
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
    _userNameTF.placeholder = @"用户名为小写字母、数字、下划线";
    [self.view addSubview:_userNameTF];
    index++;
    
    _passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(kDefaultMargin*2, kDefaultMargin*(index+2) + tfHeight*index, screenW-(kDefaultMargin*4), tfHeight)];
    _passwordTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDefaultMargin, kDefaultMargin)];
    _passwordTF.leftViewMode = UITextFieldViewModeAlways;
    _passwordTF.backgroundColor = kColorWhite;
    _passwordTF.layer.borderWidth = 0.5;
    _passwordTF.layer.borderColor = kColorGray.CGColor;
    _passwordTF.layer.cornerRadius = 5.0;
    _passwordTF.placeholder = @"用户密码为8-16个字符";
    [self.view addSubview:_passwordTF];
    index++;
    
    _checkPasswordTF = [[UITextField alloc] initWithFrame:CGRectMake(kDefaultMargin*2, kDefaultMargin*(index+2) + tfHeight*index, screenW-(kDefaultMargin*4), tfHeight)];
    _checkPasswordTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDefaultMargin, kDefaultMargin)];
    _checkPasswordTF.leftViewMode = UITextFieldViewModeAlways;
    _checkPasswordTF.backgroundColor = kColorWhite;
    _checkPasswordTF.layer.borderWidth = 0.5;
    _checkPasswordTF.layer.borderColor = kColorGray.CGColor;
    _checkPasswordTF.layer.cornerRadius = 5.0;
    _checkPasswordTF.placeholder = @"确认密码";
    [self.view addSubview:_checkPasswordTF];
    index++;
    
    UIButton *registBtn = [[UIButton alloc] initWithFrame:CGRectMake(kDefaultMargin*2, kDefaultMargin*(index+2) + tfHeight*index, screenW-(kDefaultMargin*4), tfHeight)];
    registBtn.backgroundColor = kColorRed;
    registBtn.layer.cornerRadius = 5.0;
    [registBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
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
    [_checkPasswordTF resignFirstResponder];
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

- (void)onRegist:(UIButton *)button
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
    if (!_checkPasswordTF || _checkPasswordTF.text.length < 1 || ![_passwordTF.text isEqualToString:_checkPasswordTF.text])
    {
        [self showAlert:@"提示" message:@"重设密码无效" okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        return;
    }

    LoadView *regWaitView = [LoadView loadViewWith:@"正在注册"];
    [self.view addSubview:regWaitView];
    
    __weak typeof(self) ws = self;
    //向业务后台注册
    RegistRequest *registReq = [[RegistRequest alloc] initWithHandler:^(BaseRequest *request) {
        [regWaitView removeFromSuperview];
        [ws showAlert:@"注册成功" message:nil okTitle:@"确定" cancelTitle:nil ok:^(UIAlertAction * _Nonnull action) {
            [ws.navigationController popViewControllerAnimated:YES];
            [ws.delegate showRegistUserIdentifier:ws.userNameTF.text];
            [ws.delegate showRegistUserPwd:ws.passwordTF.text];
        } cancel:nil];
    } failHandler:^(BaseRequest *request) {
        [regWaitView removeFromSuperview];
        NSString *errinfo = [NSString stringWithFormat:@"errid=%ld,errmsg=%@",(long)request.response.errorCode,request.response.errorInfo];
        NSLog(@"regist fail.%@",errinfo);
        [ws showAlert:@"注册失败" message:errinfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
    }];
    registReq.identifier = _userNameTF.text;
    registReq.pwd = _passwordTF.text;
    [[WebServiceEngine sharedEngine] asyncRequest:registReq];
    
//托管模式注册
//    [[ILiveLoginManager getInstance] tlsRegister:_userNameTF.text pwd:_passwordTF.text succ:^{
//        NSLog(@"tillivesdkshow regist succ");
//        
//        [regWaitView removeFromSuperview];
//        
//        [ws showAlert:@"注册成功" message:nil okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
//        
//    } failed:^(NSString *module, int errId, NSString *errMsg) {
//        
//        [regWaitView removeFromSuperview];
//        
//        NSString *errinfo = [NSString stringWithFormat:@"module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
//        NSLog(@"regist fail.%@",errinfo);
//        
//        [ws showAlert:@"注册失败" message:errinfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
//    }];
}


@end
