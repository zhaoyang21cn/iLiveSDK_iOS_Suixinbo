//
//  LiveMainViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "LiveMainViewController.h"
#import "LiveLiveViewController.h"
#import "LiveJoinViewController.h"



@interface LiveMainViewController () <UITextFieldDelegate>
@end

@implementation LiveMainViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
    self.userLabel.text = [[ILiveLoginManager getInstance] getLoginId];
}

//登出
- (IBAction)logout:(id)sender {
    __weak typeof(self) ws = self;
    [[ILiveLoginManager getInstance] tlsLogout:^{
        [ws.navigationController popViewControllerAnimated:YES];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        [ws.navigationController popViewControllerAnimated:YES];
    }];
}

//创建直播
- (IBAction)createLive:(id)sender {
    LiveLiveViewController *live = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveLiveViewController"];
    live.roomId = [self.roomTextField.text intValue];
    live.host = self.hostTextField.text;
    if(live.roomId == 0 || live.host.length <= 0){
        return;
    }
    [self presentViewController:live animated:YES completion:nil];
}

//加入直播
- (IBAction)joinLive:(id)sender {
    LiveJoinViewController *join = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveJoinViewController"];
    join.roomId = [self.roomTextField.text intValue];
    join.host = self.hostTextField.text;
    if(join.roomId == 0 || join.host.length <= 0){
        return;
    }
    [self presentViewController:join animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
