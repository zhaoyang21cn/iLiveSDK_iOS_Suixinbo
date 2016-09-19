/******************************************************************
 ** File 		: xpfile.h
 ** Author		: amoslan
 ** Date		: 2012-4-11
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: system undepandent file io
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#if !defined(_XPFILE_INC_)
#define _XPFILE_INC_
#pragma once

#include <xptypes.h>
#include <xpexcept.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(ANDROID) || defined(__ANDROID__) || defined (_OS_ANDROID_)
_XP_API	void set_android_app_path(const char* path);
#endif

#define READ_LEN 500 * 1024
#if _OS_WIN_
#   undef   fopen
#   define  fopen   xpio_fopen
    /**
     opens the file whose name is the string[in utf8] pointed to by filename and associates a stream with it.
     
     @filename  - filename in utf8
     @mode      - The argument mode points to a string beginning with one of the following sequences (Additional characters may follow these sequences.):
     ``r''   Open text file for reading.  The stream is positioned at the beginning of the file.
     
     ``r+''  Open for reading and writing.  The stream is positioned at the beginning of the file.
     
     ``w''   Truncate to zero length or create text file for writing.  The stream is positioned at the beginning of the file.
     
     ``w+''  Open for reading and writing.  The file is created if it does not exist, otherwise it is truncated.  The stream is positioned at the beginning of the file.
     
     ``a''   Open for writing.  The file is created if it does not exist.  The stream is positioned at the end of the file.  Subsequent writes to the file will always end up at the then current end of file, irrespective of any intervening
     fseek(3) or similar.
     
     ``a+''  Open for reading and writing.  The file is created if it does not exist.  The stream is positioned at the end of the file.  Subsequent writes to the file will always end up at the then current end of file, irrespective of any
     intervening fseek(3) or similar.
     
     @return    - return a FILE pointer.  Otherwise, NULL is returned and the global variable errno is set to indicate the error.
     
     @see fopen(...)
     */
    _XP_API FILE*   xpio_fopen(const utf8 * __restrict filename, const char * __restrict mode);
    
#   undef   rename
#   define  rename  xpio_rename
    /**
     causes the link named old to be renamed as new.  If new exists, it is first removed.
     
     @oldname   - old filename in utf8
     @newname   - new filename in utf8
     
     @return    - A 0 value is returned if the operation succeeds, otherwise rename() returns -1 and the global variable errno indicates the reason for the failure.
     
     @see rename(...)
     */
    _XP_API int     xpio_rename(const utf8 *oldname, const utf8 *newname);
    
    
#   undef   remove
#   define  remove  xpio_remove
    /**
     removes specified file.
     
     @filename  - filename in utf8
     
     @return    - A 0 value is returned if the operation succeeds, otherwise remove() returns -1 and the global variable errno indicates the reason for the failure.
     
     @see remove(...)
     */
    _XP_API int     xpio_remove(const utf8 *filename);
    
#else
#   define xpio_fopen       fopen
#   define xpio_rename      rename
#   define xpio_remove      remove
#endif
	/**
     get directory of current app just being
     
     @return    - current path in utf8 encoding.
     */
    _XP_API const utf8* xpio_getappdir(void);

    /**
     get directory of app installed
     
     @return    - current path in utf8 encoding.
     */
    _XP_API const utf8* xpio_getinstalldir(void);
        
    /**
     get document directory of current app just being
     
     @return    - current path in utf8 encoding.
     */
    _XP_API const utf8* xpio_getdocdir(void);
    
	/**
     get file system information.
     
     @path      - path specified
     @ptotal    - pointer to hold total space in bytes, it can be NULL.
     
     @return	- free space in bytes
     */
    _XP_API uint64   xpio_fsinfo(const utf8* path, uint64* ptotal);

	/*
		copy file,ctreat by silas
		copy file,500k block
		@pathSrc SrcFile
		@pathDest DestFile
		@return is success
	*/
	_XP_API boolean	 xpio_copyfile(const utf8* pathSrc, const utf8* pathDest);
    
	/**
     get file length.
     
     @path      - path specified
     
     @return	- free space in bytes.
     */
    _XP_API uint64   xpio_fsize(const utf8* path);
    
#ifdef __cplusplus
};
#endif


#ifdef __cplusplus
#include <xpstream.h>

namespace xp
{
	namespace io
	{
        class _XP_CLS CFile 
        {
        public:
            /*
             @eSeekSet  - The new access position will be offset bytes from the start of the underlying file or device.
             
             @eSeekCur  - The new access position will be offset bytes from the current access position; 
             a negative offset moves the access position backwards in the underlying file or device.
             
             @eSeekEnd  - The new access position will be offset bytes from the end of the file or device. 
             A negative offset places the access position before the end of file, and a positive offset places the access position after the end of file.
             */
            typedef enum {eSeekSet = SEEK_SET, eSeekCur = SEEK_CUR, eSeekEnd = SEEK_END} eSeekWhence;
            
            CFile(void);
            virtual ~ CFile(void);
            
            /**
             get file handle bound with oject.
             
             @return        - return FILE* handle.
             */
            inline operator  FILE* (void) {return m_fp;}
            
            /**
             opens file with specified filename and mode.
             
             @sFilename     - like @filename of xpio_fopen()
             @sMode         - like @mode of xpio_fopen()
             
             @return        - return true if seccess, otherwise return false.
             */
            boolean         Open(const utf8* sFilename, const utf8* sMode);
            
