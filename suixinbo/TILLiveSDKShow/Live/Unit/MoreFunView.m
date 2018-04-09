   //
//  MoreFunView.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/4/6.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "MoreFunView.h"
//#import "LinkRoomList.h"

//每行显示最多按钮数
#define kRowMaxNum 4

@implementation MoreFunView

- (void)configMoreFun:(MoreFunItem *)item
{
    _item = item;
    [self setFrame:item.moreFunViewRect];
    [self addOwnViews];
    [self layoutViews];
}

- (void)addOwnViews
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    _funs = [NSMutableArray array];
    
    _clearBg = [[UIView alloc] init];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [_clearBg addGestureRecognizer:tap];
    [self addSubview:_clearBg];
    
    _alphaBg = [[UIView alloc] init];
    _alphaBg.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
    [_clearBg addSubview:_alphaBg];
    
//    if (_item.isHost)
//    {
//        _linkRoomBtn = [[UIButton alloc] init];
//        [self configBtn:_linkRoomBtn title:@"跨房连麦" normalImg:@"linkRoom" selectImg:nil action:@selector(onLinkRoom)];
//        [_alphaBg addSubview:_linkRoomBtn];
//        [_funs addObject:_linkRoomBtn];
//        
//        _endLinkRoomBtn = [[UIButton alloc] init];
//        [self configBtn:_endLinkRoomBtn title:@"断开连麦" normalImg:@"unlinkRoom" selectImg:nil action:@selector(onUnLinkRoom)];
//        [_alphaBg addSubview:_endLinkRoomBtn];
//        [_funs addObject:_endLinkRoomBtn];
//    }
    
    if (_item.isHost || _item.isUpVideo)
    {
        _filterBtn = [[UIButton alloc] init];
        [self configBtn:_filterBtn title:@"滤 镜" normalImg:@"filter" selectImg:nil action:@selector(onFilter)];
        [_alphaBg addSubview:_filterBtn];
        [_funs addObject:_filterBtn];
        
        _pendantBtn = [[UIButton alloc] init];
        [self configBtn:_pendantBtn title:@"挂 件" normalImg:@"pendant" selectImg:nil action:@selector(onPendant)];
        [_alphaBg addSubview:_pendantBtn];
        [_funs addObject:_pendantBtn];
    
        _changeAudioBtn = [[UIButton alloc] init];
        [self configBtn:_changeAudioBtn title:@"变 声" normalImg:@"changevol" selectImg:nil action:@selector(onChangeAudio)];
        [_alphaBg addSubview:_changeAudioBtn];
        [_funs addObject:_changeAudioBtn];
        
        _changeRoleBtn = [[UIButton alloc] init];
        [self configBtn:_changeRoleBtn title:@"切分辨率" normalImg:@"role" selectImg:nil action:@selector(onChangeRole)];
        [_alphaBg addSubview:_changeRoleBtn];
        [_funs addObject:_changeRoleBtn];
    }
    
    _reportLogBtn = [[UIButton alloc] init];
    [self configBtn:_reportLogBtn title:@"上报日志" normalImg:@"log_report" selectImg:nil action:@selector(onReportLog)];
    [_alphaBg addSubview:_reportLogBtn];
    [_funs addObject:_reportLogBtn];
    
    if (_item.isHost || _item.isUpVideo)
    {
        _flashBtn = [[UIButton alloc] init];
        [self configBtn:_flashBtn title:@"闪光灯" normalImg:@"flash" selectImg:@"flash_hover" action:@selector(onFlash)];
        [_alphaBg addSubview:_flashBtn];
        [_funs addObject:_flashBtn];
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && (device.torchMode==AVCaptureTorchModeOn))
        {
            _flashBtn.selected = YES;
        }
    }
//    [self test];
}

