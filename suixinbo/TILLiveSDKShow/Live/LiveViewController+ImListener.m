//
//  LiveViewController+ImListener.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveViewController+ImListener.h"
#import "LiveViewController+UI.h"

@implementation LiveViewController (ImListener)

static __weak UIAlertController *_promptAlert = nil;

- (void)onTextMessage:(ILVLiveTextMessage *)msg
{
    [self onMessage:msg];
}

- (void)onCustomMessage:(ILVLiveCustomMessage *)msg
{
    if (msg.type == ILVLIVE_IMTYPE_GROUP)
    {
        //非当前直播间的群消息，不处理
        if (![_liveItem.info.groupid isEqualToString:msg.recvId])
        {
            return;
        }
    }
    int cmd = msg.cmd;
    if (msg.type == ILVLIVE_IMTYPE_C2C)
    {
        switch (cmd)
        {
            case AVIMCMD_Multi_Host_Invite:
            {
                if (_promptAlert)
                {
                    [_promptAlert dismissViewControllerAnimated:NO completion:nil];
                    _promptAlert = nil;
                }
                AlertActionHandle hdBlock = ^(UIAlertAction * _Nonnull action){
                    [self upToVideo:nil roleName:kSxbRole_InteractHD];
                };
                AlertActionHandle sdBlock = ^(UIAlertAction * _Nonnull action){
                    [self upToVideo:nil roleName:kSxbRole_InteractSD];
                };
                AlertActionHandle ldBlock = ^(UIAlertAction * _Nonnull action){
                    [self upToVideo:nil roleName:kSxbRole_InteractLD];
                };
                NSDictionary *funs = @{kSxbRole_InteractHDTitle:hdBlock,kSxbRole_InteractSDTitle:sdBlock, kSxbRole_InteractLDTitle:ldBlock};
                NSString *title = [NSString stringWithFormat:@"收到%@视频邀请",msg.sendId];
                _promptAlert = [AlertHelp alertWith:title message:@"接收请选择流控角色，否则点拒绝" funBtns:funs cancelBtn:@"拒绝" alertStyle:UIAlertControllerStyleActionSheet cancelAction:^(UIAlertAction * _Nonnull action) {
                    [self rejectToVideo:nil];
                }];
            }
                break;
            case AVIMCMD_Multi_Interact_Refuse:
            {
                [AppDelegate showAlert:self title:@"拒绝视频邀请" message:[NSString stringWithFormat:@"%@拒绝了你的邀请",msg.sendId] okTitle:@"好吧" cancelTitle:nil  ok:^(UIAlertAction * _Nonnull action) {
                    [[UserViewManager shareInstance] removePlaceholderView:msg.sendId];
                } cancel:nil];
            }
                break;
            case AVIMCMD_Multi_Host_CancelInvite:
            {
                if (_promptAlert)
                {
                    [_promptAlert dismissViewControllerAnimated:NO completion:nil];
                    _promptAlert = nil;
                }
                _promptAlert = [AppDelegate showAlert:self title:@"已取消视频邀请" message:msg.sendId okTitle:@"确定" cancelTitle:nil ok:^(UIAlertAction * _Nonnull action) {
                } cancel:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_promptAlert dismissViewControllerAnimated:YES completion:nil];
                    _promptAlert = nil;
                });
            }
                break;
            case ILVLIVE_IMCMD_LINKROOM_REQ:
            {
                [self recvLinkRoomReq:msg.sendId];
            }
                break;
            case ILVLIVE_IMCMD_LINKROOM_ACCEPT:
            {
                [self recvLinkRoomAccept:msg];
            }
                break;
            case ILVLIVE_IMCMD_LINKROOM_REFUSE:
            {
                [self recvLinkRoomRefuse:msg.sendId];
            }
                break;
            case ILVLIVE_IMCMD_LINKROOM_LIMIT:
            {
                [self recvLinkRoomLimit:msg.sendId];
            }
                break;
            default:
                break;
        }
    }
    else if (msg.type == ILVLIVE_IMTYPE_GROUP)
    {
        switch (cmd) {
            case AVIMCMD_Praise:
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserParise_Notification object:nil];
                break;
            case AVIMCMD_Multi_CancelInteract:
                if ([self isSendToSelf:msg])
                {
                    [self downToVideo:nil];
                }
                break;
            case AVIMCMD_EnterLive:
                [self onMessage:msg];
                break;
            case AVIMCMD_ExitLive:
                [[NSNotificationCenter defaultCenter] postNotificationName:kGroupDelete_Notification object:nil];
                break;
            default:
                break;
        }
    }
}

