//
//  CallRecvViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/11/2.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "CallRecvViewController.h"

@interface CallRecvViewController () <TILCallNotificationListener,TILC2CCallStatusListener>
@property (nonatomic, strong) TILC2CCall *call;
@end

@implementation CallRecvViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.errLabel.text = [NSString stringWithFormat:@"收到%@的视频邀请",self.peerId];
    [self setButtonEnable:NO];
    [self initCall];
}

- (void)initCall{
    TILC2CCallConfig * c2cConfig = [[TILC2CCallConfig alloc] init];
    c2cConfig.callType = TILCALL_TYPE_VIDEO;
    c2cConfig.isSponsor = NO;
    c2cConfig.peerId = self.peerId;
    c2cConfig.heartBeatInterval = 3;
    c2cConfig.callStatusListener = self;
    TILC2CResponderConfig * responderConfig = [[TILC2CResponderConfig alloc] init];
    responderConfig.callInvitation = self.invite;
    c2cConfig.responderConfig = responderConfig;
    self.call = [[TILC2CCall alloc] initWithConfig:c2cConfig];
}
- (void)recvCall{
    __weak typeof(self) ws = self;
    [self.call accept:^(TILCallError *err) {
        if(err){
            ws.errLabel.text = [NSString stringWithFormat:@"code:%d,msg=%@",err.code,err.errMsg];
            [ws dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            ws.errLabel.text = [NSString stringWithFormat:@"通话建立成功"];
            CGRect frame = CGRectMake(20, 20, 120, 160);
            
            [ws.call addRenderFor:ws.peerId atFrame:ws.view.bounds];
            NSString *myId = [[ILiveLoginManager getInstance] getLoginId];
            [ws.call addRenderFor:myId atFrame:frame];
            
            [self setButtonEnable:YES];
        }
    }];
    UIView *baseView = [self.call createRenderViewIn:self.view];
    [self.view sendSubviewToBack:baseView];
}

#pragma mark 设备操作（可使用ILiveRoomManager或TILC2CCall接口）
- (IBAction)closeCamera:(id)sender {
    ILiveRoomManager *manager = [ILiveRoomManager getInstance];
    BOOL isOn = [manager getCurCameraState];
    cameraPos pos = [manager getCurCameraPos];
    __weak typeof(self) ws = self;
    [manager enableCamera:pos enable:!isOn succ:^{
        ws.errLabel.text = !isOn?@"打开摄像头成功":@"关闭摄像头成功";
        [ws.closeCameraButton setTitle:(!isOn?@"关闭摄像头":@"打开摄像头") forState:UIControlStateNormal];
    }failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
    }];
}

- (IBAction)switchCamera:(id)sender {
    ILiveRoomManager *manager = [ILiveRoomManager getInstance];
    cameraPos pos = [manager getCurCameraPos];
    __weak typeof(self) ws = self;
    [manager switchCamera:!pos succ:^{
        ws.errLabel.text = @"切换摄像头成功";
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
    }];
}

- (IBAction)closeMic:(id)sender {
    ILiveRoomManager *manager = [ILiveRoomManager getInstance];
    BOOL isOn = [manager getCurMicState];
    __weak typeof(self) ws = self;
    [manager enableMic:!isOn succ:^{
        ws.errLabel.text = !isOn?@"打开麦克风成功":@"关闭麦克风成功";
        [ws.closeMicButton setTitle:(!isOn?@"关闭麦克风":@"打开麦克风") forState:UIControlStateNormal];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
    }];
}

- (IBAction)switchReceiver:(id)sender {
    ILiveRoomManager *manager = [ILiveRoomManager getInstance];
    BOOL isOn = [manager getCurSpeakerState];
    __weak typeof(self) ws = self;
    [manager enableSpeaker:!isOn succ:^{
        ws.errLabel.text = !isOn?@"打开扬声器成功":@"切换到听筒成功";
        [ws.switchReceiverButton setTitle:(!isOn?@"切换到听筒":@"打开扬声器") forState:UIControlStateNormal];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
    }];
}

- (IBAction)setBeauty:(id)sender {
    self.errLabel.text = @"美颜功能暂时不支持";
}

- (IBAction)recvInvite:(id)sender {
    [self recvCall];
}

- (IBAction)rejectInvite:(id)sender {
    __weak typeof(self) ws = self;
    [self.call refuse:^(TILCallError *err) {
        [ws dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)hangUp:(id)sender {
    __weak typeof(self) ws = self;
    [self.call hangup:^(TILCallError *err) {
        [ws dismissViewControllerAnimated:YES completion:nil];
    }];
}

//设置按钮是否可用
- (void)setButtonEnable:(BOOL)isAccept{
    self.closeCameraButton.enabled = isAccept;
    self.switchCameraButton.enabled = isAccept;
    self.closeMicButton.enabled = isAccept;
    self.switchReceiverButton.enabled = isAccept;
    self.setBeautyButton.enabled = isAccept;
    self.hangUpButton.enabled = isAccept;
    self.recvInviteButton.enabled = !isAccept;
    self.rejectButton.enabled = !isAccept;
}
//消息事件
- (void)onCallEstablish{
}

- (void)onCallEnd:(TILC2CCallEndCode)code
{
    switch (code) {
        case TILC2C_CALL_END_SPONSOR_CANCEL:
            self.errLabel.text = @"对方已取消通话";
            break;
        case TILC2C_CALL_END_SPONSOR_TIMEOUT:
            self.errLabel.text = @"对方已结束通话";
            break;
        case TILC2C_CALL_END_PEER_HANGUP:
            self.errLabel.text = @"对方已挂断";
            break;
        default:
            break;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
