/******************************************************************
 ** File 		: xpexcept.h
 ** Author		: Amoslan, xiaolan8318@163.com 
 ** Date		: 2012-02-24
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: xplatform exception
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#ifndef _XPEXCEPT_INC_
#define _XPEXCEPT_INC_
#pragma once

#include <xptypes.h>
#include <assert.h>

#if defined(__cplusplus) && !defined(NEXCEPT)
#	include <exception>
#	include <stdexcept>
#	ifndef _EXCEPT_STD_
#		define _EXCEPT_STD_	std
#	endif
#	define	xpthrow(e)			throw _EXCEPT_STD_::e
#else
#	if defined(_OS_WIN_)
#		define xpthrow(e)		{__asm int 3}
#	else
#		ifdef __i386__
#			define xpthrow(e)	{__asm__ __volatile__("int3\nnop\nnop\n");}
#		elif defined(__arm__)
#			define xpthrow(e)	{__asm__ __volatile__("bkpt 1\nnop\n");}
#		else
#			define xpthrow(e)	((void)0)
#		endif
#	endif
#endif

#endif /*_XPEXCEPT_INC_*/