- (void)recvLinkRoomReq:(NSString *)fromId
{
    //界面上已经有3个画面了 或 自己不是主播，则回复拒绝
    NSString *loginUser = [[ILiveLoginManager getInstance] getLoginId];
    if ([UserViewManager shareInstance].total >= kMaxUserViewCount || ![self.liveItem.uid isEqualToString:loginUser])
    {
        [[TILLiveManager getInstance] refuseLinkRoom:fromId succ:^{
            NSLog(@"refuse");
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            NSLog(@"refuse");
        }];
        return;
    }
    
    NSString *title = [NSString stringWithFormat:@"收到来自%@的跨房连麦邀请",fromId];
    AlertActionHandle accpetBlock = ^(UIAlertAction * _Nonnull action){
        [[TILLiveManager getInstance] acceptLinkRoom:fromId succ:^{
            NSLog(@"accpet");
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            NSLog(@"accpet");
        }];
    };
    AlertActionHandle refuseBlock = ^(UIAlertAction * _Nonnull action){
        [[TILLiveManager getInstance] refuseLinkRoom:fromId succ:^{
            NSLog(@"refuse");
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            NSLog(@"refuse");
        }];
    };
    [AlertHelp alertWith:title message:nil funBtns:@{@"拒绝":refuseBlock, @"同意":accpetBlock} cancelBtn:nil alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
}

- (void)recvLinkRoomAccept:(ILVLiveCustomMessage *)msg
{
    if (!msg.data)//无房间号，不在房间中
    {
        NSString *title = [NSString stringWithFormat:@"%@不在房间中",msg.sendId];
        [AlertHelp alertWith:title message:nil cancelBtn:@"算了" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        return;
    }
    //界面上已经有3个画面了，则回复拒绝
    if ([UserViewManager shareInstance].total >= kMaxUserViewCount)
    {
        NSString *msgInfo = [NSString stringWithFormat:@"%@同意了你的跨房连麦请求，但是你本身的界面视图已经达到视图显示个数的上限了",msg.sendId];
        [AlertHelp alertWith:@"超出视图个数" message:msgInfo cancelBtn:@"好的" alertStyle:UIAlertControllerStyleAlert cancelAction:^(UIAlertAction * _Nonnull action) {
            ILVLiveCustomMessage *overLimitMsg = [[ILVLiveCustomMessage alloc] init];
            overLimitMsg.type = ILVLIVE_IMTYPE_C2C;
            overLimitMsg.cmd = ILVLIVE_IMCMD_LINKROOM_LIMIT;
            overLimitMsg.recvId = msg.sendId;
            [[TILLiveManager getInstance] sendOnlineCustomMessage:overLimitMsg succ:nil failed:nil];
        }];
        return;
    }
    AlertActionHandle linkBlock = ^(UIAlertAction * _Nonnull action){
        NSString *roomId = [[NSString alloc] initWithData:msg.data encoding:NSUTF8StringEncoding];
        LinkRoomSigRequest *linkSigReq = [[LinkRoomSigRequest alloc] initWithHandler:^(BaseRequest *request) {
            LinkRoomSigResponseData *sigData = (LinkRoomSigResponseData *)request.response.data;
            NSLog(@"code=%ld,errmsg=%@",(long)request.response.errorCode,request.response.errorInfo);
            [[TILLiveManager getInstance] linkRoom:[roomId intValue] identifier:msg.sendId authBuff:sigData.linksig succ:^{
                [AlertHelp tipWith:@"连接成功" wait:0.5];
            } failed:^(NSString *module, int errId, NSString *errMsg) {
                NSString *msg = [NSString stringWithFormat:@"Module=%@,code=%d,Msg=%@",module,errId,errMsg];
                [AlertHelp alertWith:@"跨房连麦失败" message:msg cancelBtn:@"明白了" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
            }];
        } failHandler:^(BaseRequest *request) {
            NSString *errLog = [NSString stringWithFormat:@"获取sig失败.code=%ld,msg=%@",(long)request.response.errorCode,request.response.errorInfo];
            [AlertHelp tipWith:errLog wait:1];
        }];
        linkSigReq.token = [AppDelegate sharedAppDelegate].token;
        linkSigReq.identifier = msg.sendId;
        linkSigReq.targetRoomnum = [roomId integerValue];
        linkSigReq.selfRoomnum = _liveItem.info.roomnum;
        [[WebServiceEngine sharedEngine] asyncRequest:linkSigReq];
    };
    NSString *title = [NSString stringWithFormat:@"%@同意跨房连麦",msg.sendId];
    [AlertHelp alertWith:title message:@"是否发起跨房连麦?" funBtns:@{@"发起连麦":linkBlock} cancelBtn:@"取消" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
}

- (void)recvLinkRoomRefuse:(NSString *)fromId
{
    NSString *title = [NSString stringWithFormat:@"%@拒绝跨房连麦",fromId];
    [AlertHelp alertWith:title message:nil cancelBtn:@"好吧" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
}

- (void)recvLinkRoomLimit:(NSString *)fromId
{
    NSString *msg = [NSString stringWithFormat:@"%@的房间跨房连麦成员已达上限,无法建立连麦",fromId];
    [AlertHelp alertWith:@"上限提示" message:msg cancelBtn:@"好吧" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
}

- (BOOL)isSendToSelf:(ILVLiveCustomMessage *)msg
{
    NSString *recvId = [[NSString alloc] initWithData:msg.data encoding:NSUTF8StringEncoding];
    NSString *selfId = [[ILiveLoginManager getInstance] getLoginId];
    
    return [recvId isEqualToString:selfId];
}

//上麦
- (void)upToVideo:(id)sender roleName:(NSString *)role
{
    //    [[TILLiveManager getInstance] upToVideoMember:@"user" succ:^{//kSxbRole_Interact
    //        NSLog(@"up video succ");
    //
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kUserUpVideo_Notification object:nil];
    //    } failed:^(NSString *module, int errId, NSString *errMsg) {
    //        NSLog(@"up video  fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg);
    //    }];
    
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.type = ILVLIVE_IMTYPE_C2C;
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_Multi_Interact_Join;
    msg.recvId = _liveItem.uid;
    
    __weak typeof(self) ws = self;
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        ILiveRoomManager *roomManager = [ILiveRoomManager getInstance];
        [roomManager changeRole:role succ:^{
            NSLog(@"changeRole");
            [roomManager enableCamera:CameraPosFront enable:YES succ:^{
                NSLog(@"enable camera YES");
                [roomManager enableMic:YES succ:^{
                    ws.liveItem.info.roleName = role;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUserUpVideo_Notification object:role];
                    
                } failed:^(NSString *module, int errId, NSString *errMsg) {
                    NSLog(@"enable mic fail");
                }];
            } failed:^(NSString *module, int errId, NSString *errMsg) {
                NSLog(@"enable camera fail");
            }];
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            NSLog(@"change role fail");
        }];
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"fail");
    }];
}

//下麦
- (void)downToVideo:(id)sender
{
    //    [[TILLiveManager getInstance] downToVideoMember:ILVLIVEAUTH_GUEST role:kSxbRole_Guest succ:^{
    //        NSLog(@"down video succ");
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kUserDownVideo_Notification object:nil];
    //    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
    //        NSLog(@"down video fail.module=%@,errid=%d,errmsg=%@",moudle,errId,errMsg);
    //    }];
    
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.type = ILVLIVE_IMTYPE_GROUP;
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_Multi_CancelInteract;
    msg.recvId = [[ILiveRoomManager getInstance] getIMGroupId];
    ILiveRoomManager *manager = [ILiveRoomManager getInstance];
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        [manager changeRole:kSxbRole_GuestHD succ:^ {
            NSLog(@"down to video: change role succ");
            cameraPos pos = [[ILiveRoomManager getInstance] getCurCameraPos];
            [manager enableCamera:pos enable:NO succ:^{
                NSLog(@"down to video: disable camera succ");
                [manager enableMic:NO succ:^{
                    NSLog(@"down to video: disable mic succ");
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDownVideo_Notification object:nil];
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

//拒绝上麦
- (void)rejectToVideo:(id)sender
{
    ILVLiveCustomMessage *msg = [[ILVLiveCustomMessage alloc] init];
    msg.cmd = (ILVLiveIMCmd)AVIMCMD_Multi_Interact_Refuse;
    msg.recvId = _liveItem.uid;
    msg.type = ILVLIVE_IMTYPE_C2C;
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        NSLog(@"refuse video succ");
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"refuse video  fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg);
    }];
}

@end
