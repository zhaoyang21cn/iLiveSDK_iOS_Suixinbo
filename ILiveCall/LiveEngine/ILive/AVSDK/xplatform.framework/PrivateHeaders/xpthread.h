/******************************************************************
 ** File 		: xpthread.h
 ** Author		: stacyli
 ** Date		: 2012.3
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: thread interface
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#if !defined(_XPTHREAD_INC_)
#define _XPTHREAD_INC_

#include <xptypes.h>
#include <xpexcept.h>

#define	SPECIFIC_KEY_MAX	0x80000000

// Valid values for thread priority
typedef enum ethread_priority{
	ethr_priority_low,
	ethr_priority_normal,
	// Suitable for low-latency, glitch-resistant audio.
	ethr_priority_realtime
}ethread_priority;

#if defined(_OS_WIN_)
#	include <windows.h>
typedef DWORD				xpthread_id;
typedef HANDLE				xpthread_t;
#else
#	include <pthread.h>
#	include <unistd.h>
typedef pid_t				xpthread_id;
typedef pthread_t			xpthread_t;
#endif

typedef xpthread_t*			hxpthread;
typedef void*		(*thread_proc_t)(void*);	/* for thread */

#ifdef __cplusplus
extern "C" {
#endif
    
	/**
	 Create a thread context and start it. 
	 You must call xpthread_destory to release system resources associated with the thread when all things done with it.
	 
	 @proc		- thread proc for new thread.
	 @param		- parameter passed to @proc
	 @priority	- thread priority
	 
	 @return	- a valid thread handle if success, otherwise return NULL.
	 */
	_XP_API hxpthread	xpthread_create(thread_proc_t proc, void* param, ethread_priority priority);
    
 	/**
	 Force to stop and destory a thread. 
	 
	 @handle	- thread context.
	 @ms_waiting- how long we can wait before it terminated itself.
	 
	 @return	- return 0 if success, otherwise return error code(also set errno).
	 */
	_XP_API int32	xpthread_terminate(hxpthread handle, int64 ms_waiting /*in miliseconds*/);

 	/**
	 determine closed signal is set or not in current thread context. 
	 
	 @return	- return ture if signaled, otherwise return false.
	 */
	_XP_API boolean	xpthread_signaled(void);

 	/**
	 determine closed signal is set or not in current thread context.
	 
	 @handle	- thread context.

	 @return	- return ture if signaled, otherwise return false.
	 */
	_XP_API boolean	xpthread_signaled2(hxpthread handle);

 	/**
	 Wait for the thread to exit. 
	 
	 @handle	- thread context.
	 
	 @return	- return 0 if success, otherwise return error code(also set errno).
	 */
	_XP_API int32	xpthread_waitfor(hxpthread handle);
	
 	/**
	 // Sets the thread name visible to debuggers/tools. This has no effect
	 // otherwise. This name pointer is not copied internally. Thus, it must stay
	 // valid until the thread ends.
	 
	 @name		- name to be set
	 
	 @return	- return 0 if success, otherwise return error code(also set errno).
	 */
	_XP_API int32	xpthread_setname(const char* name);

 	/**
	 Get name of thread. See xpthread_setname for more detail.
	 
	 @return	- return name of thread.
	 */
	_XP_API const char*	xpthread_getname(void);
	
 	/**
	 Save a value to thread local storage. You must make sure it stay valid until the thread ends.
	 
	 @key		- key for mapping
	 @value		- value to save
	 
	 @return	- return 0 if success, otherwise return error code(also set errno).
	 */
	_XP_API int32	xpthread_setspecific(uint32 key, const void* value);
	
 	/**
	 Get a value from thread local storage.
	 
	 @key		- key for value

	 @return	- return value previous saved by xpthread_setspecific.
	 */
	_XP_API void*	xpthread_getspecific(uint32 key);

 	/**
	 Get id of current thread. 
	 
	 @return	- return id of thread.
	 */
	_XP_API xpthread_id	xpthread_selfid(void);

	/**
	 Just for Win8QQ. 
	 
	 @handle	- thread context.
	 
	 @return
	 */
	_XP_API void	xpthread_closehandle(hxpthread handle);
#ifdef __cplusplus
};
#endif

#endif /*_XPTHREAD_INC_*/
