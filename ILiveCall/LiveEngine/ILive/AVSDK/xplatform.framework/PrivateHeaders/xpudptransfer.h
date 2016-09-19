#pragma once

/** 
@file      
@brief	    xpudptransferservice	
@version	2014/01/13 Gavinhuang Create
*/

#include <xpudpchanneli.h>
#include <xpstreamreader.h>

class CXPUdpTransferPostRequest : public CRefCountSafe
{
public:
	uint64		uFileSize;
	xp::buffer  bufPostReq;
	uint64		uSessionId;
	uint32		uSeq;
	uint32		uFromIP;
	uint16		uFromPort;
};

class CXPUdpTransferGetRequest : public CRefCountSafe
{
public:
	xp::buffer  bufGetReq;
	uint64		uSessionId;
	uint32		uSeq;
	uint64		uRange;
	uint32		uFromIP;
	uint16		uFromPort;
};


class IXPUdpTransferSender;

class  IXPUdpTransferSenderSink  
{
public:
	IXPUdpTransferSenderSink();
	virtual ~IXPUdpTransferSenderSink();
	virtual void OnSendProgress(IXPUdpTransferSender *pSender, uint64 dwProgress, uint64 dwProgressMax,uint32 uSpeed_Byte_S){};
	virtual void OnSendComplete(IXPUdpTransferSender *pSender, uint32 dwErrorCode,const xp::strutf16 &strErrorDisc) = 0;
};

class IXPUdpTransferSender
{
public:
	virtual ~IXPUdpTransferSender();
	virtual boolean Init(IXPUdpTransferSenderSink* pSink,uint32 uDestIP,uint16 uDestPort,IXPUdpChannel* pChn,uint64 uSessionId) = 0;
	virtual boolean SendBySelfPost(xp::buffer &bufPostReq,xp::strutf16 *pstrSendFileName,IXPStreamReader* pFileReader = NULL) = 0;
	virtual boolean AcceptByPeerGet(CXPUdpTransferGetRequest* pReq,xp::strutf16 *pstrSendFileName,IXPStreamReader* pStreamReader = NULL) = 0;
	virtual void	RefuseByPeerGet(uint32 nErrCode,xp::strutf16 &strErr) = 0;
	virtual uint64  GetSessionId() = 0;
	virtual void	Cancel() = 0;
};


class IXPUdpTransferReceiver;

class  IXPUdpTransferReceiverSink 
{
public:
	IXPUdpTransferReceiverSink();
	virtual ~IXPUdpTransferReceiverSink();
	virtual void OnRecvProgress(IXPUdpTransferReceiver *pReceiver, uint64 dwProgress, uint64 dwProgressMax,uint32 uSpeed_Byte_S){};
	virtual void OnRecvComplete(IXPUdpTransferReceiver *pReceiver, uint32 dwErrorCode,const xp::strutf16 &strErrorDisc) = 0;
};

class IXPUdpTransferReceiver
{
public:
	virtual ~IXPUdpTransferReceiver();
	virtual boolean Init(IXPUdpTransferReceiverSink *pSink,IXPUdpChannel* pChn,uint32 uDestIP,uint16 uDestPort,uint64 uSessionId) = 0;
	virtual boolean ReceiveByPeerPost(CXPUdpTransferPostRequest* pReq,const xp::strutf16 &strSaveFileName) = 0;
	virtual boolean RefuseByPeerPost(uint32 uCode,xp::strutf16 &strDisc) = 0;
	virtual boolean ReceiveSelfGet(xp::buffer &bufGetReq,const xp::strutf16 &strSaveFileName) = 0;
	virtual boolean GetReceiveFilePath(xp::strutf16 &strFileName) = 0;
	virtual uint64  GetSessionId() = 0;
	virtual void	Cancel() = 0;
};

class  IXUdpTransferServiceSink
{
public:
	virtual ~IXUdpTransferServiceSink();
	virtual void OnTransferPostRequest(CXPUdpTransferPostRequest* pReq) = 0;
	virtual void OnTransferGetRequest(CXPUdpTransferGetRequest* pReq)   = 0;
};

class IXPUdpTransferService
{
public:
	virtual ~IXPUdpTransferService();
	virtual void Init(IXPUdpChannel* pChn,IXUdpTransferServiceSink* pSink) = 0;
    
    //用于发送滑动窗口快速启动的参数记录和获取
    virtual void AddParamForSliderWinQuickStart(uint32 uDestIP,uint16 uDestPort,CRefCountSafe* pParam)   = 0;
    virtual void GetParamForSliderWinQuickStart(uint32 uDestIP,uint16 uDestPort,CRefCountSafe** ppParam) = 0;
};


IXPUdpTransferService*  GetUdpTransferServiceInstance();
void                    DestoryUdpTransferServiceInstance();

IXPUdpTransferSender*   CreateXPUdpTransferSender();
IXPUdpTransferReceiver* CreateXPUdpTransferReceiver();

