//
//  LiveUIParView.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LiveUIParView.h"
#import "LinkRoomList.h"

#import <ShareSDKUI/ShareSDK+SSUI.h>//用于实现社交分享


@interface LiveUIParView () <ILiveSpeedTestDelegate>
{
    UInt64  _channelId;
    NSMutableString *_versionInfo;
}
@end

UIAlertController *_alert;

@implementation LiveUIParView

- (void)configWith:(LiveUIParViewConfig *)config
{
    _config = config;
    [self addAVParamSubViews];
    _resolutionDic = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onParPure:) name:kPureDelete_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onParNoPure:) name:kNoPureDelete_Notification object:nil];
    [ILiveSpeedTestManager shareInstance].delegate = self;
}

- (void)onParPure:(NSNotification *)noti
{
    CGRect selfFrame = self.frame;
    _restoreRect = selfFrame;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect moveToRect = CGRectMake(selfFrame.origin.x, -(selfFrame.origin.y+selfFrame.size.height), selfFrame.size.width, selfFrame.size.height);
        [self setFrame:moveToRect];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)onParNoPure:(NSNotification *)noti
{
    self.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        [self setFrame:_restoreRect];
    } completion:^(BOOL finished) {
    }];
}

- (void)addAVParamSubViews
{
    _funs = [NSMutableArray array];
    //AV Param View
    if (_config.isHost)
    {
        _interactBtn = [[UIButton alloc] init];
        [_interactBtn setImage:[UIImage imageNamed:@"interactive"] forState:UIControlStateNormal];
        [_interactBtn addTarget:self action:@selector(onInteract:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_interactBtn];
        [_funs addObject:_interactBtn];
    }
    
    UIImage *nor = [UIImage imageWithColor:[RGB(220, 220, 220) colorWithAlphaComponent:0.5]];
    UIImage *hig = [UIImage imageWithColor:[RGB(110, 110, 110) colorWithAlphaComponent:0.5]];
    
    _parBtn = [[UIButton alloc] init];
    [_parBtn setTitle:@"房间信息" forState:UIControlStateNormal];
    _parBtn.titleLabel.font = kAppSmallTextFont;
    _parBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_parBtn addTarget:self action:@selector(onPar:) forControlEvents:UIControlEventTouchUpInside];
    [_parBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
    [_parBtn setTitleColor:kColorWhite forState:UIControlStateSelected];
    [_parBtn setBackgroundImage:nor forState:UIControlStateNormal];
    [_parBtn setBackgroundImage:hig forState:UIControlStateSelected];
    _parBtn.layer.cornerRadius = 4;
    _parBtn.layer.masksToBounds = YES;
    [self addSubview:_parBtn];
    [_funs addObject:_parBtn];
    
    UIImage *image = [UIImage imageWithColor:[kColorBlue colorWithAlphaComponent:0.5]];
    
    if (_config.isHost)
    {
        _pushStreamBtn = [[UIButton alloc] init];
        [_pushStreamBtn setTitle:@"开始推流" forState:UIControlStateNormal];
        [_pushStreamBtn setTitle:@"关闭推流" forState:UIControlStateSelected];
        [_pushStreamBtn addTarget:self action:@selector(onPush:) forControlEvents:UIControlEventTouchUpInside];
        _pushStreamBtn.titleLabel.font = kAppSmallTextFont;
        [_pushStreamBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
        [_pushStreamBtn setTitleColor:kColorWhite forState:UIControlStateSelected];
        [_pushStreamBtn setBackgroundImage:nor forState:UIControlStateNormal];
        [_pushStreamBtn setBackgroundImage:hig forState:UIControlStateSelected];
        _pushStreamBtn.layer.cornerRadius = 4;
        _pushStreamBtn.layer.masksToBounds = YES;
        [self addSubview:_pushStreamBtn];
        [_funs addObject:_pushStreamBtn];
        
        _recBtn = [[UIButton alloc] init];
        [_recBtn setTitle:@"REC" forState:UIControlStateNormal];
        [_recBtn addTarget:self action:@selector(onRecord:) forControlEvents:UIControlEventTouchUpInside];
        _recBtn.titleLabel.font = kAppSmallTextFont;
        [_recBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
        [_recBtn setTitleColor:kColorWhite forState:UIControlStateSelected];
        [_recBtn setBackgroundImage:nor forState:UIControlStateNormal];
        [_recBtn setBackgroundImage:image forState:UIControlStateSelected];
        _recBtn.layer.cornerRadius = 4;
        _recBtn.layer.masksToBounds = YES;
        [self addSubview:_recBtn];
        [_funs addObject:_recBtn];
    }
    
    _speedBtn = [[UIButton alloc] init];
    [_speedBtn setTitle:@"测速" forState:UIControlStateNormal];
    [_speedBtn addTarget:self action:@selector(onTestSpeed:) forControlEvents:UIControlEventTouchUpInside];
    _speedBtn.titleLabel.font = kAppSmallTextFont;
    [_speedBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
    [_speedBtn setBackgroundImage:nor forState:UIControlStateNormal];
    [_speedBtn setBackgroundImage:image forState:UIControlStateSelected];
    _speedBtn.layer.cornerRadius = 4;
    _speedBtn.layer.masksToBounds = YES;
    [self addSubview:_speedBtn];
    [_funs addObject:_speedBtn];
    
    if (_config.isHost)
    {
        _linkRoomBtn = [[UIButton alloc] init];
        [_linkRoomBtn setTitle:@"串 门" forState:UIControlStateNormal];
        [_linkRoomBtn addTarget:self action:@selector(onLinkRoomAction) forControlEvents:UIControlEventTouchUpInside];
        _linkRoomBtn.titleLabel.font = kAppSmallTextFont;
        [_linkRoomBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
        [_linkRoomBtn setBackgroundImage:nor forState:UIControlStateNormal];
        [_linkRoomBtn setBackgroundImage:image forState:UIControlStateSelected];
        _linkRoomBtn.layer.cornerRadius = 4;
        _linkRoomBtn.layer.masksToBounds = YES;
        [self addSubview:_linkRoomBtn];
        [_funs addObject:_linkRoomBtn];
        
        _unlinkRoomBtn = [[UIButton alloc] init];
        [_unlinkRoomBtn setTitle:@"取消串门" forState:UIControlStateNormal];
        [_unlinkRoomBtn addTarget:self action:@selector(onUnLinkRoomAction) forControlEvents:UIControlEventTouchUpInside];
        _unlinkRoomBtn.titleLabel.font = kAppSmallTextFont;
        [_unlinkRoomBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
        [_unlinkRoomBtn setBackgroundImage:nor forState:UIControlStateNormal];
        [_unlinkRoomBtn setBackgroundImage:image forState:UIControlStateSelected];
        _unlinkRoomBtn.layer.cornerRadius = 4;
        _unlinkRoomBtn.layer.masksToBounds = YES;
        [self addSubview:_unlinkRoomBtn];
        [_funs addObject:_unlinkRoomBtn];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    int maxColumn = 5;
    NSInteger width = (rect.size.width - (maxColumn + 1)*3) / maxColumn;
    if (width > 80)
    {
        width = 80;
    }
    CGFloat marginX = 3;
    if (_funs.count < 5)//按钮较少时，靠右对齐
    {
        int magin = ((5 - (int)_funs.count) + 1)*3 + (5 - (int)_funs.count)*(int)width;
        rect.origin.x += magin;
    }
    [self gridViews:_funs inColumn:5 size:CGSizeMake(width, 24) margin:CGSizeMake(marginX, kDefaultMargin) inRect:rect];
}

- (void)onInteract:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onInteract)])
    {
        [self.delegate onInteract];
    }
}

- (void)onPar:(UIButton *)button
{
    _versionInfo = [NSMutableString string];
    NSString *iliveSDKVer = [NSString stringWithFormat:@"ilivesdk: %@\n",[[ILiveSDK getInstance] getVersion]];
    [_versionInfo appendString:iliveSDKVer];
    NSString *tilliveSDKVer = [NSString stringWithFormat:@"tillivesdk: %@\n",[[TILLiveManager getInstance] getVersion]];
    [_versionInfo appendString:tilliveSDKVer];
    NSString *imSDKVer = [NSString stringWithFormat:@"imsdk: %@\n",[[TIMManager sharedInstance] GetVersion]];
    [_versionInfo appendString:imSDKVer];
    NSString *avSDKVer = [NSString stringWithFormat:@"avsdk: %@\n",[QAVContext getVersion]];
    [_versionInfo appendString:avSDKVer];
    NSString *filterSDKVer = [NSString stringWithFormat:@"filter:%@\n",[TILFilter getVersion]];
    [_versionInfo appendString:filterSDKVer];
    
    if (!button.selected)
    {
        __weak typeof(self) ws = self;
        
        ws.paramTextView = [[UITextView alloc] init];
        CGRect selfRect = self.frame;
        ws.paramTextView.editable = NO;
        ws.paramTextView.font = kAppLargeTextFont;
        ws.paramTextView.backgroundColor = [kColorLightGray colorWithAlphaComponent:0.5];
        [ws.paramTextView setFrame:CGRectMake(0, selfRect.origin.y+selfRect.size.height+kDefaultMargin, selfRect.size.width, 350)];
        [self.superview addSubview:ws.paramTextView];
        _logTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(onLogTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_logTimer forMode:NSDefaultRunLoopMode];
    }
    else
    {
        if (_paramTextView)
        {
            [_paramTextView removeFromSuperview];
        }
        [_logTimer invalidate];
        _logTimer = nil;
    }
    button.selected = !button.selected;
}

- (void)onLogTimer
{
    __weak typeof(self) ws = self;
    QAVContext *context = [[ILiveSDK getInstance] getAVContext];
    if (context.videoCtrl && context.audioCtrl && context.room)
    {
        ILiveQualityData *qualityData = [[ILiveRoomManager getInstance] getQualityData];
        NSMutableString *paramString = [NSMutableString string];
        //FPS
        [paramString appendString:[NSString stringWithFormat:@"FPS:%ld.\n",qualityData.interactiveSceneFPS/10]];
        //Send Recv
        [paramString appendString:[NSString stringWithFormat:@"Send: %ldkbps, Recv: %ldkbps.\n",qualityData.sendRate,(long)qualityData.recvRate]];
        //sendLossRate recvLossRate
        CGFloat sendLossRate = (CGFloat)qualityData.sendLossRate / (CGFloat)100;
        CGFloat recvLossRate = (CGFloat)qualityData.recvLossRate / (CGFloat)100;
        NSString *per = @"%";
        [paramString appendString:[NSString stringWithFormat:@"SendLossRate: %.2f%@,   RecvLossRate: %.2f%@.\n",sendLossRate,per,recvLossRate,per]];
        
        //appcpu syscpu
        CGFloat appCpuRate = (CGFloat)qualityData.appCPURate / (CGFloat)100;
        CGFloat sysCpuRate = (CGFloat)qualityData.sysCPURate / (CGFloat)100;
        [paramString appendString:[NSString stringWithFormat:@"AppCPURate:   %.2f%@,   SysCPURate:   %.2f%@.\n",appCpuRate,per,sysCpuRate,per]];
        
        //分别角色的分辨率
        NSArray *keys = [_resolutionDic allKeys];
        for (NSString *key in keys)
        {
            QAVFrameDesc *desc = _resolutionDic[key];
            [paramString appendString:[NSString stringWithFormat:@"%@---> %d * %d\n",key,desc.width,desc.height]];
        }
        //avsdk版本号
        NSString *avSDKVer = [NSString stringWithFormat:@"AVSDK版本号: %@\n",[QAVContext getVersion]];
        [paramString appendString:avSDKVer];
        //房间号
        int roomid = [[ILiveRoomManager getInstance] getRoomId];
        [paramString appendString:[NSString stringWithFormat:@"房间号:%d\n",roomid]];
        //角色
        NSString *roleStr = _config.isHost ? @"主播" : @"非主播";
        [paramString appendString:[NSString stringWithFormat:@"角色:%@\n",roleStr]];
        
        //采集信息
        NSString *videoParam = [context.videoCtrl getQualityTips];
        NSArray *array = [videoParam componentsSeparatedByString:@"\n"]; //从字符A中分隔成2个元素的数组
        if (array.count > 3)
        {
            NSString *resolution = [array objectAtIndex:2];
            [paramString appendString:[NSString stringWithFormat:@"%@\n",resolution]];
        }
        //麦克风
        NSString *isOpen = [[ILiveRoomManager getInstance] getCurMicState] ? @"ON" : @"OFF";
        [paramString appendString:[NSString stringWithFormat:@"麦克风: %@\n",isOpen]];
        //扬声器
        NSString *isOpenSpeaker = [[ILiveRoomManager getInstance] getCurSpeakerState] ? @"ON" : @"OFF";
        [paramString appendString:[NSString stringWithFormat:@"扬声器: %@\n",isOpenSpeaker]];
        
        [paramString appendString:_versionInfo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ws.paramTextView.text = paramString;
        });
    }
}

- (void)onPush:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected)
    {
        __weak typeof(self) ws = self;
        AlertActionHandle hlsBlock = ^(UIAlertAction * _Nonnull action){
            [ws pushStream:button encodeType:ILive_ENCODE_HLS recordType:ILive_RECORD_FILE_TYPE_MP4];
        };
        AlertActionHandle rtmpBlock = ^(UIAlertAction * _Nonnull action){
            [ws pushStream:button encodeType:ILive_ENCODE_RTMP recordType:ILive_RECORD_FILE_TYPE_MP4];
        };
        NSDictionary *funs = @{@"HLS推流":hlsBlock, @"RTMP推流":rtmpBlock};
        [AlertHelp alertWith:nil message:nil funBtns:funs cancelBtn:@"取消" alertStyle:UIAlertControllerStyleActionSheet cancelAction:^(UIAlertAction * _Nonnull action) {
            button.selected = !button.selected;
        }];
    }
    else
    {
        [self stopPushStream];
    }
}

