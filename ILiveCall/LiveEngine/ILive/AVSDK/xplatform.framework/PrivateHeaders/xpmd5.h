/** 
@file 
@brief		加解密. 实现下列算法: Hash算法: MD5,已实现. 对称算法: DES,未实现. 非对称算法: RSA,未实现
@version	2002-9-25 hyj  创建
@version	2005-4-07 yuyu 整理
*/

#pragma once

#include <xptypes.h>

#define MD5_DIGEST_LENGTH	16
#define MD5_LBLOCK			16

// MD5数据结构
typedef struct MD5state_st
	{
	uint32 A,B,C,D;
	uint32 Nl,Nh;
	uint32 data[MD5_LBLOCK];
	int32 num;
	} MD5_CTX;

#ifdef __cplusplus
extern "C" {
#endif
	
_XP_API void MD5_Init(MD5_CTX *c);
_XP_API void MD5_Update(MD5_CTX *c, const register uint8 *data, uint32 len);
_XP_API void MD5_Final(uint8 *md, MD5_CTX *c);

/**@ingroup ov_Crypt
@{
*/
/// MD5 Hash函数
/** @param outBuffer out, Hash后的Buffer, 该Buffer的长度固定为MD5_DIGEST_LENGTH(16uint8)
	@param inBuffer in, 原始buffer.
	@param length in, 原始buffer的长度, 接受长度为0的buffer
*/
_XP_API void Md5HashBuffer( uint8 *outBuffer, const void *inBuffer, uint32 length);

#ifdef __cplusplus
};
#endif
