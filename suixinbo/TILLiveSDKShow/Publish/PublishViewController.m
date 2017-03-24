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
    
    self.title = @"发布直播";
    self.view.backgroundColor = kColorWhite;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _liveCover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"defaul_publishcover"]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickPublishContent:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    _liveCover.userInteractionEnabled = YES;
    [_liveCover addGestureRecognizer:tap];
    [self.view addSubview:_liveCover];
    
    _liveTitle = [[UITextField alloc] init];
    _liveTitle.placeholder = @"直播标题";
    [self.view addSubview:_liveTitle];
    
    _publishBtn = [[UIButton alloc] init];
    [_publishBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    [_publishBtn setBackgroundColor:kColorRed];
    [_publishBtn addTarget:self action:@selector(onPublish:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_publishBtn];
    
    [self layout];
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
#if kIsAppstoreVersion
    if (!(_liveTitle.text && _liveTitle.text.length > 0))
    {
        [AppDelegate showAlert:self title:nil message:@"请输入直播标题" okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        return;
    }
#else
#endif
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
        
        [[UploadImageHelper shareInstance] upload:_liveCover.image completion:^(NSString *imageSaveUrl) {
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
            [self enterLive:(int)roomData.roomnum groupId:roomData.groupid imageUrl:imageUrl];
        });
    });
}

- (void)onClickPublishContent:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        [_liveTitle resignFirstResponder];
        __weak typeof(self) ws = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws openCamera];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws openPhotoLibrary];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
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
    _liveCover.image = cutImage;
    
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

- (void)enterLive:(int)roomId groupId:(NSString *)groupid imageUrl:(NSString *)coverUrl
{
    TCShowLiveListItem *item = [[TCShowLiveListItem alloc] init];
    item.uid = [[ILiveLoginManager getInstance] getLoginId];
    item.info = [[ShowRoomInfo alloc] init];
    item.info.title = self.liveTitle.text && self.liveTitle.text.length > 0 ? self.liveTitle.text : self.liveTitle.placeholder;
    item.info.type = @"live";
    item.info.roomnum = roomId;
    item.info.groupid = groupid;
    item.info.cover = coverUrl ? coverUrl : @"";
    item.info.appid = [ShowAppId intValue];
    
    LiveViewController *liveVC = [[LiveViewController alloc] initWith:item];
    [[AppDelegate sharedAppDelegate] pushViewController:liveVC];
}

- (void)layout
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat screenW = screenRect.size.width;
    
    [_liveCover sizeWith:CGSizeMake(screenW,screenW*0.618)];
    [_liveCover alignParentTop];
    
    [_liveTitle sizeWith:CGSizeMake(screenW, 44)];
    [_liveTitle layoutBelow:_liveCover];
    
    [_publishBtn sizeWith:CGSizeMake(screenW, 44)];
    [_publishBtn layoutBelow:_liveTitle];
}


@end
