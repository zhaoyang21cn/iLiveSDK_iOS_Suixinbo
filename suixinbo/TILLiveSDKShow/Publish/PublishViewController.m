//
//  PublishViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "PublishViewController.h"
#import "LiveViewController.h"
#import "UploadImageHelper.h"

@interface PublishViewController ()
@end

@implementation PublishViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.title = @"发布直播";
    self.view.backgroundColor = kColorWhite;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _vcTitle = [[UILabel alloc] init];
    _vcTitle.text = @"发布直播";
    _vcTitle.textAlignment = NSTextAlignmentCenter;
    _vcTitle.backgroundColor = kColorRed;
    _vcTitle.textColor = kColorWhite;
    _vcTitle.font = kAppLargeTextFont;
    [self.view addSubview:_vcTitle];
    
    _closeBtn = [[UIButton alloc] init];
    [_closeBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_closeBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn.titleLabel.font = kAppMiddleTextFont;
    [self.view addSubview:_closeBtn];
    
    _liveCoverBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"defaul_publishcover"]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickPublishContent:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    _liveCoverBg.userInteractionEnabled = YES;
    [_liveCoverBg addGestureRecognizer:tap];
    [self.view addSubview:_liveCoverBg];
    
    _liveCoverIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"publishcover"]];
    _liveCoverIcon.userInteractionEnabled = YES;
    [_liveCoverBg addSubview:_liveCoverIcon];
    
    _liveCoverLabel = [[UILabel alloc] init];
    _liveCoverLabel.text = @"给你的直播设置一个满意的封面";
    _liveCoverLabel.textColor = [UIColor lightGrayColor];
    _liveCoverLabel.textAlignment = NSTextAlignmentCenter;
    [_liveCoverBg addSubview:_liveCoverLabel];
    
    _liveTitle = [[UITextField alloc] init];
    _liveTitle.placeholder = @"请输入直播标题";
    [self.view addSubview:_liveTitle];
    
    _roleView = [[UIView alloc] init];
    _roleView.layer.borderColor = kColorGray.CGColor;
    _roleView.layer.borderWidth = 1.0;
    [self.view addSubview:_roleView];
    
    _roleLabel = [[UILabel alloc] init];
    _roleLabel.text = @"分辨率";
    _roleLabel.textAlignment = NSTextAlignmentCenter;
    [_roleView addSubview:_roleLabel];
    
    _roleBtn = [UIButton buttonWithType:UIButtonTypeCustom];//[[UIButton alloc] init];
//    NSString *title = [self getTitle:[self getRoleName]];
//    [_roleBtn setTitle:title forState:UIControlStateNormal];
        NSAttributedString *title = [self getTitle:[self getRoleName]];
    [_roleBtn setAttributedTitle:title forState:UIControlStateNormal];
    [_roleBtn addTarget:self action:@selector(onRole) forControlEvents:UIControlEventTouchUpInside];
    _roleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_roleView addSubview:_roleBtn];
    
    _publishBtn = [[UIButton alloc] init];
    [_publishBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    [_publishBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_publishBtn setBackgroundColor:kColorRed];
    [_publishBtn addTarget:self action:@selector(onPublish:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_publishBtn];
    
    [self layout];
}

- (NSString *)getRoleName
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *hostRole = [user objectForKey:kSxbRole_HostValue];
    if (!(hostRole && hostRole.length > 0))
    {
        [user setObject:kSxbRole_HostHD forKey:kSxbRole_HostValue];
        hostRole = kSxbRole_HostHD;
    }
    return hostRole;
}

- (NSAttributedString *)getTitle:(NSString *)role
{
    NSString *roleTitle = @"";
    if ([role isEqualToString:kSxbRole_HostHD])
    {
        roleTitle = @"高清";
    }
    else if ([role isEqualToString:kSxbRole_HostSD])
    {
        roleTitle = @"标清";
    }
    else if ([role isEqualToString:kSxbRole_HostLD])
    {
        roleTitle = @"流畅";
    }
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:roleTitle attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}]];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:@" > " attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}]];
    return title;
}

- (void)onClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRole
{
    //选择角色
    __weak typeof(self) ws = self;
    AlertActionHandle hdBlock = ^(UIAlertAction * _Nonnull action){
        [ws setHostRole:kSxbRole_HostHD];
    };
    AlertActionHandle sdBlock = ^(UIAlertAction * _Nonnull action){
        [ws setHostRole:kSxbRole_HostSD];
    };
    AlertActionHandle ldBlock = ^(UIAlertAction * _Nonnull action){
        [ws setHostRole:kSxbRole_HostLD];
    };
    NSDictionary *funs = @{kSxbRole_HostHDTitle:hdBlock,kSxbRole_HostSDTitle:sdBlock, kSxbRole_HostLDTitle:ldBlock};
    [AlertHelp alertWith:@"选择角色" message:nil funBtns:funs cancelBtn:@"取消" alertStyle:UIAlertControllerStyleActionSheet cancelAction:nil];
}

