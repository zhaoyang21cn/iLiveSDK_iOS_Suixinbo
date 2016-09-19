/** 
 @file 
 @brief		协议编解码
 @version	2010-08-10 gavinhuang
 */

#pragma once

#include "bicmdcodec.h"
#include "bipack.h"
#include "bimess.h"

#undef	__MODULE__
#define __MODULE__			"CmdCode"

template<class T1,class T2>
class CBICmdCodecBase: public CBICmdCodec
{
public:
	CBICmdCodecBase(){};
	virtual ~CBICmdCodecBase(){};
    
public:
    
	/// 从TXData Code成buffer
	boolean  CodeST(pt_obj* pCmdData, CBIBuffer &bufferOut)
	{
		if (!pCmdData )
			return false;
		
		CommonInit();
		
		m_bCodecRet = true;
        
		m_pInST = (T1*)pCmdData;
		m_pPackOut = new CBIPack;
		m_pCurPackOut = m_pPackOut;
		SetCodeStruct();	
		m_pPackOut->GetBufferOut(bufferOut);
        
		m_pInST = NULL;
		if(m_pPackOut) 
		{
			delete m_pPackOut;
			m_pPackOut = NULL;
		}
		return m_bCodecRet;		
	}
    
	/// 从Buffer Decode得到TXData	
	boolean  DecodeBuffer(CBIBuffer &bufIn, pt_obj** ppCmdData, pt_obj* pSendData)
	{
		uint8 *p = bufIn.GetNativeBuf();
		uint32 n = bufIn.GetSize();	
		return DecodeBuffer(p,n, ppCmdData, pSendData);
	}
	
	boolean  DecodeBuffer(CBIBuffer &bufIn, pt_obj* pCmdData, pt_obj* pSendData)
	{
		uint8 *p = bufIn.GetNativeBuf();
		uint32 n = bufIn.GetSize();	
		return DecodeBuffer(p,n, pCmdData, pSendData);
	}	
	
	boolean  DecodeBuffer(uint8* pbuf,uint32 nbuflen, pt_obj* pCmdData, pt_obj* pSendData)
	{
		CommonInit();
		m_pOutST	= NULL;
		m_bCodecRet = true;
        
		m_pOutST	= (T2*)pCmdData;
		m_pPackIn	= new CBIPack;
		m_pCurPackIn= m_pPackIn;
		m_pCurPackIn->SetBufferIn(pbuf, nbuflen,true);
		
		SetDecodeStruct((T1*)pSendData);
				
		if( !m_bCodecRet )
		{
			int i = 0;
			i++;
		}
		
		if(m_pPackIn)
		{
			delete m_pPackIn;
			m_pPackIn = NULL;
		}
		
		m_pOutST = NULL;
		
		return m_bCodecRet;		
	}
	
	/// 从Buffer Decode得到TXData	
	boolean  DecodeBuffer(uint8* pbuf,uint32 nbuflen, pt_obj** ppCmdData, pt_obj* pSendData)
	{
		CommonInit();
		m_pOutST	= NULL;
		m_bCodecRet = true;
        
		m_pOutST	 = new T2; // T2 继承于 pt_obj，构造函数里面计数就是 1，m_pOutST 是智能指针，= 操作之后计数变成2
		m_pPackIn	 = new CBIPack;
		m_pCurPackIn = m_pPackIn;
		m_pCurPackIn->SetBufferIn(pbuf, nbuflen,true);
		
		SetDecodeStruct((T1*)pSendData);
		
		// 此处不需要AddRef()，new T2时计数默认为1，m_pOutST=的时候又AddRef()了一次
		*ppCmdData = (pt_obj*)m_pOutST;
				
		if( !m_bCodecRet )
		{
			int i = 0;
			i++;
		}
		
		if(m_pPackIn)
		{
			delete m_pPackIn;
			m_pPackIn = NULL;
		}
		
		m_pOutST = NULL;
		
		return m_bCodecRet;
	}	
    
protected:
	/// 设置Code协议格式
    virtual void SetCodeStruct() = 0;
	/// 设置Decode协议格式. pSendData可以为空
    virtual void SetDecodeStruct(T1* pSendData) = 0;
    
protected:
    
