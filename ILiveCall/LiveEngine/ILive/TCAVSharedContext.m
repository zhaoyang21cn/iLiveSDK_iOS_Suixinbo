//
//  TCAVSharedContext.m
//  TCShow
//
//  Created by AlexiChen on 16/5/24.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

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


+ (void)configContextWith:(TIMLoginParam *)login completion:(TCIRoomBlock)block
{
    if ([TCAVSharedContext sharedInstance].sharedContext == nil)
    {
        QAVContextConfig *config = [[QAVContextConfig alloc] init];
        
        NSString *appid = [NSString stringWithFormat:@"%d", login.sdkAppId];
        
        config.sdk_app_id = appid;
        config.app_id_at3rd = appid;
        config.identifier = login.identifier;
        config.account_type = login.accountType;
        
        QAVContext *context = [QAVContext CreateContext];
        [context setSpearEngineMode:QAV_SPEAR_ENGINE_MODE_WEBCLOUD];
        
        [context startContextwithConfig:config andblock:^(QAVResult result) {
            
            [TCAVSharedContext sharedInstance].sharedContext = context;
            
            if (block)
            {
                BOOL res = result == QAV_OK;
                NSError *err = nil;
                if (res)
                {
                    err = [NSError errorWithDomain:@"startContext失败" code:result userInfo:nil];
                }
                block(res, err);
            }
            TCILDebugLog(@"共享的QAVContext = %p result = %d", context, (int)result);
        }];
        
    }
}

+ (void)destroyContextCompletion:(TCIVoidBlock)block
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
