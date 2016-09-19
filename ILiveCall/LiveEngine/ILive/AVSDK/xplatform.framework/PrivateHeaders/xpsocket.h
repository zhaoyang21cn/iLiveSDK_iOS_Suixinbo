/*
 *  xpsocket.h
 *  hello-xp
 *
 *  Created by gavinhuang on 12-3-21.
 *  Copyright 2012 tencent. All rights reserved.
 *
 */

#if !defined(_XPISOCKET_INC_)
#define _XPISOCKET_INC_

#include "xptypes.h"
#include "xpnet.h"
#include "xptask.h"

typedef enum XPSOCKET_EVNET 
{
	XPSOCKET_EVENT_READ		= 0x02,
	XPSOCKET_EVENT_WRITE	= 0x04,
	XPSOCKET_EVENT_READWRITE= XPSOCKET_EVENT_READ|XPSOCKET_EVENT_WRITE
} XPSOCKET_EVNET;


//******************************************************************//
//******************** All Socket Interface ************************//
//******************************************************************//

//******connect tcp*********//

class CXPITCPCnnSocket;

class _XP_CLS CXPITCPCnnSocketSink
{
public:	
	virtual ~CXPITCPCnnSocketSink(){};
	virtual void OnConnected(boolean bSuccess,CXPITCPCnnSocket* pCnnSocket,boolean bIsBeClosed=false) = 0;
	virtual	void SetIpAndPort2Bind(const utf8* addr, uint16 port){}
};

class _XP_CLS CXPITCPCnnSocket
{
public:	
	virtual				~CXPITCPCnnSocket(){};
	virtual	void	    SetIpAndPort2Bind(const utf8* addr, uint16 port){}
	virtual void		SetSink(CXPITCPCnnSocketSink* pSink) = 0;
	virtual boolean		Connect(const utf8* addr,uint16 port,uint32 timeout_ms) = 0;
	virtual xpsocket	Detach() = 0;
};


//******listen tcp*********//

class CXPITCPListenSocket;

class _XP_CLS CXPITCPListenSocketSink
{
public:
	virtual ~CXPITCPListenSocketSink(){};
	virtual void OnBind(uint32 uListenIP,uint16 uListenPort,CXPITCPListenSocket* pListen) = 0;
	virtual void OnAccept(CXPITCPListenSocket* pListen) = 0;
	virtual void OnClose(CXPITCPListenSocket* pListen)  = 0;
};

class _XP_CLS CXPITCPListenSocket
{
public:
	virtual ~CXPITCPListenSocket(){};
	virtual void	 SetSink(CXPITCPListenSocketSink* pSink) = 0;
	virtual boolean  Listen(uint32 uBindIP,uint16 uBindPort,uint32 uListenTimeout_ms = 5000 ,int32 nbackbog = 5) = 0;
	virtual boolean  GetSocketName(uint32 &uListenIP,uint16 &uListenPort) = 0;
	virtual boolean  Attach(xpsocket s,uint32 uListenTimeout_ms) = 0;
	virtual xpsocket Accept() = 0;
	virtual void	 Close() = 0;
};

//******UDP*********//

class CXPIUDPSocket;

class _XP_CLS CXPIUDPSocketSink
{
public:
	virtual ~CXPIUDPSocketSink(){};
	virtual void OnBind(boolean bSuccess,uint32 uBindIP,uint16 uBindPort,CXPIUDPSocket* pUdpSocket) = 0;
	virtual void OnRecv(const uint8* pData,uint32 uDataLen,uint32 uFromIP,uint16 uFromPort,CXPIUDPSocket* pUdpSocket) = 0;
};

class _XP_CLS CXPIUDPSocket
{
public:
	virtual ~CXPIUDPSocket(){};
	
	virtual boolean  Create(uint32 uTimeout_ms,uint32 uBindIP = 0,uint16 uBindPort = 0) = 0;
	virtual void	 SetSink(CXPIUDPSocketSink* pSink) = 0;
	virtual void	 Attach(xpsocket s) = 0;
	virtual xpsocket Detach() = 0;
	virtual xpsocket NativeSocket() = 0;
	virtual int32	 SendTo(const utf8 *IP, uint16 wPort, const uint8 *pData,uint32 uBufLen) = 0;
	virtual int32	 SendTo(uint32 uIP, uint16 wPort, const uint8 *pData,uint32 uBufLen) = 0;
	virtual int32	 RecvFrom(uint8 *pData,uint32 ulen,uint32 &uFromIP,uint16 &uFromPort) = 0;
	
