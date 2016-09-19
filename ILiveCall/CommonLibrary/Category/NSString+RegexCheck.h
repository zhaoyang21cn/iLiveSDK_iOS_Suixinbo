//
//  NSString+RegexCheck.h
//  CommonLibrary
//
//  Created by Alexi on 14-2-13.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RegexCheck)

- (BOOL)matchRegex:(NSString *)regex;

- (BOOL)isValidateMobile;
@end
