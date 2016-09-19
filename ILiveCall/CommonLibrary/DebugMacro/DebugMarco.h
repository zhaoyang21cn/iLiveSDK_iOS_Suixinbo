//
//  DebugMarco.h
//  CommonLibrary
//
//  Created by Alexi on 13-10-23.
//  Copyright (c) 2013年 ywchen. All rights reserved.
//

#ifndef CommonLibrary_DebugMarco_h
#define CommonLibrary_DebugMarco_h

// 日志

#ifdef DEBUG

#ifndef DebugLog
#define DebugLog(fmt, ...) NSLog((@"[%s Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif

#else

#ifndef DebugLog
#define DebugLog(fmt, ...) // NSLog((@"[%s Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif

#define NSLog // NSLog


#endif

#endif