- (void)configBtn:(UIButton *)button title:(NSString *)title normalImg:(NSString *)norImgName selectImg:(NSString *)selImgName action:(SEL)action
{
    UIImage *norImage = [UIImage imageNamed:norImgName];
    UIImage *selImage = [UIImage imageNamed:selImgName];
    [button setImage:norImage forState:UIControlStateNormal];
    [button setImage:selImage forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:RGB(255, 210, 87) forState:UIControlStateNormal];
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.backgroundColor = [UIColor clearColor];
    button.imageView.backgroundColor = [UIColor clearColor];
    CGSize logTitleSize = button.titleLabel.bounds.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(norImage.size.height, -logTitleSize.width, 0, 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, (80-norImage.size.width)/2, 20, 0);
    button.contentMode = UIViewContentModeCenter;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)onTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self dismissSelf];
    }
}

- (void)dismissSelf
{
    [UIView animateWithDuration:0.7 animations:^{
        CGRect selfRect = self.frame;
        selfRect.origin.y += selfRect.size.height;
        [self setFrame:selfRect];
        self.item.bottomView.hidden = NO;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)test
{
    for (int index = 0; index < 10; index++)
    {
        UIButton *test1 = [[UIButton alloc] init];
        [test1 setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [test1 setImage:[UIImage imageNamed:@"comment_hover"] forState:UIControlStateHighlighted];
        [test1 addTarget:self action:@selector(onChangeRole) forControlEvents:UIControlEventTouchUpInside];
        [_alphaBg addSubview:test1];
        [_funs addObject:test1];
    }
}

- (void)onFilter
{
    NSString *beautyScheme = [[NSUserDefaults standardUserDefaults] objectForKey:kBeautyScheme];
    if (!(beautyScheme && beautyScheme.length > 0))
    {
        [[NSUserDefaults standardUserDefaults] setValue:kILiveBeauty forKey:kBeautyScheme];
        beautyScheme = kILiveBeauty;
    }
    if ([beautyScheme isEqualToString:kILiveBeauty])
    {
        //TILFilterSDK滤镜
        [self ilivesdkFilter];
    }
//    else if ([beautyScheme isEqualToString:kQAVSDKBeauty])
//    {
//        //QAVSDK滤镜
//        [self qavsdkFilter];
//    }
}

//- (void)qavsdkFilter
//{
//    __weak typeof(self) ws = self;
//    NSString *path = [[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"FilterRes.bundle"];
//    QAVVideoEffectCtrl *effectCtrl = [QAVVideoEffectCtrl shareContext];
//    AlertActionHandle comicBlock = ^(UIAlertAction *_Nonnull action){
//        NSString * tmplPath = [path stringByAppendingPathComponent:@"COMIC"];
//        [effectCtrl setFilter:tmplPath];
//        [ws dismissSelf];
//    };
//    AlertActionHandle geseBlock = ^(UIAlertAction *_Nonnull action){
//        NSString * tmplPath = [path stringByAppendingPathComponent:@"GESE"];
//        [effectCtrl setFilter:tmplPath];
//        [ws dismissSelf];
//    };
//    AlertActionHandle btightfireBlock = ^(UIAlertAction *_Nonnull action){
//        NSString * tmplPath = [path stringByAppendingPathComponent:@"BRIGHTFIRE"];
//        [effectCtrl setFilter:tmplPath];
//        [ws dismissSelf];
//    };
//    AlertActionHandle skylineBlock = ^(UIAlertAction *_Nonnull action){
//        NSString * tmplPath = [path stringByAppendingPathComponent:@"SKYLINE"];
//        [effectCtrl setFilter:tmplPath];
//        [ws dismissSelf];
//    };
//    AlertActionHandle g1Block = ^(UIAlertAction *_Nonnull action){
//        NSString * tmplPath = [path stringByAppendingPathComponent:@"G1"];
//        [effectCtrl setFilter:tmplPath];
//        [ws dismissSelf];
//    };
//    AlertActionHandle orchidBlock = ^(UIAlertAction *_Nonnull action){
//        NSString * tmplPath = [path stringByAppendingPathComponent:@"ORCHID"];
//        [effectCtrl setFilter:tmplPath];
//        [ws dismissSelf];
//    };
//    AlertActionHandle shengdaiBlock = ^(UIAlertAction *_Nonnull action){
//        NSString * tmplPath = [path stringByAppendingPathComponent:@"SHENGDAI"];
//        [effectCtrl setFilter:tmplPath];
//        [ws dismissSelf];
//    };
//    AlertActionHandle amaroBlock = ^(UIAlertAction *_Nonnull action){
//        NSString * tmplPath = [path stringByAppendingPathComponent:@"AMARO"];
//        [effectCtrl setFilter:tmplPath];
//        [ws dismissSelf];
//    };
//    AlertActionHandle fenbiBlock = ^(UIAlertAction *_Nonnull action){
//        NSString * tmplPath = [path stringByAppendingPathComponent:@"FENBI"];
//        [effectCtrl setFilter:tmplPath];
//        [ws dismissSelf];
//    };
//    NSDictionary *funs = @{@"漫画(COMIC)":comicBlock, @"盛夏(GESE)":geseBlock, @"暖阳(BRIGHTFIRE)":btightfireBlock,@"月光(SKYLINE)":skylineBlock, @"蔷薇(G1)":g1Block, @"幽兰(ORCHID)":orchidBlock, @"圣代(SHENGDAI)":shengdaiBlock, @"薄荷(AMARO)":amaroBlock, @"浪漫(FENBI)":fenbiBlock};
//    [AlertHelp alertWith:nil message:nil funBtns:funs cancelBtn:@"取消" destructiveBtn:@"清空滤镜" alertStyle:UIAlertControllerStyleAlert cancelAction:nil destrutiveAction:^(UIAlertAction * _Nonnull action) {
//        [effectCtrl setFilter:nil];
//        [ws dismissSelf];
//    }];
//}

- (void)ilivesdkFilter
{
    [self.item.preProcessor setFilterMixLevel:5];
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/FilterResource/"];
    __weak typeof(self) ws = self;
    AlertActionHandle beautyBlock = ^(UIAlertAction *_Nonnull action){
        NSString * tmplPath = [path stringByAppendingString:@"white.png"];
        [ws.item.preProcessor setFilterImage:tmplPath];
        
        [ws dismissSelf];
    };
    AlertActionHandle fennenBlock = ^(UIAlertAction *_Nonnull action){
        NSString * tmplPath = [path stringByAppendingString:@"fennen.png"];
        [ws.item.preProcessor setFilterImage:tmplPath];
        [ws dismissSelf];
    };
    AlertActionHandle huaijiuBlock = ^(UIAlertAction *_Nonnull action){
        NSString * tmplPath = [path stringByAppendingString:@"huaijiu.png"];
        [ws.item.preProcessor setFilterImage:tmplPath];
        [ws dismissSelf];
    };
    AlertActionHandle landiaoBlock = ^(UIAlertAction *_Nonnull action){
        NSString * tmplPath = [path stringByAppendingString:@"landiao.png"];
        [ws.item.preProcessor setFilterImage:tmplPath];
        [ws dismissSelf];
    };
    AlertActionHandle langmanBlock = ^(UIAlertAction *_Nonnull action){
        NSString * tmplPath = [path stringByAppendingString:@"langman.png"];
        [ws.item.preProcessor setFilterImage:tmplPath];
        [ws dismissSelf];
    };
    AlertActionHandle qingliangBlock = ^(UIAlertAction *_Nonnull action){
        NSString * tmplPath = [path stringByAppendingString:@"qingliang.png"];
        [ws.item.preProcessor setFilterImage:tmplPath];
        [ws dismissSelf];
    };
    AlertActionHandle qingxinBlock = ^(UIAlertAction *_Nonnull action){
        NSString * tmplPath = [path stringByAppendingString:@"qingxin.png"];
        [ws.item.preProcessor setFilterImage:tmplPath];
        [ws dismissSelf];
    };
    AlertActionHandle rixiBlock = ^(UIAlertAction *_Nonnull action){
        NSString * tmplPath = [path stringByAppendingString:@"rixi.png"];
        [ws.item.preProcessor setFilterImage:tmplPath];
        [ws dismissSelf];
    };
    AlertActionHandle weimeiBlock = ^(UIAlertAction *_Nonnull action){
        NSString * tmplPath = [path stringByAppendingString:@"weimei.png"];
        [ws.item.preProcessor setFilterImage:tmplPath];
        [ws dismissSelf];
    };
    NSDictionary *funs = @{@"美颜美白":beautyBlock, @"粉嫩":fennenBlock, @"怀旧":huaijiuBlock,@"蓝调":landiaoBlock, @"浪漫":langmanBlock, @"清凉":qingliangBlock, @"清新":qingxinBlock, @"日系":rixiBlock, @"唯美":weimeiBlock};
    [AlertHelp alertWith:nil message:nil funBtns:funs cancelBtn:@"取消" destructiveBtn:@"清空滤镜" alertStyle:UIAlertControllerStyleAlert cancelAction:nil destrutiveAction:^(UIAlertAction * _Nonnull action) {
        [ws.item.preProcessor setFilterType:TXE_FILTER_TYPE_NONE];
        [ws dismissSelf];
    }];
}

- (void)onPendant
{
    __weak typeof(self) ws = self;
    AlertActionHandle tuziBlock = ^(UIAlertAction *_Nonnull action){
        NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/BeautyResource/"];
        NSString * tmplPath = [path stringByAppendingString:@"video_rabbit"];
        [ws.item.preProcessor setMotionTemplate:tmplPath];
        [ws dismissSelf];
    };
    AlertActionHandle xuebaiBlock = ^(UIAlertAction *_Nonnull action){
        NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/BeautyResource/"];
        NSString * tmplPath = [path stringByAppendingString:@"video_snow_white"];
        [ws.item.preProcessor setMotionTemplate:tmplPath];
        [ws dismissSelf];
    };
    NSDictionary *funs = @{@"兔子":tuziBlock, @"白雪公主":xuebaiBlock};
    [AlertHelp alertWith:nil message:nil funBtns:funs cancelBtn:@"取消" destructiveBtn:@"清空挂件" alertStyle:UIAlertControllerStyleAlert cancelAction:nil destrutiveAction:^(UIAlertAction * _Nonnull action) {
        [ws.item.preProcessor setMotionTemplate:nil];
        [ws dismissSelf];
    }];
}

- (void)onFlash
{
    cameraPos pos = [[ILiveRoomManager getInstance] getCurCameraPos];
    if (pos == CameraPosFront && !_flashBtn.selected)
    {
        [AlertHelp alertWith:nil message:@"前置摄像头打开闪光灯会影响直播" cancelBtn:@"取消" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        return;
    }
    _flashBtn.selected = !_flashBtn.selected;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch])
    {
        [device lockForConfiguration:nil];
        [device setTorchMode: _flashBtn.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

- (void)onChangeAudio
{
    __weak typeof(self) ws = self;
    AlertActionHandle block1 = ^(UIAlertAction * _Nonnull action){
        [ws changeAudio:QAV_VOICE_TYPE_LOLITA];
    };
    AlertActionHandle block2 = ^(UIAlertAction * _Nonnull action){
        [ws changeAudio:QAV_VOICE_TYPE_UNCLE];
    };
    AlertActionHandle block3 = ^(UIAlertAction * _Nonnull action){
        [ws changeAudio:QAV_VOICE_TYPE_INTANGIBLE];
    };
    AlertActionHandle block4 = ^(UIAlertAction * _Nonnull action){
        [ws changeAudio:QAV_VOICE_TYPE_KINDER_GARTEN];
    };
    AlertActionHandle block5 = ^(UIAlertAction * _Nonnull action){
        [ws changeAudio:QAV_VOICE_TYPE_HEAVY_GARTEN];
    };
    AlertActionHandle block6 = ^(UIAlertAction * _Nonnull action){
        [ws changeAudio:QAV_VOICE_TYPE_OPTIMUS_PRIME];
    };
    AlertActionHandle block7 = ^(UIAlertAction * _Nonnull action){
        [ws changeAudio:QAV_VOICE_TYPE_CAGED_ANIMAL];
    };
    AlertActionHandle block8 = ^(UIAlertAction * _Nonnull action){
        [ws changeAudio:QAV_VOICE_TYPE_DIALECT];
    };
    AlertActionHandle block9 = ^(UIAlertAction * _Nonnull action){
        [ws changeAudio:QAV_VOICE_TYPE_METAL_ROBOT];
    };
    AlertActionHandle block10 = ^(UIAlertAction * _Nonnull action){
        [ws changeAudio:QAV_VOICE_TYPE_DEAD_FATBOY];
    };
    AlertActionHandle block11 = ^(UIAlertAction * _Nonnull action){
        [ws changeAudio:QAV_VOICE_TYPE_ORIGINAL_SOUND];
    };
    NSDictionary *funs = @{@"萝莉":block1,@"大叔":block2,@"空灵":block3,@"幼稚园":block4,@"重机器":block5,@"擎天柱":block6,@"困兽":block7,@"土掉渣/歪果仁/方言":block8,@"金属机器人":block9,@"死肥仔":block10,@"原声":block11};
    [AlertHelp alertWith:@"变声" message:nil funBtns:funs cancelBtn:@"取消" alertStyle:UIAlertControllerStyleActionSheet cancelAction:nil];
}

- (void)changeAudio:(QAVVoiceType)type
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeAudioDelegate:)])
    {
        [self.delegate changeAudioDelegate:type];
    }
}

- (void)onChangeRole
{
    BOOL isVersionLow8_3 = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.3)
    {
        isVersionLow8_3 = YES;
    }
    
    __weak typeof(self) ws = self;
    AlertActionHandle hdBlock = ^(UIAlertAction * _Nonnull action){
        [[ILiveRoomManager getInstance] changeRole:kSxbRole_HostHD succ:^{
            ws.item.curRole = kSxbRole_HostHD;
            [ws changeRole:kSxbRole_HostHD];
            [AlertHelp tipWith:@"切换成功" wait:0.5];
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            NSString *logInfo = [NSString stringWithFormat:@"切换失败.module=%@,code=%d,msg=%@",module,errId,errMsg];
            [AlertHelp tipWith:logInfo wait:1];
        }];
    };
    AlertActionHandle sdBlock = ^(UIAlertAction * _Nonnull action){
        [[ILiveRoomManager getInstance] changeRole:kSxbRole_HostSD succ:^{
            ws.item.curRole = kSxbRole_HostSD;
            [ws changeRole:kSxbRole_HostSD];
            [AlertHelp tipWith:@"切换成功" wait:0.5];
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            NSString *logInfo = [NSString stringWithFormat:@"切换失败.module=%@,code=%d,msg=%@",module,errId,errMsg];
            [AlertHelp tipWith:logInfo wait:1];
        }];
    };
    AlertActionHandle ldBlock = ^(UIAlertAction * _Nonnull action){
        [[ILiveRoomManager getInstance] changeRole:kSxbRole_HostLD succ:^{
            ws.item.curRole = kSxbRole_HostLD;
            [ws changeRole:kSxbRole_HostLD];
            [AlertHelp tipWith:@"切换成功" wait:0.5];
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            NSString *logInfo = [NSString stringWithFormat:@"切换失败.module=%@,code=%d,msg=%@",module,errId,errMsg];
            [AlertHelp tipWith:logInfo wait:1];
        }];
    };
    
    NSDictionary *funs = @{kSxbRole_HostHDTitle:hdBlock,kSxbRole_HostSDTitle:sdBlock, kSxbRole_HostLDTitle:ldBlock};
    NSString *message = nil;
    if (isVersionLow8_3)
    {
        NSString *title = [ws titleWith:ws.item.curRole];
        message = [NSString stringWithFormat:@"当前:%@",title];
    }
    UIAlertController *alert = [AlertHelp alertWith:nil message:message funBtns:funs cancelBtn:@"取消" alertStyle:UIAlertControllerStyleActionSheet cancelAction:nil];
    
    if (!isVersionLow8_3)
    {
        //选中当前角色
        NSString *title = [ws titleWith:ws.item.curRole];
        NSArray *alertActions = alert.actions;
        for (UIAlertAction *action in alertActions)
        {
            if ([action.title isEqualToString:title])
            {
                [action setValue:[UIColor grayColor] forKey:@"titleTextColor"];
            }
        }
    }
}

