//
//  HostInfoViewModel.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "HostInfoViewModel.h"
#import "EngineHeaders.h"

@implementation HostInfoViewModel

- (NSString*)getHostId
{
    return [[TCICallManager sharedInstance] host].identifier;
}

- (NSString*)getHostNick
{
    return [[TCICallManager sharedInstance] host].nickname;
}

@end
