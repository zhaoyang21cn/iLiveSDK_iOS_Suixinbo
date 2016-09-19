
/** 
 @file      
 @brief	    xpUDPCHANNEL	
 @version	2013/11/25 Gavinhuang Create
 */

#ifndef _IUDPCHANNEL_INCLUDE_
#define _IUDPCHANNEL_INCLUDE_

#include <xprefc.h>
#include <xpstream.h>

//udpchn通道命令
enum
{
	XPUDPCHN_CMD_DISCOVER = 1,//探测包,用于破防火墙
	XPUDPCHN_CMD_FILE	  = 100,//传文件命令字
	//其他命令最好在这里登记下，方式冲突
};

//=====Udp通道协议编解码=============
class _XP_CLS CXPUdpChnPacket : public CRefCountSafe
{
public:    
	uint32		m_uCmd;		 //命令
	uint32		m_uSeq;		 //seq
	uint32		m_uSubCmd;	 //子命令
	uint64		m_uSessionId;//回话ID

	uint8		m_isNeedAck; //需要应答
	uint8		m_isAckPK;	 //是应答包

	//Chn层进行快速的应答，提高大数据传输速度,普通的信令不需要关心
	uint8		m_isNeedChnAutoAck; //需要Chn底层自动应答
	uint8		m_isChnAutoAck;		//该包是Chn底层的自动应答
	uint64		m_uChnAutoAckExData;//通道快速应答附带数据

	xp::buffer	m_bufBody;	 //数据本身
public:
	CXPUdpChnPacket();
	~CXPUdpChnPacket();
};

class _XP_CLS CXPUdpChnRetryInfo
{
public:
	CXPUdpChnRetryInfo(int32 uSendTimesPer,int32 uRetryCount,int32 uRetryIntervalms);
	int32	m_uSendTimesPer;	//每次重复发送几个包
	int32	m_uRetryCount;		//总共重复多少次
	int32	m_uRetryInterval;	//重复的时间间隔，单位为(ms)
};

class IXPUdpChannel;

//注册收到数据
class _XP_CLS IXPUdpChnRecvSink
{
public:
	virtual void OnReceiveData(CXPUdpChnPacket* pPack,const uint8* pData,uint32 uDataLen,uint32 uFromIP,uint16 uFromPort,IXPUdpChannel* fromChn) = 0;
	virtual ~IXPUdpChnRecvSink();
};


//对于需要应答包的回包通知
class _XP_CLS IXPUdpChnResponseSink
{
public:
	virtual void OnResponse(CXPUdpChnPacket* pSendPack,CXPUdpChnPacket* pResponsePack,IXPUdpChannel* fromChn) = 0;	
	virtual void OnSendTimeOut(CXPUdpChnPacket* pSendPack,IXPUdpChannel* fromChn)	= 0;	
	virtual ~IXPUdpChnResponseSink();
};

class _XP_CLS IXPUdpChannel
{
public:
	virtual boolean Create(uint16 nBindPort=0,uint32 bindIP=0) = 0;
	virtual void	Close() = 0;
	virtual void	GetSocketInfo(uint32 &uIP,uint16 &nPort) = 0;
	virtual boolean	Register(IXPUdpChnRecvSink *pSink,uint32 uCmd,uint32 uSubCmd=-1, uint64 uSessionId=-1) = 0;
	virtual void	Unregister(IXPUdpChnRecvSink *pSink) = 0;
	virtual boolean	Send(uint32 uDestIP,uint16 uDestPort,CXPUdpChnPacket* pSendPack,IXPUdpChnResponseSink* pSink = NULL,CXPUdpChnRetryInfo* pRetryInfo = NULL) = 0;
	virtual void    DeleteResponseSink(IXPUdpChnResponseSink* pSink) = 0;
	virtual void	SendDiscover(uint32 uDestIP,uint16 uPort) = 0;
    
    //减少copy的高效率自编码发送，用于大数据传输
    virtual  uint32  GetPacketHeadLen() = 0;
    virtual  boolean CodePacketHead(CXPUdpChnPacket *pack,xp::buffer &buf,uint32 uBodyLen) = 0;
    virtual  boolean SendBySelfCode(const xp::strutf8 &strDestIP,uint16 uDestPort,const xp::buffer &bufPacket) = 0;
    
	virtual ~IXPUdpChannel();
};

IXPUdpChannel* CreateNewUdpChannel();

#endif