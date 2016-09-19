#pragma once

#ifndef __BUNDLER_INC_
#define __BUNDLER_INC_

#include "biclss.h"
#include <xptypes.h>


#ifndef TXBL_TYPE
#define TXBL_TYPE
enum  TXBL_types
{
	TXBL_TYPE_NONE   = 0,
	TXBL_TYPE_OBJECT,
	TXBL_TYPE_BOOL,
	TXBL_TYPE_CHAR,
	TXBL_TYPE_UCHAR,
	TXBL_TYPE_SHORT,
	TXBL_TYPE_USHORT,
	TXBL_TYPE_INT,
	TXBL_TYPE_UINT,
	TXBL_TYPE_INT64,
	TXBL_TYPE_UINT64, //10
	TXBL_TYPE_STRING,
	TXBL_TYPE_BINARY,
	TXBL_TYPE_BUNDLER,
	TXBL_TYPE_ARRAY,
};
#endif


struct _XP_CLS bi_object: public CRefCountSafe
{
	virtual ~bi_object(){}
	virtual boolean istype(const utf8 * typedesc) = 0;
	virtual boolean querytype(const utf8 * typedesc, bi_object ** obj){return false;}
};

inline boolean bi_is_bundler(bi_object* obj)
{
	return obj && obj->istype("bi_bundler");
}
inline boolean bi_is_array(bi_object* obj)
{
	return obj && obj->istype("bi_array");
}

struct _XP_CLS bi_serialize
{
	virtual ~bi_serialize(){}
	virtual void write(const void * s, uint32 len) = 0;
	virtual boolean read(void * s, uint32 len) = 0;

	virtual boolean putsig(int32 sig) = 0;
	virtual boolean checksig(int32 sig, boolean remove) = 0;

	virtual void put(const void * s, uint32 len) = 0;
	virtual boolean get(utf8 * & s, uint32 & len) = 0;

	virtual void getallout(utf8 * &s, uint32 & len, boolean bremove) = 0;
	virtual uint32 tell() = 0;
	virtual boolean seek(int32 dir, int32 count) = 0;

	template <class T> void write(T obj){write(&obj,sizeof(obj));}
	template <class T> boolean read(T & obj){return read(&obj, sizeof(obj));}
};

struct bi_bundler_read;
struct bi_bundler;
struct bi_array_read;
struct bi_array;

struct _XP_CLS bi_array_read : bi_object
{
	virtual int32  get_size() = 0;
	virtual boolean get_fieldtype(int32 idx, int32 & type) = 0;
	virtual boolean get_object1(int32 idx, bi_object* & v) = 0;
	virtual boolean get_bool(int32 idx, boolean & v) = 0;
	virtual boolean get_char(int32 idx, utf8 & v) = 0;
	virtual boolean get_uchar(int32 idx, uint8 & v) = 0;
	virtual boolean get_int16(int32 idx, int16 &v) = 0;
	virtual boolean get_uint16(int32 idx, uint16 &v) = 0;
	virtual boolean get_int32(int32 idx, int32 & v) = 0;
	virtual boolean get_uint32(int32 idx, uint32 & v) = 0;
	virtual boolean get_int64(int32 idx, int64 & v) = 0;
	virtual boolean get_uint64(int32 idx, uint64 & v) = 0;
	virtual boolean get_string(int32 idx, utf8*& mem, uint32& len) = 0;
	virtual boolean get_binary(int32 idx, uint8*& mem, uint32& len) = 0;
	virtual boolean get_buf(int32 idx, bi_buf& bufout) = 0;
	virtual boolean get_doc(utf8 * &s, uint32 & len) = 0;
	virtual boolean get_bundler_read(int32 idx, bi_bundler_read** ppbnd) = 0;
	virtual boolean get_array_read(int32 idx, bi_array_read**  pparr) = 0;
};	 

struct _XP_CLS bi_array : bi_array_read
{
	virtual boolean set_doc(utf8 * s, uint32 len) = 0;
	virtual boolean get_bundler(int32 idx, bi_bundler** v) = 0;
	virtual boolean get_array(int32 idx, bi_array** arr) = 0;
	 
	virtual boolean insert_object1(int32 idx, bi_object* v) = 0;
	virtual boolean insert_bool(int32 idx, boolean v) = 0;
	virtual boolean insert_char(int32 idx, utf8 v) = 0;
	virtual boolean insert_uchar(int32 idx, uint8 v) = 0;
	virtual boolean insert_short(int32 idx, short v) = 0;
	virtual boolean insert_ushort(int32 idx, uint16 v) = 0;
	virtual boolean insert_int(int32 idx, int32 v) = 0;
	virtual boolean insert_uint(int32 idx, uint32 v) = 0;
	virtual boolean insert_int64(int32 idx, int64 v) = 0;
	virtual boolean insert_uint64(int32 idx, uint64 v) = 0;
	virtual boolean insert_string(int32 idx, const utf8* block, uint32 len) = 0;
	virtual boolean insert_binary(int32 idx, const uint8* block, uint32 len) = 0;
	virtual boolean insert_bundler(int32 idx, bi_bundler* v) = 0;
	virtual boolean insert_array(int32 idx, bi_array* arr) = 0;
	virtual boolean insert_newbundler(int32 idx, bi_bundler** pbundler) = 0;
	virtual boolean insert_newarray(int32 idx, bi_array** par) = 0;

