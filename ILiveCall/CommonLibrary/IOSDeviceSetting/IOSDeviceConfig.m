
//
//  IOSDeviceConfig.m
//  CommonLibrary
//
//  Created by AlexiChen on 13-1-11.
//  Copyright (c) 2013年 AlexiChen. All rights reserved.
//

#import "IOSDeviceConfig.h"
#import "IOSDeviceMacro.h"


@implementation IOSDeviceConfig

static IOSDeviceConfig *_sharedConfig = nil;


@synthesize isIPad = _isIPad;
@synthesize isIPhone = _isIPhone;
@synthesize isIPhone4 = _isIPhone4;
@synthesize isIPhone5 = _isIPhone5;
@synthesize isIOS7 = _isIOS7;
@synthesize isIOS6 = _isIOS6;
@synthesize isIOS6Later = _isIOS6Later;


//@synthesize deviceUUID = _deviceUUID;

+ (IOSDeviceConfig *)sharedConfig
{
    @synchronized(_sharedConfig)
    {
        if (_sharedConfig == nil) {
            _sharedConfig = [[IOSDeviceConfig alloc] init];
        }
        return _sharedConfig;
    }
}

- (void)dealloc
{
//    [_deviceUUID release];
    CommonRelease(_deviceUUID);
    CommonSuperDealloc();
//    [super dealloc];
}


- (id)init
{
	if (self = [super init])
	{
        _isIPad = isIPad();
        _isIPhone = isIPhone();
        _isIPhone4 = isIPhone4();
        _isIPhone5 = isIPhone5();
        _isIOS7 = isIOS7();
        _isIOS6 = isIOS6();
        _isIOS6Later = [[UIDevice currentDevice].systemVersion doubleValue]>= 7.0;
        _isIOS7Later = [[UIDevice currentDevice].systemVersion doubleValue]>= 8.0;
        
//#if kIsAppStoreVersion
//        _deviceUUID = [[[UIDevice currentDevice].identifierForVendor UUIDString] copy];
//#else
//        _deviceUUID = [@"460030766529870" copy];
//#endif
//        _navigationHeight = _isIOS7 ? 44.0f : 44.0;
	}
	return self;
}

- (BOOL)isPortrait
{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}


@end