            /**
             opens file with specified filename[in utf16 encoding] and mode[in utf16 encoding].
             
             @sFilename     - like @filename of xpio_fopen()
             @sMode         - like @mode of xpio_fopen()
             
             @return        - return true if seccess, otherwise return false.
             */
            boolean         Open(const utf16* sFilename, const utf8* sMode);
			
			/**
             Attach the file what is opened
             
             @f				- the opened FILE handle
             @return        - return true if seccess, otherwise return false.
             */
            void			Attach(FILE* f);
			
			/**
             Detach the file 
             
             @return        - if the file is opened,will return the nonull value,otherwise will return NULL
             */			
			FILE*			Detach();
            
            /**
             determinates current object is bound with file or not.
             
             @return        - return true if bound (or Open is called), otherwise return false.
             */
            boolean         IsOpened(void);
            
            /**
             closes file.
             */
            void            Close(void);
            
            /**
             changes the current access position for file opened.
             
             @iOffset       - specify the position at which the next read or write will occur.
             @sMode         - specify the position which current seek-op is basing on. see eSeekWhence for more detail.
             
             @return        - return true if seccess, otherwise return false.
             */
            boolean         Seek(int64 iOffset, eSeekWhence eWhence);
            
            /**
             obtains the current value of the file position indicator.
             
             @return        - current offset, if file has not opened, it return -1.
             */
            int64           GetPos(void);

            /**
             obtains the total size of file.
             
             @return        - total size of file, if file has not opened, it return -1.
             */
            int64           GetSize(void);
            
            /**
             set the total size of file, if original size larger than @iSize, file will be truncated
             
             @iSize         - new size of the file.

             @return        - return true if seccess, otherwise return false.
             */
            boolean         SetSize(int64 iSize);
            
            /**
             read data from file.
             
             @pOut          - buffer to hold data, it can't be NULL.
             @iOutMax       - indicate max size of buffer.
             
             @return        - total size read from file, if file has not opened, it return -1.
             */
            int64           Read(uint8* pOut, int64 iOutMax);
            
            /**
             write data to file.
             
             @pIn           - data to be writen to file.
             @iInLen        - indicate lenght of buffer to be writen.
             
             @return        - total size writen to file, if file has not opened, it return -1.
             */
            int64           Write(const uint8* pIn, int64 iInLen);

            /**
             flush data to disk.
             
             @return        - return true if seccess, otherwise return false.
             */
            boolean         Flush(void);
            
            /*additional io*/
            /**
             obtains file name bound with current CFile's object.
             
             @return        - return filename in utf16 encoding.
             */
            const utf16*    GetFileName(void);
            
            /**
             determinates specified file is existed or not.
             
             @sFilename     - file name in utf8
             
             @return        - return true if existed, otherwise return false.
             */
            static boolean  IsExisted(const utf8* sFilename);
            
            /**
             determinates specified file is existed or not.
             
             @sFilename     - file name
             
             @return        - return true if existed, otherwise return false.
             */
            static boolean  IsExisted(const utf16* sFilename);
            
            /**
             rename.
             
             @sOldname      - old filename in utf8
             @sNewname      - new filename in utf8
             
             @return        - return true if existed, otherwise return false.
             */
            static boolean  Move(const utf8* sOldname, const utf8* sNewname);
            
            /**
             rename.
             
             @sOldname      - old filename in utf16
             @sNewname      - new filename in utf16

             @return        - return true if existed, otherwise return false.
             */
            static boolean  Move(const utf16* sOldname, const utf16* sNewname);
            
            /**
             remove.
             
             @sFilename     - file name
             
             @return        - return true if existed, otherwise return false.
             */
            static boolean  Remove(const utf8* sFilename);
            
            /**
             remove.
             
             @sFilename     - file name
             
             @return        - return true if existed, otherwise return false.
             */
            static boolean  Remove(const utf16* sFilename);
            
        protected:
            FILE*           m_fp;
            strutf16        m_sFilename;
        };
        
        class _XP_CLS CDirectory 
        {
        public:
            /**
             determinates specified directory is existed or not.
             
             @sPath         - path to be tested
             
             @return        - return true if existed, otherwise return false.
             */
            static boolean  IsExisted(const utf8* sPath);

            /**
             determinates specified directory is existed or not.
             
             @sPath         - path to be tested
             
             @return        - return true if existed, otherwise return false.
             */
            static boolean  IsExisted(const utf16* sPath);
            
            /**
             create specified path.
             
             @sPath         - path to be created
             
             @return        - return true if success, otherwise return false.
             */
            static boolean  Create(const utf8* sPath);

            /**
             create specified path.
             
             @sPath         - path to be created
             
             @return        - return true if success, otherwise return false.
             */
            static boolean  Create(const utf16* sPath);
            
            boolean  Open(const utf8* sFolderName, const utf8* sMode);
            
            
            /*additional io*/
            /**
             obtains file name bound with current CFile's object.
             
             @return        - return filename in utf16 encoding.
             */
            const utf16*    GetFolderName(void);
            
        private:
            FILE*           m_fp;
            strutf16        m_sFolderName;
        };
    };
};

#endif

#endif /*_XPFILE_INC_*/
