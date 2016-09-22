//
//  IMAHost+HostAPIs.m
//  TIMChat
//
//  Created by AlexiChen on 16/3/22.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAHost+HostAPIs.h"

#ifndef kNicknameMaxLength
#define kNicknameMaxLength  64
#endif

@implementation IMAHost (HostAPIs)

- (void)asyncSetFaceUrl:(NSString *)face  succ:(TIMSucc)succ fail:(TIMFail)fail
{
    __weak IMAHost *ws = self;
    [[TIMFriendshipManager sharedInstance] SetFaceURL:face succ:^{
        //        ws.nickName = nick;
        ws.profile.faceURL = face;
        if (succ)
        {
            succ();
        }
    } fail:^(int code, NSString *msg) {
        //        dispatch_async(dispatch_get_main_queue(), ^{
        DebugLog(@"code = %d, err = %@", code, msg);
        [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, msg)];
        if (fail)
        {
            fail(code, msg);
        }
    }];
}

- (void)asyncSetNickname:(NSString *)nick  succ:(TIMSucc)succ fail:(TIMFail)fail
{
    if ([NSString isEmpty:nick])
    {
        [[HUDHelper sharedInstance] tipMessage:@"昵称不能为空"];
        return;
    }
    if ([nick utf8Length] > kNicknameMaxLength)
    {
        [[HUDHelper sharedInstance] tipMessage:@"昵称超过长度限制"];
        return;
    }
    
    __weak IMAHost *ws = self;
    [[TIMFriendshipManager sharedInstance] SetNickname:nick succ:^{
//        ws.nickName = nick;
        ws.profile.nickname = nick;
        if (succ)
        {
            succ();
        }
    } fail:^(int code, NSString *msg) {
        //        dispatch_async(dispatch_get_main_queue(), ^{
        DebugLog(@"code = %d, err = %@", code, msg);
        [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, msg)];
        if (fail)
        {
            fail(code, msg);
        }
    }];

}

- (void)asyncSetSignature:(NSString *)signature succ:(TIMSucc)succ fail:(TIMFail)fail
{
    
    if ([signature utf8Length] > 150)
    {
        [[HUDHelper sharedInstance] tipMessage:@"签名超过长度限制"];
        return;
    }
    
    __weak IMAHost *ws = self;
    NSData *data = [signature dataUsingEncoding:NSUTF8StringEncoding];
    
    [[TIMFriendshipManager sharedInstance] SetSelfSignature:data succ:^{
        ws.profile.selfSignature = data;
        if (succ)
        {
            succ();
        }
    } fail:^(int code, NSString *msg) {
        DebugLog(@"code = %d, err = %@", code, msg);
        [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, msg)];
        if (fail)
        {
            fail(code, msg);
        }
    }];
}
#if kIsTCShowSupportIMCustom
- (void)asyncSetGender:(BOOL)woman succ:(TIMSucc)succ fail:(TIMFail)fail
{
    NSDictionary *customDic = @{@"gender" : @(woman)};
    
    if ([NSJSONSerialization isValidJSONObject:customDic])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:customDic options:NSJSONWritingPrettyPrinted error:&error];
        if(error)
        {
            DebugLog(@"[%@] Post Json Error: %@", [self class], customDic);
            return;
        }
        
        NSDictionary *dic = @{kIMCustomFlag : data};
        
        __weak IMAHost *ws = self;
        [[TIMFriendshipManager sharedInstance] SetCustom:dic succ:^{
            ws.profile.customInfo = dic;
            if (succ)
            {
                succ();
            }
        } fail:^(int code, NSString *msg) {
            DebugLog(@"code = %d, err = %@", code, msg);
            [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, msg)];
            if (fail)
            {
                fail(code, msg);
            }
        }];
    }
}
#endif

- (void)asyncGetProfileOf:(id<IMUserAble>)user succ:(void (^)(TIMUserProfile *profile))succ fail:(TIMFail)fail
{
    if (!user)
    {
        DebugLog(@"参数为空");
        return;
    }
    [[TIMFriendshipManager sharedInstance] GetUsersProfile:@[[user imUserId]] succ:^(NSArray *friends) {
        if (friends.count)
        {
            if (succ)
            {
                succ(friends[0]);
            }
        }
        else
        {
            if (fail)
            {
                fail(-1, @"未找到用户");
            }
        }
        
    } fail:^(int code, NSString *msg) {
        if (fail)
        {
            fail(code, msg);
        }
    }];
}

@end
