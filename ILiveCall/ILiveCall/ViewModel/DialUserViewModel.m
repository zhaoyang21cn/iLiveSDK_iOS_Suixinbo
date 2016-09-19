//
//  DialUserModel.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "DialUserViewModel.h"

@implementation DialUserViewModel
{
    NSString * _userId;
}
- (void)onDialUserChanged:(NSString *)userId path:(NSIndexPath *)path
{
    DebugLog(@"user id changed : %@", userId);
    _userId = userId;
}

- (NSString*)getDialUser
{
    return _userId;
}

@end

