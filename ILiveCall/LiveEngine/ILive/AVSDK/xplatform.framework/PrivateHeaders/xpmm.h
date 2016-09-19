/******************************************************************
 ** File 		: xpmm.h
 ** Author		: Amoslan, xiaolan8318@163.com 
 ** Date		: 2012-02-24
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: xplatform memory
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#ifndef _XPMM_INC_
#define _XPMM_INC_
#pragma once

#ifndef	XP_MMC_CONFIG_DISABLE

#if defined(_WIN32)||defined(_WIN64)
#ifdef XP_MEM_CHECK_ALL
#include  <stdexcept>
#include "debug_new.h"
#endif

#ifdef XP_MEM_CHECK_PART
#include  <stdexcept>
#include "debug_new.h"
#endif

#ifdef XP_MEM_CHECK_NONE
#include <new>
#include <stdio.h>
#include <string>
#include <stdlib.h>
#endif
#endif

#endif

#ifndef xpfree
#	define	xpfree		free
#endif

#ifndef xpmalloc
#	define	xpmalloc	malloc
#endif

#ifndef xprealloc
#	define	xprealloc	realloc
#endif

#ifndef xpmemmove
#	define	xpmemmove	memmove
#endif

#endif /*_XPMM_INC_*/
