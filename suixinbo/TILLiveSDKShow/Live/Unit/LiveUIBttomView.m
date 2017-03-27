//
//  LiveUIBttomView.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LiveUIBttomView.h"

#import "SetBeautyView.h"

@interface LiveUIBttomView ()
{
    CGFloat _lastBeautyValue;
    CGFloat _lastWhiteValue;
}
@end

@implementation LiveUIBttomView

- (instancetype)initWith:(NSString *)role
{
    if (self = [self init])
    {
        self.mainWindowRole = role;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _isUpVideo = NO;
        _lastBeautyValue = 0;
        _lastWhiteValue = 0;
        [self addBottomSubViews];
        [self addNotification];
    }
    return self;
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upVideoUpdateFuns) name:kUserUpVideo_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downVideoUpdateFuns) name:kUserDownVideo_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchRoomRefresh) name:kUserSwitchRoom_Notification object:nil];
}

//上麦之后更新界面
- (void)upVideoUpdateFuns
{
    _isUpVideo = YES;
    
    [self setNeedsLayout];
}

//下麦之后更新界面
- (void)downVideoUpdateFuns
{
    _isUpVideo = NO;
    [self setNeedsLayout];
}

- (void)switchRoomRefresh
{
    _isUpVideo = NO;
    [self setNeedsLayout];
}