	virtual boolean erase_object(int32 idx) = 0;
	virtual boolean erase_bool(int32 idx) = 0;
	virtual boolean erase_char(int32 idx) = 0;
	virtual boolean erase_uchar(int32 idx) = 0;
	virtual boolean erase_short(int32 idx) = 0;
	virtual boolean erase_ushort(int32 idx) = 0;
	virtual boolean erase_int(int32 idx) = 0;
	virtual boolean erase_uint(int32 idx) = 0;
	virtual boolean erase_int64(int32 idx) = 0;
	virtual boolean erase_uint64(int32 idx) = 0;
	virtual boolean erase_string(int32 idx) = 0;
	virtual boolean erase_binary(int32 idx) = 0;
	virtual boolean erase_bundler(int32 idx) = 0;
	virtual boolean erase_array(int32 idx) = 0;
	 
	inline boolean insert_buf(int32 idx, bi_buf &buf)
	 {
		 return insert_binary(idx, buf.pbuf, (uint32)buf.ulen);
	 }
};	 

struct _XP_CLS bi_bundler_read : bi_object
{
	virtual boolean get_doc(utf8 * &s, uint32 & len) = 0;
	virtual boolean get_object1(const utf8 * name, bi_object* & v) = 0;
	virtual boolean get_bool(const utf8 * name, boolean & v) = 0;
	virtual boolean get_char(const utf8 * name, utf8 & v) = 0;
	virtual boolean get_uchar(const utf8 * name, uint8 & v) = 0;
	virtual boolean get_int16(const utf8 * name, int16 &v) = 0;
	virtual boolean get_uint16(const utf8 * name, uint16 &v) = 0;
	virtual boolean get_int32(const utf8 * name, int32 & v) = 0;
	virtual boolean get_uint32(const utf8 * name, uint32 & v) = 0;
	virtual boolean get_int64(const utf8 * name, int64 & v) = 0;
	virtual boolean get_uint64(const utf8 * name, uint64 & v) = 0;
	virtual boolean get_string(const utf8 * name, utf8*& mem, uint32& len) = 0;
	virtual boolean get_binary(const utf8 * name, uint8*& mem, uint32& len) = 0;
	virtual boolean get_fieldtype(const utf8 * name, int32 & type) = 0;
	virtual boolean get_buf(const utf8 * name, bi_buf& bufout) = 0;

	virtual boolean enum_name(int32 idx, utf8 * name, int32 & type, int32 & len) = 0;

	virtual boolean get_bundler_read(const utf8 * name, bi_bundler_read** bnd) = 0;
	virtual boolean get_array_read(const utf8 * name, bi_array_read** arr) = 0;
};

struct _XP_CLS bi_bundler : bi_bundler_read
{
	virtual boolean set_doc(utf8 * s, uint32 len) = 0;
	virtual boolean get_bundler(const utf8 * name, bi_bundler** ppbnd) = 0;
	virtual boolean get_array(const utf8 * name, bi_array** arr)=0;

	virtual boolean put_object1(const utf8 * name, bi_object* v) = 0;
	virtual boolean put_bool(const utf8 * name, boolean v) = 0;
	virtual boolean put_char(const utf8 * name, utf8 v) = 0;
	virtual boolean put_uchar(const utf8 * name, uint8 v) = 0;
	virtual boolean put_int16(const utf8 * name, short v) = 0;
	virtual boolean put_uint16(const utf8 * name, uint16 v) = 0;
	virtual boolean put_int32(const utf8 * name, int32 v) = 0;
	virtual boolean put_uint32(const utf8 * name, uint32 v) = 0;
	virtual boolean put_int64(const utf8 * name, int64 v) = 0;
	virtual boolean put_uint64(const utf8 * name, uint64 v) = 0;
	virtual boolean put_string(const utf8 * name, const utf8* mem, uint32 len) = 0;
	virtual boolean put_binary(const utf8 * name, uint8* mem, uint32 len) = 0;
	virtual boolean put_buf(const utf8 * name, const bi_buf &buf)
	{
		return put_binary(name, buf.pbuf, (uint32)buf.ulen);
	}
	virtual boolean put_bundler(const utf8 * name, bi_bundler* v) = 0;
	virtual boolean put_array(const utf8 * name, bi_array* arr) = 0;
	virtual boolean put_newarray(const utf8 * name, bi_array** par) = 0;
	virtual boolean put_newbundler(const utf8 * name, bi_bundler** pbundler) = 0;

	virtual boolean erase_object(const utf8 * name) = 0;
	virtual boolean erase_bool(const utf8 * name) = 0;
	virtual boolean erase_char(const utf8 * name) = 0;
	virtual boolean erase_uchar(const utf8 * name) = 0;
	virtual boolean erase_short(const utf8 * name) = 0;
	virtual boolean erase_ushort(const utf8 * name) = 0;
	virtual boolean erase_int(const utf8 * name) = 0;
	virtual boolean erase_uint(const utf8 * name) = 0;
	virtual boolean erase_int64(const utf8 * name) = 0;
	virtual boolean erase_uint64(const utf8 * name) = 0;
	virtual boolean erase_string(const utf8 * name) = 0;
	virtual boolean erase_binary(const utf8 * name) = 0;
	virtual boolean erase_bundler(const utf8 * name) = 0;
	virtual boolean erase_array(const utf8 * name) = 0;
};	 

_XP_API boolean bi_create_array(bi_array ** par);
_XP_API boolean bi_create_bundler(bi_bundler ** pbundler);

inline void bi_free_obj(bi_object * obj)
{
	if (obj) obj->Release();
}

void do_break();

#endif /*__BUNDLER_INC_*/