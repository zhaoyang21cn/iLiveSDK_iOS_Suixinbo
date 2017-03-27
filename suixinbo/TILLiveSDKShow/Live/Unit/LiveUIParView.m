//
//  LiveUIParView.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LiveUIParView.h"

#import <ShareSDKUI/ShareSDK+SSUI.h>//用于实现社交分享

@interface LiveUIParView () <ILiveSpeedTestDelegate>
{
    UInt64  _channelId;
}
@end

UIAlertController *_alert;

@implementation LiveUIParView

- (instancetype)init
{
    if (self = [super init])
    {
        [self addAVParamSubViews];
        _resolutionDic = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onParPure:) name:kPureDelete_Notification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onParNoPure:) name:kNoPureDelete_Notification object:nil];
        [ILiveSpeedTestManager shareInstance].delegate = self;
    }
    return self;
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
    //AV Param View
    _interactBtn = [[UIButton alloc] init];
    [_interactBtn setImage:[UIImage imageNamed:@"interactive"] forState:UIControlStateNormal];
    [_interactBtn addTarget:self action:@selector(onInteract:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_interactBtn];
    
    UIImage *nor = [UIImage imageWithColor:[RGB(220, 220, 220) colorWithAlphaComponent:0.5]];
    UIImage *hig = [UIImage imageWithColor:[RGB(110, 110, 110) colorWithAlphaComponent:0.5]];
    
    _parBtn = [[UIButton alloc] init];
    [_parBtn setTitle:@"PAR" forState:UIControlStateNormal];
    _parBtn.titleLabel.font = kAppMiddleTextFont;
    [_parBtn addTarget:self action:@selector(onPar:) forControlEvents:UIControlEventTouchUpInside];
    [_parBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
    [_parBtn setTitleColor:kColorWhite forState:UIControlStateSelected];
    [_parBtn setBackgroundImage:nor forState:UIControlStateNormal];
    [_parBtn setBackgroundImage:hig forState:UIControlStateSelected];
    _parBtn.layer.cornerRadius = 4;
    _parBtn.layer.masksToBounds = YES;
    [self addSubview:_parBtn];
    
    _pushStreamBtn = [[UIButton alloc] init];
    [_pushStreamBtn setTitle:@"开始推流" forState:UIControlStateNormal];
    [_pushStreamBtn setTitle:@"关闭推流" forState:UIControlStateSelected];
    [_pushStreamBtn addTarget:self action:@selector(onPush:) forControlEvents:UIControlEventTouchUpInside];
    if (self.bounds.size.width <= 320)
    {
        _pushStreamBtn.titleLabel.font = kAppSmallTextFont;
    }
    else
    {
        _pushStreamBtn.titleLabel.font = kAppMiddleTextFont;
    }
    [_pushStreamBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
    [_pushStreamBtn setTitleColor:kColorWhite forState:UIControlStateSelected];
    [_pushStreamBtn setBackgroundImage:nor forState:UIControlStateNormal];
    [_pushStreamBtn setBackgroundImage:hig forState:UIControlStateSelected];
    _pushStreamBtn.layer.cornerRadius = 4;
    _pushStreamBtn.layer.masksToBounds = YES;
    [self addSubview:_pushStreamBtn];
    
    UIImage *recHig = [UIImage imageWithColor:[kColorBlue colorWithAlphaComponent:0.5]];
    _recBtn = [[UIButton alloc] init];
    [_recBtn setTitle:@"REC" forState:UIControlStateNormal];
    [_recBtn addTarget:self action:@selector(onRecord:) forControlEvents:UIControlEventTouchUpInside];
    _recBtn.titleLabel.font = kAppMiddleTextFont;
    [_recBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
    [_recBtn setTitleColor:kColorWhite forState:UIControlStateSelected];
    [_recBtn setBackgroundImage:nor forState:UIControlStateNormal];
    [_recBtn setBackgroundImage:recHig forState:UIControlStateSelected];
    _recBtn.layer.cornerRadius = 4;
    _recBtn.layer.masksToBounds = YES;
    [self addSubview:_recBtn];
    
    _speedBtn = [[UIButton alloc] init];
    [_speedBtn setTitle:@"测速" forState:UIControlStateNormal];
    [_speedBtn addTarget:self action:@selector(onTestSpeed:) forControlEvents:UIControlEventTouchUpInside];
    _speedBtn.titleLabel.font = kAppMiddleTextFont;
    [_speedBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
    [_speedBtn setBackgroundImage:nor forState:UIControlStateNormal];
    [_speedBtn setBackgroundImage:recHig forState:UIControlStateSelected];
    _speedBtn.layer.cornerRadius = 4;
    _speedBtn.layer.masksToBounds = YES;
    [self addSubview:_speedBtn];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    NSMutableArray *funs = [NSMutableArray array];
    if (_isHost)
    {
        [funs addObjectsFromArray:@[_interactBtn,_parBtn,_pushStreamBtn,_recBtn,_speedBtn]];
    }
    else
    {
        [funs addObjectsFromArray:@[_parBtn,_pushStreamBtn,_recBtn,_speedBtn]];
    }
    NSInteger width = (rect.size.width - (funs.count + 1)*3) / funs.count;
    if (width > 80)
    {
        width = 80;
    }
    [self gridViews:funs inColumn:funs.count size:CGSizeMake(width, 24) margin:CGSizeMake(3, 3) inRect:rect];
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
    if (!button.selected)
    {
        __weak typeof(self) ws = self;
        
        ws.paramTextView = [[UITextView alloc] init];
        CGRect selfRect = self.frame;
        ws.paramTextView.editable = NO;
        [ws.paramTextView setFrame:CGRectMake(0, selfRect.origin.y+selfRect.size.height+kDefaultMargin, selfRect.size.width, 350)];
        ws.paramTextView.backgroundColor = [kColorLightGray colorWithAlphaComponent:0.5];
        [self.superview addSubview:ws.paramTextView];

        _logTimer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            
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
                NSString *roleStr = _isHost ? @"主播" : @"非主播";
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
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    ws.paramTextView.text = paramString;
                });
            }
        }];
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

- (void)onPush:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected)
    {
        __weak typeof(self) ws = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"HLS推流" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws pushStream:button encodeType:AV_ENCODE_HLS recordType:AV_RECORD_FILE_TYPE_MP4];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"RTMP推流" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws pushStream:button encodeType:AV_ENCODE_RTMP recordType:AV_RECORD_FILE_TYPE_MP4];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            button.selected = !button.selected;
        }]];
        [[AppDelegate sharedAppDelegate].navigationViewController presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [self stopPushStream];
    }
}