	virtual boolean  SetSendBufferSize(int32 size) = 0;
	virtual boolean  SetRecvBufferSize(int32 size) = 0;
	virtual boolean  GetSocketName(uint32 &ip,uint16 &port) = 0;
	virtual boolean  SelectEvent(XPSOCKET_EVNET e,boolean bIsToClear) = 0;
	virtual void	 Close() = 0;	
};

//******Communication TCP*********//

class CXPITCPSocket;

class _XP_CLS CXPITCPSocketSink
{
public:	
	virtual ~CXPITCPSocketSink(){};
	virtual void OnRecv(CXPITCPSocket* pTCPSocket)	= 0;
	virtual void OnSend(CXPITCPSocket* pTCPSocket)	= 0;
	virtual void OnClose(CXPITCPSocket* pTCPSocket)	= 0;
};

class _XP_CLS CXPITCPSocket
{
public:
	
	virtual ~CXPITCPSocket(){};
	
	virtual void	 SetSink(CXPITCPSocketSink* pSink) = 0;
	virtual void	 Attach(xpsocket s) = 0;
	virtual xpsocket Detach() = 0;
    virtual xpsocket NativeSocket() = 0;
	
	virtual int32	Send(const void *pData,uint32 ulen) = 0;
	virtual int32	Recv(void *pData,uint32 ulen) = 0;
	
	virtual uint32  GetUnReadDataLen() = 0;
	virtual boolean SetSendBufferSize(int32 size) = 0;
    virtual boolean GetSendBufferSize(int32 &size) = 0;
	virtual boolean SetRecvBufferSize(int32 size) = 0;
    virtual boolean GetRecvBufferSize(int32 &size) = 0;
	virtual boolean SetNoDelay(boolean bIsToSet = true) = 0;
	virtual boolean GetSocketName(uint32 &ip,uint16 &port) = 0;
	virtual boolean GetPeerName(uint32 &ip,uint16 &port) = 0;
	virtual boolean SelectEvent(XPSOCKET_EVNET e,boolean bIsToClear = false) = 0;
	virtual void	Close() = 0;
};


//******Communication TCP For Combine Logic Packet*********//

typedef boolean (*xpcombinetcp_getpklenfun)(const uint8* pData,uint32 len,uint32 &uPacketTotalLen);

class CXPICombineTCPSocket;

class _XP_CLS CXPICombineTCPSocketSink
{
public:	
	virtual ~CXPICombineTCPSocketSink(){};
	virtual void OnRecv(const uint8* pPacket,uint32 uPacketlen,CXPICombineTCPSocket* pTCPSocket)	= 0;
	virtual void OnSend(CXPICombineTCPSocket* pTCPSocket)	= 0;
	virtual void OnClose(CXPICombineTCPSocket* pTCPSocket)	= 0;
};

class _XP_CLS CXPICombineTCPSocket
{
public:
	virtual ~CXPICombineTCPSocket(){};
	
	virtual void	 SetSink(CXPICombineTCPSocketSink* pSink) = 0;
	virtual boolean	 SetCombineInfo(uint32 uPacketHeadLen,xpcombinetcp_getpklenfun fun,uint32 maxPacketSize = 2048) = 0;
	virtual void	 Attach(xpsocket s) = 0;
	virtual xpsocket Detach() = 0;
	
	virtual int32	Send(const void *pData,uint32 ulen) = 0;
	virtual uint32  GetUnReadDataLen() = 0;
	virtual boolean SetSendBufferSize(int32 size) = 0;
	virtual boolean SetRecvBufferSize(int32 size) = 0;
	virtual boolean SetNoDelay(boolean bIsToSet = true) = 0;
	virtual boolean GetSocketName(uint32 &ip,uint16 &port) = 0;
	virtual boolean GetPeerName(uint32 &ip,uint16 &port) = 0;
	virtual boolean SelectEvent(XPSOCKET_EVNET e,boolean bIsToClear = false) = 0;
	virtual void	Close() = 0;
};
#if !defined(_OS_ANDROID_)
//****************************************************************************//
//****** Reverse TCP Cnn Mgr *********//
//****************************************************************************//

//Reverse TCP Cnn Mgr added by medivhwu
class _XP_CLS CXPIReverseTcpMgrSink
{
public:
    virtual ~CXPIReverseTcpMgrSink() {};
    virtual void OnStart(uint32 dwIP,uint16 uPort) = 0;
    virtual void OnConnected(boolean isSuccess,CXPICombineTCPSocket* socket) = 0;
    virtual void OnNewReverseTcpSocket(boolean isSuccess,CXPITCPSocket* socket,uint32 dwPeerIP,uint16 uPeerPort,uint32 chnID) = 0;
};