- (void)setHostRole:(NSString *)role
{
    if (!(role && role.length > 0))
    {
        return;
    }
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:role forKey:kSxbRole_HostValue];
    
//    NSString *title = [self getTitle:[self getRoleName]];
//    [_roleBtn setTitle:title forState:UIControlStateNormal];
    NSAttributedString *title = [self getTitle:role];
    [_roleBtn setAttributedTitle:title forState:UIControlStateNormal];
}

- (void)onPublish:(UIButton *)button
{
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(videoStatus == AVAuthorizationStatusRestricted || videoStatus == AVAuthorizationStatusDenied)
    {
        [AppDelegate showAlert:self title:nil message:@"您没有相机使用权限,请到 设置->隐私->相机 中开启权限" okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        return;
    }
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(audioStatus == AVAuthorizationStatusRestricted || audioStatus == AVAuthorizationStatusDenied)
    {
        [AppDelegate showAlert:self title:nil message:@"您没有麦克风使用权限,请到 设置->隐私->麦克风 中开启权限" okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        return;
    }
    NSString *role = [self getRoleName];
    [self publish:role];
}

- (void)publish:(NSString *)role
{
    LoadView *reqIdWaitView = [LoadView loadViewWith:@"正在请求房间ID"];
    [self.view addSubview:reqIdWaitView];
    __block CreateRoomResponceData *roomData = nil;
    __block NSString *imageUrl = nil;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        CreateRoomRequest *createRoomReq = [[CreateRoomRequest alloc] initWithHandler:^(BaseRequest *request) {
            roomData = (CreateRoomResponceData *)request.response.data;
            dispatch_semaphore_signal(semaphore);
            
        } failHandler:^(BaseRequest *request) {
            dispatch_semaphore_signal(semaphore);
        }];
        createRoomReq.token = [AppDelegate sharedAppDelegate].token;
        createRoomReq.type = @"live";
        [[WebServiceEngine sharedEngine] asyncRequest:createRoomReq];
        
        [[UploadImageHelper shareInstance] upload:_liveCoverBg.image completion:^(NSString *imageSaveUrl) {
            imageUrl = imageSaveUrl;
            dispatch_semaphore_signal(semaphore);
            
        } failed:^(NSString *failTip) {
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC));
        dispatch_semaphore_wait(semaphore, timeoutTime);
        dispatch_semaphore_wait(semaphore, timeoutTime);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [reqIdWaitView removeFromSuperview];
            [self enterLive:(int)roomData.roomnum groupId:roomData.groupid imageUrl:imageUrl roleName:role];
        });
    });
}

- (void)reportRoomInfo:(int)roomId groupId:(NSString *)groupid imageUrl:(NSString *)imageUrl
{
    ReportRoomRequest *reportReq = [[ReportRoomRequest alloc] initWithHandler:^(BaseRequest *request) {
        NSLog(@"-----> 上传成功");
        
    } failHandler:^(BaseRequest *request) {
        // 上传失败
        NSLog(@"-----> 上传失败");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *errinfo = [NSString stringWithFormat:@"code=%ld,msg=%@",(long)request.response.errorCode,request.response.errorInfo];
            [AppDelegate showAlert:self title:@"上传RoomInfo失败" message:errinfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        });
    }];
    
    reportReq.token = [AppDelegate sharedAppDelegate].token;
    
    reportReq.room = [[ShowRoomInfo alloc] init];
    reportReq.room.title = _liveTitle.text.length > 0 ? _liveTitle.text : _liveTitle.placeholder;
    reportReq.room.type = @"live";
    reportReq.room.roomnum = roomId;
    reportReq.room.groupid = [NSString stringWithFormat:@"%d",roomId];
    reportReq.room.cover = imageUrl.length > 0 ? imageUrl : @"";
    reportReq.room.appid = [ShowAppId intValue];
    
    [[WebServiceEngine sharedEngine] asyncRequest:reportReq];
}

- (void)onClickPublishContent:(UITapGestureRecognizer *)tap
{
    if (_liveTitle.editing)
    {
        [_liveTitle resignFirstResponder];
        return;
    }
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        __weak typeof(self) ws = self;
        AlertActionHandle cameraBlock = ^(UIAlertAction * _Nonnull action){
            [ws openCamera];
        };
        AlertActionHandle photoBlock = ^(UIAlertAction * _Nonnull action){
            [ws openPhotoLibrary];
        };
        NSDictionary *funs = @{@"拍照":cameraBlock, @"相册":photoBlock};
        [AlertHelp alertWith:nil message:nil funBtns:funs cancelBtn:@"取消" alertStyle:UIAlertControllerStyleActionSheet cancelAction:nil];
    }
}

