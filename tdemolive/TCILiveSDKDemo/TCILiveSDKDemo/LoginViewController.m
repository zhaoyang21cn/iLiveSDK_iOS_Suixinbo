//
//  LoginViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getUserDefault];
}
- (IBAction)login:(id)sender {
    NSString *name = self.nameTextField.text;
    NSString *pwd = self.passTextField.text;
    
    __weak typeof(self) ws = self;
//    [[ILiveLoginManager getInstance] iLiveLogin:name sig:name succ:^{
//        [ws setUserDefault];
//        ws.errLabel.text = @"登录成功";
//        [ws performSegueWithIdentifier:@"toDemo" sender:nil];
//    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
//        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",moudle,errId,errMsg];
//    }];
    [[ILiveLoginManager getInstance] tlsLogin:name pwd:pwd succ:^{
        [ws setUserDefault];
        [ws performSegueWithIdentifier:@"toDemo" sender:nil];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",moudle,errId,errMsg];
    }];
}
- (IBAction)registe:(id)sender {
    [self performSegueWithIdentifier:@"toRegister" sender:nil];
}

- (void)getUserDefault{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *name = [userDefaults objectForKey:@"name"];
    NSString *pwd = [userDefaults objectForKey:@"pwd"];
    self.nameTextField.text = name;
    self.passTextField.text = pwd;
}

- (void)setUserDefault{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *name = self.nameTextField.text;
    NSString *pwd = self.passTextField.text;
    [userDefaults setObject:name forKey:@"name"];
    [userDefaults setObject:pwd forKey:@"pwd"];
    [userDefaults synchronize];
}
@end
