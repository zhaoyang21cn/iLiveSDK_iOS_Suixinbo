
//
//  NSObject+loadPadClass.m
//  CommonLibrary
//
//  Created by Alexi Chen on 2/28/13.
//  Copyright (c) 2013 AlexiChen. All rights reserved.
//

#import "NSObject+loadPadClass.h"

#import "IOSDeviceMacro.h"


@implementation NSObject (loadClass)

- (void)configParams:(id)params
{
    // do nothing
}

+ (Class)getPadClass:(Class)phone
{
    if (isIPad())
    {
        NSString *newClassDesc = [phone description];
        
        NSString *padNewClassDesc = [NSString stringWithFormat:@"%@_Pad", newClassDesc];
        
        Class padNewClass = NSClassFromString(padNewClassDesc);
        
        if (padNewClass)
        {
            return padNewClass;
        }
        else
        {
            return phone;
        }
    }
    else
    {
        return phone;
    }

}

//加载判断Phone的或者pad的文件
+ (id)loadClass:(Class)newClass
{
    id ret = nil;
    if (isIPad())
    {
        NSString *newClassDesc = [newClass description];
        
        NSString *padNewClassDesc = [NSString stringWithFormat:@"%@_Pad", newClassDesc];
        
        Class padNewClass = NSClassFromString(padNewClassDesc);
        
        if (padNewClass)
        {
            ret = [[padNewClass alloc] init];
        }
        else
        {
            ret = [[newClass alloc] init];
        }
    }
    else
    {
        ret = [[newClass alloc] init];
    }
    return CommonReturnAutoReleased(ret);
}

+ (id)loadClassFromNib:(Class)newClass
{
    id ret = nil;
    if (isIPad())
    {
        NSString *newClassDesc = [newClass description];
        
        NSString *padNewClassDesc = [NSString stringWithFormat:@"%@_Pad", newClassDesc];
        
        Class padNewClass = NSClassFromString(padNewClassDesc);
        
        if (padNewClass)
        {
            ret = [[padNewClass alloc] initWithNibName:padNewClassDesc bundle:[NSBundle mainBundle]];
        }
        else
        {
            ret = [[newClass alloc] initWithNibName:newClassDesc bundle:[NSBundle mainBundle]];
        }
    }
    else
    {
        ret = [[newClass alloc] initWithNibName:[newClass description] bundle:[NSBundle mainBundle]];
    }
    return CommonReturnAutoReleased(ret);
}

+ (id)loadClass:(Class)newClass withParams:(id)params
{

    id instance = [NSObject loadClass:newClass];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([instance respondsToSelector:@selector(configParams:)]) {
        [instance performSelector:@selector(configParams:) withObject:params];
    }
 #pragma clang diagnostic pop
    return instance;

}

+ (id)loadClass:(Class)newClass withParams:(id)params withConfigSelector:(SEL)selector
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id instance = [NSObject loadClass:newClass];
    if ([instance respondsToSelector:selector]) {
        [instance performSelector:selector withObject:params];
    }
    return instance;
#pragma clang diagnostic pop
}

@end
