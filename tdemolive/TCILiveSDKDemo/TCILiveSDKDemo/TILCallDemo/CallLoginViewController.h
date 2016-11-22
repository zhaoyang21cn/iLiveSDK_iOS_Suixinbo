//
//  CallLoginViewController.h
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
- (IBAction)login:(id)sender;
- (IBAction)registe:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *errLabel;

@end
