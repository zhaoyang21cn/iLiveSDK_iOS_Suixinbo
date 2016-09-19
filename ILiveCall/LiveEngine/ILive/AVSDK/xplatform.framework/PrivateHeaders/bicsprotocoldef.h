/** 
@file 
@version	2010-08-13 gavinhuang
*/

#pragma  once

#include <xprefc.h>
#include <xpvector.h>
#include "biclss.h"

//the protocol definition
#define STX				0x02
#define ETX				0x03
#define RS				0x1e
#define US				0x1f
#define MS				0x1d
#define CH_US			US
#define CH_RS			RS
#define QQ_CCCMD_HEAD	0
#define QQ_CMD_CS_HEAD	2


typedef struct tag_pt_obj : public st_obj
{
	//用于在协议收发过程中携带部分相关用户数据
	CScopePtr<st_obj>	pCustomObj;
	uint64				uCustomId;
	uint8				cCustomFlag;
} pt_obj;

typedef struct tag_pt_cs_rq : public pt_obj 
{
	//CS命令
	uint16  wCSCmd;
	uint16  wCSSeq;
	boolean  bEncrypt;
		
	//发生频率和超时控制	
	uint32 dwRetryInterval;//ms
	uint8  cPacketPerTime; //count
	uint8  cRetryLimit;    //count
	
	//登录命令－需要填写的Key,第一个为加解密Key[并且默认为前缀]，第二个为解密Key
	//其他命令不需要填写
	bi_buf bufPrefix;
	bi_buf bufKey1;
	bi_buf bufKey2;

	//是否应答包
	boolean  bReplyPk;
	
	tag_pt_cs_rq()
	{
		wCSSeq			= 0;
		wCSCmd			= 0;
		bEncrypt		= true;
		dwRetryInterval = 5000;
		cPacketPerTime	= 1;
		cRetryLimit		= 3;
		bReplyPk		= false;
	};	
} pt_cs_rq;

template<class T>
struct pt_ar
{
	xpstl::vector<T*>  vec;
	
	size_t size()
	{
		return vec.size();
	}
	
	T* operator[](size_t i)
	{
		return vec[i];
	}
	
	void add(T t)
	{
		T* pt = new T;
		*pt	= t;
		vec.insert(vec.end(),pt);
	}
	
	void add(T* t)
	{
		if( NULL == t)
		{
			return;
		}
		
		vec.insert(vec.end(),t);
	}
	
	void clear()
	{
		size_t size = vec.size();
		
		for( size_t i=0; i<size; i++ )
		{
			delete vec[i];
		}
		
		vec.clear();		
	}
	
	virtual ~pt_ar()
	{
		clear();
	}
};

typedef struct  tag_pt_cs_rs: public pt_obj
{
	tag_pt_cs_rs() 
	{ 
		wCSCmd = 0; 
		wCSSeq = 0; 
	}
	
	uint16 wCSCmd;
	uint16 wCSSeq;
} pt_cs_rs;

typedef struct  tag_pt_cs_svrpush: public tag_pt_cs_rs
{
	bi_buf	bufBody;
} pt_cs_svrpush;

typedef struct tag_pt_sysmsg_rs : public pt_cs_rs
{
	uint32	dwFromUin;
	uint32	dwToUin;
	uint32	dwMsgID;
	uint32	dwReplyIP;
	uint16	wReplyPort;
	uint16	wMsgType;
	uint16	wExtInfoTag;
	bi_buf	bufExtInfo;
	bi_buf  bufBody;	
} pt_sysmsg_rs;


typedef struct tag_pt_oldsysmsg_rs: public pt_cs_rs
{
	uint16	wMsgType;
	uint32	dwFromUin;
	uint32	dwToUin;
	bi_buf	bufBody;
} pt_oldsysmsg_rs;


class ICCNetSendSink;

typedef struct tag_pt_cc_rq : public pt_obj
{
	uint64			uToUin;
	uint16			wcsSeq;
	uint16			wccCmd;
	uint16			wccSeq;
	bi_buf			bufExtInfo;
	bi_buf			bufccBody;
	ICCNetSendSink*	pSink;
	
	tag_pt_cc_rq()
	{
		wcsSeq = 0;
		wccSeq = 0;
		pSink  = NULL;
	}
} pt_cc_rq;

typedef struct tag_pt_cc_rs : public pt_obj
{
	uint8	cResult;
} pt_cc_rs;

typedef struct tag_pt_sysmsg_ccmsg_rs : public pt_cs_rs
{
	uint8	cVerMain;
	uint8	cVerSub;
	uint32  dwFromUin;
	uint32  dwToUin;
	bi_buf	bufC2CKey;
	uint16	wCCCmd;
	uint16	wCCSeq;
	uint32  dwDateTime;
	uint16	wFace;
	uint32  dwLastChangeTime;
	bi_buf  bufOther;
} pt_sysmsg_ccmsg_rs;