- (void)addBottomSubViews
{
    _btnArray = [NSMutableArray array];
    
    _flashBtn = [[UIButton alloc] init];
    [_flashBtn setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    [_flashBtn setImage:[UIImage imageNamed:@"flash_hover"] forState:UIControlStateSelected];
    [_flashBtn addTarget:self action:@selector(onFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_flashBtn];
    [_btnArray addObject:_flashBtn];
    
    _cameraBtn = [[UIButton alloc] init];
    [_cameraBtn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [_cameraBtn addTarget:self action:@selector(onCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cameraBtn];
    [_btnArray addObject:_cameraBtn];
    
    _beautyBtn = [[UIButton alloc] init];
    [_beautyBtn setImage:[UIImage imageNamed:@"beauty"] forState:UIControlStateNormal];
    [_beautyBtn setImage:[UIImage imageNamed:@"beauty_hover"] forState:UIControlStateHighlighted];
    [_beautyBtn addTarget:self action:@selector(onBeauty:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_beautyBtn];
    [_btnArray addObject:_beautyBtn];
    
//    _whiteBtn = [[UIButton alloc] init];
//    [_whiteBtn setImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
//    [_whiteBtn setImage:[UIImage imageNamed:@"white_hover"] forState:UIControlStateHighlighted];
//    [_whiteBtn addTarget:self action:@selector(onWhite:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_whiteBtn];
//    [_btnArray addObject:_whiteBtn];
    
    _micBtn = [[UIButton alloc] init];
    [_micBtn setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
    [_micBtn setImage:[UIImage imageNamed:@"mic_shut"] forState:UIControlStateSelected];
    [_micBtn addTarget:self action:@selector(onMic:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_micBtn];
    [_btnArray addObject:_micBtn];
    
    _pureBtn = [[UIButton alloc] init];
    [_pureBtn setImage:[UIImage imageNamed:@"full_screen"] forState:UIControlStateNormal];
    [_pureBtn setImage:[UIImage imageNamed:@"normal"] forState:UIControlStateSelected];
    [_pureBtn addTarget:self action:@selector(onPure:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_pureBtn];
    [_btnArray addObject:_pureBtn];
    
    _praiseBtn = [[UIButton alloc] init];
    [_praiseBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [_praiseBtn addTarget:self action:@selector(onPraise:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_praiseBtn];
    [_btnArray addObject:_praiseBtn];
    
    _sendMsgBtn = [[UIButton alloc] init];
    [_sendMsgBtn setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [_sendMsgBtn setImage:[UIImage imageNamed:@"comment_hover"] forState:UIControlStateHighlighted];
    [_sendMsgBtn addTarget:self action:@selector(onPopMsgInputView:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendMsgBtn];
    [_btnArray addObject:_sendMsgBtn];
    
    _downVideo = [[UIButton alloc] init];
    [_downVideo setImage:[UIImage imageNamed:@"exit_interact"] forState:UIControlStateNormal];
    [_downVideo addTarget:self action:@selector(onDownVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_downVideo];
    [_btnArray addObject:_downVideo];
}

- (void)onPopMsgInputView:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(popMsgInputView)])
    {
        [self.delegate popMsgInputView];
    }
}

- (void)onDownVideo:(UIButton *)button
{
//    __weak typeof(self) ws = self;
//    [[TILLiveManager getInstance] downToVideoMember:ILVLIVEAUTH_GUEST role:kSxbRole_Guest succ:^{
//        NSLog(@"down video succ");
//        ws.isUpVideo = NO;
//        [ws layoutSubviews];
//    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
//        NSLog(@"down video fail.module=%@,errid=%d,errmsg=%@",moudle,errId,errMsg);
//    }];
    
    if (_isHost)//如果是主播点击bottom中的下麦操作时，是下别人的麦
    {
        ILVLiveCustomMessage *video = [[ILVLiveCustomMessage alloc] init];
        video.recvId = [UserViewManager shareInstance].mainUserId;//_mainWindowUserId;
        video.data = [[UserViewManager shareInstance].mainUserId dataUsingEncoding:NSUTF8StringEncoding];
        video.type = ILVLIVE_IMTYPE_GROUP;
        video.cmd = (ILVLiveIMCmd)AVIMCMD_Multi_CancelInteract;
        [[TILLiveManager getInstance] sendCustomMessage:video succ:^{
            NSLog(@"send succ");
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            NSLog(@"login fail. module=%@,errid=%d,errmsg=%@",module,errId,errMsg);
        }];
        return;
    }
    __weak typeof(self) ws = self;
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.type = ILVLIVE_IMTYPE_GROUP;
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_Multi_CancelInteract;
    msg.recvId = [[ILiveRoomManager getInstance] getIMGroupId];
    msg.data = [[[ILiveLoginManager getInstance] getLoginId] dataUsingEncoding:NSUTF8StringEncoding];
    
    ILiveRoomManager *manager = [ILiveRoomManager getInstance];
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        [manager changeRole:kSxbRole_Guest succ:^ {
            NSLog(@"down to video: change role succ");
            cameraPos pos = [[ILiveRoomManager getInstance] getCurCameraPos];
            [manager enableCamera:pos enable:NO succ:^{
                NSLog(@"down to video: disable camera succ");
                [manager enableMic:NO succ:^{
                    NSLog(@"down to video: disable mic succ");
                    ws.mainWindowRole = kSxbRole_Host;
                    ws.isUpVideo = NO;
                    [ws layoutSubviews];
                    
                } failed:^(NSString *module, int errId, NSString *errMsg) {
                    NSLog(@"down to video: disable mic fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
                }];
            } failed:^(NSString *module, int errId, NSString *errMsg) {
                NSLog(@"down to video: disable camera fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
            }];
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            NSLog(@"down to video: change role fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
        }];
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"down to video: change auth fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
    }];
}

- (void)onFlash:(UIButton *)button
{
    cameraPos pos = [[ILiveRoomManager getInstance] getCurCameraPos];
    if (pos == CameraPosFront && !button.selected)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"前置摄像头打开闪光灯会影响直播" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        UIViewController *vc = [self viewController];
        [vc presentViewController:alert animated:YES completion:nil];
        return;
    }
    button.selected = !button.selected;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch])
    {
        [device lockForConfiguration:nil];
        [device setTorchMode: button.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

- (UIViewController *)viewController
{
    UIResponder *next = self.nextResponder;
    do
    {
        //判断响应者对象是否是视图控制器类型
        if ([next isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)next;
        }
        next = next.nextResponder;
    }while(next != nil);
    return nil;
}

- (void)onCamera:(UIButton *)button
{
    [[ILiveRoomManager getInstance] switchCamera:^{
        NSLog(@"switch camera succ");
        
        cameraPos pos = [[ILiveRoomManager getInstance] getCurCameraPos];
        if (pos == CameraPosFront && _flashBtn.selected == YES)
        {
            _flashBtn.selected = !_flashBtn.selected;
        }
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSString *errInfo = [NSString stringWithFormat:@"switch camera fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
        NSLog(@"%@",errInfo);
    }];
}

- (void)onBeauty:(UIButton *)button
{
    CGRect rect = self.superview.bounds;
    SetBeautyView *beautyView = [[SetBeautyView alloc] initWithFrame:CGRectMake(0, 170, rect.size.width, rect.size.height)];
    [self.superview addSubview:beautyView];
    [UIView animateWithDuration:0.5 animations:^{
        [beautyView setFrame:rect];
    } completion:^(BOOL finished) {
    }];
//    [beautyView setFrame:self.superview.bounds];
//    [beautyView relayoutFrameOfSubViews];
    
    __weak LiveUIBttomView *ws = self;
    beautyView.changeCompletion = ^(BeautyViewType type, CGFloat value){
        if (type == BeautyViewType_Beauty)
        {
            [ws onBeautyChanged:value];
        }
        if (type == BeautyViewType_White)
        {
            [ws onWhiteChanged:value];
        }
    };
//    [beautyView setBeauty:_lastBeautyValue];
    [beautyView setBeautyValue:_lastBeautyValue];
    [beautyView setWhiteValue:_lastWhiteValue];
}

- (void)onBeautyChanged:(CGFloat)value
{
    _lastBeautyValue = value;
    NSInteger be = (NSInteger)((value + 0.05) * 10);
    //TILFilterSDK美颜效果
    if (self.delegate && [self.delegate respondsToSelector:@selector(setTilBeauty:)])
    {
        [self.delegate setTilBeauty:be];
    }
//QAVSDK美颜效果
//    QAVContext *context = [[ILiveSDK getInstance] getAVContext];
//    if (context && context.videoCtrl)
//    {
//        [context.videoCtrl inputBeautyParam:be];
//    }
}

//- (void)onWhite:(UIButton *)button
//{
//    SetBeautyView *whiteView = [[SetBeautyView alloc] init];
//    [self.superview addSubview:whiteView];
//    
//    __weak LiveUIBttomView *ws = self;
//    whiteView.changeCompletion = ^(BeautyViewType type, CGFloat value){
//        [ws onWhiteChanged:value];
//    };
//    [whiteView setFrame:self.superview.bounds];
//    [whiteView relayoutFrameOfSubViews];
//    
//    whiteView.isWhiteMode = YES;
//    [whiteView setBeauty:_lastWhiteValue];
//}

- (void)onWhiteChanged:(CGFloat)value
{
    _lastWhiteValue = value;
    
    NSInteger be = (NSInteger)((value + 0.05) * 10);
    //TILFilterSDK美白效果
    if (self.delegate && [self.delegate respondsToSelector:@selector(setTilBeauty:)])
    {
        [self.delegate setTilWhite:be];
    }
    //QAVSDK美白效果
//    QAVContext *context = [[ILiveSDK getInstance] getAVContext];
//    if (context && context.videoCtrl)
//    {
//        [context.videoCtrl inputWhiteningParam:be];
//    }
}

- (void)onMic:(UIButton *)button
{
    button.selected = !button.selected;
    BOOL curMic = [[ILiveRoomManager getInstance] getCurMicState];
    [[ILiveRoomManager getInstance] enableMic:!curMic succ:^{
        NSLog(@"enable succ");
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSString *errInfo = [NSString stringWithFormat:@"switch camera fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
        NSLog(@"%@",errInfo);
    }];
}

- (void)onPure:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected)
    {
        [self hidddenButtons:@[_pureBtn] isHide:NO];
        [self hidddenButtons:@[_flashBtn, _sendMsgBtn, _cameraBtn, _beautyBtn, _micBtn, _downVideo, _praiseBtn] isHide:YES];//_whiteBtn
        [_pureBtn alignParentRightWithMargin:kDefaultMargin];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPureDelete_Notification object:nil];
    }
    else
    {
        [self setNeedsLayout];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNoPureDelete_Notification object:nil];
    }
}

- (void)onNonPure:(UIButton *)button
{
}

- (void)onPraise:(UIButton *)button
{
    if (_isHost)
    {
        return;
    }
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.type = ILVLIVE_IMTYPE_GROUP;
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_Praise;
    msg.recvId = [[ILiveRoomManager getInstance] getIMGroupId];
    
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        NSMutableDictionary *pointDic = [NSMutableDictionary dictionary];
        [pointDic setObject:[NSNumber numberWithFloat:button.center.x] forKey:@"parise_x"];
        [pointDic setObject:[NSNumber numberWithFloat:button.center.y] forKey:@"parise_y"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserParise_Notification object:pointDic];
        
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        
    }];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect = CGRectInset(rect, 0, (rect.size.height - 40)/2);
    
    NSMutableArray *funs = [NSMutableArray array];
    if ([_mainWindowRole isEqualToString:kSxbRole_Host])//主窗口是主播
    {
        if (_isHost)//自己是主播(随心播中主播不能发送消息，业务测可自己定)
        {
            [funs addObjectsFromArray:@[_flashBtn, _cameraBtn, _beautyBtn, _micBtn, _pureBtn]];//_whiteBtn,_praiseBtn
            
            [self hidddenButtons:@[_sendMsgBtn, _downVideo] isHide:YES];
            [self hidddenButtons:@[_flashBtn, _cameraBtn, _beautyBtn, _micBtn, _pureBtn, _praiseBtn] isHide:NO];//_whiteBtn
        }
        else if (_isUpVideo)
        {
            [funs addObjectsFromArray:@[_flashBtn, _sendMsgBtn, _cameraBtn, _beautyBtn, _micBtn, _pureBtn, _praiseBtn]];//_whiteBtn
            
            [self hidddenButtons:@[_downVideo] isHide:YES];
            [self hidddenButtons:@[_flashBtn, _sendMsgBtn, _cameraBtn, _beautyBtn, _micBtn, _pureBtn, _praiseBtn] isHide:NO];//_whiteBtn
        }
        else
        {
            [funs addObjectsFromArray:@[_sendMsgBtn, _pureBtn, _praiseBtn]];
            
            [self hidddenButtons:@[_flashBtn, _cameraBtn, _beautyBtn, _micBtn, _downVideo] isHide:YES];//_whiteBtn
            [self hidddenButtons:@[_sendMsgBtn, _pureBtn, _praiseBtn] isHide:NO];
        }
    }
    else//主窗口是连麦用户
    {
        if (_isHost)
        {
            [funs addObjectsFromArray:@[_flashBtn, _cameraBtn, _beautyBtn, _micBtn, _downVideo, _pureBtn]];//_whiteBtn _praiseBtn
            
            [self hidddenButtons:@[_sendMsgBtn] isHide:YES];
            [self hidddenButtons:@[_flashBtn, _cameraBtn, _beautyBtn, _micBtn, _downVideo, _pureBtn, _praiseBtn] isHide:NO];//_whiteBtn
        }
        else if (_isUpVideo)//随心播中，连麦用户和普通观众不能下麦其他人的视频(业务测可自己定)
        {
            if ([[UserViewManager shareInstance].mainUserId isEqualToString:[[ILiveLoginManager getInstance] getLoginId]])//如果主窗口就是登录用户的画面，则可以下麦
            {
                [funs addObjectsFromArray:@[_flashBtn, _sendMsgBtn, _cameraBtn, _beautyBtn, _micBtn, _downVideo,_pureBtn, _praiseBtn]];//_whiteBtn
                
                [self hidddenButtons:@[_flashBtn, _sendMsgBtn, _cameraBtn, _beautyBtn, _micBtn, _downVideo, _pureBtn, _praiseBtn] isHide:NO];//_whiteBtn
            }
            else
            {
                [funs addObjectsFromArray:@[_flashBtn, _sendMsgBtn, _cameraBtn, _beautyBtn, _micBtn, _pureBtn, _praiseBtn]];//_whiteBtn
                
                [self hidddenButtons:@[_downVideo] isHide:YES];
                [self hidddenButtons:@[_flashBtn, _sendMsgBtn, _cameraBtn, _beautyBtn, _micBtn, _pureBtn, _praiseBtn] isHide:NO];//_whiteBtn
            }
            
        }
        else
        {
            [funs addObjectsFromArray:@[_sendMsgBtn, _pureBtn, _praiseBtn]];
            
            [self hidddenButtons:@[_flashBtn, _cameraBtn, _beautyBtn, _micBtn, _downVideo] isHide:YES];//_whiteBtn
            [self hidddenButtons:@[_sendMsgBtn, _pureBtn, _praiseBtn] isHide:NO];
        }
    }
    if (funs.count > 1)
    {
        [self alignSubviews:funs horizontallyWithPadding:0 margin:0 inRect:rect];
    }
}

- (void)hidddenButtons:(NSArray *)buttons isHide:(BOOL)hide
{
    for (UIButton *button in buttons)
    {
        button.hidden = hide;
    }
}

@end
