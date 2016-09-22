//
//  NSString+RegexCheck.m
//  CommonLibrary
//
//  Created by Alexi on 14-2-13.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//

#import "NSString+RegexCheck.h"


@implementation NSString (RegexCheck)

- (BOOL)matchRegex:(NSString *)regex
{
    //SELF MATCHES一定是大写
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return  [predicate evaluateWithObject:self];
}

- (BOOL)isValidateMobile
{
    NSString *phoneRegex = @"^1(3[0-9]|4[57]|5[0-35-9]|(7[0[059]|6｜7｜8])|8[0-9])\\d{8}$";
    return [self matchRegex:phoneRegex];
}
@end
