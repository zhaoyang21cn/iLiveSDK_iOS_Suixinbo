//
//  UserViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "UserViewController.h"
#import "ILiveLoginManager.h"
#import "LiveViewController.h"
#import "JoinViewController.h"

@interface UserViewController () <UITextFieldDelegate>
@end

@implementation UserViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    self.userLabel.text = [[ILiveLoginManager getInstance] getLoginId];
}

//登出
- (IBAction)logout:(id)sender {
    __weak typeof(self) ws = self;
    [[ILiveLoginManager getInstance] iLiveLogout:^{
        ws.errLabel.text = @"注销成功";
        [ws.navigationController popViewControllerAnimated:YES];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",moudle,errId,errMsg];
    }];
}

//创建直播
- (IBAction)createLive:(id)sender {
    LiveViewController *live = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveViewController"];
    live.roomId = [self.roomTextField.text intValue];
    live.host = self.hostTextField.text;
    if(live.roomId == 0 || live.host.length <= 0){
        return;
    }
    [self presentViewController:live animated:YES completion:nil];
}

//加入直播
- (IBAction)joinLive:(id)sender {
    JoinViewController *live = [self.storyboard instantiateViewControllerWithIdentifier:@"JoinViewController"];
    live.roomId = [self.roomTextField.text intValue];
    live.host = self.hostTextField.text;
    if(live.roomId == 0 || live.host.length <= 0){
        return;
    }
    [self presentViewController:live animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