- (NSString *)titleWith:(NSString *)role
{
    if ([role isEqualToString:kSxbRole_HostHD])
    {
        return kSxbRole_HostHDTitle;
    }
    if ([role isEqualToString:kSxbRole_HostSD])
    {
        return kSxbRole_HostSDTitle;
    }
    if ([role isEqualToString:kSxbRole_HostLD])
    {
        return kSxbRole_HostLDTitle;
    }
    if ([role isEqualToString:kSxbRole_InteractHD])
    {
        return kSxbRole_InteractHDTitle;
    }
    if ([role isEqualToString:kSxbRole_InteractSD])
    {
        return kSxbRole_InteractSDTitle;
    }
    if ([role isEqualToString:kSxbRole_InteractLD])
    {
        return kSxbRole_InteractLDTitle;
    }
    return nil;
}

- (void)changeRole:(NSString *)role
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeRoleDelegate:)])
    {
        [self.delegate changeRoleDelegate:role];
    }
}

- (void)onReportLog
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"上报日志" message:@"输入要上报日志的描述和日期" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"日志描述";
        textField.text = @"随心播_LOG主动上报";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"0-当天，1-昨天，2-前天，以此类推";
        textField.text = 0;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"上报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *logDesc = alert.textFields.firstObject.text;
        int dayOffset = [alert.textFields.lastObject.text intValue];
        [[ILiveSDK getInstance] uploadLog:logDesc logDayOffset:dayOffset uploadResult:^(int retCode, NSString *retMsg, NSString *logKey) {
            if (retCode == 0)
            {
                NSString *logInfo = [NSString stringWithFormat:@"log上报成功，关键key=%@",logKey];
                ActionHandle copyKeyHandle = ^(UIAlertAction * _Nonnull action){
                    UIPasteboard *paste = [UIPasteboard generalPasteboard];
                    [paste setString:logKey];
                };
                [AlertHelp alertWith:@"log上报成功" message:logInfo funBtns:@{@"复制KEY":copyKeyHandle} cancelBtn:@"取消" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
            }
            else
            {
                NSString *logErrInfo = [NSString stringWithFormat:@"code=%d,errInfo=%@",retCode,retMsg];
                [AlertHelp alertWith:@"log上报失败" message:logErrInfo cancelBtn:@"OK" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
            }
        }];
    }]];    
    [[AlertHelp topViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)layoutViews
{
    CGRect selfRect = self.bounds;
    _clearBg.frame = selfRect;
    
    NSInteger rowNum;
    if (_funs.count % 4 == 0)
    {
        rowNum = _funs.count / 4;
    }
    else
    {
        rowNum = _funs.count / 4 + 1;
    }
    
    CGFloat rowHeight = 55;
    CGFloat rowWidth = 80;
    CGFloat marginY = 30;//上下间隔30
    [_alphaBg sizeWith:CGSizeMake(selfRect.size.width, rowNum * rowHeight + (rowNum-1)*kDefaultMargin + marginY * 2)];
    [_alphaBg alignParentBottom];
    
    NSInteger column = kRowMaxNum;
    CGFloat marginX = (_alphaBg.bounds.size.width-rowWidth*_funs.count) / (_funs.count + 1);
    if (_funs.count < kRowMaxNum)
    {
        column = _funs.count;
    }
    else
    {
        marginX = (_alphaBg.bounds.size.width-rowWidth*kRowMaxNum) / (kRowMaxNum + 1);
    }
    
    CGRect inRect = CGRectMake(_alphaBg.bounds.origin.x+marginX, _alphaBg.bounds.origin.y+marginY, _alphaBg.bounds.size.width, rowNum * rowHeight + (rowNum-1)*kDefaultMargin);
    [self gridViews:_funs inColumn:column size:CGSizeMake(rowWidth, rowHeight) margin:CGSizeMake(marginX, kDefaultMargin) inRect:inRect];
}

@end

@implementation MoreFunItem
@end
