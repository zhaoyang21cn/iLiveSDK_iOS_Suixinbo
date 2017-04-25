//
//  LiveJoinViewController.h
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/27.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveJoinViewController : UIViewController
@property (nonatomic, assign) int roomId;
@property (nonatomic, strong) NSString *host;
@property (weak, nonatomic) IBOutlet UITextField *textTextField;
@property (weak, nonatomic) IBOutlet UITextView *msgTextView;
@property (weak, nonatomic) IBOutlet UIButton *upToVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *downToVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectToVideoButton;
- (IBAction)switchCamera:(id)sender;

- (IBAction)exitLive:(id)sender;
- (IBAction)upToVideo:(id)sender;
- (IBAction)downToVideo:(id)sender;
- (IBAction)sendMsg:(id)sender;
- (IBAction)rejectToVideo:(id)sender;
@end
