/** 
@file 
@brief		加解密. 实现下列算法: Hash算法: MD5,已实现. 对称算法: DES,未实现. 非对称算法: RSA,未实现
@version	2002-9-25 hyj  创建
@version	2005-4-07 yuyu 整理
*/

#pragma once

#include <xptypes.h>

#ifdef __cplusplus
extern "C" {
#endif
	
/// 可追加的CRC32校验，crc-->原有的crc校验值，buf-->待追加校验的缓冲，len-->缓冲长度
_XP_API uint32 CRC32(uint32 crc, const uint8* buf, int32 len);

#ifdef __cplusplus
};
#endif