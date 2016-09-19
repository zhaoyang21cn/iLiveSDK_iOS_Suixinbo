/******************************************************************
 ** File 		: xpmess.h
 ** Author		: amoslan
 ** Date		: 2012-3-27
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: xplatform mess
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#if !defined(_XPMESS_INC_)
#define _XPMESS_INC_
#pragma once
#include <xptypes.h>
#ifdef _OS_WIN_
#include <stdio.h>
#include <windows.h>
#else
#include <sys/time.h>
#include <sys/times.h>
#endif
#include <xpexcept.h>
#include <time.h>
#include <sys/timeb.h>
#if	defined(_OS_WIN_)
#	if defined(_OS_WIN_DESKTOP_)
#		include <winsock2.h> /*for struct timeval*/
#       include <ws2tcpip.h>
#   else
#		undef WINAPI_FAMILY
#		define WINAPI_FAMILY	WINAPI_FAMILY_DESKTOP_APP
#		define WINSOCK_API_LINKAGE
#		include <winsock2.h>
#		undef WINAPI_FAMILY
#		define WINAPI_FAMILY	WINAPI_FAMILY_APP
#	endif
#endif

#if defined(__MACH__)
#include <mach/mach_time.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif
	
	/**
	 suspend execution for an interval of time.

	 @return	- return 0 if success, otherwise return error code(also set errno).
	 */
	_XP_API int32  xp_msleep(uint32 milliseconds);
	
#ifdef _OS_WIN_
     struct timezone {
             int     tz_minuteswest; /* of Greenwich */
             int     tz_dsttime;     /* type of dst correction to apply */
     };
	/**
	get date and time.
	The system's notion of the current Greenwich time and the current time zone is obtained with the gettimeofday() call.
	The time is expressed in seconds and microseconds since midnight (0 hour), January 1, 1970.
	The resolution of the system clock is hardware dependent, and the time may be updated continuously or in 'ticks'.
	If tp is NULL and tzp is non-NULL, gettimeofday() will populate the timezone struct in tzp.
	If tp is non-NULL and tzp is NULL, then only the timeval struct in tp is populated. If both tp and tzp are NULL, nothing is returned.

	@return	- A 0 return value indicates that the call succeeded.  A -1 return value indicates an error occurred, and in this case an error code is stored into the global variable errno.
	*/
	_XP_API	int gettimeofday(struct timeval* tp, struct timezone* tz);
#endif
    
	//returns the value of time in seconds since 0 hours, 0 minutes, 0 seconds, January 1, 1970
	_XP_API uint32 xp_time();

	_XP_API int xp_gettimeofday(struct timeval* tp, struct timezone* tz) ;	
	
	_XP_API inline uint32 xp_gettickcount()
		{
#ifdef _OS_WIN8_
			return (uint32)GetTickCount64();
#elif defined(_OS_WIN_)
			return GetTickCount();
#elif defined(__MACH__)//for ios and macos
            static mach_timebase_info_data_t info = {0};
            static kern_return_t krv __attribute__((unused)) = mach_timebase_info(&info);
            static double r = 1.0 * info.numer / (info.denom * NSEC_PER_MSEC);
            return mach_absolute_time() * r;
		/* 
		//get time err @ Lenovo A288T
#elif defined (_OS_ANDROID_)
		   static int s_fd = -1;
			if (s_fd == -1) {
				s_fd = open("/dev/alarm", O_RDONLY);
			}
		
			if (s_fd == -1) {
				struct timeval current;
				gettimeofday(&current, NULL);
				return current.tv_sec*1000 + current.tv_usec/1000;
			}
		
   #define ANDROID_ALARM_ELAPSED_REALTIME 4
			struct timespec ts;
			int result = ioctl(s_fd,
					ANDROID_ALARM_GET_TIME(ANDROID_ALARM_ELAPSED_REALTIME), &ts);
		
			if (result == 0) {
				int64_t when = seconds_to_nanoseconds(ts.tv_sec) + ts.tv_nsec;
				return (uint32) nanoseconds_to_milliseconds(when);
			} else {
				// XXX: there was an error, probably because the driver didn't
				// exist ... this should return
				// a real error, like an exception!
			   struct timeval current;
			gettimeofday(&current, NULL);
			return current.tv_sec*1000 + current.tv_usec/1000;
			}	
			*/
#else
			struct timeval current;
			gettimeofday(&current, NULL);
			return (current.tv_sec*1000 + current.tv_usec/1000);
#endif
		}
		
	

	_XP_API int64	xp_gettimeoffsetutc();
	
	_XP_API int32  xp_rand();
	
	_XP_API uint8* xp_rand16();
	
	_XP_API boolean xp_isalldigit(const utf8* str);	
	_XP_API boolean xp_str2time(const utf8* strTime,uint32 &dwTime);
	_XP_API boolean xp_int642str(int64 i64Value,utf8** pputf8,uint32 *pulen);
	_XP_API boolean xp_uint642str(uint64 ui64Value,utf8** pputf8,uint32 *pulen);
	_XP_API boolean xp_str2int(const utf8* strValue, int32 & iValue);
	_XP_API boolean xp_str2uint32(const utf8* strValue, uint32 & dwValue);
	_XP_API boolean xp_str2int64(const utf8* strValue, int64 & i64Value);
	_XP_API boolean xp_str2uint64(const utf8* strValue, uint64 & ui64Value);
    _XP_API uint32  xp_strlen(const utf16* str);
	
#ifdef __cplusplus
};
#endif

#ifdef _OS_WIN_

#define XPDEFINE_GUID(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) \
extern const GUID name;// = {l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8}

#else

typedef struct
{
	uint8 Data1[16];
} GUID;

#define XPDEFINE_GUID(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) \
extern const GUID name __attribute__ ((weak))\
= {(l & 0xFF000000) >> 24, (l & 0x00FF0000) >> 16, (l & 0x0000FF00) >> 8, (l & 0x000000FF), (w1 & 0xFF00) >> 8, (w1 & 0x00FF), (w2 & 0xFF00) >> 8, (w2 & 0x00FF), b1, b2, b3, b4, b5, b6, b7, b8}
#endif

#ifndef MIN
#define MIN(x, y)	((x < y) ? x : y)
#endif

#ifndef MAX
#define MAX(x, y)	((x > y) ? x : y)
#endif

#ifndef XPMAKEUINT64
#define XPMAKEUINT64(a, b) ((uint64)(((uint32)(b)) | ((uint64)((uint32)(a))) << 32))
#endif

#endif /* _XPMESS_INC_ */
