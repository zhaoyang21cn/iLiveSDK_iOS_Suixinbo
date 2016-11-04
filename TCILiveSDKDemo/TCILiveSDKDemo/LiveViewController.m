//
//  LiveViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "LiveViewController.h"
#import "TILLiveManager.h"
#import "TILLiveConfig.h"
#import "ILiveRoomOption.h"
#import "ILiveLoginManager.h"
#import "ILiveRenderView.h"
#import "ILiveSDK.h"
#import "TILLiveConfig.h"

#import "TILLiveCommon.h"

@interface LiveViewController ()<ILVLiveIMListener,ILVLiveAVListener,UITextFieldDelegate>
@property (nonatomic, assign) NSInteger count;
@end
@implementation LiveViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self createLive];
}

//创建直播
- (void)createLive{
    ILiveRoomOption *option = [ILiveRoomOption defaultHostLiveOption];
    TILLiveManager *manager = [TILLiveManager getInstance];
    [manager setAVListener:self];
    [manager setIMListener:self];
    [manager setAVRootView:self.view];
    [manager addAVRenderView:self.view.bounds forKey:self.host];
    
    __weak typeof(self) ws = self;
    [manager createRoom:self.roomId option:option succ:^{
        ws.errLabel.text = @"创建房间成功";
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",moudle,errId,errMsg];
    }];
}

//退出直播
- (IBAction)exitLive:(id)sender {
    TILLiveManager *manager = [TILLiveManager getInstance];
    __weak typeof(self) ws = self;
    [manager quitRoom:^{
        ws.errLabel.text = @"退出房间成功";
        [ws dismissViewControllerAnimated:YES completion:nil];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moldleID=%@;errid=%d;errmsg=%@",moudle,errId,errMsg];
        [ws dismissViewControllerAnimated:YES completion:nil];
    }];
}

//直播事件
- (void)onUserUpdateInfo:(ILVLiveAVEvent)event users:(NSArray *)users{
    TILLiveManager *manager = [TILLiveManager getInstance];
    switch(event) {
        case ILVLIVE_AVEVENT_CAMERA_ON:
        {
            //视频事件
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

//收到文本消息
- (void)onTextMessage:(ILVLiveTextMessage *)msg{
    [self addTextToView:msg.text];
}

//收到自定义消息
- (void)onCustomMessage:(ILVLiveCustomMessage *)msg{
    switch (msg.cmd) {
        case ILVLIVE_IMCMD_INTERACT_REJECT:
            self.errLabel.text = [NSString stringWithFormat:@"%@拒绝了你的上麦邀请",msg.sendId];
            break;
        case ILVLIVE_IMCMD_LEAVE:
        {
            NSString *text = [NSString stringWithFormat:@"%@退出房间",msg.sendId];
            [self addTextToView:text];
            break;
        }
        case ILVLIVE_IMCMD_ENTER:
        {
            NSString *text = [NSString stringWithFormat:@"%@进入房间",msg.sendId];
            [self addTextToView:text];
            break;
        }
        case ILVLIVE_IMCMD_CUSTOM_LOW_LIMIT:
        {
            //用户自定义消息
            NSString *text = [NSString stringWithFormat:@"cmd=%ld,data=%@",(long)msg.cmd,[[NSString alloc] initWithData:msg.data encoding:NSUTF8StringEncoding]];
            [self addTextToView:text];
            break;
        }
        default:
            break;
    }
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
            NSString *text = [NSString stringWithFormat:@"cmd=%ld,data=%@",(long)msg.cmd,sendStr];
            [ws addTextToView:text];
        } failed:^(NSString *moudle, int errId, NSString *errMsg) {
            ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
        }];
    }
    else{
        //发送文本消息
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

//邀请上麦
- (IBAction)inviteToVideo:(id)sender {
    TILLiveManager *manager = [TILLiveManager getInstance];
    NSString *recvId = self.upVideoTextField.text;
    if(recvId.length <= 0){
        return;
    }
    
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_INVITE;
    msg.recvId = recvId;
    msg.type = ILVLIVE_IMTYPE_C2C;
    
    __weak typeof(self) ws = self;
    [manager sendCustomMessage:msg succ:^{
        ws.errLabel.text = [NSString stringWithFormat:@"给%@发送上麦邀请",recvId];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
    }];
}

//取消邀请
- (IBAction)cancelInvite:(id)sender {
    TILLiveManager *manager = [TILLiveManager getInstance];
    NSString *recvId = self.cancelVideoTextField.text;
    if(recvId.length <= 0){
        return;
    }
    
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_INVITE_CANCEL;
    msg.recvId = recvId;
    msg.type = ILVLIVE_IMTYPE_C2C;
    
    __weak typeof(self) ws = self;
    [manager sendCustomMessage:msg succ:^{
        ws.errLabel.text = [NSString stringWithFormat:@"取消对%@的上麦邀请",recvId];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
    }];
}

//取消观众的上麦
- (IBAction)cancelToVideo:(id)sender {
    TILLiveManager *manager = [TILLiveManager getInstance];
    NSString *recvId = self.downVideoTextField.text;
    if(recvId.length <= 0){
        return;
    }
    
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_INVITE_CLOSE;
    msg.recvId = recvId;
    msg.type = ILVLIVE_IMTYPE_C2C;
    
    __weak typeof(self) ws = self;
    [manager sendCustomMessage:msg succ:^{
        ws.errLabel.text = [NSString stringWithFormat:@"取消%@上麦",recvId];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        ws.errLabel.text = [NSString stringWithFormat:@"moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg];
    }];
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
