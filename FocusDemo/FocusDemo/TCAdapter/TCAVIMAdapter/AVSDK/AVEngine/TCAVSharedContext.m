//
//  TCAVSharedContext.m
//  TCShow
//
//  Created by AlexiChen on 16/5/24.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kIsUseAVSDKAsLiveScene
#import "TCAVSharedContext.h"

@interface TCAVSharedContext ()

@property (nonatomic, strong) QAVContext *sharedContext;

@end

@implementation TCAVSharedContext

static TCAVSharedContext *kSharedConext = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        kSharedConext = [[TCAVSharedContext alloc] init];
    });
    
    return kSharedConext;
}


+ (QAVContext *)sharedContext
{
    return [TCAVSharedContext sharedInstance].sharedContext;
}

+ (void)configWithStartedContext:(QAVContext *)context
{
    if ([TCAVSharedContext sharedInstance].sharedContext)
    {
        [TCAVSharedContext destroyContextCompletion:^{
            [TCAVSharedContext sharedInstance].sharedContext = context;
        }];
    }
    else
    {
        [TCAVSharedContext sharedInstance].sharedContext = context;
    }
    
}

+ (void)configWithStartedContext:(id<IMHostAble>)host completion:(CommonVoidBlock)block
{
    if ([TCAVSharedContext sharedInstance].sharedContext == nil)
    {
        QAVContextConfig *config = [[QAVContextConfig alloc] init];
        
        NSString *appid = [host imSDKAppId];
        
        config.sdk_app_id = appid;
        config.app_id_at3rd = appid;
        config.identifier = [host imUserId];
        config.account_type = [host imSDKAccountType];
        
        QAVContext *context = [QAVContext CreateContext];
        [context setSpearEngineMode:QAV_SPEAR_ENGINE_MODE_WEBCLOUD];
        
        [context startContextwithConfig:config andblock:^(QAVResult result) {
            
            [TCAVSharedContext sharedInstance].sharedContext = context;
            if (block)
            {
                block();
            }
            DebugLog(@"共享的QAVContext = %p result = %d", context, (int)result);
        }];
        
    }
}

+ (void)destroyContextCompletion:(CommonVoidBlock)block
{
    if ([TCAVSharedContext sharedInstance].sharedContext)
    {
        [[TCAVSharedContext sharedInstance].sharedContext stopContext];
        [[TCAVSharedContext sharedInstance].sharedContext destroy];
        [TCAVSharedContext sharedInstance].sharedContext = nil;
        if (block)
        {
            block();
        }
    }
}

@end
#endif
