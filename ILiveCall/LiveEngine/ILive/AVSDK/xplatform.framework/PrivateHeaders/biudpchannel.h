/*
 *  UdpChannel.h
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

class _XP_CLS CBIUDPChannel 
	: public CBIIChannel
	, public CXPIUDPSocketSink
	, public CXPTimer
{
protected:
	CBIUDPChannel();
	virtual ~CBIUDPChannel();
	
public:
	static bool CreateInstance(CBIIChannel** ppChannel); 
	virtual void SetSink(CBIIChannelSink *pSink);
	virtual void Connect(uint32 uIP, uint16 usPort);
	virtual boolean	SendData(uint8* pcBuf,uint32 uiLen,uint32 &ulCookie,uint32 nTryCount=5,uint32 nTryInternal=5000,boolean bCallTimeOut = true, xpstl::list<xp::strutf8>* plstHosts = NULL);
	virtual boolean	CancelSend(uint32 dwCookie);
	virtual void ForceAllTimeOut(int32 nReason = 0);
    virtual xpsocket NativeSocket(void);//warning by silas
		
private:
	
	//timer
	void	OnTimer(uint32 uId);

	//CXPIUDPSocketSink
	void OnBind(boolean bSuccess,uint32 uBindIP,uint16 uBindPort,CXPIUDPSocket* pUdpSocket);
	void OnRecv(const uint8* pData,uint32 uDataLen,uint32 uFromIP,uint16 uFromPort,CXPIUDPSocket* pUdpSocket);
		
	void	CheckData();
	void	ClearAllSendData();
	
private:
	
	
	
	
	uint32					m_uIP;
	uint16					m_usPort;
	uint32					m_uCookieBase;
    uint32                  lasttime;
	CScopePtr<CBIIChannelSink> m_pSink;

	CXPLock					m_lock;
	CMapCookie2SendData		m_mapCookie2SendData;
	boolean					m_bPause;
	CXPIUDPSocket*			m_pUdpSocket;
    boolean                changenet;
};
