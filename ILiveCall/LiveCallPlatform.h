//
//  LiveCallPlatform.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/18.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveCallLoginParam.h"
#import <ImSDK/ImSDK.h>

@interface LiveCallPlatform : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isAutoLogin;

- (void)setAutoLogin:(BOOL)value;

- (LiveCallLoginParam*)loadLoginParam;

- (void)saveLoginParam:(LiveCallLoginParam*)param;

- (void)setChat:(BOOL)isChat;

- (BOOL)isChat;

@end
