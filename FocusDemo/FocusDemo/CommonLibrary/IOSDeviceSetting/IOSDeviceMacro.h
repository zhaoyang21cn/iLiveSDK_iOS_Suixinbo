//
//  IOSDeviceMacro.h
//  CommonLibrary
//
//  Created by Alexi on 13-10-23.
//  Copyright (c) 2013年 ywchen. All rights reserved.
//

#ifndef CommonLibrary_IOSDeviceMacro_h
#define CommonLibrary_IOSDeviceMacro_h


#pragma mark -
#pragma mark iOS 4 Version Checkers

#define isIPad() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define isIPhone() (!isIPad())

#define isIPhone5() ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define isIPhone4() ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define isIOS7() ([[UIDevice currentDevice].systemVersion doubleValue]>= 7.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 8.0)

#define isIOS6() ([[UIDevice currentDevice].systemVersion doubleValue]>= 6.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 7.0)



#endif
