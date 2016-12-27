//
//  LiveLiveViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/26.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "LiveLiveViewController.h"

@interface LiveLiveViewController ()<ILVLiveIMListener,ILVLiveAVListener,UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *identifierArray;
@property (nonatomic, strong) NSMutableArray *srcTypeArray;
@end


@implementation LiveLiveViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    _identifierArray = [[NSMutableArray alloc] init];
    _srcTypeArray = [[NSMutableArray alloc] init];
    
    [self createLive];
}

#pragma mark - TILLiveSDK相关接口
- (void)createLive{
    ILiveRoomOption *option = [ILiveRoomOption defaultHostLiveOption];
    TILLiveManager *manager = [TILLiveManager getInstance];
    [manager setAVListener:self];
    [manager setIMListener:self];
    [manager setAVRootView:self.view];
    
    __weak typeof(self) ws = self;
    [manager createRoom:_roomId option:option succ:^{
        [ws addTextToView:@"创建房间成功"];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        [ws addTextToView:[NSString stringWithFormat:@"创建房间失败,moldle=%@;errid=%d;errmsg=%@",moudle,errId,errMsg]];
    }];
}


- (IBAction)exitLive:(id)sender {
    TILLiveManager *manager = [TILLiveManager getInstance];
    __weak typeof(self) ws = self;
    [manager quitRoom:^{
        [ws addTextToView:@"退出房间成功"];
        [ws selfDismiss];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        [ws addTextToView:[NSString stringWithFormat:@"退出房间失败,moldle=%@;errid=%d;errmsg=%@",moudle,errId,errMsg]];
        [ws selfDismiss];
    }];
}


