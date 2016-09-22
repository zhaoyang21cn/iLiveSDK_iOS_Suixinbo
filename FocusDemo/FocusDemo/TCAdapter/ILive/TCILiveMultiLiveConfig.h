//
//  TCILiveMultiLiveConfig.h
//  TCShow
//
//  Created by AlexiChen on 16/8/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportILiveSDK
#import "TCILiveLiveConfig.h"

@interface TCILiveMultiLiveConfig : TCILiveLiveConfig

// 互动用户的角色信息
@property (nonatomic, copy) NSString *interactUserRole;

@end

@interface TCILiveMultiLiveRoomEngine : TCAVMultiLiveRoomEngine

@property (nonatomic, strong) TCILiveMultiLiveConfig *runtimeConfig;

@end

@interface TCILiveMultiLiveViewController : TCAVMultiLiveViewController
{
@protected
    TCILiveMultiLiveConfig *_runtimeConfig;
}

@property (nonatomic, readonly) TCILiveMultiLiveConfig *runtimeConfig;

// init之后，显示之前配置有效
- (void)configRuntime:(TCILiveMultiLiveConfig *)config;
@end
#endif