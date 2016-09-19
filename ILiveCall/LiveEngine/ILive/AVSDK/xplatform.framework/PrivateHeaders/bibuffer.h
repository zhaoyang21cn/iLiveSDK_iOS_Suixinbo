

#pragma once

#include <xptypes.h>
#include "biclss.h"

class _XP_API CBIBuffer
{
public:
	CBIBuffer();
	~CBIBuffer();
	CBIBuffer(const CBIBuffer &buf );
public:
	boolean IsEmpty() const;
	boolean Empty();
	boolean CopyFrom(const uint8* pcBuf, uint32 uSize);
	boolean CopyFromTXBuffer(CBIBuffer &buf);
	boolean Attach(uint8* pcBuf, uint32 uSize);
	uint8*	Detach();
	uint8*	Resize(uint32 uSize);
	uint8*	GetNativeBuf() const;
	boolean GetAt(uint32 uIndex, uint8* pcValue) const;
	boolean SetAt(uint32 uIndex, uint8 cValue);
	uint32	GetSize() const;
	int32	Compare(uint8* pcBuf, uint32 uSize) const;
	uint8*	Append(uint8* pcBuf, uint32 uSize);
	boolean SetAllocBase(uint32 uSize);

	CBIBuffer& operator=(const bi_buf& bufSrc);
	CBIBuffer& operator=(const CBIBuffer& bufSrc );
	
	operator bi_buf() const;

	void Swap(CBIBuffer & rhs);
	
private:
	/// 调整buffer。注意不会Free原buf，调用者自己处理。
	void AdjustBuffer(uint32 uSize);

private:
	uint8*	m_pcBuf;
	uint32	m_uSize;
	uint32	m_uAllocBase;
	uint32	m_uAllocSize;
};