- (IBAction)sendMsg:(id)sender {
    TILLiveManager *manager = [TILLiveManager getInstance];
    NSString *text = _textTextField.text;
    __weak typeof(self) ws = self;
    if(text.length <= 0){
        //为空，发送自定义测试消息
        NSString *sendStr = @"自定义测试消息";
        ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
        msg.type = ILVLIVE_IMTYPE_GROUP;
        msg.data = [sendStr dataUsingEncoding:NSUTF8StringEncoding];
        msg.cmd = ILVLIVE_IMCMD_CUSTOM_LOW_LIMIT;
        [manager sendCustomMessage:msg succ:^{
            NSString *text = [NSString stringWithFormat:@"发送自定义消息成功,cmd=%ld,data=%@",(long)msg.cmd,sendStr];
            [ws addTextToView:text];
        } failed:^(NSString *moudle, int errId, NSString *errMsg) {
            [ws addTextToView:[NSString stringWithFormat:@"发送自定义消息失败,moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg]];
        }];
    }
    else{
        //发送文本消息
        ILVLiveTextMessage *msg = [[ILVLiveTextMessage alloc] init];
        msg.text = text;
        msg.type = ILVLIVE_IMTYPE_GROUP;
        [manager sendTextMessage:msg succ:^{
            [ws addTextToView:[NSString stringWithFormat:@"发送文本消息:%@",text]];
        } failed:^(NSString *moudle, int errId, NSString *errMsg) {
            [ws addTextToView:[NSString stringWithFormat:@"发送文本消息失败,moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg]];
        }];
    }
}

- (IBAction)inviteToVideo:(id)sender {
    TILLiveManager *manager = [TILLiveManager getInstance];
    NSString *recvId = _interactTextField.text;
    if(recvId.length <= 0){
        return;
    }
    
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_INVITE;
    msg.recvId = recvId;
    msg.type = ILVLIVE_IMTYPE_C2C;
    
    __weak typeof(self) ws = self;
    [manager sendCustomMessage:msg succ:^{
        [ws addTextToView:[NSString stringWithFormat:@"给%@发送上麦邀请",recvId]];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        [ws addTextToView:[NSString stringWithFormat:@"发送上麦邀请失败,moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg]];
    }];
}


- (IBAction)cancelInvite:(id)sender {
    TILLiveManager *manager = [TILLiveManager getInstance];
    NSString *recvId = _interactTextField.text;
    if(recvId.length <= 0){
        return;
    }
    
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_INVITE_CANCEL;
    msg.recvId = recvId;
    msg.type = ILVLIVE_IMTYPE_C2C;
    
    __weak typeof(self) ws = self;
    [manager sendCustomMessage:msg succ:^{
        [ws addTextToView:[NSString stringWithFormat:@"取消对%@的上麦邀请",recvId]];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        [ws addTextToView:[NSString stringWithFormat:@"取消上麦邀请失败,moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg]];
    }];
}


- (IBAction)cancelToVideo:(id)sender {
    TILLiveManager *manager = [TILLiveManager getInstance];
    NSString *recvId = _interactTextField.text;
    if(recvId.length <= 0){
        return;
    }
    
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_INVITE_CLOSE;
    msg.recvId = recvId;
    msg.type = ILVLIVE_IMTYPE_C2C;
    
    __weak typeof(self) ws = self;
    [manager sendCustomMessage:msg succ:^{
        [ws addTextToView:[NSString stringWithFormat:@"取消%@上麦",recvId]];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        [ws addTextToView:[NSString stringWithFormat:@"取消上麦失败,moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg]];
    }];
}

#pragma mark - 事件回调
- (void)onUserUpdateInfo:(ILVLiveAVEvent)event users:(NSArray *)users{
    TILLiveManager *manager = [TILLiveManager getInstance];
    switch(event) {
        case ILVLIVE_AVEVENT_CAMERA_ON:
        {
            //视频事件
            for (NSString *user in users) {
                if(![user isEqualToString:_host]){
                    [manager addAVRenderView:[self getRenderFrame:_identifierArray.count] forIdentifier:user srcType:QAVVIDEO_SRC_TYPE_CAMERA];
                    [_identifierArray addObject:user];
                    [_srcTypeArray addObject:@(QAVVIDEO_SRC_TYPE_CAMERA)];
                }
                else{
                    [manager addAVRenderView:self.view.bounds forIdentifier:_host srcType:QAVVIDEO_SRC_TYPE_CAMERA];
                }
            }
        }
            break;
        case ILVLIVE_AVEVENT_CAMERA_OFF:
        {
            for (NSString *user in users) {
                if(![user isEqualToString:_host]){
                    NSInteger index = [_identifierArray indexOfObject:user];
                    [manager removeAVRenderView:user srcType:QAVVIDEO_SRC_TYPE_CAMERA];
                    [_identifierArray removeObjectAtIndex:index];
                    [_srcTypeArray removeObjectAtIndex:index];
                }
                else{
                }
                [self updateRenderFrame];
            }
        }
            break;
        case ILVLIVE_AVEVENT_SCREEN_ON:
        {
            for (NSString *user in users) {
                if(![user isEqualToString:_host]){
                    [manager addAVRenderView:[self getRenderFrame:_identifierArray.count] forIdentifier:user srcType:QAVVIDEO_SRC_TYPE_SCREEN];
                    [_identifierArray addObject:user];
                    [_srcTypeArray addObject:@(QAVVIDEO_SRC_TYPE_SCREEN)];
                }
                else{
                }
            }
        }
            break;
        case ILVLIVE_AVEVENT_SCREEN_OFF:
        {
            for (NSString *user in users) {
                if(![user isEqualToString:_host]){
                    NSInteger index = [_identifierArray indexOfObject:user];
                    [manager removeAVRenderView:user srcType:QAVVIDEO_SRC_TYPE_SCREEN];
                    [_identifierArray removeObjectAtIndex:index];
                    [_srcTypeArray removeObjectAtIndex:index];
                }
                else{
                }
                [self updateRenderFrame];
            }
        }
        default:
            break;
    }
}

#pragma mark - 消息回调
- (void)onTextMessage:(ILVLiveTextMessage *)msg{
    [self addTextToView:[NSString stringWithFormat:@"收到文本消息:%@",msg.text]];
}

- (void)onCustomMessage:(ILVLiveCustomMessage *)msg{
    switch (msg.cmd) {
        case ILVLIVE_IMCMD_INTERACT_REJECT:
            [self addTextToView:[NSString stringWithFormat:@"%@拒绝了你的上麦邀请",msg.sendId]];
            break;
        case ILVLIVE_IMCMD_INVITE_CLOSE:
            [self addTextToView:[NSString stringWithFormat:@"%@已经下麦",msg.sendId]];
            break;
        case ILVLIVE_IMCMD_INTERACT_AGREE:
            [self addTextToView:[NSString stringWithFormat:@"%@同意了你的上麦邀请",msg.sendId]];
            break;
        case ILVLIVE_IMCMD_LEAVE:
            [self addTextToView:[NSString stringWithFormat:@"%@退出房间",msg.sendId]];
            break;
        case ILVLIVE_IMCMD_ENTER:
            [self addTextToView:[NSString stringWithFormat:@"%@进入房间",msg.sendId]];
            break;
        case ILVLIVE_IMCMD_CUSTOM_LOW_LIMIT:
        {
            //用户自定义消息
            NSString *text = [NSString stringWithFormat:@"收到自定义消息:cmd=%ld,data=%@",(long)msg.cmd,[[NSString alloc] initWithData:msg.data encoding:NSUTF8StringEncoding]];
            [self addTextToView:text];
            break;
        }
        default:
            break;
    }
}


#pragma mark - 界面相关
- (void)addTextToView:(NSString *)newText{
    NSString *text = _msgTextView.text;
    text = [text stringByAppendingString:@"\n"];
    text = [text stringByAppendingString:newText];
    _msgTextView.text = text;
}

- (CGRect)getRenderFrame:(NSInteger)count{
    if(count == 3){
        return CGRectZero;
    }
    CGFloat height = (self.view.frame.size.height - 2*20 - 3 * 10)/3;
    CGFloat width = height*3/4;//宽高比3:4
    CGFloat y = 20 + (count * (height + 10));
    CGFloat x = 20;
    return CGRectMake(x, y, width, height);
}

- (void)updateRenderFrame{
    TILLiveManager *manager = [TILLiveManager getInstance];
    for(NSInteger index = 0; index < _identifierArray.count; index++){
        CGRect frame = [self getRenderFrame:index];
        NSString *identifier = _identifierArray[index];
        avVideoSrcType srcType = [_srcTypeArray[index] intValue];
        [manager modifyAVRenderView:frame forIdentifier:identifier srcType:srcType];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)selfDismiss
{
    //为了看到关闭打印的信息，demo延迟1秒关闭
    __weak typeof(self) ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ws dismissViewControllerAnimated:YES completion:nil];
    });
}
@end