	/// 改变配置，可以在任何语句前面调用。
	void EnableUnicodeString(boolean bUnicodeString = false)
	{
		m_bUnicodeString = bUnicodeString;
	}
	
	void ChangeConfig(boolean bNetOrderNumber = true, boolean bbooleanAsByte = true)
	{
		m_bNetOrderNumber = bNetOrderNumber;
		m_bbooleanAsByte     = bbooleanAsByte;
	}
	
	
	void CommonInit()
	{
		m_bbooleanAsByte			= true;
		m_bNetOrderNumber		= true;
		m_bUnicodeString		= true;		
	};
	
public:
	boolean m_bbooleanAsByte;
	boolean m_bNetOrderNumber;
	boolean m_bUnicodeString;
	boolean m_bCodecRet;
	
public:	
	
	CScopePtr<T1>		m_pInST;
	CBIPack*	m_pPackOut;
	CBIPack*	m_pCurPackOut;
	
	CScopePtr<T2>		m_pOutST;
	CBIPack*	m_pPackIn;
	CBIPack*	m_pCurPackIn;
};


#ifdef _DEBUG_
    #define BrokenCodec() {BrokenCodec_debug();}
#else
#define BrokenCodec() {\
m_bCodecRet = false;\
return;\
};
#endif


//inline void BrokenCodec(LPCTSTR pszParam = _T(""))
//{
//#ifdef __DEPLOYMENT
//	throw(1);
//#else
//	//todo..
//	TXLog2("CmdCodecBase","%s","!!!!!!! BrokenCodec !!!!!!");
//	throw(1);
//#ifdef __i386
//	__asm__("int $3\n");
//#endif
//#endif		
//};	//出错


#define GetCodeNumberUnsigned(szName)	(uint32)(m_pOutST->szName);
#define GetCodeNumberSigned(szName)		(int)(m_pOutST->szName);\

#define CodeNumber(szName,TYPE)				m_pCurPackOut->Add##TYPE(m_pInST->szName);
#define CodeNumber_HostOrder(szName,TYPE)	m_pCurPackOut->Add##TYPE(m_pInST->szName,false);

#define CodeTLV(bufferName,bufferNumber,TYPE,LENTYPE)\
{\
    for(size_t i=0;i<m_pInST->bufferNumber;i++)\
    {\
        m_pCurPackOut->Add##TYPE((TYPE)m_pInST->bufferName[i].wTag);\
        m_pCurPackOut->Add##LENTYPE((LENTYPE)m_pInST->bufferName[i].wLen);\
        m_pCurPackOut->AddBuf((uint8*)m_pInST->bufferName[i].pValue,m_pInST->bufferName[i].wLen);\
    }\
};

#define CodeStringLenHead(strName,LENTYPE) \
{\
bi_str struf8;\
struf8 = m_pInST->strName;\
m_pCurPackOut->Add##LENTYPE((LENTYPE)struf8.ulen);\
if( struf8.ulen > 0 )\
{\
m_pCurPackOut->AddBuf((uint8*)struf8.pstr,struf8.ulen);\
}\
}

#define CodeString(szName)\
{\
bi_str struf8;\
struf8 = m_pInST->szName;\
if( struf8.ulen > 0 )\
{\
m_pCurPackOut->AddBuf((uint8*)struf8.pstr,struf8.ulen);\
}\
};


#define CodeBufferLenHead(bufName,LENTYPE) \
{\
m_pCurPackOut->Add##LENTYPE((LENTYPE)m_pInST->bufName.ulen);\
if( m_pInST->bufName.ulen > 0 )\
{\
m_pCurPackOut->AddBuf((uint8*)m_pInST->bufName.pbuf,m_pInST->bufName.ulen);\
}\
}

#define CodeBuffer(szName)\
{\
if(m_pInST->szName.ulen > 0 )\
{\
m_pCurPackOut->AddBuf(m_pInST->szName.pbuf,m_pInST->szName.ulen);\
}\
};

