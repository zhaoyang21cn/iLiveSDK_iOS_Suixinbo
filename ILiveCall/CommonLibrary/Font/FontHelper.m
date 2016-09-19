//
//  FontHelper.m
//  CommonLibrary
//
//  Created by Alexi on 13-10-22.
//  Copyright (c) 2013年 ywchen. All rights reserved.
//

#import "FontHelper.h"

#import "IOSDeviceConfig.h"

@implementation FontHelper

static FontHelper *_sharedInstance = nil;


#if kIsCommonLibraryAppBuild

#define MYRIADPRO_BOLD          @"MyriadPro-Bold"
#define MYRIADPRO_LIGHT         @"MyriadPro-Light"
#define MYRIADPRO_REGULAR       @"MyriadPro-Regular"
#define MYRIADPRO_SEMIBOLD      @"MyriadPro-Semibold"

#endif

//#define kAppFontName @"Regular"

+ (instancetype)shareHelper
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _sharedInstance = [[FontHelper alloc] init];
    });
    
    return _sharedInstance;
}

- (void)configIPadFonts
{
    [self configIPhoneFonts];
}

- (void)configIPhoneFonts
{
#if kIsCommonLibraryAppBuild
    const CGFloat size = 14;
    _titleFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18];
    _subTitleFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:size];
    _textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:size];
    _subTextFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:size];
    _tipFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:size];
    _superLargeFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:size];
    _largeFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:size];
    _mediumFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:size];
    _smallFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:size];
#else
    _titleFont = [UIFont systemFontOfSize:14];
    _subTitleFont = [UIFont systemFontOfSize:14];
    _textFont = [UIFont systemFontOfSize:14];
    _subTextFont = [UIFont systemFontOfSize:14];
    _tipFont = [UIFont systemFontOfSize:14];
    _superLargeFont = [UIFont systemFontOfSize:14];
    _largeFont = [UIFont systemFontOfSize:14];
    _mediumFont = [UIFont systemFontOfSize:14];
    _smallFont = [UIFont systemFontOfSize:14];
#endif
}

- (id)init
{
    if (self = [super init])
    {
        if ([IOSDeviceConfig sharedConfig].isIPad)
        {
            [self configIPadFonts];
        }
        else
        {
            [self configIPhoneFonts];
        }
    }
    return self;
}


+ (UIFont *)fontWithName:(NSString *)name size:(CGFloat)size
{
    return [UIFont fontWithName:name size:size];
}

+ (UIFont *)fontWithSize:(CGFloat)size
{
#if kIsCommonLibraryAppBuild
    return [UIFont fontWithName:MYRIADPRO_REGULAR size:size];
#else
    return [UIFont systemFontOfSize:size];
#endif
}
+ (UIFont *)boldFontWithSize:(CGFloat)size
{
#if kIsCommonLibraryAppBuild
    return [UIFont fontWithName:MYRIADPRO_BOLD size:size];
#else
    return [UIFont boldSystemFontOfSize:size];
#endif
}


@end
