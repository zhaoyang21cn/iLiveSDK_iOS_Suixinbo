//
//  LiveLoginViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "LiveLoginViewController.h"
#import "LiveRegisterViewController.h"

@implementation LiveLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getUserDefault];    
}
- (IBAction)login:(id)sender {
    NSString *name = self.nameTextField.text;
    NSString *pwd = self.passTextField.text;
    
//    __weak typeof(self) ws = self;
//    [[ILiveLoginManager getInstance] iLiveLogin:name sig:name succ:^{
//        [ws setUserDefault];
//        [ws performSegueWithIdentifier:@"toLiveUser" sender:nil];
//    } failed:^(NSString *module, int errId, NSString *errMsg) {
//        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",module,errId,errMsg];
//    }];
    
    __weak typeof(self) ws = self;
    [[ILiveLoginManager getInstance] tlsLogin:name pwd:pwd succ:^{
        
        [ws setUserDefault];
        [ws performSegueWithIdentifier:@"toLiveUser" sender:nil];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",moudle,errId,errMsg];
    }];
}
- (IBAction)registe:(id)sender {
    [self performSegueWithIdentifier:@"toLiveRegister" sender:nil];
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
