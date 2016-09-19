/******************************************************************
 ** File 		: txclss.h
 ** Author		: Amoslan
 ** Copyright	: Copyright 2011 Tencent. All rights reserved.
 ** Description	: basic class
 **
 ******************************************************************/
#ifndef __TXCLSS_INC_
#define __TXCLSS_INC_

#include <xptypes.h>
#include <xprefc.h>

/*basic object*/
typedef struct _XP_CLS tag_st_obj
{
	tag_st_obj(void);
	virtual ~ tag_st_obj(void);	
	
	atomic32	AddRef_w(void);
	atomic32	AddRef(void);
	boolean		Release(void);
	
	void	 setrwlock(void*);
	void*	 internal;
	atomic32 iRefs;
} st_obj;


/*octet stream*/
typedef struct _XP_CLS tag_bi_buf {
	uint32  ulen;
	uint8* pbuf;
	tag_bi_buf(void);
	tag_bi_buf(const tag_bi_buf& bufSrc);
	tag_bi_buf(const uint8* data, int32 len);
	
	virtual ~ tag_bi_buf(void);
	
	tag_bi_buf& operator = (const tag_bi_buf& bufSrc);

	tag_bi_buf& assign(const uint8* data, int32 len);
	
	boolean		operator == (const tag_bi_buf& Src);

	void empty(void);
} bi_buf;

/*string in utf16 format*/
typedef struct _XP_CLS tag_bi_stru16 {
	uint32		ulen;
	utf16*	pstr;
	
	tag_bi_stru16(void);
	tag_bi_stru16(const tag_bi_stru16& Src);
	tag_bi_stru16(const utf16* pSrc, uint32 ul = -1);
	tag_bi_stru16(const utf8* putf8, uint32 ul = -1);
	
	virtual ~tag_bi_stru16(void);
	
	tag_bi_stru16& operator = (const tag_bi_stru16& Src);
	tag_bi_stru16& operator = (const utf8* pSrc /*in utf8 format*/);
	boolean		operator == (const tag_bi_stru16& Src);
	
	void empty(void);
} bi_stru16;

/*string in native format*/
typedef struct _XP_CLS tag_bi_str {
	uint32		ulen;
	utf8*		pstr;
	
	tag_bi_str(void);
	tag_bi_str(const utf8* pSrc);
	tag_bi_str(const tag_bi_str& Src);
	tag_bi_str(const tag_bi_stru16& Src);
	
	virtual ~tag_bi_str(void);
	
	tag_bi_str& operator = (const tag_bi_str& Src);
	tag_bi_str& operator = (const tag_bi_stru16& Src);
	tag_bi_str& operator = (const utf8* pSrc);
	boolean operator == (const tag_bi_str& Src);
	
	const utf8* c_str(void);
	void empty(void);
} bi_str;

/*string in utf16 format*/
typedef struct _XP_CLS bi_str_utf16 : public bi_stru16
{
	bi_str_utf16(void);
	bi_str_utf16(const utf8* _s);
	bi_str_utf16(const utf16* _s, uint32 _l);
	
	virtual ~bi_str_utf16(void);
	
	bi_str_utf16& operator = (const utf16* _s);
	
	uint32		assign(const utf8* _s);
	uint32		assign(const utf8* _s, uint32 _l);
	uint32		assign(const utf16* _p, uint32 _l);
	
	inline const utf16* c_str(void) const {return pstr;}
	inline uint32 length(void) const {return ulen;}
}bi_str_utf16;

/*string in utf8 format*/
typedef struct _XP_CLS bi_str_utf8 : public bi_str
{
	bi_str_utf8(void);
	bi_str_utf8(const utf8* _s);
	bi_str_utf8(bi_str_utf16& utf16);
	bi_str_utf8(const bi_stru16& utf16);	

	virtual ~bi_str_utf8(void);

	bi_str_utf8&	operator = (const utf8* s);
	bi_str_utf8&	operator = (const bi_str_utf16& utf16);
	
	bi_str_utf8&	assign(const utf8* _s, uint32 _l);
	
	inline const utf8* c_str(void) const {return (utf8*)pstr;}
	inline uint32 length(void) const {return ulen;} 
}bi_str_utf8;

template<class T>
boolean bi_create_obj(T** ppobj) {
	T* pobj = new T;
	
	if( 2 == pobj->AddRef())
	{
		pobj->Release();
	}

	(*ppobj) = pobj;
	return true;
};


#endif /*__TXCLSS_INC_*/
