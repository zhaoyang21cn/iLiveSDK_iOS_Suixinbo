//
//  TCILiveCallConfig.h
//  TCShow
//
//  Created by AlexiChen on 16/8/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportILiveSDK

#if kSupportCallScene
#import "TCILiveMultiLiveConfig.h"

@interface TCILiveCallConfig : TCILiveMultiLiveConfig

@end

@interface TCILiveCallRoomEngine : TCAVCallRoomEngine

@property (nonatomic, strong) TCILiveCallConfig *runtimeConfig;

@end

@interface TCILiveCallViewController : TCAVCallViewController
{
@protected
    TCILiveCallConfig *_runtimeConfig;
}

@property (nonatomic, readonly) TCILiveCallConfig *runtimeConfig;

// init之后，显示之前配置有效
- (void)configRuntime:(TCILiveCallConfig *)config;
@end
#endif
#endif