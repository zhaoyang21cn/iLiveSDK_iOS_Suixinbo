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
//@property (nonatomic, strong) UITextField *checkPasswordTF;

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
    _userNameTF.placeholder = @"用户名4～24个字符,不能为纯数字";
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
    
//    _checkPasswordTF = [[UITextField alloc] initWithFrame:CGRectMake(kDefaultMargin*2, kDefaultMargin*(index+2) + tfHeight*index, screenW-(kDefaultMargin*4), tfHeight)];
//    _checkPasswordTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDefaultMargin, kDefaultMargin)];
//    _checkPasswordTF.leftViewMode = UITextFieldViewModeAlways;
//    _checkPasswordTF.backgroundColor = kColorWhite;
//    _checkPasswordTF.layer.borderWidth = 0.5;
//    _checkPasswordTF.layer.borderColor = kColorGray.CGColor;
//    _checkPasswordTF.layer.cornerRadius = 5.0;
//    _checkPasswordTF.placeholder = @"确认密码";
//    [self.view addSubview:_checkPasswordTF];
//    index++;
    
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
//    [_checkPasswordTF resignFirstResponder];
}

//用户名为4～24个字符，不能为纯数字
- (BOOL)invalidAccount:(NSString *)account
{
    if (account.length < 4 || account.length > 24)
    {
        return YES;
    }
    
    NSString *inputString = [account stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if (inputString.length <= 0) {//是纯数字
        return YES;
    }
    else{
        return NO;
    }
}

//密码长度为8～16个字符
- (BOOL)invalidPwd:(NSString *)pwd
{
    if (pwd.length < 8 || pwd.length > 16)
    {
        return YES;
    }
    return NO;
}

- (void)onRegist:(UIButton *)button
{
    if (!_userNameTF || _userNameTF.text.length < 1)
    {
        [AlertHelp alertWith:nil message:@"请输入用户名" cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        return;
    }
    if (!_passwordTF || _passwordTF.text.length < 1)
    {
        [AlertHelp alertWith:nil message:@"请输入密码" cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        return;
    }
//    if (!_checkPasswordTF || _checkPasswordTF.text.length < 1 || ![_passwordTF.text isEqualToString:_checkPasswordTF.text])
//    {
//        [AlertHelp alertWith:@"提示" message:@"重设密码无效" cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
//        return;
//    }
    
    if ([self invalidAccount:_userNameTF.text])
    {
        [AlertHelp alertWith:nil message:@"输入用户名格式不对" cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        return;
    }
    if ([self invalidPwd:_passwordTF.text])
    {
        [AlertHelp alertWith:nil message:@"输入密码格式不对" cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        return;
    }
    
    LoadView *regWaitView = [LoadView loadViewWith:@"正在注册"];
    [self.view addSubview:regWaitView];
    
    __weak typeof(self) ws = self;
    //向业务后台注册
    RegistRequest *registReq = [[RegistRequest alloc] initWithHandler:^(BaseRequest *request) {
        [regWaitView removeFromSuperview];
        AlertActionHandle okBlock = ^(UIAlertAction * _Nonnull action){
            [ws.navigationController popViewControllerAnimated:YES];
            [ws.delegate showRegistUserIdentifier:ws.userNameTF.text];
            [ws.delegate showRegistUserPwd:ws.passwordTF.text];
        };
        [AlertHelp alertWith:@"注册成功" message:nil funBtns:@{@"确定":okBlock} cancelBtn:nil alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
    } failHandler:^(BaseRequest *request) {
        [regWaitView removeFromSuperview];
        NSString *errinfo = [NSString stringWithFormat:@"errid=%ld,errmsg=%@",(long)request.response.errorCode,request.response.errorInfo];
        NSLog(@"regist fail.%@",errinfo);
        [AlertHelp alertWith:@"注册失败" message:errinfo cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
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
