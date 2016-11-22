//
//  CallMainViewController.h
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/11/2.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallMainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITextField *peerTextField;
@property (weak, nonatomic) IBOutlet UILabel *errLabel;
- (IBAction)makeCall:(id)sender;
- (IBAction)logout:(id)sender;

@end
