/** 
@file 
@brief		协议加解码
@version	2010-08-13 gavinhuang
*/

#pragma once

#include "bicsprotocoldef.h"
#include "bibuffer.h"

class CBICmdCodec
{
public:
	virtual ~CBICmdCodec(void) {};
	/// 从TXData Code成buffer
	virtual boolean  CodeST(pt_obj* pCmdData, CBIBuffer &bufferOut) = 0;

	/// 从Buffer Decode得到TXData	
	virtual boolean  DecodeBuffer(CBIBuffer &bufIn, pt_obj** ppCmdData, pt_obj* pSendData) = 0;
	virtual boolean  DecodeBuffer(uint8* pbuf,uint32 nbuflen, pt_obj* pCmdData, pt_obj* pSendData) = 0;
	virtual boolean  DecodeBuffer(uint8* pbuf,uint32 nbuflen, pt_obj** ppCmdData, pt_obj* pSendData) = 0;
};

