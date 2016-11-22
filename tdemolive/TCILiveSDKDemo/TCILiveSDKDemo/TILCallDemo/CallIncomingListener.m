//
//  CallIncomingListener.m
//  TCILiveSDKDemo
//
//  Created by kennethmiao on 16/11/3.
//  Copyright © 2016年 kennethmiao. All rights reserved.
//

#import "CallIncomingListener.h"
#import "CallRecvViewController.h"
#import "AppDelegate.h"

@implementation CallIncomingListener
- (void)onC2CCallInvitation:(TILC2CCallInvitation*)invitation;
{
    UINavigationController *nav = (UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    CallRecvViewController *call = [nav.storyboard instantiateViewControllerWithIdentifier:@"CallRecvViewController"];
    call.peerId = invitation.sponsorId;
    call.invite = invitation;
    [nav presentViewController:call animated:YES completion:nil];
}
@end
