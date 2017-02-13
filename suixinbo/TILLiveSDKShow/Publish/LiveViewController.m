//
//  LiveViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LiveViewController.h"

#import "UIImage+TintColor.h"
#import "UIColor+MLPFlatColors.h"

#import "LiveViewController+UI.h"
#import "LiveViewController+ImListener.h"
#import "LiveViewController+AVListener.h"

#import "LiveCallView.h"

#define kHeartInterval 5 //心跳间隔

@interface LiveViewController ()

//@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *heartTimer;
@end

@implementation LiveViewController

- (instancetype)initWith:(TCShowLiveListItem *)item
{
    if (self = [super init])
    {
        _liveItem = item;
        
        NSString *loginId = [[ILiveLoginManager getInstance] getLoginId];
        
        _isHost = [loginId isEqualToString:item.uid];
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //初始化直播
    [self initLive];
    
    //创建房间
    if (_isHost)
    {
        [self createRoom:(int)_liveItem.info.roomnum groupId:_liveItem.info.groupid];
        //上报房间信息
        [self reportRoomInfo:(int)_liveItem.info.roomnum groupId:_liveItem.info.groupid];
    }
    else
    {
        UISwipeGestureRecognizer *downGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwitchToNextRoom:)];
        downGes.direction = UISwipeGestureRecognizerDirectionDown;
        [self.view addGestureRecognizer:downGes];
        
        UISwipeGestureRecognizer *upGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwitchToPreRoom:)];
        upGes.direction = UISwipeGestureRecognizerDirectionUp;
        [self.view addGestureRecognizer:upGes];
        
        [self joinRoom:(int)_liveItem.info.roomnum groupId:_liveItem.info.groupid];
    }
    
    //发送心跳
    [self startLiveTimer];
    
    [self addSubviews];
    
    //进入房间，上报成员id
    [self reportMemberId:_liveItem.info.roomnum operate:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchRoomRefresh:) name:kUserSwitchRoom_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGotupDelete:) name:kGroupDelete_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLikeHeartStartRect:) name:kUserParise_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLiveViewPure:) name:kPureDelete_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLiveViewNoPure:) name:kNoPureDelete_Notification object:nil];
    
    _msgDatas = [NSMutableArray array];
    
    //测试代码，无需关注
    /*
//    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, 100, 50)];
//    [button1 addTarget:self action:@selector(onTest1) forControlEvents:UIControlEventTouchUpInside];
//    [button1 setTitle:@"isRotate_no" forState:UIControlStateNormal];
//    [self.view addSubview:button1];
//    
//    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(150, 100, 100, 50)];
//    [button2 addTarget:self action:@selector(onTest2) forControlEvents:UIControlEventTouchUpInside];
//    [button2 setTitle:@"isRotate_yes" forState:UIControlStateNormal];
//    [self.view addSubview:button2];
//    
//    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 150, 100, 50)];
//    [button3 addTarget:self action:@selector(onTest3) forControlEvents:UIControlEventTouchUpInside];
//    [button3 setTitle:@"same_SCAL" forState:UIControlStateNormal];
//    [self.view addSubview:button3];
//    
//    UIButton *button4 = [[UIButton alloc] initWithFrame:CGRectMake(100, 150, 100, 50)];
//    [button4 addTarget:self action:@selector(onTest4) forControlEvents:UIControlEventTouchUpInside];
//    [button4 setTitle:@"same_BLAC" forState:UIControlStateNormal];
//    [self.view addSubview:button4];
//    
//    UIButton *button5 = [[UIButton alloc] initWithFrame:CGRectMake(200, 150, 100, 50)];
//    [button5 addTarget:self action:@selector(onTest5) forControlEvents:UIControlEventTouchUpInside];
//    [button5 setTitle:@"same_STRE" forState:UIControlStateNormal];
//    [self.view addSubview:button5];
//    
//    UIButton *button6 = [[UIButton alloc] initWithFrame:CGRectMake(0, 200, 100, 50)];
//    [button6 addTarget:self action:@selector(onTest6) forControlEvents:UIControlEventTouchUpInside];
//    [button6 setTitle:@"diff_SCAL" forState:UIControlStateNormal];
//    [self.view addSubview:button6];
//    
//    UIButton *button7 = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 50)];
//    [button7 addTarget:self action:@selector(onTest7) forControlEvents:UIControlEventTouchUpInside];
//    [button7 setTitle:@"diff_BLAC" forState:UIControlStateNormal];
//    [self.view addSubview:button7];
//    
//    UIButton *button8 = [[UIButton alloc] initWithFrame:CGRectMake(200, 200, 100, 50)];
//    [button8 addTarget:self action:@selector(onTest8) forControlEvents:UIControlEventTouchUpInside];
//    [button8 setTitle:@"diff_STRE" forState:UIControlStateNormal];
//    [self.view addSubview:button8];
     */
}