- (void)pushStream:(UIButton *)button encodeType:(ILiveEncodeType)encodeType recordType:(ILiveRecordFileType)recordType
{
    ILiveChannelInfo *info = [[ILiveChannelInfo alloc] init];
    info.channelName = [NSString stringWithFormat:@"新随心播推流_%@",[[ILiveLoginManager getInstance] getLoginId]];
    info.channelDesc = [NSString stringWithFormat:@"新随心播推流描述测试文本"];
    
    ILivePushOption *option = [[ILivePushOption alloc] init];
    option.channelInfo = info;
    option.encodeType = encodeType;
    option.recrodFileType = recordType;
    
    __weak typeof(self) ws = self;
    [[ILiveRoomManager getInstance] startPushStream:option succ:^(id selfPtr) {
        AVStreamerResp *resp = (AVStreamerResp *)selfPtr;
        NSLog(@"--->resp %@",resp);
        [ws setChannelId:resp.channelID];
        AVLiveUrl *url = nil;
        if (resp && resp.urls && resp.urls.count > 0)
        {
            url = resp.urls[0];
        }
        NSString *msg = url ? url.playUrl : @"url为nil";
        
        AlertActionHandle copyBlock = ^(UIAlertAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:msg];
        };
        AlertActionHandle copyShareBlock = ^(UIAlertAction * _Nonnull action){
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:msg];
            [ws shareLive:msg];
        };
        NSDictionary *funs = @{@"复制":copyBlock, @"复制并分享":copyShareBlock};
        [AlertHelp alertWith:nil message:msg funBtns:funs cancelBtn:@"取消" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        button.selected = !button.selected;
        NSString *errinfo = [NSString stringWithFormat:@"push stream fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
        NSLog(@"%@",errinfo);
        [AlertHelp alertWith:@"推流失败" message:errinfo cancelBtn:@"明白了" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
    }];
}

- (void)shareLive:(NSString *)url
{
    //分享链接到社交平台
    NSArray* imageArray = @[_config.item.info.cover];
    if (!imageArray)
    {
        return;
    }
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:@"走过路过，不要错过~快来观看直播吧！" images:imageArray url:[NSURL URLWithString:url] title:_config.item.info.title type:SSDKContentTypeAuto];
    //有的平台要客户端分享需要加此方法，例如微博
    [shareParams SSDKEnableUseClientShare];
    //可以弹出分享菜单和编辑界面
    [ShareSDK showShareActionSheet:nil items:nil shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData,SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        switch (state)
        {
            case SSDKResponseStateSuccess:
            {
                [AlertHelp alertWith:@"分享成功" message:nil cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
                break;
            }
            case SSDKResponseStateFail:
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [AlertHelp alertWith:@"分享失败" message:[NSString stringWithFormat:@"%@",error] cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
                });
                break;
            }
            case SSDKResponseStateCancel:
            {
                break;
            }
            default:
                break;
        }
    }];
}

