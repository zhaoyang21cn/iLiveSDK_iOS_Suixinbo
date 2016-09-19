#pragma once

/** 
@file      
@brief	    xpstreamreader.h	
@version	2014/01/23 Gavinhuang Create
*/

#ifndef _XPSTREAM_READER_INC_
#define _XPSTREAM_READER_INC_
#pragma once

#include <xptypes.h>

class IXPStreamReader
{
public:
	IXPStreamReader(){};
	virtual ~IXPStreamReader() {};
	virtual boolean Seek(int64 iOffset, int where) = 0;
	virtual void    Close(void) = 0;
	virtual int64   GetSize(void) = 0;
	virtual int64   Read(uint8* pOut, int64 iOutMax) = 0;
    virtual IXPStreamReader* Clone(){return NULL;}
};

#endif