- (void)onLiveViewPure:(NSNotification *)noti
{
    _msgTableView.hidden = YES;
}
- (void)onLiveViewNoPure:(NSNotification *)noti
{
    _msgTableView.hidden = NO;
}

//测试代码，无需关注
/*
//- (void)onTest1
//{
//    ILiveRenderView *renderView = [[[ILiveRoomManager getInstance] frameDispatcher] getRenderView:@"wilder2" srcType:QAVVIDEO_SRC_TYPE_CAMERA];
//    renderView.isRotate = NO;
//}
//- (void)onTest2
//{
//    ILiveRenderView *renderView = [[[ILiveRoomManager getInstance] frameDispatcher] getRenderView:@"wilder2" srcType:QAVVIDEO_SRC_TYPE_CAMERA];
//    renderView.isRotate = YES;
//}
//
//- (void)onTest3
//{
//    ILiveRenderView *renderView = [[[ILiveRoomManager getInstance] frameDispatcher] getRenderView:@"wilder2" srcType:QAVVIDEO_SRC_TYPE_CAMERA];
//    renderView.sameDirectionRenderMode = ILIVERENDERMODE_SCALETOFIT;
//}
//- (void)onTest4
//{
//    ILiveRenderView *renderView = [[[ILiveRoomManager getInstance] frameDispatcher] getRenderView:@"wilder2" srcType:QAVVIDEO_SRC_TYPE_CAMERA];
//    renderView.sameDirectionRenderMode = ILIVERENDERMODE_BLACKTOFILL;
//}
//- (void)onTest5
//{
//    ILiveRenderView *renderView = [[[ILiveRoomManager getInstance] frameDispatcher] getRenderView:@"wilder2" srcType:QAVVIDEO_SRC_TYPE_CAMERA];
//    renderView.sameDirectionRenderMode = ILIVERENDERMODE_STRETCHTOFILL;
//}
//- (void)onTest6
//{
//    ILiveRenderView *renderView = [[[ILiveRoomManager getInstance] frameDispatcher] getRenderView:@"wilder2" srcType:QAVVIDEO_SRC_TYPE_CAMERA];
//    renderView.diffDirectionRenderMode = ILIVERENDERMODE_SCALETOFIT;
//}
//- (void)onTest7
//{
//    ILiveRenderView *renderView = [[[ILiveRoomManager getInstance] frameDispatcher] getRenderView:@"wilder2" srcType:QAVVIDEO_SRC_TYPE_CAMERA];
//    renderView.diffDirectionRenderMode = ILIVERENDERMODE_BLACKTOFILL;
//}
//- (void)onTest8
//{
//    ILiveRenderView *renderView = [[[ILiveRoomManager getInstance] frameDispatcher] getRenderView:@"wilder2" srcType:QAVVIDEO_SRC_TYPE_CAMERA];
//    renderView.diffDirectionRenderMode = ILIVERENDERMODE_STRETCHTOFILL;
//}
*/

- (void)onSwitchToPreRoom:(UIGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateEnded)
    {
        [self switchRoom:YES];
    }
}

- (void)onSwitchToNextRoom:(UIGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateEnded)
    {
        [self switchRoom:NO];
    }
}