- (void)stopPushStream
{
    __weak typeof(self) ws = self;
    [[ILiveRoomManager getInstance] stopPushStreams:@[@(_channelId)] succ:^{
        [ws setChannelId:0];//重置channelid
        [AlertHelp alertWith:@"已停止推流" message:nil cancelBtn:@"好的" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSString *errinfo = [NSString stringWithFormat:@"push stream fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
        NSLog(@"%@",errinfo);
        [AlertHelp alertWith:@"停止推流失败" message:errinfo cancelBtn:@"明白了" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
    }];
}

- (void)setChannelId:(UInt64)channelId
{
    _channelId = channelId;
}

- (void)onRecord:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected)
    {
        __weak typeof(self) ws = self;
        AlertActionHandle videoRecordBlock = ^(UIAlertAction * _Nonnull action){
            [ws startRecord:button type:ILive_RECORD_TYPE_VIDEO];
        };
        AlertActionHandle audioRecordBlock = ^(UIAlertAction * _Nonnull action){
            [ws startRecord:button type:ILive_RECORD_TYPE_AUDIO];
        };
        NSDictionary *funs = @{@"视频录制":videoRecordBlock,@"纯音频录制":audioRecordBlock};
        [AlertHelp alertWith:nil message:nil funBtns:funs cancelBtn:@"取消" alertStyle:UIAlertControllerStyleActionSheet cancelAction:^(UIAlertAction * _Nonnull action) {
            button.selected = !button.selected;
        }];
    }
    else
    {
        [[ILiveRoomManager getInstance] stopRecordVideo:^(id selfPtr) {
            [AlertHelp alertWith:@"已停止录制" message:nil cancelBtn:@"好的" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
            
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            button.selected = !button.selected;
            NSString *errinfo = [NSString stringWithFormat:@"push stream fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
            NSLog(@"%@",errinfo);
            [AlertHelp alertWith:@"停止录制失败" message:errinfo cancelBtn:@"明白了" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        }];
    }
}

- (void)showEditAlert:(UIViewController *)rootVC title:(NSString *)title message:(NSString *)msg placeholder:(NSString *)holder okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle ok:(EditAlertHandle)succ cancel:(ActionHandle)fail
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = holder;
    }];
    if (okTitle)
    {
        [alert addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            succ(alert.textFields.firstObject.text);
        }]];
    }
    if (cancelTitle)
    {
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:fail]];
    }
    [rootVC presentViewController:alert animated:YES completion:nil];
}

