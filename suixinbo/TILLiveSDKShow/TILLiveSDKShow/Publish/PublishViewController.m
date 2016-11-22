//
//  PublishViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "PublishViewController.h"

#import "LiveViewController.h"

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
    [self.view addSubview:_liveCover];
    
    _liveTitle = [[UITextField alloc] init];
    _liveTitle.placeholder = @"新随心播";
    [self.view addSubview:_liveTitle];
    
    _publishBtn = [[UIButton alloc] init];
    [_publishBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    [_publishBtn setBackgroundColor:kColorRed];
    [_publishBtn addTarget:self action:@selector(onPublish:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_publishBtn];
    
    [self layout];
}

- (void)showAlert:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle ok:(ActionHandle)succ cancel:(ActionHandle)fail
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    if (okTitle)
    {
        [alert addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:succ]];
    }
    if (cancelTitle)
    {
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:fail]];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onPublish:(UIButton *)button
{
    LoadView *reqIdWaitView = [LoadView loadViewWith:@"正在请求房间ID"];
    [self.view addSubview:reqIdWaitView];
    
    __weak typeof(self) ws = self;
    LiveAVRoomIDRequest *req = [[LiveAVRoomIDRequest alloc] initWithHandler:^(BaseRequest *request) {
       
        [reqIdWaitView removeFromSuperview];
        
        LiveAVRoomIDResponseData *data = (LiveAVRoomIDResponseData *)request.response.data;
        [ws createRoom:data.avRoomId];
        
    } failHandler:^(BaseRequest *request) {
        
        [reqIdWaitView removeFromSuperview];
        
        NSString *errinfo = [NSString stringWithFormat:@"code=%ld,msg=%@",(long)request.response.errorCode,request.response.errorInfo];
        
        NSLog(@"request id fail. %@",errinfo);
        
        [ws showAlert:@"获取房间id失败" message:errinfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
    }];
    req.uid = [[ILiveLoginManager getInstance] getLoginId];
    [[WebServiceEngine sharedEngine] asyncRequest:req wait:NO];
}

- (void)createRoom:(int)roomId
{
    __weak PublishViewController *ws = self;
    
    ILiveRoomOption *option = [ILiveRoomOption defaultHostLiveOption];
    
    LoadView *createRoomWaitView = [LoadView loadViewWith:@"正在创建房间"];
    [self.view addSubview:createRoomWaitView];
    
    [[TILLiveManager getInstance] createRoom:roomId option:option succ:^{
        
        NSLog(@"createRoom succ");
        [createRoomWaitView removeFromSuperview];
        
        [ws startLive:roomId];
        
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        
        [createRoomWaitView removeFromSuperview];
        
        NSString *errinfo = [NSString stringWithFormat:@"module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
        NSLog(@"createRoom fail.%@",errinfo);
        
        [ws showAlert:@"创建房间失败" message:errinfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
    }];
    
}

- (void)startLive:(int)roomId
{
    LoadView *uploadToServerWaitView = [LoadView loadViewWith:@"上传房间信息"];
    [self.view addSubview:uploadToServerWaitView];
    
    __weak typeof(self) ws = self;
    //上传直播信息到随心播业务后台
    LiveStartRequest *req = [[LiveStartRequest alloc] initWithHandler:^(BaseRequest *request) {
        
        [uploadToServerWaitView removeFromSuperview];
        NSLog(@"-----> 上传成功");
        
        [ws dismissViewControllerAnimated:NO completion:nil];
        
        TCShowLiveListItem *item = [[TCShowLiveListItem alloc] init];
        TCShowUser *user = [[TCShowUser alloc] init];
        user.uid = [[ILiveLoginManager getInstance] getLoginId];
        item.host = user;
        
        LiveViewController *liveVC = [[LiveViewController alloc] initWith:item];
        [[AppDelegate sharedAppDelegate] pushViewController:liveVC];
        
    } failHandler:^(BaseRequest *request) {
        
        [uploadToServerWaitView removeFromSuperview];
        // 上传失败
        NSLog(@"-----> 上传失败");
        
        NSString *errinfo = [NSString stringWithFormat:@"code=%ld,msg=%@",(long)request.response.errorCode,request.response.errorInfo];
        [ws showAlert:@"上传RoomInfo失败" message:errinfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
    }];
    
    req.liveItem = [[TCShowLiveListItem alloc] init]; //(TCShowLiveListItem *)self.liveController.roomInfo;
    req.liveItem.title = _liveTitle.text && _liveTitle.text.length > 0 ? _liveTitle.text : _liveTitle.placeholder;
    req.liveItem.avRoomId = roomId;
    req.liveItem.chatRoomId = [[ILiveRoomManager getInstance] getIMGroupId];
    
    TCShowUser *host = [[TCShowUser alloc] init];
    host.uid = [[ILiveLoginManager getInstance] getLoginId];
    host.username = host.uid;
    req.liveItem.host = host;
    
    [[WebServiceEngine sharedEngine] asyncRequest:req wait:NO];
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
