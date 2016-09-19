
/** 
 @file      
 @brief	    Http	
 @version	2009/01/10 Gavinhuang Create
 */

#ifndef _HTTDATA_READER_INCLUDE_
#define _HTTDATA_READER_INCLUDE_

#include <xpfile.h>
#include <xpihttpserver.h>
#include "httpspeedcalc.h"

#define  MAX_TMPBUFLEN (64*1024)

class CDataReader
{
public:
    
	CDataReader(uint64 uLogId);
	~CDataReader();
    
	///设置请求文件名
	boolean SetFileName(const utf8* lpFileName,IXPStreamReader* pStreamReader = NULL);
    
	///设置请求Buffer
	boolean SetBuffer(const uint8* pBuf,uint32 dwLength);
    
	///得到总长度
	uint64 GetLength();
    
	///得到指定长度
	boolean GetBuf(uint8** ppBuf,uint32 &dwBufLen);
    
	///移动下次发送起点[增量移动]
	boolean MoveSendPos(uint64 dwLength);
    
	///复位
	boolean Reset();
    
	///是否所有数据都已经发生
	boolean IsAllSent();
    
	///得到已经发送的长度
	uint64 GetSentLen();
    
    //得到读取速度
    uint32 GetSpeed(uint64 &uTransferLen);
    
    boolean CloseFile();
    
private:
    boolean         CreateBufTmp();

private:
    
	boolean         m_bBuffer;   ///< 是否Buffer上传
    
	uint64          m_dwLength;	 ///< 总长度，文件总长度或则Buffer总长度
	uint64          m_dwSendPos; ///< 发送起点
    
    uint64          m_uRealReadLen;
    uint32          m_startTime;
    
	//文件请求数据
    xp::strutf8		m_strFileName; //文件名
	xp::io::CFile*	 m_pFile;
    IXPStreamReader* m_pStreamReader;
	uint8*			m_pbufTmp;
    uint32          m_bufTmpMaxLen;
    uint32          m_uOffsetForbufTmp;
    uint32          m_uLenForbufTmp;
    CHttpSpeedCalc  m_SpeedCalc;
    
	//buf请求
	uint8*          m_pBuf; //请求的Buf数据
    
	//Log
	uint64			m_uLogId;
};

#endif