- (void)switchRoom:(BOOL)isPreRoom
{
    ILiveRoomOption *option = [ILiveRoomOption defaultGuestLiveOption];
    option.controlRole = kSxbRole_Guest;
    
    __weak typeof(self) ws = self;
    
    RoomListRequest *listReq = [[RoomListRequest alloc] initWithHandler:^(BaseRequest *request) {
        RoomListRequest *wreq = (RoomListRequest *)request;
        RoomListRspData *respData = (RoomListRspData *)wreq.response.data;
        
        if (respData.rooms.count <= 1)
        {
            [AppDelegate showAlert:self title:@"提示" message:@"没有更多房间" okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
            return ;
        }
        
        int curRoomIndex = -1;
        int switchToIndex = -1;
        for (int index = 0; index < respData.rooms.count; index++ )
        {
            TCShowLiveListItem *item = respData.rooms[index];
            if (item.info.roomnum == ws.liveItem.info.roomnum)
            {
                curRoomIndex = index;
            }
        }
        
        if (isPreRoom)
        {
            if (curRoomIndex == -1)
            {
                switchToIndex = 0;
                
            }
            else if (curRoomIndex > 0)
            {
                switchToIndex = curRoomIndex-1;
            }
            //如果当前房间是第一个，则切换到最后一个房间
            else if (curRoomIndex == 0 && respData.rooms.count > 1)
            {
                switchToIndex = (int)respData.rooms.count-1;
            }
        }
        else
        {
            if (curRoomIndex == -1)
            {
                switchToIndex = 0;
            }
            else if (curRoomIndex < respData.rooms.count - 1)
            {
                switchToIndex = curRoomIndex + 1;
            }
            //如果当前房间是最后一个，则切换到第一个房间
            else if (curRoomIndex == respData.rooms.count-1 && respData.rooms.count > 1)
            {
                switchToIndex = 0;
            }
        }
        //回收上一个房间的资源
        [ws reportMemberId:ws.liveItem.info.roomnum operate:1];//上一个房间退房
        [[UserViewManager shareInstance] releaseManager];//移除渲染画面
        
        TCShowLiveListItem *item = respData.rooms[switchToIndex];
        ws.liveItem = item;
        ILiveRoomOption *option = [ILiveRoomOption defaultGuestLiveOption];
        option.controlRole = kSxbRole_Guest;
        [[ILiveRoomManager getInstance] switchRoom:(int)item.info.roomnum option:option succ:^{
            //更新当前房间
            [ws reportMemberId:item.info.roomnum operate:0];//当前房间进房
            [ws sendJoinRoomMsg];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserSwitchRoom_Notification object:item userInfo:nil];
            
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            [ws onClose];
        }];
        
    } failHandler:^(BaseRequest *request) {
        NSLog(@"get room list fail");
    }];
    
    listReq.token = [AppDelegate sharedAppDelegate].token;
    listReq.type = @"live";
    listReq.index = 0;
    listReq.size = 20;
    listReq.appid = [ShowAppId intValue];
    
    [[WebServiceEngine sharedEngine] asyncRequest:listReq];
}

- (void)createRoom:(int)roomId groupId:(NSString *)groupid
{
    __weak typeof(self) ws = self;
    
    ILiveRoomOption *option = [ILiveRoomOption defaultHostLiveOption];
    option.controlRole = kSxbRole_Host;
    option.avOption.autoHdAudio = YES;//使用高音质模式，可以传背景音乐
    
    LoadView *createRoomWaitView = [LoadView loadViewWith:@"正在创建房间"];
    [self.view addSubview:createRoomWaitView];
    
    [[TILLiveManager getInstance] createRoom:roomId option:option succ:^{
        [createRoomWaitView removeFromSuperview];
        
        NSLog(@"createRoom succ");
        //将房间参数保存到本地，如果异常退出，下次进入app时，可提示返回这次的房间
        [ws.liveItem saveToLocal];
        
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        [createRoomWaitView removeFromSuperview];
        
        NSString *errinfo = [NSString stringWithFormat:@"module=%@,errid=%d,errmsg=%@",module,errId,errMsg];
        NSLog(@"createRoom fail.%@",errinfo);
        [AppDelegate showAlert:ws title:@"创建房间失败" message:errinfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
    }];
}

- (void)joinRoom:(int)roomId groupId:(NSString *)groupid
{
    ILiveRoomOption *option = [ILiveRoomOption defaultGuestLiveOption];
    option.controlRole = kSxbRole_Guest;

    __weak typeof(self) ws = self;
    [[TILLiveManager getInstance] joinRoom:roomId option:option succ:^{
        NSLog(@"join room succ");
        [ws sendJoinRoomMsg];

    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"join room fail. module=%@,errid=%d,errmsg=%@",module,errId,errMsg);
    }];
}

- (void)sendJoinRoomMsg
{
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.type = ILVLIVE_IMTYPE_GROUP;
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_EnterLive;
    msg.recvId = [[ILiveRoomManager getInstance] getIMGroupId];
    
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        NSLog(@"succ");
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"fail");
    }];
}

