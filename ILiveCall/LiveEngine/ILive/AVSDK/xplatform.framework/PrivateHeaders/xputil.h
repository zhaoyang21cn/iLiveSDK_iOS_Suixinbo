/** Copyright (c) 2011-2021 Tencent Technology All Right Reserved.
  * @file       xputil.h
  * @brief      
  * @version    2012-10-11  create this file
  */

#ifndef __XP_UTIL_H__
#define __XP_UTIL_H__

#include "xplock.h"
#include "xpmap.h"

class _XP_CLS CPktFlowStat
{
public:
    CPktFlowStat();

    void Reset();
    void RecvData(uint32 uPktSeqNO);
    void UpdateStat();

    uint32 GetLossTimes() const { return m_stat.uLossTimes; }
    uint32 GetTotalPkt() const { return m_stat.uTotalPkt; }
    uint32 GetRecvPkt() const { return m_stat.uRecvPkt; }

private:
    CXPLock m_lockFlowStat;
    boolean m_bInit;

    typedef xpstl::map<uint32, uint32> SeqMap;
    SeqMap m_mapLoss;
    uint32 m_uBase;
    uint32 m_uLast;
    uint32 m_uPktRecv;

    struct
    {
        uint32 uLossTimes;
        uint32 uTotalPkt;
        uint32 uRecvPkt;
    }m_stat;
};

#if defined(_OS_WIN_)

_XP_API HRESULT XPCreateObjectFromFile(LPCTSTR szFile, REFCLSID clsid, REFIID iid, void** ppv);

#endif

#define CHECK_NULL_AND_RETURN_VOID(checkvalue)	\
	if( checkvalue == NULL ) {\
		return;\
	}
#define CHECK_NULL_AND_RETURN_RET(checkvalue, ret)	\
	if( checkvalue == NULL ) {\
		return ret;\
	}
#define CHECK_NULL_AND_GOTO_EXIT(checkvalue)	\
	if( checkvalue == NULL ) {\
		goto EXIT;\
	}

#endif