class _XP_CLS CXPIReverseTcpSocketCreaterSink
{
public:
    virtual ~CXPIReverseTcpSocketCreaterSink() {};
    virtual void OnCreatReverseTcpSocket(boolean isSuccess,xpsocket socket,uint32 dwPeerIP,uint16 uPeerPort,uint32 chnID) = 0;
};

class _XP_CLS CXPIReverseTcpSocketCreater
{
public:
    virtual void         CreatReverseTcpSocket(xpnet_endpoint peerEndpoint,uint32 chnID,CXPIReverseTcpSocketCreaterSink* pSink, uint32 timeout_ms) = 0;
    virtual void         EraseReverseTcpSocketCreaterSink(uint32 chnID) = 0;
    virtual				 ~CXPIReverseTcpSocketCreater() {};
};

class _XP_CLS CXPIReverseTcpMgr : public CXPIReverseTcpSocketCreater
{
public:
    virtual void         SetSink(CXPIReverseTcpMgrSink* pSink) = 0;
    virtual void		 Start() = 0;
    virtual void		 Connect(uint32 dwTargetIP,uint16 uTargetPort) = 0;
    virtual boolean      IsOK() = 0;
    virtual void		 Stop() = 0;
    virtual CXPTaskIO*   GetTask() = 0;
    virtual				 ~CXPIReverseTcpMgr() {};
};

#endif

//****************************************************************************//
//******Help API To Create the Socket Interface and Set Network Proxy*********//
//****************************************************************************//

typedef enum XPProxyType 
{
	xpproxy_none,
	xpproxy_http,
	xpproxy_socks5
} XPProxyType;
	
//set global proxy
_XP_API void XPSetGlobalProxyInfo(XPProxyType type,const utf8* proxyip,uint16 proxyport, const utf8* usename,const utf8* password);

//get golbal proxy , notice: the utf8** direct refence the golbal data,unneed to free
_XP_API void XPGetGlobalProxyInfo(XPProxyType &type,utf8** proxyip = NULL,uint16* proxyport = NULL,utf8** usename = NULL,utf8** password = NULL);



//******Create Cnn TCP******/

//create connet socket by global proxy
_XP_API CXPITCPCnnSocket*		XPCreateCnnTCPSocket();

//appiont create a none proxy cnn socket
_XP_API CXPITCPCnnSocket*		XPCreateNoneProxyCnnTCPSocket();

//appiont create a proxy cnn socket
_XP_API CXPITCPCnnSocket*		XPCreateProxyCnnTCPSocket(XPProxyType type,const utf8* proxyip,uint16 proxyport, const utf8* usename,const utf8* password);
#if !defined(_OS_ANDROID_)
_XP_API CXPITCPCnnSocket*		XPCreateReverseCnnTCPSocket(CXPIReverseTcpSocketCreater* creater,CXPTaskIO* pTask);

_XP_API CXPIReverseTcpMgr*		XPCreateReverseTCPMgr();
#endif
//******Create Listen TCP******/

//create listen socket by global proxy
_XP_API CXPITCPListenSocket*	XPCreateTCPListenSocket();

//appiont create a none proxy listen socket
_XP_API CXPITCPListenSocket*	XPCreateNoneProxyTCPListenSocket();

//appiont create a proxy listen socket
_XP_API CXPITCPListenSocket*	XPCreateProxyTCPListenSocket(XPProxyType type,const utf8* proxyip,uint16 proxyport, const utf8* usename,const utf8* password);



//******Create UDP ******/

//create udp socket by global proxy
_XP_API CXPIUDPSocket*			XPCreateUDPSocket();

//appiont create a none proxy udp socket
_XP_API CXPIUDPSocket*			XPCreateNoneProxyUDPSocket();

//appiont create a proxy udp socket
_XP_API CXPIUDPSocket*			XPCreateProxyUDPSocket(XPProxyType type,const utf8* proxyip,uint16 proxyport, const utf8* usename,const utf8* password);


//******Create Communication TCP******/

//create a communication tcp
_XP_API CXPITCPSocket*			XPCreateTCPSocket();

//create a communication tcp by combine logic packet( send or recv always a complete logic packet)
_XP_API CXPICombineTCPSocket*	XPCreateCombineTCPSocket();

//create a communication tcp by combine logic packet( send or recv always a complete logic packet)
//and support mutilthread to send
_XP_API CXPICombineTCPSocket*	XPCreateCombineTCPSocket_MutilThread();


#endif