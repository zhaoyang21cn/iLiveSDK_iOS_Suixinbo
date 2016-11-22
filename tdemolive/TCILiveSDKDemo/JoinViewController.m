//
//  JoinViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/27.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "JoinViewController.h"
#import "TILLiveManager.h"
#import "ILiveLoginManager.h"
#import "TILLiveConfig.h"

@interface JoinViewController ()<ILVLiveAVListener,ILVLiveIMListener,UITextFieldDelegate>
@property (nonatomic, assign) NSInteger count;
@end
@implementation JoinViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.downToVideoButton.enabled = NO;
    self.upToVideoButton.enabled = NO;
    self.rejectToVideoButton.enabled = NO;
    [self joinLive];
}

//加入直播
- (void)joinLive{
    ILiveRoomOption *option = [ILiveRoomOption defaultGuestLiveOption];
    TILLiveManager *manager = [TILLiveManager getInstance];
    [manager setAVListener:self];
    [manager setIMListener:self];
    [manager setAVRootView:self.view];
    [manager addAVRenderView:self.view.bounds forKey:self.host];
    
    __weak typeof(self) ws = self;
    [manager joinRoom:self.roomId option:option succ:^{
        ws.errLabel.text = @"进入房间成功";
        //进群消息
        ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
        msg.cmd = ILVLIVE_IMCMD_ENTER;
        msg.type = ILVLIVE_IMTYPE_GROUP;
        [manager sendCustomMessage:msg succ:^{
        } failed:^(NSString *moudle, int errId, NSString *errMsg) {
            ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
        }];
        
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",moudle,errId,errMsg];
    }];
}

//退出房间
- (IBAction)exitLive:(id)sender {
    //退群消息
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_LEAVE;
    msg.type = ILVLIVE_IMTYPE_GROUP;
    TILLiveManager *manager = [TILLiveManager getInstance];
    __weak typeof(self) ws = self;
    [manager sendCustomMessage:msg succ:^{
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
    }];
    //退出房间
    [manager quitRoom:^{
        ws.errLabel.text = @"退出房间成功";
        [ws dismissViewControllerAnimated:YES completion:nil];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",moudle,errId,errMsg];
        [ws dismissViewControllerAnimated:YES completion:nil];
    }];
}

//上麦
- (IBAction)upToVideo:(id)sender {
    __weak typeof(self) ws = self;
    [[TILLiveManager getInstance] upToVideoMember:ILVLIVEAUTH_INTERACT role:@"user" succ:^{
        ws.errLabel.text = @"上麦成功";
        ws.downToVideoButton.enabled = YES;
        ws.upToVideoButton.enabled = NO;
        ws.rejectToVideoButton.enabled = NO;
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",moudle,errId,errMsg];
    }];
}

//下麦
- (IBAction)downToVideo:(id)sender {
    __weak typeof(self) ws = self;
    [[TILLiveManager getInstance] downToVideoMember:ILVLIVEAUTH_GUEST role:@"user" succ:^{
        ws.errLabel.text = @"下麦成功";
        ws.downToVideoButton.enabled = NO;
        ws.upToVideoButton.enabled = NO;
        ws.rejectToVideoButton.enabled = NO;
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",moudle,errId,errMsg];
    }];
}

//拒绝上麦
- (IBAction)rejectToVideo:(id)sender {
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_INTERACT_REJECT;
    msg.recvId = self.host;
    msg.type = ILVLIVE_IMTYPE_C2C;
    __weak typeof(self) ws = self;
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        ws.errLabel.text = [NSString stringWithFormat:@"拒绝%@发送的上麦邀请",self.host];
        ws.downToVideoButton.enabled = NO;
        ws.upToVideoButton.enabled = NO;
        ws.rejectToVideoButton.enabled = NO;
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
    }];
}

//视频事件回调
- (void)onUserUpdateInfo:(ILVLiveAVEvent)event users:(NSArray *)users
{
    TILLiveManager *manager = [TILLiveManager getInstance];
    switch (event) {
        case ILVLIVE_AVEVENT_CAMERA_ON:
        {
            for (NSString *user in users) {
                if(![user isEqualToString:self.host]){
                    [manager addAVRenderView:[self getRenderFrame] forKey:user];
                    self.count ++;
                }
            }
        }
            break;
        case ILVLIVE_AVEVENT_CAMERA_OFF:
        {
            for (NSString *user in users) {
                [manager removeAVRenderView:user];
                self.count --;
            }
        }
            break;
        default:
            break;
    }
}

