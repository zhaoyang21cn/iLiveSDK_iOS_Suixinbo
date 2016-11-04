//
//  RegisterViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "RegisterViewController.h"

@implementation RegisterViewController

- (IBAction)userRegister:(id)sender {
    ILiveLoginManager *manager = [ILiveLoginManager getInstance];
    NSString *name = self.nameTextField.text;
    NSString *pwd = self.passTextField.text;
    
    __weak typeof(self) ws = self;
    [manager tlsRegister:name pwd:pwd succ:^{
        ws.errLabel.text = @"注册成功";
        [ws.navigationController popViewControllerAnimated:YES];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",moudle,errId,errMsg];
    }];
}
@end
