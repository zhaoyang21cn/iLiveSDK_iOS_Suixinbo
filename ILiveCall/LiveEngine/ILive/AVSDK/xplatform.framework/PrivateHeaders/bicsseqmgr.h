
#pragma once

#include <xptypes.h>

// 管理序列号
class  _XP_CLS CBICSSeqMgr  
{
public:
	
	CBICSSeqMgr();
	virtual ~CBICSSeqMgr();

	/// 根据cmd获得该cmd的下个系列号
	uint16 GetNextSendSeq(uint16 wCmd);

	/// 由wCmd 和 wSeq 判断是否之前已收到同样的命令
	boolean IsCmdSeqRecved(uint16 wCmd, uint16 wSeq);
	
	void Reset();

protected:

	uint16		m_wSeqBase;
	uint32*		m_pardwCmd2Seq; //简单处理
	int32		m_nPos;
};


