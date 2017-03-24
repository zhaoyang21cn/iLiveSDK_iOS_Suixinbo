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
                _promptAlert = [AppDelegate showAlert:self title:@"收到视频邀请" message:msg.sendId okTitle:@"接收" cancelTitle:@"拒绝"  ok:^(UIAlertAction * _Nonnull action) {
                    [self upToVideo:nil];
                } cancel:^(UIAlertAction * _Nonnull action) {
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

- (BOOL)isSendToSelf:(ILVLiveCustomMessage *)msg
{
    NSString *recvId = [[NSString alloc] initWithData:msg.data encoding:NSUTF8StringEncoding];
    NSString *selfId = [[ILiveLoginManager getInstance] getLoginId];
    
    return [recvId isEqualToString:selfId];
}

//上麦
- (void)upToVideo:(id)sender
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
    
    [[TILLiveManager getInstance] sendCustomMessage:msg succ:^{
        ILiveRoomManager *roomManager = [ILiveRoomManager getInstance];
        [roomManager changeRole:kSxbRole_Interact succ:^{
            NSLog(@"changeRole");
            [roomManager enableCamera:CameraPosFront enable:YES succ:^{
                NSLog(@"enable camera YES");
                [roomManager enableMic:YES succ:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUserUpVideo_Notification object:nil];
                    
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
        [manager changeRole:kSxbRole_Guest succ:^ {
            TCILDebugLog(@"down to video: change role succ");
            cameraPos pos = [[ILiveRoomManager getInstance] getCurCameraPos];
            [manager enableCamera:pos enable:NO succ:^{
                TCILDebugLog(@"down to video: disable camera succ");
                [manager enableMic:NO succ:^{
                    TCILDebugLog(@"down to video: disable mic succ");
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDownVideo_Notification object:nil];
                } failed:^(NSString *module, int errId, NSString *errMsg) {
                    TCILDebugLog(@"down to video: disable mic fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
                }];
            } failed:^(NSString *module, int errId, NSString *errMsg) {
                TCILDebugLog(@"down to video: disable camera fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
            }];
        } failed:^(NSString *module, int errId, NSString *errMsg) {
            TCILDebugLog(@"down to video: change role fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
        }];
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        TCILDebugLog(@"down to video: change auth fail: module=%@,errId=%d,errMsg=%@",module, errId, errMsg);
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
    } failed:^(NSString *moudle, int errId, NSString *errMsg) {
        NSLog(@"refuse video  fail.module=%@,errid=%d,errmsg=%@",moudle,errId,errMsg);
    }];
}

@end