- (void)pushStream:(UIButton *)button encodeType:(AVEncodeType)encodeType recordType:(AVRecordFileType)recordType
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        if (encodeType != AV_ENCODE_RTMP)
        {
            [alert addAction:[UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ws shareLive:msg];
            }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:msg];
        }]];
        [[AppDelegate sharedAppDelegate].navigationViewController presentViewController:alert animated:YES completion:nil];
        
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        button.selected = !button.selected;
        NSString *errinfo = [NSString stringWithFormat:@"push stream fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
        NSLog(@"%@",errinfo);
        [ws showAlert:@"推流失败" message:errinfo okTitle:@"确认" cancelTitle:nil ok:nil cancel:nil];
    }];
}

- (void)shareLive:(NSString *)url
{
    //分享链接到社交平台
    NSArray* imageArray = @[_coverUrl];
    if (!imageArray)
    {
        return;
    }
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:@"走过路过，不要错过~快来观看直播吧！" images:imageArray url:[NSURL URLWithString:url] title:_roomTitle type:SSDKContentTypeAuto];
    //有的平台要客户端分享需要加此方法，例如微博
    [shareParams SSDKEnableUseClientShare];
    //可以弹出分享菜单和编辑界面
    [ShareSDK showShareActionSheet:nil items:nil shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData,SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        switch (state)
        {
            case SSDKResponseStateSuccess:
            {
                [self showAlert:@"分享成功" message:nil okTitle:@"确定" cancelTitle:@"取消" ok:nil cancel:nil];
                break;
            }
            case SSDKResponseStateFail:
            {
                [self showAlert:@"分享失败" message:[NSString stringWithFormat:@"%@",error] okTitle:@"确定" cancelTitle:@"取消" ok:nil cancel:nil];
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
        [ws showAlert:@"已停止推流" message:nil okTitle:@"确认" cancelTitle:nil ok:nil cancel:nil];
        
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSString *errinfo = [NSString stringWithFormat:@"push stream fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
        NSLog(@"%@",errinfo);
        [ws showAlert:@"停止推流失败" message:errinfo okTitle:@"确认" cancelTitle:nil ok:nil cancel:nil];
    }];
}

- (void)showAlert:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle ok:(ActionHandle)succ cancel:(ActionHandle)fail
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    if (cancelTitle)
    {
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:fail]];
    }
    if (okTitle)
    {
        [alert addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:succ]];
    }
    [[AppDelegate sharedAppDelegate].navigationViewController presentViewController:alert animated:YES completion:nil];
}

- (void)setChannelId:(UInt64)channelId
{
    _channelId = channelId;
}

