//
//  FocusDemoUser.m
//  FocusDemo
//
//  Created by wilderliao on 16/9/18.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "FocusDemoUser.h"

@implementation FocusDemoUser

- (NSString *)imUserId
{
    return _uid;
}

- (NSString *)imUserName
{
    return _name.length ? _name : _uid;
}

- (NSString *)imUserIconUrl
{
    return _icon;
}

@end
