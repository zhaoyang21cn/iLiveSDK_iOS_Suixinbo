/******************************************************************
 ** File 		: txclss.h
 ** Author		: Amoslan
 ** Copyright	: Copyright 2011 Tencent. All rights reserved.
 ** Description	: basic class
 **
 ******************************************************************/
#ifndef __TXCLSSEXT_INC_
#define __TXCLSSEXT_INC_

#include "biclss.h"
#include "bibuffer.h"

inline uint32 bi_str16len(const utf16* pu16) {
	if( NULL == pu16 ) return 0;
	const utf16 *pend = pu16;
	while(*pend++){;};
	return (uint32)(pend-pu16-1);
}


_XP_API boolean bi_put_buf(bi_buf &stbufdest, CBIBuffer &bufSrc);
_XP_API boolean bi_put_buf(bi_buf &stbufdest, uint8* pcbuf,uint32 ulen);
_XP_API boolean bi_put_buf(bi_buf &stbufdest, bi_buf &stbufsrc);

_XP_API boolean bi_put_str(bi_str &strdest, const utf8* pstr,uint32 ulen = -1);
_XP_API boolean bi_put_str(bi_str &strdest, bi_str &strsrc);
_XP_API boolean bi_put_str(bi_stru16 &strdest, const utf16* pstr,uint32 ulen = -1);
_XP_API boolean bi_put_str(bi_stru16 &strdest, bi_stru16 &strsrc);
_XP_API boolean bi_put_str(bi_stru16 &strdest, const utf8* pstr,uint32 ulen = -1);

_XP_API boolean bi_get_buf(uint8* pbuf, bi_buf &srcbuf);
_XP_API boolean bi_get_buf(uint8** ppbuf, bi_buf &srcbuf);
_XP_API boolean bi_get_buf(CBIBuffer &buf, bi_buf &srcbuf);

_XP_API boolean bi_detach_buf(bi_buf &bufdest, bi_buf &bufsrc);
_XP_API boolean bi_detach_str(bi_str &strdest, bi_str &strsrc);
_XP_API boolean bi_detach_str(bi_stru16 &strdest, bi_stru16 &strsrc);

_XP_API int32 bi_str_cmp(const bi_stru16 &stra, const bi_stru16 &strb);
_XP_API int32 bi_str_cmp(const bi_str &stra, const bi_str &strb);
_XP_API int32 bi_buf_cmp(const bi_buf &bufa, const bi_buf &bufb);
_XP_API void bi_combine_str(const bi_str &str1,const bi_str &str2,bi_str &str);
_XP_API void bi_combine_str(const bi_stru16 &str1,const bi_stru16 &str2,bi_stru16 &str);
_XP_API void bi_combine_path(const bi_str &str1,const bi_str &str2,bi_str &str);
_XP_API void bi_combine_path(const bi_stru16 &str1,const bi_stru16 &str2,bi_stru16 &str);

_XP_API void bi_revise_backslash(bi_stru16& str);
_XP_API void bi_revise_backslash(bi_str &str);

#define bi_put_guid(buf,guid)	bi_put_buf(buf,(uint8*)&guid.Data1,sizeof(GUID));
#define cmp_guid(guid,buf)		memcmp((void*)(&guid.Data1), buf.pbuf, buf.ulen);

#endif /*__TXCLSSEXT_INC_*/
