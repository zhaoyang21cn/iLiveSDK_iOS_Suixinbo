/*
 *  UtilEncode.h
 *  Engine
 *
 *  Created by gavinhuang on 10-11-4.
 *  Copyright 2010 Tencent. All rights reserved.
 *
 */

#include "biclss.h"

#define MAKEUINT64(a, b)		((uint64)(((uint32)(a)) | ((uint64)((uint32)(b))) << 32))


_XP_API boolean bi_encode16(const bi_buf &buffer,bi_stru16 &strOut);
_XP_API boolean bi_encode16(const void * mem, uint32 len,bi_stru16 &strOut);
_XP_API boolean bi_decode16(const bi_str & strContent,bi_buf & bufOut);
_XP_API boolean bi_decode16(const utf8* p,int len ,bi_buf & bufOut);
_XP_API boolean bi_encodehash(const bi_buf & bufMd5, bi_str &strOut );
_XP_API boolean bi_decodehash(const bi_stru16 &strIn, bi_buf &bufMd5Out );
_XP_API boolean bi_hashname2guidname(const bi_stru16&strFileName,bi_str &strHashPureName);
_XP_API boolean bi_guidname2hashname(const bi_str &strHashName,bi_str &strGuidName);


_XP_API boolean bi_utf162gbk(const utf16* pstrUTF16, uint32 len,bi_str &strgbk);
_XP_API boolean bi_gbk2utf16(const utf8* pstrGBK,uint32 len,bi_stru16 &strUtf16);
_XP_API boolean bi_utf82utf16(const utf8* pstrUTF8, uint32 len,bi_stru16 &strUtf16);
_XP_API boolean bi_utf162utf8(const utf16* pstrUTF16, uint32 len,bi_str &strUtf8);
_XP_API boolean bi_int642str(int64 i64Value,bi_str &v);
_XP_API boolean bi_uint642str(uint64 ui64Value,bi_str &v);
_XP_API int BrokenCodec_debug();
