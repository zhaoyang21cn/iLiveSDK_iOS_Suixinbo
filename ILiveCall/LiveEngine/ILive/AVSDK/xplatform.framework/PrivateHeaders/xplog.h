/******************************************************************
** File 		: xplog.h
 ** Author		: amoslan
 ** Date		: 2012-03-30
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: x platform log system
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#if !defined(_XPLOG_INC_)
#define _XPLOG_INC_
#pragma once

#include <xptypes.h>
#include <xpexcept.h>

#define _MAX_EVT_LEN	10240

#ifndef __MODULE__
#	define	__MODULE__	"unnamed"
#endif

/*
 *	system log level
 */
#define	_SLT_GRIEVOUS	0
#define	_SLT_ERROR		1
#define	_SLT_WARNING	2
#define	_SLT_GENERIC	3
#define	_SLT_DEBUG		4

#ifndef _SLT_DEFAULT
#	if defined(_DEBUG) || defined(DEBUG) || defined(_DEBUG_) || !defined(NDEBUG)
#		define _SLT_DEFAULT	_SLT_ERROR
#	else
#		define _SLT_DEFAULT	_SLT_ERROR
#	endif
#endif

typedef	enum {
	/*this type is used for app panic, it most like some app crash or data loss will happen.*/
	esyslog_grievous	= _SLT_GRIEVOUS,
	
	/*this type is used for app logic error*/
	esyslog_error		= _SLT_ERROR,
	
	/*this type is used for app logic warning, 
	 in this case, something happened but we really don't want it be, so just throw a warning
	 */
	esyslog_warning		= _SLT_WARNING,
	
	/*this type is used to make some tips to user or developer for further purpose. 
	 there very important thing, like login/out/audit/security operation, is happening. 
	 */
	esyslog_generic		= _SLT_GENERIC,
	
	/*this type is used to make some tips to developer for debuging purpose only.*/
	esyslog_debug		= _SLT_DEBUG
} esyslog_type;

#if	defined(_OS_WIN_) && (_MSC_VER < 1300) //MS VC++ 7.0 _MSC_VER = 1300, __VA_ARGS__ is unsupported if _MSC_VER < 1300
#	pragma message ("syslog is unsupported under current compiler!")
/*
 we do nothing here,
 just make such compiler happy,
 so he can skip all 'undefined error'!
 */
inline void log_panic(...) {}
inline void log_error(...) {}
inline void log_warning(...) {}
inline void log_notice(...) {}
inline void log_debug(...) {}
inline void log_suc(fmt, ...){}
inline void log_fail(fmt, ...){}

#else

#   define  log_suc(fmt,...) log_notice("<<<<<<<<" #fmt ">>>>>>>>",##__VA_ARGS__)
#   define  log_fail(fmt,...) log_error("!!!!!!!!" #fmt "!!!!!!!!",##__VA_ARGS__)

#	define	log_panic(...)	xpsyslog(esyslog_grievous,__MODULE__, __LINE__,  __VA_ARGS__)

//# if		_SLT_DEFAULT >= _SLT_ERROR
#	define	log_error(...)	xpsyslog(esyslog_error,	__MODULE__, __LINE__,  __VA_ARGS__)
//# else
//#	define	log_error(...)
//# endif

//# if		_SLT_DEFAULT >= _SLT_WARNING
#	define	log_warning(...)xpsyslog(esyslog_warning, __MODULE__, __LINE__,  __VA_ARGS__)
//# else
//#	define	log_warning(...)
//# endif

//# if		_SLT_DEFAULT >= _SLT_GENERIC
#	define	log_notice(...)	xpsyslog(esyslog_generic, __MODULE__, __LINE__,  __VA_ARGS__)
//# else
//#	define	log_notice(...)
//# endif

//# if		_SLT_DEFAULT >= _SLT_DEBUG
#	define	log_debug(...)	xpsyslog(esyslog_debug,	__MODULE__, __LINE__,  __VA_ARGS__)
//# else
//#	define	log_debug(...)
//# endif

#endif

typedef void (*fnsyslog_hook)(esyslog_type level, const char* module, int line, const char* message, int contentoffset);
typedef uint32(*fnsysregulartime_hook)();

#ifdef __cplusplus
extern "C" {
#endif
	
	/**
	 init syslog hook to store message.
	 
	 @hook		- hook entry for further use to store message;
	 */
	_XP_API int32	syslog_hook(fnsyslog_hook hook);
    
	_XP_API uint32	sysregulartime_hook(fnsysregulartime_hook hook);

	/**
	 init syslog hook to store message.
	 
	 @hook		- hook entry for further use to store message;
	 */
	_XP_API int32	syslog_setlevel(esyslog_type level);

	/**
	 syslog is a system log interface to send log messages to xplatform.
	 
	 notice: here we don't store any data to disk, we only redirect message to a callback entry previous initialized by syslog_hook call.
	 
	 @level		- event type, please see 'esyslog_type' above for more detail;
	 @module	- indicate who is calling 'syslog'
	 @format	- event description
	 */
	_XP_API void	xpsyslog(esyslog_type level, const char* module, int line, const char* format, ...) 
#ifndef _MSC_VER
	__attribute__ ((format (printf, 4, 5)))
#endif
	;
	
	/*
	 va_list version of syslog
	 
	 @args		- argument list
	 
	 */
	_XP_API void	syslogv(esyslog_type level, const char* module, int line, const char* format, va_list args);
	_XP_API void    StopLog(void);
	
#ifdef __cplusplus
};
#endif

#endif /*_XPLOG_INC_*/