- (void)removeSelfAndLinked:(NSMutableArray *)array
{
    NSArray *linkedUsers = [[TILLiveManager getInstance] getCurrentLinkedUserArray];
    NSMutableArray *willRemoveItems = [NSMutableArray array];
    for (TCShowLiveListItem *item in array)
    {
        if ([item.uid isEqualToString:[[ILiveLoginManager getInstance] getLoginId]])
        {
            //            [array removeObject:item];
            [willRemoveItems addObject:item];
        }
        else
        {
            NSUInteger index = [linkedUsers indexOfObject:item.uid];
            if (index != NSNotFound)
            {
                //                [array removeObject:item];
                [willRemoveItems addObject:item];
            }
        }
    }
    [array removeObjectsInArray:willRemoveItems];
}

- (void)onLinkRoomAction
{
    //向业务后台请求直播间列表
    __weak typeof(self) ws = self;
    RoomListRequest *listReq = [[RoomListRequest alloc] initWithHandler:^(BaseRequest *request) {
        RoomListRequest *wreq = (RoomListRequest *)request;
        RoomListRspData *respData = (RoomListRspData *)wreq.response.data;
        [ws removeSelfAndLinked:respData.rooms];
        dispatch_async(dispatch_get_main_queue(), ^{
            LinkRoomList *roomList = [[LinkRoomList alloc] init];
            RoomListConfig *config = [[RoomListConfig alloc] init];
            CGRect rect = [UIScreen mainScreen].bounds;
            config.frame = CGRectMake(rect.origin.x, rect.origin.y-rect.size.height, rect.size.width, rect.size.height);
            config.liveList = respData.rooms;
            [roomList configRoomList:config];
            [ws.superview addSubview:roomList];
            [UIView animateWithDuration:0.5 animations:^{
                [roomList setFrame:rect];
            } completion:^(BOOL finished) {
                roomList.roomListconfig.frame = rect;
            }];
        });
    } failHandler:^(BaseRequest *request) {
        NSString *logInfo = [NSString stringWithFormat:@"code=%ld,mesg=%@",(long)request.response.errorCode,request.response.errorInfo];
        [AlertHelp alertWith:@"获取主播列表失败" message:logInfo cancelBtn:@"算了" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
    }];
    listReq.token = [AppDelegate sharedAppDelegate].token;
    listReq.type = @"live";
    RequestPageParamItem *pageItem = [[RequestPageParamItem alloc] init];
    listReq.index = pageItem.pageIndex;
    listReq.size = pageItem.pageSize;
    listReq.appid = [ShowAppId intValue];
    [[WebServiceEngine sharedEngine] asyncRequest:listReq wait:YES];
}

- (void)onUnLinkRoomAction
{
    AlertActionHandle okBlock = ^(UIAlertAction *_Nonnull action){
        [[TILLiveManager getInstance] unLinkRoom:^{
            [AlertHelp tipWith:@"已结束跨房连麦" wait:1];
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            NSString *errInfo = [NSString stringWithFormat:@"module=%@,code=%d,msg=%@",module,errId,errMsg];
            [AlertHelp alertWith:@"结束跨房连麦失败" message:errInfo cancelBtn:@"明白了" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        }];
    };
    [AlertHelp alertWith:@"结束跨房连麦" message:@"确定结束所有跨房连麦吗？" funBtns:@{@"确定":okBlock} cancelBtn:@"取消" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
}

- (void)startRecord:(UIButton *)button type:(ILiveRecordType)recordType
{
    __weak typeof(self) ws = self;
    [self showEditAlert:[AlertHelp topViewController] title:@"输入录制文件名" message:nil placeholder:@"录制文件名" okTitle:@"确定" cancelTitle:@"取消" ok:^(NSString * _Nonnull editString) {
        NSString *recName = editString && editString.length > 0 ? editString : @"sxb默认录制文件名";
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(onRecReport:type:)])
        {
            [ws.delegate onRecReport:recName type:recordType];
        }
        ILiveRecordOption *option = [[ILiveRecordOption alloc] init];
        NSString *identifier = [[ILiveLoginManager getInstance] getLoginId];
        option.fileName = [NSString stringWithFormat:@"sxb_%@_%@",identifier,recName];
        option.recordType = recordType;
        [[ILiveRoomManager getInstance] startRecordVideo:option succ:^{
            [AlertHelp alertWith:@"已开始录制" message:nil cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];

        } failed:^(NSString *module, int errId, NSString *errMsg) {
            button.selected = !button.selected;
            NSString *errinfo = [NSString stringWithFormat:@"push stream fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
            NSLog(@"%@",errinfo);
            [AlertHelp alertWith:@"开始录制失败" message:errinfo cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        }];
    } cancel:^(UIAlertAction * _Nonnull action) {
        button.selected = !button.selected;
    }];
}

- (void)onTestSpeed:(UIButton *)button
{
    SpeedTestRequestParam *param = [[SpeedTestRequestParam alloc] init];
    [[ILiveSpeedTestManager shareInstance] requestSpeedTest:param succ:^{
        
    } fail:^(NSString *module, int errId, NSString *errMsg) {
        NSString *string = [NSString stringWithFormat:@"module=%@,code=%d,msg=%@",module,errId,errMsg];
        [AlertHelp alertWith:@"请求测速失败" message:string cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
    }];
}

#pragma mark - measure speed delegate

//开始测速成功
- (void)onILiveSpeedTestStartSucc
{
    _alert = [UIAlertController alertControllerWithTitle:@"正在测速" message:@"0/0" preferredStyle:UIAlertControllerStyleAlert];
    [_alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[ILiveSpeedTestManager shareInstance] cancelSpeedTest:^{
            
        } fail:^(int code, NSString *msg) {
            NSString *string = [NSString stringWithFormat:@"code=%d,msg=%@",code,msg];
            [AlertHelp alertWith:@"取消测速失败" message:string cancelBtn:@"明白了" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        }];
    }]];
    [[AlertHelp topViewController] presentViewController:_alert animated:YES completion:nil];
}

//开始测速失败
- (void)onILiveSpeedTestStartFail:(int)code errMsg:(NSString *)errMsg
{
    NSString *string = [NSString stringWithFormat:@"code=%d,msg=%@",code,errMsg];
    [AlertHelp alertWith:@"开始测速失败" message:string cancelBtn:@"明白了" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
}

//测速进度回调
- (void)onILiveSpeedTestProgress:(SpeedTestProgressItem *)item
{
    if (_alert)
    {
        _alert.message = [NSString stringWithFormat:@"%d/%d", item.recvPkgNum, item.totalPkgNum];
    }
}

//测速完成(超时时间30s)
- (void)onILiveSpeedTestCompleted:(SpeedTestResult *)result code:(int)code msg:(NSString *)msg
{
    if (code == 0)
    {
//        [_alert dismissViewControllerAnimated:YES completion:nil];
        
        NSMutableString *text = [NSMutableString string];
        //测试信息
        //测速id
        [text appendFormat:@"测速Id：%llu\n", result.testId];
        //测速结束时间
        [text appendFormat:@"测速结束时间：%llu\n", result.testTime];
        //客户端类型
        [text appendFormat:@"客户端类型：%llu.(3:iphone 4:ipad)\n", result.clientType];
        //网络类型
        [text appendFormat:@"网络类型：%d.(1:wifi 2,3,4(G))\n", result.netType];
        //网络变换次数
        [text appendFormat:@"网络变换次数：%d.\n", result.netChangeCnt];
        //客户端ip
        [text appendFormat:@"客户端IP：%d(%@)\n", result.clientIp,[self ip4FromUInt:result.clientIp]];
        //通话类型
        [text appendFormat:@"通话类型：%d(0:纯音频，1:音视频)\n", result.callType];
        //sdkappid
        [text appendFormat:@"SDKAPPID：%d\n", result.sdkAppid];
        //测试结果列表
        for (SpeedTestResultItem *item in result.results)
        {
            //接口机端口、ip
            NSString *accInfo = [NSString stringWithFormat:@"%d:%u(%@)\n",item.accessPort,item.accessIp,[self ip4FromUInt:item.accessIp]];
            [text appendString:accInfo];
            //运营商 测试次数
            [text appendFormat:@"%@:%@:%@; 测试次数:%d\n",item.accessCountry,item.accessProv,item.accessIsp,item.testCnt];
            //上行、下行丢包率，平均延时
            [text appendFormat:@"upLoss:%d,dwLoss:%d,延时:%dms.\n",item.upLoss,item.dwLoss,item.avgRtt];
        }
        AlertActionHandle copyBlock = ^(UIAlertAction * _Nonnull action){
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:text];
        };
        [AlertHelp alertWith:@"测速结果" message:text funBtns:@{@"复制":copyBlock} cancelBtn:@"关闭" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
    }
    else
    {
        //测速失败
        NSString *str = [NSString stringWithFormat:@"%d,%@",code,msg];
        [AlertHelp alertWith:@"测速失败" message:str cancelBtn:@"关闭" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
    }
}

- (NSString *)ip4FromUInt:(unsigned int)ipNumber
{
    if (sizeof (unsigned int) != 4)
    {
        NSLog(@"Unkown type!");
        return @"";
    }
    unsigned int mask = 0xFF000000;
    unsigned int array[sizeof(unsigned int)];
    int steps = 8;
    int counter;
    for (counter = 0; counter < 4 ; counter++)
    {
        array[counter] = ((ipNumber & mask) >> (32-steps*(counter+1)));
        mask >>= steps;
    }
    NSMutableString *mutableString = [NSMutableString string];
    for (int index = counter-1; index >=0; index--)
    {
        [mutableString appendString:[NSString stringWithFormat:@"%d",array[index]]];
        if (index != 0)
        {
            [mutableString appendString:@"."];
        }
    }
    
    return mutableString;
}
@end

@implementation LiveUIParViewConfig
@end
