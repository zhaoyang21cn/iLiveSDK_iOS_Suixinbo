/******************************************************************
 ** File 		: xpstream.h
 ** Author		: Amoslan
 ** Date		: 2011-02-24
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: xplatform stream
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#if !defined(_XPSTREAM_INC_)
#define _XPSTREAM_INC_

#include <xptypes.h>
#include <xpexcept.h>

namespace xp {
    struct strutf8;
    struct strutf16;
    
    struct _XP_CLS stream {
        stream(const uint8* p, uint32 dlen);
        stream(const utf8* txt = NULL, uint32 dlen = 0);
        stream(const utf16* txt16, uint32 dlen = 0);
        stream(const stream& src);
        virtual ~stream(void){clear();}
        
        stream&    operator = (const utf8* txt);
        stream&    operator = (const strutf8& src);
        stream&    operator = (const strutf16& src);
        stream&    operator = (const stream& src);
        stream&    operator += (const stream& src) {
            return append(src, src.size());
        }
        
        stream&    assign(const uint8* p, uint32 dlen);
		void	   attach(uint8* p, uint32 dlen);
		uint8*	   detach();
        stream&    append(const uint8* p, uint32 dlen);
        stream&    replace(uint32 pos, uint32 dlen, const uint8* tar, uint32 tarlen);
        
        void        resize(uint32 newlen);
        
        inline void clear(void) {*this = NULL;}
        
		inline bool operator ==(const stream& _R) const {
			return (len == _R.len) && (len == 0 || (memcmp(data, _R.data, len * sizeof(uint8)) == 0)); 
		}
        
        inline bool operator !=(const stream& _R) const {
            return !operator==(_R);
        }
        
        inline bool operator < (const stream& _R) const {
            if(data == NULL || _R.data == NULL){return data < _R.data ? true : false;}
            uint32  minlen = len > _R.len ? _R.len : len;
            int mv = memcmp(data, _R.data, minlen * sizeof(uint8));
            if (mv == 0) {
                if (len <= _R.len) {
                    return false;
                }
            }
            return mv < 0 ? true : false;
        }

        bool     bits(uint32 _i) const;
        void     bitset(uint32 _i, bool v);
        void     bitsmerge(const stream& src);
        void     bitsand(const stream& src);
        
		inline uint8&		at(uint32 pos) {return data[pos];}
		inline const uint8&	at(uint32 pos) const {return data[pos];}
		inline uint8&		operator [] (uint32 pos) {return data[pos];}
		inline const uint8&	operator [] (uint32 pos) const {return data[pos];}
        inline				operator uint8* (void) const {return data;}
        inline				utf8* tos8(void) const {return (utf8*)data;}
		inline uint32		size(void) const {return len;}
        
	private:
        uint32      grow(uint32 newlen);
        uint32      shrink(uint32 newlen);
        
	private:
		uint32		room;
		uint32		len;
		uint8*		data;
    };
    typedef struct stream    buffer;
    typedef struct stream    octets;

    struct _XP_CLS strutf8 {
        
        strutf8(const utf8* txt = NULL, uint32 dlen = 0);
        strutf8(const utf16* txt16, uint32 dlen = 0);
        strutf8(const strutf8& src);
        strutf8(const strutf16& src);
        virtual ~strutf8(void){clear();}
        
        strutf8&    format(const char* _format, ...);
        strutf8&    operator = (const utf8* txt);
        strutf8&    operator = (const strutf8& src);
        strutf8&    operator = (const strutf16& src);
        
        strutf8&    tolower(void);
        strutf8&    toupper(void);
        strutf8&    trim(bool tail = true, bool front = true);
        strutf8&    trimleft(void) {return trim(false, true);}
        strutf8&    trimright(void) {return trim(true, false);}
		strutf8&    assign(const utf8* p, uint32 dlen = 0);
		strutf8&    assign(const strutf8 &str){return assign(str.c_str(), str.length());}
		strutf8&    operator +=(const utf8* p);
		strutf8     operator +(const utf8* p)const ;//Add by silas
		strutf8     operator +(const strutf8& str)const ;//Add by silas
		strutf8&    operator +=(const strutf8 &str){ return append(str.c_str());}//Add by silas
        strutf8&    append(const utf8* p, uint32 dlen = 0) ;
		strutf8&	append(const strutf8& str, uint32 pos, uint32 dlen);//Add by silas
		strutf8&    append(const strutf8& str) {return append(str.c_str(), str.length());}//Add by silas
        strutf8&    replace(uint32 pos, uint32 dlen, const utf8* s);
        uint32      resize(uint32 _l);
        uint32      reserve(uint32 _l);
        
        inline void clear(void) {*this = NULL;}
        
        int32       find(const utf8* pattern, int32 begin = 0,bool ignore_case = false) const;
        int32       reversefind(const utf8* str, int32 start = 0, bool ignore_case = false) const;

		int32	    compare(int32 pos, int32 dlen, const strutf8& str)const;//Add by silas
        inline int32 compare(const char *str) const {
            return strcmp(_data, str);
        }
		strutf8	    substr(uint32 pos = 0, uint32 count = -1)const;
		inline bool operator != (const strutf8& str) const {
            return !(*this == str);
        }
		inline bool operator == (const utf8* p)const{//Add by silas
            if(NULL == p && len > 0)
                return false;
			return ( NULL==p && len == 0 ) || ( (len == strlen(p)) && (len == 0 || (memcmp(_data, p, len * sizeof(utf8)) == 0)));
		}
		inline bool operator ==(const strutf8& _R) const {
			return (len == _R.len) && (len == 0 || (memcmp(_data, _R._data, len * sizeof(utf8)) == 0)); 
		}
        
        inline bool operator < (const strutf8& _R) const {
            if(_data == NULL || _R._data == NULL){return _data < _R._data ? true : false;}
            return strcmp(_data, _R._data) < 0 ? true : false;
        }
		inline utf8&		at(uint32 pos) {return _data[pos];}
		inline const utf8&	at(uint32 pos) const {return _data[pos];}
		inline utf8&		operator [] (uint32 pos) {return _data[pos];}
		inline const utf8&	operator [] (uint32 pos) const {return _data[pos];}

        inline operator utf8* (void) {return _data;}
		inline const utf8 *	c_str() const {return _data==NULL ? "" : _data;}
		inline uint32		length(void) const {return len;}
		inline uint32		size(void) const {return len;}
		inline const void*		data() const {return _data;}
        boolean endswith(const char *value)
        {
            if ((NULL == _data) || (0 == *_data)) {
                return false;
            }
            if ((NULL == value) || (0 == *value)) {
                return false;
            }
            
            size_t valueLen = strlen(value);
            if (len < valueLen) {
                return false;
            }
            
            if (0 == strncmp(_data + len - valueLen, value, valueLen)) {
                return true;
            }
            return false;
        }
        
        boolean startswith(const char *value)
        {
            if ((NULL == _data) || (0 == *_data)) {
                return false;
            }
            if ((NULL == value) || (0 == *value)) {
                return false;
            }
            
            size_t valueLen = strlen(value);
            if (len < valueLen) {
                return false;
            }
            
            if (0 == strncmp(_data, value, valueLen)) {
                return true;
            }
            return false;
        }
        
        boolean equals(const char *str) const {
            if ((NULL == _data) || (0 == *_data)) {
                return false;
            }
            if ((NULL == str) || (0 == *str)) {
                return false;
            }
            
            if (0 == strcmp(_data, str)) {
                return true;
            }
            return false;
        }
        
	private:
        uint32      grow(uint32 newlen);
        uint32      shrink(uint32 newlen);
        
	private:
		uint32		room;
		uint32		len;
		utf8*		_data;
    };
    
    struct _XP_CLS strutf16 { //little bit order
        strutf16(const utf8* txt = NULL, uint32 dlen = 0);
        strutf16(const utf16* txt16, uint32 dlen = 0);
        strutf16(const strutf8& src);
        strutf16(const strutf16& src);
        virtual ~strutf16(void){clear();}
        
        strutf16&   operator = (const utf8* txt);
        strutf16&   operator = (const strutf8& src);
        strutf16&   operator = (const strutf16& src);
        
        strutf16&   tolower(void);
        strutf16&   toupper(void);
        strutf16&   trim(bool tail = true, bool front = true);
        strutf16&   trimleft(void) {return trim(false, true);}
        strutf16&   trimright(void) {return trim(true, false);}
        strutf16&   assign(const utf16* p, uint32 dlen = 0);
        strutf16&   append(const utf16* p, uint32 dlen = 0);
        
        inline void clear(void) {*this = NULL;}
        
        int32       find(const utf16* pattern, int32 begin = 0) const;
        
		inline bool operator ==(const strutf16& _R) const {
			return (len == _R.len) && (len == 0 || (memcmp(data, _R.data, len * sizeof(utf16)) == 0)); 
		}
        
        inline bool operator < (const strutf16& _R) const {
            if(data == NULL || _R.data == NULL){return data < _R.data ? true : false;}
            uint32  minlen = len > _R.len ? _R.len : len;
            int mv = memcmp(data, _R.data, minlen * sizeof(utf16));
            if (mv == 0) {
                if (len <= _R.len) {
                    return false;
                }
            }
            return mv < 0 ? true : false;
        }
        
		inline utf16&		at(uint32 pos) {return data[pos];}
		inline const utf16&	at(uint32 pos) const {return data[pos];}
		inline utf16&		operator [] (uint32 pos) {return data[pos];}
		inline const utf16&	operator [] (uint32 pos) const {return data[pos];}
		
        inline operator utf16* (void) {return data;}
		inline const utf16* c_str() const {return data;}
		inline uint32		length(void) const {return len;} 
		inline uint32		size(void) const {return len;}
        
	private:
        uint32      grow(uint32 newlen);
        uint32      shrink(uint32 newlen);
        
	private:
		uint32		room;
		uint32		len;
		utf16*		data;
    };
};

#endif // !defined(_XPSTREAM_INC_)
