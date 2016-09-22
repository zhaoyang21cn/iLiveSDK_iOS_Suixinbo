//
//  TIMUserProfile+IMUserAble.h
//  TCShow
//
//  Created by AlexiChen on 16/4/15.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <ImSDK/TIMGroupManager.h>

@interface TIMUserProfile (IMUserAble) <AVMultiUserAble>

@property (nonatomic, assign) NSInteger avCtrlState;

@property (nonatomic, assign) NSInteger avMultiUserState;

@property (nonatomic, assign) CGRect avInteractArea;

@property (nonatomic, weak) UIView *avInvisibleInteractView;

@end


@interface TIMGroupMemberInfo (IMUserAble) <AVMultiUserAble>

@property (nonatomic, assign) NSInteger avCtrlState;

@property (nonatomic, assign) NSInteger avMultiUserState;

@property (nonatomic, assign) CGRect avInteractArea;

@property (nonatomic, weak) UIView *avInvisibleInteractView;

@end
