//
//  CallMainViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/11/2.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "CallMainViewController.h"
#import "CallMakeViewController.h"
#import "CallIncomingListener.h"

@interface CallMainViewController () <UITextFieldDelegate>
@end

@implementation CallMainViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.userLabel.text = [[ILiveLoginManager getInstance] getLoginId];
    [[TILCallManager sharedInstance] setIncomingCallListener:[[CallIncomingListener alloc] init]];
}

- (IBAction)makeCall:(id)sender {
    NSString *peerId = self.peerTextField.text;
    if(peerId.length <= 0){
        return;
    }
    CallMakeViewController *make = [self.storyboard instantiateViewControllerWithIdentifier:@"CallMakeViewController"];
    make.peerId = self.peerTextField.text;
    [self presentViewController:make animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
