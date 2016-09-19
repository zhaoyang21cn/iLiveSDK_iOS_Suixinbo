
/** 
@file      
@brief	    Http	
@version	2009/01/10 Gavinhuang Create
*/

#pragma once

#include <xptypes.h>
#include <xpstream.h>

#define MAXNUM_SIZE		16
#define MAXTRAILER_SIZE 2*1024 //暂定2K，超过2K则不处理了

class CDataWriter;

class CHttpChunker
{

public:

	CHttpChunker(uint64 uLogId);
	~CHttpChunker();

	boolean	CheckBuffer(boolean bWithChunkTrailer,uint8* pBufIn,uint32 dwLenIn,CDataWriter *pWriter,boolean &bComplete);
	boolean GetTrailer(xp::strutf16 &strTailer);

private:

	boolean IsHexDigit(char digit);

	boolean GetHexSize(boolean bWithChunkTrailer,uint8* &pBufIn,uint32 &dwLenIn,boolean &bContinue,boolean &bComplete);
	boolean GetHexSizeEnd(uint8* &pBufIn,uint32 &dwLenIn,boolean &bContinue,boolean &bComplete);
	boolean ReadData(uint8* &pBufIn,uint32 &dwLenIn,CDataWriter *pWriter,boolean &bContinue,boolean &bComplete);
	boolean GetDataEnd(uint8* &pBufIn,uint32 &dwLenIn,boolean &bContinue,boolean &bComplete);
	boolean ReadTrailer(uint8* pBufIn,uint32 dwLenIn,boolean &bComplete);

private:

	typedef enum 
	{
		WAIT_HEXSIZE,		//wait HEX Data Size
		WAIT_HEXSIZE_END,	//wait CRLF
		WAIT_DATA,			//wait DATA
		WAIT_DATA_END,		//wait CRLF
		WAIT_TRAILER,		//wait TRAILER
		WAIT_TRAILER_END,	//wait CRLF
	} ChunkyState;

	ChunkyState		m_eState;
	char			m_chexbuffer[MAXNUM_SIZE+1];
	int				m_chexbufferPos;
	uint32			m_dwDataTatolSize;
	uint32			m_dwDataLeftSize;	

	char			m_cPreChar;//用于凑齐CRLF两个字节

	uint8*		    m_pTrailerBuf;
	uint32			m_dwTrailerBufPos;
	uint32			m_dwTrailerBufTotalLen;

	uint64			m_uLogId;
	
};