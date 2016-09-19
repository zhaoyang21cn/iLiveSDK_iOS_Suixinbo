/*
 *  TXIChannel.h
 *  BaseIM
 *
 *  Created by gavinhuang on 12-3-31.
 *  Copyright 2012 tencent. All rights reserved.
 *
 */

#pragma once

#include <xpnet.h>
#include <xptypes.h>
#include <xprefc.h>
#include <xprefsink.h>
#include <xplist.h>
#include <xpmap.h> //todo
#include <xpsocket.h>
#include <xpstream.h>

class _XP_CLS CBIIChannelSink : public CRefCountSafe
{
public:
	virtual void OnConnect(bool bSuccess)					= 0;
	virtual void OnRecv(const uint8* pcBuf,int32 nlen)		= 0;
	virtual void OnTimeOut(uint32 dwCookie,int32 nReason)	= 0;
	virtual void OnClose()									= 0;
};
DECLARE_REFSINK_BEGIN(CBIIChannelSinkProxy, CBIIChannelSink)
	IMPLEMENT_REFSINK_FUNCTION(OnConnect, (bool bSuccess), (bSuccess))
	IMPLEMENT_REFSINK_FUNCTION(OnRecv, (const uint8* pcBuf, int32 nlen), (pcBuf, nlen))
	IMPLEMENT_REFSINK_FUNCTION(OnTimeOut, (uint32 dwCookie, int32 nReason), (dwCookie, nReason))
	IMPLEMENT_REFSINK_FUNCTION(OnClose, (), ())
DECLARE_REFSINK_END()

class _XP_CLS CBIIChannel : public CRefCountSafe
{
public:
	virtual void SetSink(CBIIChannelSink *pSink) = 0;
	virtual void Connect(uint32 uIP, uint16 usPort) = 0;
	virtual boolean	SendData(uint8* pcBuf,uint32 uiLen,uint32 &uCookie,uint32 nTryCount=3,uint32 nTryInternal_ms=5000,boolean bCallTimeOut = true, xpstl::list<xp::strutf8>* plstHosts = NULL) = 0;
	virtual boolean	CancelSend(uint32 dwCookie) = 0;
	virtual void ForceAllTimeOut(int32 nReason = 0) = 0;
    virtual xpsocket NativeSocket(void) = 0;//warning by silas
};

typedef struct tagsenddata
{
	uint8* pcBuf;
	uint32 uiLen;
	uint32 nTryCount;
	uint32 nTryInternal;
	uint32 tNextSendTime;
	boolean bCallTimeOut;
} senddata;

class _XP_CLS CMapCookie2SendData : public xpstl::map<uint32,senddata*>
{};

class _XP_CLS CBIITCPChannel : public CBIIChannel
{
public:
	virtual void SetGetPacketLength(xpcombinetcp_getpklenfun pFunc) = 0;
	virtual void SetMaxPacketLength(uint32 uLen) = 0;
	virtual void SetHeadLength(uint32 uLen) = 0;
};