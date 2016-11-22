//
//  UserViewController.h
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITextField *roomTextField;
@property (weak, nonatomic) IBOutlet UITextField *hostTextField;
@property (weak, nonatomic) IBOutlet UILabel *errLabel;

- (IBAction)createLive:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)joinLive:(id)sender;
@end
