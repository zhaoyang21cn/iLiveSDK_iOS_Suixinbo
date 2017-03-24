//
//  LiveViewController+UI.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveViewController.h"

@interface LiveViewController (UI)<LiveUITopDelegate,InviteInteractDelegate,BottomViewDelegate,UITableViewDelegate,UITableViewDataSource>

- (void)onBtnClose:(UIButton *)button;
- (void)onTapBlankToHide;
- (void)onTapReportViewBlankToHide;

- (void)onGotupDelete:(NSNotification *)noti;
- (void)switchRoomRefresh:(NSNotification *)noti;
- (void)showLikeHeartStartRect:(NSNotification *)noti;

- (void)onMessage:(ILVLiveMessage *)msg;

@end

