/** 
@file 
@brief		UDP发送调节器,用于UDP发送的流量控制
@version	
*/

#pragma once

#include <xpvector.h>

class CHttpSpeedCalc
{
public:
	CHttpSpeedCalc();
	~CHttpSpeedCalc();
	
	void	AddTransferLen(uint64 uLen);
	uint32	GetTransferSpeed(uint32 utickcount,uint64 &uTransferLen);

private:

    uint32  m_uStartTickCount;
    uint64  m_uTotalLen;
    
	uint64  m_uTransferLen;
	uint32  m_uLastGetTickCount;
};
