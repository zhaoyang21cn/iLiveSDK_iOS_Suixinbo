//
//  CallRecvViewController.h
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/11/2.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallRecvViewController : UIViewController
@property (strong, nonatomic) NSString *peerId;
@property (weak, nonatomic) IBOutlet UILabel *errLabel;
@property (strong, nonatomic) TILC2CCallInvitation *invite;
- (IBAction)closeCamera:(id)sender;
- (IBAction)switchCamera:(id)sender;
- (IBAction)closeMic:(id)sender;
- (IBAction)switchReceiver:(id)sender;
- (IBAction)setBeauty:(id)sender;
- (IBAction)recvInvite:(id)sender;
- (IBAction)rejectInvite:(id)sender;
- (IBAction)hangUp:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;
@property (weak, nonatomic) IBOutlet UIButton *closeCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *closeMicButton;
@property (weak, nonatomic) IBOutlet UIButton *switchReceiverButton;
@property (weak, nonatomic) IBOutlet UIButton *setBeautyButton;
@property (weak, nonatomic) IBOutlet UIButton *hangUpButton;
@property (weak, nonatomic) IBOutlet UIButton *recvInviteButton;
@end
