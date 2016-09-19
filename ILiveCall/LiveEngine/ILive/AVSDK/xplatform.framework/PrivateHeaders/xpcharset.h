/******************************************************************
 ** File 		: xpcharset.h
 ** Author		: gavinhuang
 ** Date		: 2011-02-27
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: xplatform character library
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#if !defined(_XPCHARSET_INC_)
#define _XPCHARSET_INC_
#pragma once

#include <xptypes.h>
#include <xpexcept.h>
#include <xpstream.h>
/*
#ifdef __cplusplus
extern "C" {
#endif
*/
_XP_API boolean xpgbk2utf16(const gbk* str,uint32 len,xp::strutf16 &strutf16);

_XP_API boolean xputf162gbk(const utf16* pstr, uint32 ulen,xp::strutf8 &strgbk);
	
_XP_API boolean xputf82utf16(const utf8* str, uint32 len,xp::strutf16 &strutf16);

_XP_API boolean xputf162utf8(const utf16* str, uint32 len,xp::strutf8 &strutf8);

_XP_API
uint32 xpgbk2utf16(const gbk* str,uint32 len,utf16 **pputf16);

_XP_API
uint32 xputf162gbk(const utf16* pstr, uint32 ulen,gbk **pgbk);
	
_XP_API
uint32 xputf82utf16(const utf8* str, uint32 len,utf16 **pputf16);

_XP_API
uint32 xputf162utf8(const utf16* str, uint32 len,utf8** pputf8);

/*	
#ifdef __cplusplus
};
#endif
*/
#endif /*_XPCHARSET_INC_*/
