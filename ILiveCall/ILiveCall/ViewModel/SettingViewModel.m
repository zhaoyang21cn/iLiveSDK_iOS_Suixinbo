//
//  SettingViewModel.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "SettingViewModel.h"
#import "EngineHeaders.h"

@implementation SettingViewModel 

- (void)logout
{
    [[LiveCallPlatform sharedInstance] setAutoLogin:NO];
    
    [[TCICallManager sharedInstance] logout:^{
        DebugLog(@"logout succ");
    } fail:^(int code, NSString *msg) {
        DebugLog(@"logout fail");
    }];
}

@end
