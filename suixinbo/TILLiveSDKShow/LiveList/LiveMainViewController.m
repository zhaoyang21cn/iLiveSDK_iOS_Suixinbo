//
//  LiveMainViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/5/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveMainViewController.h"
#import "LiveViewController.h"

@interface LiveMainViewController ()

@end

@implementation LiveMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UISegmentedControl *segmentedCtl=[[UISegmentedControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f) ];
    [segmentedCtl insertSegmentWithTitle:@"最新直播" atIndex:0 animated:YES];
    [segmentedCtl insertSegmentWithTitle:@"录制回放" atIndex:1 animated:YES];
    segmentedCtl.multipleTouchEnabled = NO;
    segmentedCtl.selectedSegmentIndex = 0;
    [segmentedCtl addTarget:self action:@selector(onSegmeted:) forControlEvents:UIControlEventValueChanged];
    [self.navigationItem setTitleView:segmentedCtl];
    
    _liveListVC = [[LiveListViewController alloc] init];
    [_liveListVC.view setFrame:self.view.bounds];
    _liveListVC.view.hidden = NO;
    [_liveListVC loadMore:nil];
    [self addChildViewController:_liveListVC];
    [self.view addSubview:_liveListVC.view];
    
    _recordListVC = [[RecordListViewController alloc] init];
    [_recordListVC.view setFrame:self.view.bounds];
    _recordListVC.view.hidden = YES;
    [_recordListVC loadMore:nil];
    [self addChildViewController:_recordListVC];
    [self.view addSubview:_recordListVC.view];
    
    TCShowLiveListItem *restoreItem = [TCShowLiveListItem loadFromToLocal];
    if (restoreItem)
    {
        AlertActionHandle okAction = ^(UIAlertAction * _Nonnull action){
            LiveViewController *liveVC = [[LiveViewController alloc] initWith:restoreItem roomOptionType:RoomOptionType_CrateRoom];
            [[AppDelegate sharedAppDelegate] presentViewController:liveVC animated:YES completion:nil];
        };
        [AlertHelp alertWith:nil message:@"是否恢复上次直播" funBtns:@{@"确定":okAction} cancelBtn:@"取消" alertStyle:UIAlertControllerStyleAlert cancelAction:^(UIAlertAction * _Nonnull action) {
            //如果不恢复上次的直播间，则发送一个群消息，通知所有在群中的观众，主播已经退出房间了
            [[ILiveRoomManager getInstance] bindIMGroupId:restoreItem.info.groupid];
            ILVLiveCustomMessage *customMsg = [[ILVLiveCustomMessage alloc] init];
            customMsg.type = ILVLIVE_IMTYPE_GROUP;
            customMsg.recvId = restoreItem.info.groupid;
            customMsg.cmd = (ILVLiveIMCmd)AVIMCMD_ExitLive;
            [[TILLiveManager getInstance] sendCustomMessage:customMsg succ:^{
                NSLog(@"succ");
            } failed:^(NSString *module, int errId, NSString *errMsg) {
                NSLog(@"");
            }];
            [restoreItem cleanLocalData];
        }];
    }
}

- (void)onSegmeted:(UISegmentedControl *)segmented
{
    if (segmented.selectedSegmentIndex == 0)
    {
        _liveListVC.view.hidden = NO;
        _recordListVC.view.hidden = YES;
    }
    else
    {
        _liveListVC.view.hidden = YES;
        _recordListVC.view.hidden = NO;
    }
}

@end
