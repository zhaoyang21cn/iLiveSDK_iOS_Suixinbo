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
    
    _whiteBtn = [[UIButton alloc] init];
    [_whiteBtn setImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
    [_whiteBtn setImage:[UIImage imageNamed:@"white_hover"] forState:UIControlStateHighlighted];
    [_whiteBtn addTarget:self action:@selector(onWhite:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_whiteBtn];
    [_btnArray addObject:_whiteBtn];
    
    _micBtn = [[UIButton alloc] init];
    [_micBtn setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
    [_micBtn setImage:[UIImage imageNamed:@"mic_shut"] forState:UIControlStateSelected];
    BOOL curMic = [[ILiveRoomManager getInstance] getCurMicState];
    _micBtn.selected = !curMic;
    [_micBtn addTarget:self action:@selector(onMic:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_micBtn];
    [_btnArray addObject:_micBtn];
    
    _pureBtn = [[UIButton alloc] init];
    [_pureBtn setImage:[UIImage imageNamed:@"full_screen"] forState:UIControlStateNormal];
    [_pureBtn addTarget:self action:@selector(onPure:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_pureBtn];
    [_btnArray addObject:_pureBtn];
    
    _noPureBtn = [[UIButton alloc] init];
    [_noPureBtn setImage:[UIImage imageNamed:@"normal"] forState:UIControlStateNormal];
    [_noPureBtn addTarget:self action:@selector(onNonPure:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_noPureBtn];
    [_btnArray addObject:_noPureBtn];
    
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
    
    __weak typeof(self) ws = self;
    
    ILiveRoomManager *manager = [ILiveRoomManager getInstance];
    
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.type = ILVLIVE_IMTYPE_GROUP;
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_Multi_CancelInteract;
    msg.recvId = [[ILiveRoomManager getInstance] getIMGroupId];
    msg.data = [[[ILiveLoginManager getInstance] getLoginId] dataUsingEncoding:NSUTF8StringEncoding];
    
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        [manager changeRole:kSxbRole_Guest succ:^ {
            TCILDebugLog(@"down to video: change role succ");
            cameraPos pos = [[ILiveRoomManager getInstance] getCurCameraPos];
            [manager enableCamera:pos enable:NO succ:^{
                TCILDebugLog(@"down to video: disable camera succ");
                [manager enableMic:NO succ:^{
                    TCILDebugLog(@"down to video: disable mic succ");
                    ws.isUpVideo = NO;
                    [ws layoutSubviews];
                } failed:^(NSString *module, int errId, NSString *errMsg) {
                    TCILDebugLog(@"down to video: disable mic fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
                    
                }];
            } failed:^(NSString *module, int errId, NSString *errMsg) {
                TCILDebugLog(@"down to video: disable camera fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
                
            }];
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            TCILDebugLog(@"down to video: change role fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
            
        }];
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        TCILDebugLog(@"down to video: change auth fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
        
    }];
}

- (void)onFlash:(UIButton *)button
{
}

- (void)onCamera:(UIButton *)button
{
    [[ILiveRoomManager getInstance] switchCamera:^{
        NSLog(@"switch camera succ");
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSString *errInfo = [NSString stringWithFormat:@"switch camera fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
        NSLog(@"%@",errInfo);
    }];
}

- (void)onBeauty:(UIButton *)button
{
    SetBeautyView *beautyView = [[SetBeautyView alloc] init];
    [self.superview addSubview:beautyView];
    [beautyView setFrame:self.superview.bounds];
    [beautyView relayoutFrameOfSubViews];
    
    __weak LiveUIBttomView *ws = self;
    beautyView.changeCompletion = ^(CGFloat value){
        [ws onBeautyChanged:value];
    };
    
    [beautyView setBeauty:_lastBeautyValue];
}

- (void)onBeautyChanged:(CGFloat)value
{
    _lastBeautyValue = value;
    
    NSInteger be = (NSInteger)((value + 0.05) * 10);
    
    QAVContext *context = [[ILiveSDK getInstance] getAVContext];
    if (context && context.videoCtrl)
    {
        [context.videoCtrl inputBeautyParam:be];
    }
}

- (void)onWhite:(UIButton *)button
{
    SetBeautyView *whiteView = [[SetBeautyView alloc] init];
    [self.superview addSubview:whiteView];
    
    __weak LiveUIBttomView *ws = self;
    whiteView.changeCompletion = ^(CGFloat value){
        [ws onWhiteChanged:value];
    };
    [whiteView setFrame:self.superview.bounds];
    [whiteView relayoutFrameOfSubViews];
    
    whiteView.isWhiteMode = YES;
    [whiteView setBeauty:_lastWhiteValue];
}

- (void)onWhiteChanged:(CGFloat)value
{
    _lastWhiteValue = value;
    
    NSInteger be = (NSInteger)((value + 0.05) * 10);
    
    QAVContext *context = [[ILiveSDK getInstance] getAVContext];
    if (context && context.videoCtrl)
    {
        [context.videoCtrl inputWhiteningParam:be];
    }
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
}

- (void)onNonPure:(UIButton *)button
{
}

- (void)onPraise:(UIButton *)button
{
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.type = ILVLIVE_IMTYPE_GROUP;
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_Praise;
    msg.recvId = [[ILiveRoomManager getInstance] getIMGroupId];
    
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserParise_Notification object:nil];
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        
    }];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect = CGRectInset(rect, 0, (rect.size.height - 40)/2);
    
    BOOL curMic = [[ILiveRoomManager getInstance] getCurMicState];
    _micBtn.selected = !curMic;
    
    NSMutableArray *funs = [NSMutableArray array];
    if (_isHost)
    {
        [funs addObjectsFromArray:@[_cameraBtn, _beautyBtn, _whiteBtn, _micBtn]];
        [self hidddenButtons:@[_sendMsgBtn, _praiseBtn, _downVideo] isHide:YES];
        [self hidddenButtons:@[_cameraBtn, _beautyBtn, _whiteBtn, _micBtn] isHide:NO];
    }
    else if (_isUpVideo)
    {
        [funs addObjectsFromArray:@[_sendMsgBtn, _praiseBtn, _cameraBtn, _beautyBtn, _whiteBtn, _micBtn, _downVideo]];
        [self hidddenButtons:@[_sendMsgBtn, _praiseBtn, _cameraBtn, _beautyBtn, _whiteBtn, _micBtn, _downVideo] isHide:NO];
    }
    else
    {
        [funs addObjectsFromArray:@[_sendMsgBtn, _praiseBtn]];
        [self hidddenButtons:@[_cameraBtn, _beautyBtn, _whiteBtn, _micBtn, _downVideo] isHide:YES];
        [self hidddenButtons:@[_sendMsgBtn, _praiseBtn] isHide:NO];
    }
    
    if (funs.count > 1)
    {
        [self alignSubviews:funs horizontallyWithPadding:0 margin:0 inRect:rect];
    }
//    else if (funs.count == 1)
//    {
//        UIView *view = funs[0];
//        [view sizeWith:CGSizeMake(40, 40)];
//        [view alignParentRightWithMargin:15];
//        [view layoutParentVerticalCenter];
//    }
}

- (void)hidddenButtons:(NSArray *)buttons isHide:(BOOL)hide
{
    for (UIButton *button in buttons)
    {
        button.hidden = hide;
    }
}

@end