//收到自定义消息
- (void)onCustomMessage:(ILVLiveCustomMessage *)msg{
    switch (msg.cmd) {
        case ILVLIVE_IMCMD_INVITE:
        {
            self.errLabel.text = [NSString stringWithFormat:@"收到%@的上麦邀请",msg.sendId];
            self.downToVideoButton.enabled = NO;
            self.upToVideoButton.enabled = YES;
            self.rejectToVideoButton.enabled = YES;
            break;
        }
        case ILVLIVE_IMCMD_INVITE_CANCEL:
        {
            self.errLabel.text = [NSString stringWithFormat:@"%@取消上麦邀请",msg.sendId];
            self.downToVideoButton.enabled = NO;
            self.upToVideoButton.enabled = NO;
            self.rejectToVideoButton.enabled = NO;
            break;
        }
        case ILVLIVE_IMCMD_INVITE_CLOSE:
        {
            self.errLabel.text = [NSString stringWithFormat:@"%@关闭了你的上麦",msg.sendId];
            [self downToVideo:nil];
            break;
        }
        case ILVLIVE_IMCMD_LEAVE:
        {
            NSString *temp = [NSString stringWithFormat:@"%@退出房间",msg.sendId];
            [self addTextToView:temp];
            break;
        }
        case ILVLIVE_IMCMD_ENTER:
        {
            NSString *temp = [NSString stringWithFormat:@"%@进入房间",msg.sendId];
            [self addTextToView:temp];
            break;
        }
        case ILVLIVE_IMCMD_CUSTOM_LOW_LIMIT:
        {
            NSString *temp = [NSString stringWithFormat:@"cmd=%ld,data=%@",(long)msg.cmd,[[NSString alloc] initWithData:msg.data encoding:NSUTF8StringEncoding]];
            [self addTextToView:temp];
            break;
        }
        default:
            break;
    }
    
}

//收到文本消息
- (void)onTextMessage:(ILVLiveTextMessage *)msg{
    [self addTextToView:msg.text];
}

//发送消息
- (IBAction)sendMsg:(id)sender {
    TILLiveManager *manager = [TILLiveManager getInstance];
    NSString *text = self.textTextField.text;
    __weak typeof(self) ws = self;
    if(text.length <= 0){
        //为空，发送自定义测试消息
        NSString *sendStr = @"自定义测试消息";
        ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
        msg.type = ILVLIVE_IMTYPE_GROUP;
        msg.data = [sendStr dataUsingEncoding:NSUTF8StringEncoding];
        msg.cmd = ILVLIVE_IMCMD_CUSTOM_LOW_LIMIT;
        [manager sendCustomMessage:msg succ:^{
            NSString *temp = [NSString stringWithFormat:@"cmd=%ld,data=%@",(long)msg.cmd,sendStr];
            [ws addTextToView:temp];
        } failed:^(NSString *moudle, int errId, NSString *errMsg) {
            ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
        }];
    }
    else{
        ILVLiveTextMessage *msg = [[ILVLiveTextMessage alloc] init];
        msg.text = text;
        msg.type = ILVLIVE_IMTYPE_GROUP;
        [manager sendTextMessage:msg succ:^{
            [ws addTextToView:text];
        } failed:^(NSString *moudle, int errId, NSString *errMsg) {
            ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
        }];
    }
}

//添加消息到屏幕
- (void)addTextToView:(NSString *)newText{
    NSString *text = self.msgTextView.text;
    text = [text stringByAppendingString:@"\n"];
    text = [text stringByAppendingString:newText];
    self.msgTextView.text = text;
}

//获取渲染位置
- (CGRect)getRenderFrame{
    if(self.count == 3){
        return CGRectZero;
    }
    CGFloat height = (self.view.frame.size.height - 2*20 - 3 * 10)/3;
    CGFloat width = height*3/4;//宽高比3:4
    CGFloat y = 20 + (self.count * (height + 10));
    CGFloat x = 20;
    return CGRectMake(x, y, width, height);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
