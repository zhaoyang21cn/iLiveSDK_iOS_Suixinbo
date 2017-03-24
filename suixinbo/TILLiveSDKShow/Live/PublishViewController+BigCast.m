//
//  PublishViewController+BigCast.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/3/21.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "PublishViewController+BigCast.h"

@implementation PublishViewController (BigCast)

- (void)onBigCast:(UIButton *)button
{
    __weak typeof(self) ws = self;
    [self prepare:^(int roomId, NSString * _Nonnull groupId, NSString * _Nonnull imageUrl) {
        //创建没有音视频房间的直播间
        TILLiveRoomOption *roomOption = [TILLiveRoomOption defaultHostLiveOption];
//        roomOption.avOption.avSupport = NO;
        roomOption.avOption.autoMic = NO;
        roomOption.avOption.autoCamera = NO;
        roomOption.avOption.autoSpeaker = NO;
        roomOption.avOption.autoHdAudio = YES;
        [[TILLiveManager getInstance] createRoom:(int)roomId option:roomOption succ:^{
            //上报房间信息
            [ws reportRoomInfo:roomId groupId:groupId imageUrl:imageUrl];
            //上报成员信息
            [ws reportMemberId:roomId operate:0];
            //开始心跳
            TCShowLiveListItem *item = [[TCShowLiveListItem alloc] init];
            item.info.roomnum = roomId;
            [[NSNotificationCenter defaultCenter] postNotificationName:kBigCastStartHeartbeat_Notification object:item];
            [AppDelegate showAlert:ws title:@"创建成功" message:@"可在个人资料页查看" okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            NSString *errInfo = [NSString stringWithFormat:@"module=%@,codr=%d,msg=%@",module,errId,errMsg];
            [AppDelegate showAlert:ws title:@"创建大咖模式房间失败" message:errInfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        }];
    }];
}

- (void)reportRoomInfo:(int)roomId groupId:(NSString *)groupid imageUrl:(NSString *)imageUrl
{
    ReportRoomRequest *reportReq = [[ReportRoomRequest alloc] initWithHandler:^(BaseRequest *request) {
        NSLog(@"-----> 上传成功");
    } failHandler:^(BaseRequest *request) {
        NSLog(@"-----> 上传失败");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *errinfo = [NSString stringWithFormat:@"code=%ld,msg=%@",(long)request.response.errorCode,request.response.errorInfo];
            [AppDelegate showAlert:self title:@"上传RoomInfo失败" message:errinfo okTitle:@"确定" cancelTitle:nil ok:nil cancel:nil];
        });
    }];
    reportReq.token = [AppDelegate sharedAppDelegate].token;
    reportReq.room = [[ShowRoomInfo alloc] init];
    reportReq.room.title = _liveTitle.text;
    reportReq.room.type = @"live";
    reportReq.room.roomnum = roomId;
    reportReq.room.groupid = [NSString stringWithFormat:@"%d",roomId];
    reportReq.room.cover = imageUrl;
    reportReq.room.appid = [ShowAppId intValue];
    [[WebServiceEngine sharedEngine] asyncRequest:reportReq];
}

- (void)reportMemberId:(NSInteger)roomnum operate:(NSInteger)operate
{
    ReportMemIdRequest *req = [[ReportMemIdRequest alloc] initWithHandler:^(BaseRequest *request) {
        NSLog(@"report memeber id succ");
    } failHandler:^(BaseRequest *request) {
        NSLog(@"report memeber id fail");
    }];
    req.token = [AppDelegate sharedAppDelegate].token;
    req.userId = [[ILiveLoginManager getInstance] getLoginId];
    req.roomnum = roomnum;
    req.role = 1;//TODO
    req.operate = operate;
    
    [[WebServiceEngine sharedEngine] asyncRequest:req wait:NO];
}

@end
