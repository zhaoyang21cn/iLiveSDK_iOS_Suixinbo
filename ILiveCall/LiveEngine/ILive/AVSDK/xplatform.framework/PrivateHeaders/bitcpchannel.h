/*
 *  TCPChannel.h
 *  BaseIM
 *
 *  Created by gavinhuang on 12-3-31.
 *  Copyright 2012 tencent. All rights reserved.
 *
 */

#pragma once

#include <xpsocket.h>
#include <xprefc.h>
#include <xptimer.h>
#include "biclss.h"
#include "biichannel.h"
#include <xplock.h>

#undef  __MODULE__
#define __MODULE__ "udpchannel"

class _XP_CLS CBITCPChannel
	: public CBIITCPChannel
	, public CXPICombineTCPSocketSink
	, public CXPITCPCnnSocketSink
	, public CXPTimer
{
protected:
	CBITCPChannel();
	virtual ~CBITCPChannel();
	
public:
	static bool CreateInstance(CBIIChannel** ppChannel, CBIITCPChannel** ppTcpChannel); 

	//  CBIIChannel的接口实现
	virtual void SetSink(CBIIChannelSink *pSink);
	virtual void Connect(uint32 uIP, uint16 usPort);
	virtual boolean	SendData(uint8* pcBuf,uint32 uiLen,uint32 &ulCookie,uint32 nTryCount=3,uint32 nTryInternal=5000,boolean bCallTimeOut = true, xpstl::list<xp::strutf8>* plstHosts = NULL);
	virtual boolean	CancelSend(uint32 dwCookie);
	virtual void ForceAllTimeOut(int32 nReason = 0);
    virtual xpsocket NativeSocket();//warning by silas

	// CBIITCPChannel的接口实现
	virtual void SetGetPacketLength(xpcombinetcp_getpklenfun pFunc);
	virtual void SetMaxPacketLength(uint32 uLen);
	virtual void SetHeadLength(uint32 uLen);
	
private:
	
	//timer
	void	OnTimer(uint32 uId);
	
	//CXPITCPCnnSocketSink
	void	OnConnected(boolean bSucccess,CXPITCPCnnSocket* pCnnSocket,boolean bIsBeClosed);
	
	//CXPICombineTCPSocketSink
	void	OnRecv(const uint8* pPacket,uint32 uPacketlen,CXPICombineTCPSocket* pTCPSocket);
	void	OnSend(CXPICombineTCPSocket* pTCPSocket);
	void	OnClose(CXPICombineTCPSocket* pTCPSocket);
	
	boolean IsHaveDataToSend();
	void	ClearAllSendData();
	
private:	
    xpsocket                m_sksave;
	
	uint32					m_uIP;
	uint16					m_usPort;
	uint32					m_uCookieBase;

	CScopePtr<CBIIChannelSink> m_pSink;

	CXPLock					m_lock;
	CMapCookie2SendData		m_mapCookie2SendData;
	CXPITCPCnnSocket*		m_pCnnSocket;
	CXPICombineTCPSocket*   m_pCombineTCP;
	xpcombinetcp_getpklenfun m_pGetPktLenFunc;
	uint32	m_uMaxPktLen;
	uint32	m_uHeadLen;
};
