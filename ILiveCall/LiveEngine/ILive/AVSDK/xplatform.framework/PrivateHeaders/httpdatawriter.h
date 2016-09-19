
#pragma once

/** 
 @file      
 @brief	    Http	
 @version	2009/01/10 Gavinhuang Create
 */

#ifndef _HTTDATA_WRITER_INCLUDE_
#define _HTTDATA_WRITER_INCLUDE_

#include <xpfile.h>
#include "httpspeedcalc.h"

class CDataWriter
{
public:
    
	CDataWriter(uint64 uLogId);
	~CDataWriter();
    
	boolean     SetDest(boolean bUseFile,const utf8* lpFileName = NULL);
	
	uint64      GetLength();
	uint64      GetWritenLen();
	boolean     SetLength0();
    
	boolean     Write(uint8* pbuf,uint32 dwLength);
	boolean     Flush();
    
	boolean     GetFileName(xp::strutf8 &strFileName);
	boolean     GetBuffer(uint8 **ppBuf,uint32 *pdwBufLen);
	boolean     CloseFile();
    
    uint32      GetSpeed(uint64 &uTransferLen);
    
private:
    
	boolean         m_bUseFile;  
    
    //速度计算
    uint64          m_uRealWriteLen;
    uint32          m_startTime;
    
	//文件写入
	xp::strutf8		m_strFileName;      
	xp::io::CFile*  m_pFile;
	uint8*          m_pFileCacheBuf;///Cache一下Buf，防止频繁I/O写入[10K写入一次]
	uint32          m_dwFileCacheBufLen;
	uint32          m_dwFileCacheWritePos;
	
	//Buf写入
	uint8*          m_pBuf;
	uint32          m_dwLength;
	uint32          m_dwWritePos;
	uint32          m_dwLeftCacheSize;
    
	//Log
	uint64			m_uLogId;
    CHttpSpeedCalc  m_SpeedCalc;
};

#endif