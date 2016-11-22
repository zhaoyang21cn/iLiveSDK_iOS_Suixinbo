//
//  CallLoginViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "CallLoginViewController.h"
#import "CallRegisterViewController.h"

//独立模式
//#define CallSDKAppID 1400016949
//#define CallAccountType 8002

@implementation CallLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getUserDefault];
}
- (IBAction)login:(id)sender {
    [self tlsLogin];
}

//托管模式登录
- (void)tlsLogin{
    __weak typeof(self) ws = self;
    NSString *name = self.nameTextField.text;
    NSString *pwd = self.passTextField.text;
    [[ILiveLoginManager getInstance] tlsLogin:name pwd:pwd succ:^{
        [ws setUserDefault];
        [ws performSegueWithIdentifier:@"toCallUser" sender:nil];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",moudle,errId,errMsg];
    }];
}

//独立模式登录
- (void)iLiveLogin{
    NSString *name = self.nameTextField.text;
    NSString *pwd = self.passTextField.text;
    NSString *urlStr = [NSString stringWithFormat:@"http://182.254.234.225:8085/login?account=%@&password=%@",name,pwd];
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(session) wsession = session;
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [wsession invalidateAndCancel];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(error || httpResponse.statusCode != 200 || data == nil){
            //请求sig出错
        }
        //请求sig成功
        NSString *sig = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [[ILiveLoginManager getInstance] iLiveLogin:name sig:sig succ:^{
            //独立模式登录成功
        } failed:^(NSString *moudle, int errId, NSString *errMsg) {
            //独立模式登录失败
        }];
    }];
    [task resume];
}

- (IBAction)registe:(id)sender {
    [self performSegueWithIdentifier:@"toCallRegister" sender:nil];
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
