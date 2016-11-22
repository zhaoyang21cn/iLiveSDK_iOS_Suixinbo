//
//  CallRegisterViewController.h
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallRegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UILabel *errLabel;

- (IBAction)userRegister:(id)sender;
@end