- (void)openCamera
{
    // 打开系统相机拍照
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        [AppDelegate showAlert:self title:nil message:@"您没有相机使用权限,请到设置->隐私中开启权限" okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        return;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *cameraIPC = [[UIImagePickerController alloc] init];
        cameraIPC.delegate = self;
        cameraIPC.allowsEditing = YES;
        cameraIPC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:cameraIPC animated:YES completion:nil];
        return;
    }
}

- (void)openPhotoLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
        return;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    UIImage *cutImage = [self cutImage:image];
    _liveCoverBg.image = cutImage;
    
    //如果是相机拍照，则保存到相册
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 图片剪裁

- (CGSize)publishSize
{
    CGRect selfRect = self.view.frame;
    return CGSizeMake(selfRect.size.width, (NSInteger)(selfRect.size.width * 0.618));
}

- (UIImage *)cutImage:(UIImage *)image
{
    CGSize pubSize = [self publishSize];
    if (image)
    {
        CGSize imgSize = image.size;
        CGFloat pubRation = pubSize.height / pubSize.width;
        CGFloat imgRatio = imgSize.height / imgSize.width;
        if (fabs(imgRatio -  pubRation) < 0.01)
        {
            // 直接上传
            return image;
        }
        else
        {
            if (imgRatio > 1)
            {
                // 长图，截正中间部份
                CGSize upSize = CGSizeMake(imgSize.width, (NSInteger)(imgSize.width * pubRation));
                UIImage *upimg = [self cropImage:image inRect:CGRectMake(0, (image.size.height - upSize.height)/2, upSize.width, upSize.height)];
                return upimg;
            }
            else
            {
                // 宽图，截正中间部份
                CGSize upSize = CGSizeMake(imgSize.height, (NSInteger)(imgSize.height * pubRation));
                UIImage *upimg = [self cropImage:image inRect:CGRectMake((image.size.width - upSize.width)/2, 0, upSize.width, upSize.height)];
                return upimg;
            }
        }
    }
    return image;
}

- (UIImage *)cropImage:(UIImage *)image inRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [image drawInRect:drawRect];
    
    // grab image
    UIImage* croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return croppedImage;
}

- (void)enterLive:(int)roomId groupId:(NSString *)groupid imageUrl:(NSString *)coverUrl roleName:(NSString *)role
{
    TCShowLiveListItem *item = [[TCShowLiveListItem alloc] init];
    item.uid = [[ILiveLoginManager getInstance] getLoginId];
    item.info = [[ShowRoomInfo alloc] init];
    item.info.title = self.liveTitle.text && self.liveTitle.text.length > 0 ? self.liveTitle.text : @"直播间";
    item.info.type = @"live";
    item.info.roomnum = roomId;
    item.info.groupid = groupid;
    item.info.cover = coverUrl ? coverUrl : @"";
    item.info.appid = [ShowAppId intValue];
    item.info.roleName = role;
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        LiveViewController *liveVC = [[LiveViewController alloc] initWith:item roomOptionType:RoomOptionType_CrateRoom];
        [[AppDelegate sharedAppDelegate] presentViewController:liveVC animated:YES completion:nil];
    }];
}

- (void)layout
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat screenW = screenRect.size.width;
    
    [_vcTitle sizeWith:CGSizeMake(screenW, 64)];
    [_vcTitle alignParentTop];
    
    [_closeBtn sizeWith:CGSizeMake(50, 30)];
    [_closeBtn alignParentRight];
    [_closeBtn alignVerticalCenterOf:_vcTitle];
    
    [_liveCoverBg sizeWith:CGSizeMake(screenW,screenW*0.618)];
    [_liveCoverBg layoutBelow:_vcTitle];
    
    CGSize iconSize = _liveCoverIcon.image.size;
    [_liveCoverIcon sizeWith:iconSize];
    [_liveCoverIcon layoutParentHorizontalCenter];
    CGFloat margin = (_liveCoverBg.bounds.size.height-iconSize.height-20)/2;
    [_liveCoverIcon alignParentTopWithMargin:margin];
    
    [_liveCoverLabel sizeWith:CGSizeMake(screenW, 20)];
    [_liveCoverLabel layoutParentHorizontalCenter];
    [_liveCoverLabel layoutBelow:_liveCoverIcon margin:kDefaultMargin];
    
    [_liveTitle sizeWith:CGSizeMake(screenW, 44)];
    [_liveTitle layoutBelow:_liveCoverBg];
    
    [_roleView sizeWith:CGSizeMake(screenW, 44)];
    [_roleView layoutBelow:_liveTitle];
    
    [_roleLabel sizeWith:CGSizeMake(70, 44)];
    [_roleLabel alignParentLeft];
    [_roleLabel layoutParentVerticalCenter];
    
    [_roleBtn sizeWith:CGSizeMake(screenW-70, 44)];
    [_roleBtn alignParentRightWithMargin:kDefaultMargin];
    [_roleBtn layoutParentVerticalCenter];
    
    [_publishBtn sizeWith:CGSizeMake(screenW, 64)];
    [_publishBtn alignParentBottom];
}


@end
