//
//  ARCCompile.h
//  CommonLibrary
//
//  Created by Alexi on 14-2-10.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//

#ifndef CommonLibrary_ARCCompile_h
#define CommonLibrary_ARCCompile_h

#if ! __has_feature(objc_arc)
    #define CommonAutoRelease(__v) ([__v autorelease])
    #define CommonReturnAutoReleased Autorelease

    #define CommonRetain(__v) ([__v retain])
    #define CommonReturnRetained Retain

    #define CommonRelease(__v) ([__v release])

    #define CommonDispatchQueueRelease(__v) (dispatch_release(__v))

    #define PropertyRetain retain
// 在括号内声明时使用
    #define CommonDelegateAssign
// 在property中使用
    #define DelegateAssign assign
    #define CommonSuperDealloc()  [super dealloc]
#else
    // -fobjc-arc
    #define CommonAutoRelease(__v)
    #define CommonReturnAutoReleased(__v) (__v)

    #define CommonRetain(__v)
    #define CommonReturnRetained(__v) (__v)

    #define CommonRelease(__v)

    #define PropertyRetain strong
    #define CommonDelegateAssign __unsafe_unretained
    #define DelegateAssign unsafe_unretained
    #define CommonSuperDealloc()

    #if TARGET_OS_IPHONE
        // Compiling for iOS
        #if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
        // iOS 6.0 or later
            #define CommonDispatchQueueRelease(__v)
        #else
        // iOS 5.X or earlier
            #define CommonDispatchQueueRelease(__v) (dispatch_release(__v))
        #endif
    #else
    // Compiling for Mac OS X
        #if MAC_OS_X_VERSION_MIN_REQUIRED >= 1080
        // Mac OS X 10.8 or later
            #define CommonDispatchQueueRelease(__v)
        #else
        // Mac OS X 10.7 or earlier
            #define CommonDispatchQueueRelease(__v) (dispatch_release(__v))
        #endif
    #endif
#endif

#endif
