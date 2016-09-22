//
//  IMAHost+HostAPIs.h
//  TIMChat
//
//  Created by AlexiChen on 16/3/22.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAHost.h"

// 当前用户常用的操作
@interface IMAHost (HostAPIs)

//- (void)asyncSetAllowType:(TIMFriendAllowType)type succ:(TIMSucc)succ fail:(TIMFail)fail;

- (void)asyncSetFaceUrl:(NSString *)face  succ:(TIMSucc)succ fail:(TIMFail)fail;

- (void)asyncSetNickname:(NSString *)nick  succ:(TIMSucc)succ fail:(TIMFail)fail;

- (void)asyncSetSignature:(NSString *)signature succ:(TIMSucc)succ fail:(TIMFail)fail;

#if kIsTCShowSupportIMCustom
- (void)asyncSetGender:(BOOL)woman succ:(TIMSucc)succ fail:(TIMFail)fail;
#endif

- (void)asyncGetProfileOf:(id<IMUserAble>)user succ:(void (^)(TIMUserProfile *profile))succ fail:(TIMFail)fail;


@end