- (void)addSubviews
{
    _closeBtn = [[UIButton alloc] init];
    [_closeBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(onBtnClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeBtn];
    
    _topView = [[LiveUITopView alloc] initWith:_liveItem isHost:_isHost];
    _topView.delegate = self;
    [self.view addSubview:_topView];
    
    _parView = [[LiveUIParView alloc] init];
    _parView.delegate = self;
    _parView.isHost = _isHost;
    [self.view addSubview:_parView];
    
    _bgAlphaView = [[UIView alloc] init];
    _bgAlphaView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBlankToHide)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [_bgAlphaView addGestureRecognizer:tap];
    [self.view addSubview:_bgAlphaView];
    
    _reportView = [[ReportView alloc] initWithFrame:CGRectMake(0, -30, self.view.bounds.size.width, self.view.bounds.size.height)];
    _reportView.backgroundColor = [UIColor clearColor];
    _reportView.identifier.text = _liveItem.uid;
    _reportView.hidden = YES;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapReportViewBlankToHide)];
    tap1.numberOfTapsRequired = 1;
    tap1.numberOfTouchesRequired = 1;
    [_reportView addGestureRecognizer:tap1];
    [self.view addSubview:_reportView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectVideoBegin:) name:kClickConnect_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectVideoCancel:) name:kCancelConnect_Notification object:nil];
    
    _memberListView = [[UITableView alloc] init];
    _memberListView.delegate = self;
    _memberListView.dataSource = self;
    _memberListView.tableFooterView = [[UIView alloc] init];
    _memberListView.separatorInset = UIEdgeInsetsZero;
    [_bgAlphaView addSubview:_memberListView];
    
    _members = [NSMutableArray array];
    _upVideoMembers = [NSMutableArray array];
    
    _msgTableView = [[UITableView alloc] init];
    _msgTableView.backgroundColor = [UIColor clearColor];
    _msgTableView.delegate = self;
    _msgTableView.dataSource = self;
    _msgTableView.separatorInset = UIEdgeInsetsZero;
    _msgTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _msgTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_msgTableView];
    
    _msgInputView = [[MsgInputView alloc] initWith:self];
    _msgInputView.limitLength = 32;
    _msgInputView.hidden = YES;
    [self.view addSubview:_msgInputView];
    
    _bottomView = [[LiveUIBttomView alloc] initWith:kSxbRole_Host];
    _bottomView.delegate = self;
    _bottomView.isHost = _isHost;
    [self.view addSubview:_bottomView];
}

- (void)connectVideoBegin:(NSNotification *)noti
{
    [self onTapBlankToHide];//点击连麦时自动收起好友列表
    
    //增加连麦小视图
    NSString *userid = (NSString *)noti.object;
    LiveCallView *callView = [[UserViewManager shareInstance] addPlaceholderView:userid];
    [self.view addSubview:callView];
}

- (void)connectVideoCancel:(NSNotification *)noti
{
    NSString *userId = (NSString *)noti.object;
    [[UserViewManager shareInstance] removePlaceholderView:userId];
    [[UserViewManager shareInstance] refreshViews];
}

- (void)initLive
{
    TILLiveManager *manager = [TILLiveManager getInstance];
    [manager setAVListener:self];
    [manager setIMListener:self];
    [manager setAVRootView:self.view];
}

- (void)reportRoomInfo:(int)roomId groupId:(NSString *)groupid
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
    reportReq.room.title = _liveItem.info.title;
    reportReq.room.type = @"live";
    reportReq.room.roomnum = roomId;
    reportReq.room.groupid = [NSString stringWithFormat:@"%d",roomId];
    reportReq.room.cover = _liveItem.info.cover.length > 0 ? _liveItem.info.cover : @"";
    reportReq.room.appid = [ShowAppId intValue];
    
    [[WebServiceEngine sharedEngine] asyncRequest:reportReq];
}

- (void)reportMemberId:(NSInteger)roomnum operate:(NSInteger)operate
{
    __weak typeof(self) ws = self;
    ReportMemIdRequest *req = [[ReportMemIdRequest alloc] initWithHandler:^(BaseRequest *request) {
        NSLog(@"report memeber id succ");
        [ws onRefreshMemberList];
        
    } failHandler:^(BaseRequest *request) {
        NSLog(@"report memeber id fail");
    }];
    req.token = [AppDelegate sharedAppDelegate].token;
    req.userId = [[ILiveLoginManager getInstance] getLoginId];
    req.roomnum = roomnum;
    req.role = _isHost ? 1 : 0;
    req.operate = operate;
    
    [[WebServiceEngine sharedEngine] asyncRequest:req wait:NO];
}

