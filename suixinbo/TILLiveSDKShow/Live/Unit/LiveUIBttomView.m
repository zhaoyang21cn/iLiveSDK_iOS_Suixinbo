//
//  LiveUIBttomView.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LiveUIBttomView.h"

#import "SetBeautyView.h"
#import "MoreFunView.h"

@interface LiveUIBttomView () <MoreFunDelegate>
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
    
    _moreFun = [[UIButton alloc] init];
    [_moreFun setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [_moreFun addTarget:self action:@selector(onMoreFun:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_moreFun];
    [_btnArray addObject:_moreFun];
}

- (void)onMoreFun:(UIButton *)button
{
    _curRole = _curRole.length > 0 ? _curRole : (_isHost ? kSxbRole_Host : kSxbRole_Guest);
    CGRect rect = self.superview.bounds;
    MoreFunView *moreFunView = [[MoreFunView alloc] init];
    moreFunView.delegate = self;
    MoreFunItem *item = [[MoreFunItem alloc] init];
    item.isHost = _isHost;
    item.isUpVideo = _isUpVideo;
    item.curRole = _curRole;
    item.moreFunViewRect = CGRectMake(rect.origin.x, rect.size.height, rect.size.width, rect.size.height);
    item.bottomView = self;
    item.tilFilter = _tilFilter;
    [moreFunView configMoreFun:item];
    [self.superview addSubview:moreFunView];
    [UIView animateWithDuration:0.3 animations:^{
        [moreFunView setFrame:rect];
        self.hidden = YES;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - MoreFunView delegate
- (void)changeAudioDelegate:(QAVVoiceType)type
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeVoiceType:)])
    {
        [self.delegate changeVoiceType:type];
    }
}

- (void)changeRoleDelegate:(NSString *)role
{
    _curRole = role;
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
        
//        cameraPos pos = [[ILiveRoomManager getInstance] getCurCameraPos];
//        if (pos == CameraPosFront && _flashBtn.selected == YES)
//        {
//            _flashBtn.selected = !_flashBtn.selected;
//        }
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
    NSString *beautyScheme = [[NSUserDefaults standardUserDefaults] objectForKey:kBeautyScheme];
    if (!(beautyScheme && beautyScheme.length > 0))
    {
        [[NSUserDefaults standardUserDefaults] setValue:kILiveBeauty forKey:kBeautyScheme];
        beautyScheme = kILiveBeauty;
    }
    if ([beautyScheme isEqualToString:kILiveBeauty])
    {
        //TILFilterSDK美颜效果
        if (self.delegate && [self.delegate respondsToSelector:@selector(setTilBeauty:)])
        {
            [self.delegate setTilBeauty:be];
        }
    }
    if ([beautyScheme isEqualToString:kQAVSDKBeauty])
    {
        //QAVSDK美颜效果
        QAVContext *context = [[ILiveSDK getInstance] getAVContext];
        if (context && context.videoCtrl)
        {
            [context.videoCtrl inputBeautyParam:be];
        }
    }
}

- (void)onWhiteChanged:(CGFloat)value
{
    _lastWhiteValue = value;
    
    NSInteger be = (NSInteger)((value + 0.05) * 10);
    NSString *beautyScheme = [[NSUserDefaults standardUserDefaults] objectForKey:kBeautyScheme];
    if ([beautyScheme isEqualToString:kILiveBeauty])
    {
        //TILFilterSDK美白效果
        if (self.delegate && [self.delegate respondsToSelector:@selector(setTilBeauty:)])
        {
            [self.delegate setTilWhite:be];
        }
    }
    if ([beautyScheme isEqualToString:kQAVSDKBeauty])
    {
        //QAVSDK美白效果
        QAVContext *context = [[ILiveSDK getInstance] getAVContext];
        if (context && context.videoCtrl)
        {
            [context.videoCtrl inputWhiteningParam:be];
        }
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
    button.selected = !button.selected;
    if (button.selected)
    {
        [self hidddenButtons:@[_pureBtn] isHide:NO];
        [self hidddenButtons:@[_sendMsgBtn, _cameraBtn, _beautyBtn, _micBtn, _downVideo, _praiseBtn, _moreFun] isHide:YES];//_whiteBtn
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
    if (_isHost)//主播
    {
        [funs addObjectsFromArray:@[_sendMsgBtn, _cameraBtn, _micBtn ,_beautyBtn, _moreFun,_pureBtn]];
            
        [self hidddenButtons:@[_downVideo,_praiseBtn] isHide:YES];
        [self hidddenButtons:@[_sendMsgBtn,_cameraBtn, _micBtn, _beautyBtn, _moreFun, _pureBtn] isHide:NO];
        }
    else if (_isUpVideo)//连麦用户
        {
        [funs addObjectsFromArray:@[_sendMsgBtn, _cameraBtn, _micBtn, _beautyBtn, _downVideo, _praiseBtn, _moreFun,_pureBtn]];
            
        [self hidddenButtons:@[_sendMsgBtn, _cameraBtn, _micBtn, _beautyBtn, _downVideo, _praiseBtn, _moreFun,_pureBtn] isHide:NO];
        }
    else//观众
        {
        [funs addObjectsFromArray:@[_sendMsgBtn, _praiseBtn, _moreFun,_pureBtn]];
            
        [self hidddenButtons:@[_downVideo,_beautyBtn, _cameraBtn, _micBtn] isHide:YES];
        [self hidddenButtons:@[_sendMsgBtn, _praiseBtn, _moreFun,_pureBtn] isHide:NO];
        }
    if (funs.count > 1)
    {
        [self alignSubviews:funs horizontallyWithPadding:0 margin:0 inRect:rect];
    }
    BOOL isOpenMic = [[ILiveRoomManager getInstance] getCurMicState];
    if (isOpenMic)
    {
        _micBtn.selected = NO;
    }
    else
    {
        _micBtn.selected = YES;
    }
}

- (void)hidddenButtons:(NSArray *)buttons isHide:(BOOL)hide
{
    for (UIButton *button in buttons)
    {
        button.hidden = hide;
    }
}

- (void)setMicState:(BOOL)on
{
    _micBtn.selected = !on;
}
@end