#define CodeArray(arName,SubClass)\
{\
size_t ulen = m_pInST->arName.size();\
for(size_t i=0; i<ulen; i++ )\
{\
SubClass* pItem = m_pInST->arName[i];

#define CodeArrayLenHead(arName,SubClass,LENTYPE)\
{\
size_t ulen = m_pInST->arName.size();\
m_pCurPackOut->Add##LENTYPE((LENTYPE)ulen);\
for(size_t i=0; i<ulen; i++ )\
{\
SubClass* pItem = m_pInST->arName[i];


//#define CodeArray(szName,nNum,SubClass)\
//	{\
//		for(int i=0; i<nNum; i++ )\
//		{\
//			SubClass* pItem = &m_pInST->szName[i];
//
//#define CodeArrayLenHead(szName,arLenName,SubClass,LENTYPE)\
//	{\
//		m_pCurPackOut->Add##LENTYPE((LENTYPE)m_pInST->arLenName);\
//		for(int i=0; i<m_pInST->arLenName; i++ )\
//		{\
//			SubClass* pItem = &m_pInST->szName[i];

#define CodeEndArray() }};

#define CodeArrayStructNumber(szSubName,TYPE)			m_pCurPackOut->Add##TYPE(pItem->szSubName);
#define CodeArrayStructNumber_HostOrder(szSubName,TYPE)	m_pCurPackOut->Add##TYPE(pItem->szSubName,false);


#define CodeArrayStructStringLenHead(szSubName,LENTYPE)\
{\
bi_str strutf8;\
strutf8 = pItem->szSubName;\
m_pCurPackOut->Add##LENTYPE((LENTYPE)strutf8.ulen);\
if(strutf8.ulen > 0 )\
{\
m_pCurPackOut->AddBuf((uint8*)strutf8.pstr,strutf8.ulen);\
}\
};

#define CodeArrayStructString(szSubName)\
{\
bi_str strutf8;\
strutf8 = pItem->szSubName;\
if(strutf8.ulen > 0 )\
{\
m_pCurPackOut->AddBuf((uint8*)strutf8.pstr,strutf8.nlen);\
}\
};\


#define CodeArrayStructBufLenHead(szSubName,LENTYPE)\
{\
m_pCurPackOut->Add##LENTYPE((LENTYPE)pItem->szSubName.ulen);\
if(pItem->szSubName.ulen > 0 )\
{\
packOut->AddBuf((uint8*)pItem->szSubName.pstr,pItem->szSubName.ulen);\
}\
};

#define CodeArrayStructBuffer(szSubName)\
{\
if(pItem->szSubName.ulen > 0 )\
{\
packOut->AddBuf((uint8*)pItem->szSubName.pstr,pItem->szSubName.ulen);\
}\
};\


#define CodeArrayNumber(LENTYPE)			m_pCurPackOut->Add##LENTYPE((LENTYPE)(*pItem));
#define CodeArrayNumber_HostOrder(LENTYPE)	m_pCurPackOut->Add##LENTYPE((LENTYPE)(*pItem),false);

#define DecodeMulTLVBegin(TTYPE,LENTYPE)\
{\
CBIPack *pOldCurPackIn = m_pCurPackIn;\
boolean bDecodeRet = true;\
while(bDecodeRet)\
{\
TTYPE	t = 0;\
LENTYPE	l = 0;\
uint8*	v = NULL;\
if(bDecodeRet) bDecodeRet = m_pCurPackIn->Get##TTYPE(t);\
if(bDecodeRet) bDecodeRet = m_pCurPackIn->Get##LENTYPE(l);\
if(bDecodeRet) bDecodeRet = m_pCurPackIn->GetBuf(&v,l);\
if(!bDecodeRet) break;\
CBIPack packtlv;\
packtlv.SetBufferIn(v,l,true);\
m_pCurPackIn = &packtlv;

#define DecodeTLV(T)\
if(t == T )\
{\

#define DecodeTLVEnd()\
}

#define DecodeMulTLVEnd()\
m_pCurPackIn = pOldCurPackIn;\
}}


#define EncodeTLVBegin(TTYPE,LENTYPE,t)\
{\
m_pCurPackOut->Add##TTYPE(t);\
uint32 uLenBeginPos = m_pCurPackOut->GetBufferOutLen();\
m_pCurPackOut->Add##LENTYPE(0);\


#define EncodeTLVEnd(LENTYPE)\
uint32 uLenEndPos = m_pCurPackOut->GetBufferOutLen();\
m_pCurPackOut->Set##LENTYPE((LENTYPE)(uLenEndPos-uLenBeginPos-sizeof(LENTYPE)),uLenBeginPos);\
}\



#define GetDecodeNumberUnsigned(szName) (uint32)(m_pOutST->szName)
#define GetDecodeNumberSigned(szName)	(int)(m_pOutST->szName)


#define DecodeNumber(szName,TYPE)				if(!m_pCurPackIn->Get##TYPE(m_pOutST->szName))			BrokenCodec();
#define DecodeNumber_HostOrder(szName,TYPE)		if(!m_pCurPackIn->Get##TYPE(m_pOutST->szName,false))	BrokenCodec();

#define DecodeJumpBuf(nSize) if(!m_pCurPackIn->JumpBuf(nSize)) BrokenCodec();


#define DecodeBuf(szName,nSize)\
{\
int nNum = (int)nSize;\
if( nNum < 0 )\
{\
nNum = m_pCurPackIn->GetBufferByteLeft();\
}\
if(nNum > 0)\
{\
m_pOutST->szName.pbuf = (uint8*)malloc(nNum);\
if( NULL == m_pOutST->szName.pbuf)\
{\
BrokenCodec();\
}\
m_pOutST->szName.ulen = (uint32)nNum;\
if( !m_pCurPackIn->GetBuf(m_pOutST->szName.pbuf,nNum))\
{\
BrokenCodec();\
}\
}\
}

#define DecodeBufLeft(szName) DecodeBuf(szName, -1)

/// 从buffer获取一个字符串。buffer首部指定了后续字符串的长度
#define DecodeString(szName) \
{\
boolean bRet = true;\
uint32 len = m_pCurPackIn->GetBufferByteLeft();\
if(bRet && len > 0 )\
{\
if(m_bUnicodeString)\
{\
uint8* pTmpUtf8 = NULL;\
if(bRet) bRet = m_pCurPackIn->GetBuf(&pTmpUtf8,len);\
if(bRet) bi_utf82utf16((char*)pTmpUtf8,len,m_pOutST->szName);\
}\
else\
{\
uint8* pTmpGBK = NULL;\
if(bRet) bRet = m_pCurPackIn->GetBuf(&pTmpGBK,len);\
if(bRet) bi_gbk2utf16((char*)pTmpGBK,len,m_pOutST->szName);\
}\
}\
if(!bRet)\
{\
BrokenCodec();\
}\
}

/// 从buffer获取一个字符串。buffer首部指定了后续字符串的长度
#define DecodeStringLen(szName,len) \
{\
boolean bRet = true;\
if(bRet && len > 0 )\
{\
if(m_bUnicodeString)\
{\
uint8* pTmpUtf8 = NULL;\
if(bRet) bRet = m_pCurPackIn->GetBuf(&pTmpUtf8,len);\
if(bRet) bi_utf82utf16((char*)pTmpUtf8,len,m_pOutST->szName);\
}\
else\
{\
uint8* pTmpGBK = NULL;\
if(bRet) bRet = m_pCurPackIn->GetBuf(&pTmpGBK,len);\
if(bRet) bi_gbk2utf16((char*)pTmpGBK,len,m_pOutST->szName);\
}\
}\
if(!bRet)\
{\
BrokenCodec();\
}\
}

/// 从buffer获取一个字符串。buffer首部指定了后续字符串的长度
#define DecodeStringLenHead(szName,LENTYPE) \
{\
boolean bRet = true;\
LENTYPE  len = 0;\
bRet = m_pCurPackIn->Get##LENTYPE(len);\
if(bRet && len > 0 )\
{\
if(m_bUnicodeString)\
{\
uint8* pTmpUtf8 = NULL;\
if(bRet) bRet = m_pCurPackIn->GetBuf(&pTmpUtf8,len);\
if(bRet) bi_utf82utf16((utf8*)pTmpUtf8,len,m_pOutST->szName);\
}\
else\
{\
uint8* pTmpGBK = NULL;\
if(bRet) bRet = m_pCurPackIn->GetBuf(&pTmpGBK,len);\
if(bRet) bi_gbk2utf16((char*)pTmpGBK,len,m_pOutST->szName);\
}\
}\
if(!bRet)\
{\
BrokenCodec();\
}\
}

/// 从buffer获取一个字符串。buffer首部指定了后续字符串的长度
#define DecodeStringLenHead_Self(szName,LENTYPE) \
{\
boolean bRet = true;\
LENTYPE  len = 0;\
bRet = m_pCurPackIn->Get##LENTYPE(len);\
if(bRet && len > 0 )\
{\
if(m_bUnicodeString)\
{\
uint8* pTmpUtf8 = NULL;\
if(bRet) bRet = m_pCurPackIn->GetBuf(&pTmpUtf8,len);\
if(bRet) bi_utf82utf16((char*)pTmpUtf8,len,szName);\
}\
else\
{\
uint8* pTmpGBK = NULL;\
if(bRet) bRet = m_pCurPackIn->GetBuf(&pTmpGBK,len);\
if(bRet) bi_gbk2utf16((char*)pTmpGBK,len,szName);\
}\
}\
m_bCodecRet = bRet;\
}

#define DecodeStringToChar(szName,c)\
{\
int nlen = m_pCurPackIn->CheckBufEndChar(c);\
if( nlen == - 1)\
{\
BrokenCodec();\
}\
if( nlen > 0 )\
{\
boolean bRet = true;\
if(m_bUnicodeString)\
{\
uint8* pTmpUtf8 = NULL;\
if(bRet) bRet = m_pCurPackIn->GetBuf(&pTmpUtf8,nlen);\
if(bRet) bi_utf82utf16((char*)pTmpUtf8,nlen,m_pOutST->szName);\
}\
else\
{\
uint8* pTmpGBK = NULL;\
if(bRet) bRet = m_pCurPackIn->GetBuf(&pTmpGBK,nlen);\
if(bRet) bi_gbk2utf16((char*)pTmpGBK,nlen,m_pOutST->szName);\
}\
if(bRet) bRet = m_pCurPackIn->JumpBuf(1);\
if( !bRet ) BrokenCodec();\
}\
}

/// 从buffer获取一个buffer，源buffer首部指定了后续的长度
#define DecodeBufferLenHead(szName,LENTYPE)\
{\
boolean bRet = true;\
LENTYPE len = 0;\
bRet = m_pCurPackIn->Get##LENTYPE(len);\
m_pOutST->szName.ulen = (uint32)len;\
if(bRet && len > 0 )\
{\
m_pOutST->szName.pbuf = (uint8*)malloc(len);\
bRet = (m_pOutST->szName.pbuf != NULL );\
if(bRet) bRet = m_pCurPackIn->GetBuf(m_pOutST->szName.pbuf,len);\
}\
if(!bRet)\
{\
BrokenCodec();\
}\
}

#define DecodeArray(szName,ulen,SubClass){\
boolean bRet = true;\
if( bRet && ulen > 0 )\
{\
for(int i=0; i<ulen; i++ )\
{\
SubClass* pItem = new SubClass();\
m_pOutST->szName.add(pItem);\

#define DecodeArrayLenHead(szName,SubClass,LENTYPE){\
boolean bRet = true;\
LENTYPE len = 0;\
bRet = m_pCurPackIn->Get##LENTYPE(len);\
if( bRet && len > 0 )\
{\
for(int i=0; i<len; i++ )\
{\
SubClass* pItem = new SubClass;\
m_pOutST->szName.add(pItem);\

#define DecodeArrayToEnd(szName,SubClass){\
boolean bRet = true;\
{\
while( bRet && m_pCurPackIn->GetBufferByteLeft() > 0 )\
{\
SubClass* pItem = new SubClass;\
m_pOutST->szName.add(pItem);\

//#define DecodeArray(szName,szlenName,SubClass){\
//	boolean bRet = true;\
//	if( bRet && m_pOutST->szlenName > 0 )\
//	{\
//		m_pOutST->szName = new SubClass[m_pOutST->szlenName];\
//		if( NULL == m_pOutST->szName ) BrokenCodec();\
//		for(int i=0; i<m_pOutST->szlenName; i++ )\
//		{\
//			SubClass* pItem = &m_pOutST->szName[i];\


//#define DecodeArrayLenHead(szName,szlenName,SubClass,LENTYPE){\
//		boolean bRet = true;\
//		m_pOutST->szlenName = 0;\
//		bRet = m_pCurPackIn->Get##LENTYPE(m_pOutST->szlenName);\
//		if( bRet && m_pOutST->szlenName > 0 )\
//		{\
//			m_pOutST->szName = new SubClass[m_pOutST->szlenName];\
//			if( NULL == m_pOutST->szName ) BrokenCodec();\
//			for(int i=0; i<m_pOutST->szlenName; i++ )\
//			{\
//				SubClass* pItem = &m_pOutST->szName[i];\


#define DecodeEndArray() }} if(!bRet) BrokenCodec(); }; 

#define DecodeArrayStructNumber(szSubName,TYPE)			    if(bRet) bRet=m_pCurPackIn->Get##TYPE(pItem->szSubName);
#define DecodeArrayStructNumber_HostOrder(szSubName,TYPE)	if(bRet) bRet=m_pCurPackIn->Get##TYPE(pItem->szSubName,false);


#define DecodeArrayStructString(szSubName,nlen)\
{\
if( bRet && nlen > 0 )\
{\
if(m_bUnicodeString)\
{\
uint8* pTmpUtf8 = NULL;\
if(bRet) bRet = m_pCurPackIn->GetBuf(&pTmpUtf8,nlen);\
if(bRet) bi_utf82utf16((char*)pTmpUtf8,nlen,pItem->szSubName);\
}\
else\
{\
uint8* pTmpGBK = NULL;\
if(bRet) bRet = m_pCurPackIn->GetBuf(&pTmpGBK,nlen);\
if(bRet) bi_gbk2utf16((char*)pTmpGBK,nlen,pItem->szSubName);\
}\
}\
}

#define DecodeArrayStructStringLenHead(szSubName,TYPE)\
{\
pItem->szSubName.ulen = 0;\
TYPE nlen = 0;\
if(bRet) bRet = m_pCurPackIn->Get##TYPE(nlen);\
if(bRet && nlen > 0 )\
{\
DecodeArrayStructString(szSubName,nlen);\
}\
}


#define DecodeArrayStructBuffer(szSubName,nLen)\
{\
if( bRet && nLen > 0 )\
{\
pItem->szSubName.pbuf  = (uint8*)malloc(nLen);\
if( NULL == pItem->szSubName.pbuf) BrokenCodec();\
pItem->szSubName.ulen  = (uint32)nLen;\
bRet = m_pCurPackIn->GetBuf(pItem->szSubName.pbuf,nLen);\
}\
}

#define DecodeArrayStructBufferLenHead(szSubName,LENTYPE)\
{\
LENTYPE len = 0;\
if(bRet) bRet = m_pCurPackIn->Get##LENTYPE(len);\
if(bRet && len > 0 )\
{\
DecodeArrayStructBuffer(szSubName,len);\
}\
}


#define DecodeArrayNumber(TYPE)				if(bRet) bRet = m_pCurPackIn->Get##TYPE((*pItem));
#define DecodeArrayNumber_HostOrder(TYPE)	if(bRet) bRet = m_pCurPackIn->Get##TYPE((*pItem),false);
#define DecodeArrayStructJumpBuf(szSubName)	if(bRet) bRet = m_pCurPackIn->JumpBuf(pItem->szSubName);
#define DecodeArrayStructJumpBuf2(nlen)		if(bRet) bRet = m_pCurPackIn->JumpBuf(nlen);

#define CodeSubTLVNumber(pack,val,TYPE)\
if(!pack->Add##TYPE(val))\
    return false;

#define CodeSubTLVNumber_HostOrder(pack,val,TYPE)\
if(!pack->Add##TYPE(val,false))\
return false;

#define CodeSubTLVString(pack,val,TYPE)\
{\
bi_str struf8;\
struf8 = val;\
if(!pack->Add##TYPE((TYPE)struf8.ulen)) return false;\
if( struf8.ulen > 0 )\
{\
    if(!pack->AddBuf((uint8*)struf8.pstr,struf8.ulen)) return false;\
}\
}

#define CodeSubTLVBuffer(pack,val,TYPE)\
if(!pack->Add##TYPE(val.ulen)) return false;\
if(!pack->AddBuf(val.pbuf,val.ulen)) return false;\

#define DeCodeSubTLVNumber(pack,val,TYPE)\
if(!pack->Get##TYPE(val)) return false;

#define DeCodeSubTLVNumber_HostOrder(pack,val,TYPE)\
if(!pack->Get##TYPE(val,false)) return false;

#define DeCodeSubBuffer(pack,val,len)\
if(len > 0)\
{\
    val.pbuf = (uint8*)malloc(len);\
    if( NULL == val.pbuf)\
    {\
        return false;\
    }\
    val.ulen = (uint32)len;\
    if( !pack->GetBuf(val.pbuf,len))\
    {\
        return false;\
    }\
}

#define DeCodeSubBufferLenHeader(pack,val,TYPE)\
TYPE len = 0;\
if(!pack->Get##TYPE(len))\
return false;\
if(len > 0)\
{\
    int nNum = (int)len;\
    if( nNum < 0 )\
    {\
        nNum = pack->GetBufferByteLeft();\
    }\
    if(nNum > 0)\
    {\
        val.pbuf = (uint8*)malloc(nNum);\
        if( NULL == val.pbuf)\
        {\
            return false;\
        }\
        val.ulen = (uint32)nNum;\
        if( !pack->GetBuf(val.pbuf,nNum))\
        {\
            return false;\
        }\
    }\
}\

#define DeCodeSubStringLenHeader(pack,val,m_bUnicodeString,TYPE)\
{\
boolean bRet = true;\
TYPE len = 0;\
if(!pack->Get##TYPE(len)) return false;\
    if(bRet && len > 0 )\
    {\
        if(m_bUnicodeString)\
        {\
            uint8* pTmpUtf8 = NULL;\
            if(bRet) bRet = pack->GetBuf(&pTmpUtf8,len);\
                if(bRet) bi_utf82utf16((utf8*)pTmpUtf8,len,val);\
        }\
        else\
        {\
            uint8* pTmpGBK = NULL;\
            if(bRet) bRet = pack->GetBuf(&pTmpGBK,len);\
                if(bRet) bi_gbk2utf16((utf8*)pTmpGBK,len,val);\
        }\
    }\
    if(!bRet)\
    {\
        return false;\
    }\
}


#define EncodeSubTLVBegin(pack,TTYPE,LENTYPE,t)\
{\
pack->Add##TTYPE(t);\
uint32 uLenBeginPos = pack->GetBufferOutLen();\
pack->Add##LENTYPE(0);\


#define EncodeSubTLVEnd(pack,LENTYPE)\
uint32 uLenEndPos = pack->GetBufferOutLen();\
pack->Set##LENTYPE((LENTYPE)(uLenEndPos-uLenBeginPos-sizeof(LENTYPE)),uLenBeginPos);\
}


#define DECLARE_CMDCODEC(className, protoCS, protoSC) \
class className : public CBICmdCodecBase<protoCS, protoSC> \
{ \
protected: \
virtual void SetCodeStruct(); \
virtual void SetDecodeStruct(protoCS* pPack_CS); \
public: \
static boolean CreateCodec(CBICmdCodec** p) \
{ \
(*p) = new className; \
if (NULL == (*p)) \
{ \
return false; \
} \
return true; \
} \
};
