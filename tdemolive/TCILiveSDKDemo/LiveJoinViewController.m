//
//  LiveJoinViewController.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/10/27.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "LiveJoinViewController.h"

@interface LiveJoinViewController ()<ILVLiveAVListener,ILVLiveIMListener,UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *identifierArray;
@property (nonatomic, strong) NSMutableArray *srcTypeArray;
@end
@implementation LiveJoinViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    _identifierArray = [[NSMutableArray alloc] init];
    _srcTypeArray = [[NSMutableArray alloc] init];
    
    _downToVideoButton.enabled = NO;
    _upToVideoButton.enabled = NO;
    _rejectToVideoButton.enabled = NO;
    [self joinLive];
}

#pragma mark - TILLiveSDK相关接口
- (void)joinLive{
    ILiveRoomOption *option = [ILiveRoomOption defaultGuestLiveOption];
    TILLiveManager *manager = [TILLiveManager getInstance];
    [manager setAVListener:self];
    [manager setIMListener:self];
    [manager setAVRootView:self.view];
    [manager addAVRenderView:self.view.bounds forKey:self.host];
    
    __weak typeof(self) ws = self;
    [manager joinRoom:self.roomId option:option succ:^{
        [ws addTextToView:@"进入房间成功"];
        //进群消息
        ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
        msg.cmd = ILVLIVE_IMCMD_ENTER;
        msg.type = ILVLIVE_IMTYPE_GROUP;
        [manager sendCustomMessage:msg succ:nil failed:nil];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        [ws addTextToView:[NSString stringWithFormat:@"进入房间失败,moldle=%@;errid=%d;errmsg=%@",moudle,errId,errMsg]];
    }];
}

- (IBAction)exitLive:(id)sender {
    //退群消息
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_LEAVE;
    msg.type = ILVLIVE_IMTYPE_GROUP;
    TILLiveManager *manager = [TILLiveManager getInstance];
    [manager sendCustomMessage:msg succ:nil failed:nil];
    
    //退出房间
    __weak typeof(self) ws = self;
    [manager quitRoom:^{
        [ws addTextToView:@"退出房间成功"];
        [ws selfDismiss];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        [ws addTextToView:[NSString stringWithFormat:@"退出房间失败,moldle=%@;errid=%d;errmsg=%@",moudle,errId,errMsg]];
        [ws selfDismiss];
    }];
}


- (IBAction)upToVideo:(id)sender {
    //上麦消息
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_INTERACT_AGREE;
    msg.recvId = self.host;
    msg.type = ILVLIVE_IMTYPE_C2C;
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:nil failed:nil];
    
    //上麦
    __weak typeof(self) ws = self;
    [[TILLiveManager getInstance] upToVideoMember:@"user" succ:^{
        [ws addTextToView:@"上麦成功"];

        ws.downToVideoButton.enabled = YES;
        ws.upToVideoButton.enabled = NO;
        ws.rejectToVideoButton.enabled = NO;
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        [ws addTextToView:[NSString stringWithFormat:@"上麦失败,moldle=%@;errid=%d;errmsg=%@",moudle,errId,errMsg]];
    }];
}


- (IBAction)downToVideo:(id)sender {
    //关闭上麦
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_INVITE_CLOSE;
    msg.recvId = self.host;
    msg.type = ILVLIVE_IMTYPE_C2C;
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:nil failed:nil];
    
    __weak typeof(self) ws = self;
    [[TILLiveManager getInstance] downToVideoMember:@"user" succ:^{
        [ws addTextToView:@"下麦成功"];
        
        ws.downToVideoButton.enabled = NO;
        ws.upToVideoButton.enabled = NO;
        ws.rejectToVideoButton.enabled = NO;
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        [ws addTextToView:[NSString stringWithFormat:@"下麦失败,moldle=%@;errid=%d;errmsg=%@",moudle,errId,errMsg]];
    }];
}


- (IBAction)rejectToVideo:(id)sender {
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = ILVLIVE_IMCMD_INTERACT_REJECT;
    msg.recvId = self.host;
    msg.type = ILVLIVE_IMTYPE_C2C;
    __weak typeof(self) ws = self;
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        [ws addTextToView:@"拒绝上麦邀请成功"];
        ws.downToVideoButton.enabled = NO;
        ws.upToVideoButton.enabled = NO;
        ws.rejectToVideoButton.enabled = NO;
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        [ws addTextToView:[NSString stringWithFormat:@"拒绝上麦邀请失败,moudle=%@,errId=%d,errMsg=%@",moudle,errId,errMsg]];
    }];
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
                [manager addAVRenderView:[self getRenderFrame:_identifierArray.count] forIdentifier:user srcType:QAVVIDEO_SRC_TYPE_SCREEN];
                [_identifierArray addObject:user];
                [_srcTypeArray addObject:@(QAVVIDEO_SRC_TYPE_SCREEN)];
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
- (void)onCustomMessage:(ILVLiveCustomMessage *)msg{
    switch (msg.cmd) {
        case ILVLIVE_IMCMD_INVITE:
        {
            [self addTextToView:[NSString stringWithFormat:@"收到%@的上麦邀请",msg.sendId]];
            
            _downToVideoButton.enabled = NO;
            _upToVideoButton.enabled = YES;
            _rejectToVideoButton.enabled = YES;
            break;
        }
        case ILVLIVE_IMCMD_INVITE_CANCEL:
        {
            [self addTextToView:[NSString stringWithFormat:@"%@取消上麦邀请",msg.sendId]];
            _downToVideoButton.enabled = NO;
            _upToVideoButton.enabled = NO;
            _rejectToVideoButton.enabled = NO;
            break;
        }
        case ILVLIVE_IMCMD_INVITE_CLOSE:
        {
            [self addTextToView:[NSString stringWithFormat:@"%@关闭了你的上麦",msg.sendId]];
            [self downToVideo:nil];
            break;
        }
        case ILVLIVE_IMCMD_LEAVE:
            [self addTextToView:[NSString stringWithFormat:@"%@退出房间",msg.sendId]];
            break;
        case ILVLIVE_IMCMD_ENTER:
            [self addTextToView:[NSString stringWithFormat:@"%@进入房间",msg.sendId]];
            break;
        case ILVLIVE_IMCMD_CUSTOM_LOW_LIMIT:
        {
            NSString *temp = [NSString stringWithFormat:@"收到自定义消息:cmd=%ld,data=%@",(long)msg.cmd,[[NSString alloc] initWithData:msg.data encoding:NSUTF8StringEncoding]];
            [self addTextToView:temp];
            break;
        }
        default:
            break;
    }
    
}

//收到文本消息
- (void)onTextMessage:(ILVLiveTextMessage *)msg{
    [self addTextToView:[NSString stringWithFormat:@"收到文本消息:%@",msg.text]];
}



//添加消息到屏幕
- (void)addTextToView:(NSString *)newText{
    NSString *text = self.msgTextView.text;
    text = [text stringByAppendingString:@"\n"];
    text = [text stringByAppendingString:newText];
    self.msgTextView.text = text;
}

#pragma mark - 界面相关
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
