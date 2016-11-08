//
//  CallRegisterViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "CallRegisterViewController.h"

@implementation CallRegisterViewController

- (IBAction)userRegister:(id)sender {
    [self tlsRegister];
}

//托管模式注册
- (void)tlsRegister{
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

//独立模式注册
- (void)iLiveRegister{
    NSString *name = self.nameTextField.text;
    NSString *pwd = self.passTextField.text;
    NSString *urlStr = [NSString stringWithFormat:@"http://182.254.234.225:8085/regist?account=%@&password=%@",name,pwd];
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(session) wsession = session;
    __weak typeof(self) ws = self;
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [wsession invalidateAndCancel];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(error || httpResponse.statusCode != 200 || data == nil){
            //注册失败
        }
        //注册成功
    }];
    [task resume];
}
@end