- (void)onRecord:(UIButton *)button
{
    button.selected = !button.selected;
    __weak typeof(self) ws = self;
    if (button.selected)
    {
        __weak typeof(self) ws = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"视频录制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [ws startRecord:button type:AV_RECORD_TYPE_VIDEO];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"纯音频录制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [ws startRecord:button type:AV_RECORD_TYPE_AUDIO];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            button.selected = !button.selected;
        }]];
        [[AppDelegate sharedAppDelegate].navigationViewController presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [[ILiveRoomManager getInstance] stopRecordVideo:^(id selfPtr) {
            [ws showAlert:@"已停止录制" message:nil okTitle:nil cancelTitle:@"确定" ok:nil cancel:nil];
            
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            button.selected = !button.selected;
            NSString *errinfo = [NSString stringWithFormat:@"push stream fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
            NSLog(@"%@",errinfo);
            [ws showAlert:@"停止录制失败" message:errinfo okTitle:@"确认" cancelTitle:nil ok:nil cancel:nil];
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

- (void)startRecord:(UIButton *)button type:(AVRecordType)recordType
{
    __weak typeof(self) ws = self;
    [self showEditAlert:[self viewController] title:@"输入录制文件名" message:nil placeholder:@"录制文件名" okTitle:@"确定" cancelTitle:@"取消" ok:^(NSString * _Nonnull editString) {
        NSString *recName = editString && editString.length > 0 ? editString : @"sxb默认录制文件名";
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(onRecReport:type:)])
        {
            [ws.delegate onRecReport:recName type:recordType];
        }
        ILiveRecordOption *option = [[ILiveRecordOption alloc] init];
        NSString *identifier = [[ILiveLoginManager getInstance] getLoginId];
        option.fileName = [NSString stringWithFormat:@"sxb_%@_%@",identifier,recName];
        option.recordType = recordType;
        __weak typeof(self) ws = self;
        [[ILiveRoomManager getInstance] startRecordVideo:option succ:^{
            [ws showAlert:@"已开始录制" message:nil okTitle:nil cancelTitle:@"确定" ok:nil cancel:nil];

        } failed:^(NSString *module, int errId, NSString *errMsg) {
            button.selected = !button.selected;
            NSString *errinfo = [NSString stringWithFormat:@"push stream fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
            NSLog(@"%@",errinfo);
            [ws showAlert:@"开始录制失败" message:errinfo okTitle:@"确认" cancelTitle:nil ok:nil cancel:nil];
        }];
    } cancel:^(UIAlertAction * _Nonnull action) {
        button.selected = !button.selected;
    }];
}

- (void)onTestSpeed:(UIButton *)button
{
    __weak typeof(self) ws = self;
    SpeedTestRequestParam *param = [[SpeedTestRequestParam alloc] init];
    [[ILiveSpeedTestManager shareInstance] requestSpeedTest:param succ:^{
        
    } fail:^(NSString *module, int errId, NSString *errMsg) {
        NSString *string = [NSString stringWithFormat:@"module=%@,code=%d,msg=%@",module,errId,errMsg];
        [ws showAlert:@"请求测速失败" message:string okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
    }];
}

#pragma mark - measure speed delegate

//开始测速成功
- (void)onILiveSpeedTestStartSucc
{
    __weak typeof(self) ws = self;
    _alert = [UIAlertController alertControllerWithTitle:@"正在测速" message:@"0/0" preferredStyle:UIAlertControllerStyleAlert];
    [_alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[ILiveSpeedTestManager shareInstance] cancelSpeedTest:^{
            
        } fail:^(int code, NSString *msg) {
            NSString *string = [NSString stringWithFormat:@"code=%d,msg=%@",code,msg];
            [ws showAlert:@"取消测速失败" message:string okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        }];
    }]];
    [[AppDelegate sharedAppDelegate].navigationViewController presentViewController:_alert animated:YES completion:nil];
}

//开始测速失败
- (void)onILiveSpeedTestStartFail:(int)code errMsg:(NSString *)errMsg
{
    NSString *string = [NSString stringWithFormat:@"code=%d,msg=%@",code,errMsg];
    [self showAlert:@"开始测速失败" message:string okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
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
        [_alert dismissViewControllerAnimated:YES completion:nil];
        
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
        [self showAlert:@"测速结果" message:text okTitle:@"复制" cancelTitle:@"关闭" ok:^(UIAlertAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:text];
        } cancel:nil];
    }
    else
    {
        //测速失败
        NSString *str = [NSString stringWithFormat:@"%d,%@",code,msg];
        [self showAlert:@"测速失败" message:str okTitle:nil cancelTitle:@"关闭" ok:nil cancel:nil];
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