- (void)onClose
{
    //停止心跳
    [self stopLiveTimer];
    
    __weak typeof(self) ws = self;
    
    if (_isHost)
    {
        //通知业务服务器，退房
        ExitRoomRequest *exitReq = [[ExitRoomRequest alloc] initWithHandler:^(BaseRequest *request) {
            NSLog(@"上报退出房间成功");
        } failHandler:^(BaseRequest *request) {
            NSLog(@"上报退出房间失败");
        }];
        
        exitReq.token = [AppDelegate sharedAppDelegate].token;
        exitReq.roomnum = _liveItem.info.roomnum;
        exitReq.type = @"live";
        
        [[WebServiceEngine sharedEngine] asyncRequest:exitReq wait:NO];
    }
    else
    {
        [self reportMemberId:_liveItem.info.roomnum operate:1];
    }
    
    TILLiveManager *manager = [TILLiveManager getInstance];
    //退出房间
    [manager quitRoom:^{
        [ws.liveItem cleanLocalData];
        
        [ws.navigationController setNavigationBarHidden:NO animated:YES];
        [[AppDelegate sharedAppDelegate] popToRootViewController];
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        NSLog(@"exit room fail.module=%@,errid=%d,errmsg=%@",moudle,errId,errMsg);
        
        [ws.navigationController setNavigationBarHidden:NO animated:YES];
        [[AppDelegate sharedAppDelegate] popToRootViewController];
    }];
    
    [[UserViewManager shareInstance] releaseManager];
}

#pragma mark - 心跳（房间保活）

//开始发送心跳
- (void)startLiveTimer
{
    [self stopLiveTimer];
    _heartTimer = [NSTimer scheduledTimerWithTimeInterval:kHeartInterval target:self selector:@selector(onPostHeartBeat:) userInfo:nil repeats:YES];
}

//发送心跳
- (void)onPostHeartBeat:(NSTimer *)timer
{
    HostHeartBeatRequest *heartReq = [[HostHeartBeatRequest alloc] initWithHandler:^(BaseRequest *request) {
        
        NSLog(@"---->heart beat succ");
    } failHandler:^(BaseRequest *request) {
        NSLog(@"---->heart beat fail");
    }];
    heartReq.token = [AppDelegate sharedAppDelegate].token;
    heartReq.roomnum = _liveItem.info.roomnum;
    heartReq.thumbup = _liveItem.info.thumbup;
    //判断自己是什么角色
    if (_isHost)
    {
        heartReq.role = 1;
    }
    else
    {
        BOOL isOpenCamear = [[ILiveRoomManager getInstance] getCurCameraState];
        
        if (isOpenCamear)//连麦用户
        {
            heartReq.role = 2;
        }
        else//普通观众
        {
            heartReq.role = 0;
        }
    }
    [[WebServiceEngine sharedEngine] asyncRequest:heartReq wait:NO];
    
    //每次心跳刷新一下成员列表，在随心播中，只显示了成员数
    [self onRefreshMemberList];
}

- (void)onRefreshMemberList
{
    __weak LiveViewController *ws = self;
    
    RoomMemListRequest *listReq = [[RoomMemListRequest alloc] initWithHandler:^(BaseRequest *request) {
        RoomMemListRspData *listRspData = (RoomMemListRspData *)request.response.data;
        [ws freshAudience:listRspData.idlist];
        
    } failHandler:^(BaseRequest *request) {
        NSLog(@"get group member fail ,code=%ld,msg=%@",(long)request.response.errorCode, request.response.errorInfo);
    }];
    listReq.token = [AppDelegate sharedAppDelegate].token;
    listReq.roomnum = _liveItem.info.roomnum;
    listReq.index = 0;
    listReq.size = 20;
    
    [[WebServiceEngine sharedEngine] asyncRequest:listReq wait:NO];
}

- (void)freshAudience:(NSArray *)memList
{
    _liveItem.info.memsize = (int)memList.count;
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserMemChange_Notification object:nil];
}

//停止发送心跳
- (void)stopLiveTimer
{
    if(_heartTimer)
    {
        [_heartTimer invalidate];
        _heartTimer = nil;
    }
}
@end


