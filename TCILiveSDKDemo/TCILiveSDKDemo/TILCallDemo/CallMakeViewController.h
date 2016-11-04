//
//  CallMakeViewController.h
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/11/2.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallMakeViewController : UIViewController
@property (strong, nonatomic) NSString *peerId;
@property (weak, nonatomic) IBOutlet UILabel *errLabel;
- (IBAction)closeCamera:(id)sender;
- (IBAction)switchCamera:(id)sender;
- (IBAction)closeMic:(id)sender;
- (IBAction)switchReceiver:(id)sender;
- (IBAction)setBeauty:(id)sender;
- (IBAction)hangUp:(id)sender;
- (IBAction)cancelInvite:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *hungUpButton;
@property (weak, nonatomic) IBOutlet UIButton *closeCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *swichCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *closeMicButton;
@property (weak, nonatomic) IBOutlet UIButton *switchReceiverButton;
@property (weak, nonatomic) IBOutlet UIButton *setBeautyButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelInviteButton;
@end
