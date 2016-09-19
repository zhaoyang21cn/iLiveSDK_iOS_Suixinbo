/******************************************************************
 ** File 		: xplock.h
 ** Author		: renzhang, amoslan
 ** Date		: 2012-3-12
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: about mutex lock and read&write lock
 **
 ** Version		: 1.0
										   
 ** History		:
 ******************************************************************/
#if !defined(_XPLOCK_INC_)
#define _XPLOCK_INC_

#include <xptypes.h>
#include <xpexcept.h>
#include <xpmap.h>
#include <xpthread.h>

#ifdef _OS_WIN_
#include <windows.h>
#else
#include <pthread.h>
#endif	/* _OS_WIN_ */

//#ifdef __aarch64__
//#define XPLOCK_ALIGN __declspec(align(8))
//#else
//#define XPLOCK_ALIGN
//#endif

#if defined(__aarch64__) && defined(_OS_ANDROID_)
#define XPLOCK_ALIGN __declspec(align(8))
#else
#define XPLOCK_ALIGN
#endif


#ifdef _OS_WIN_	 /* this is a definition for a mutex lock in different platform */
typedef CRITICAL_SECTION	xplock_t;
#else 
typedef pthread_mutex_t		xplock_t;
#endif	/* _OS_WIN_ */
/**
 System independent lock type. 
 It point to a CRITICAL_SECTION instance under windows, and to a pthread_mutex_t instance under posix.
 Please use reinterpret_cast<CRITICAL_SECTION*>(handle) or reinterpret_cast<pthread_mutex_t*>(handle) to convert it if you want it be used by native sys api.
 */
typedef	xplock_t*			hxplock;

/**
 System independent read+write-lock type. 
 */
typedef	void*				hxplockrw;

#ifdef __cplusplus
extern "C" {
#endif
	
	/**
	 init a lock.
	 
	 @plock		- a memory space to hold data of mutex. This argument can't be NULL.

	 @return	- return a valid lock context if success, otherwise return NULL.
	 */
	_XP_API hxplock	xplock_init(xplock_t* plock);
	
	/**
	 destroy a lock context.
	 
	 @hlock		- lock context.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xplock_destroy(hxplock hlock);
	
	/**
	 try to hold it on.
	 
	 @hlock		- lock context.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xplock_trylock(hxplock hlock);
	
	/**
	 excute a lock operating(hold it on).
	 
	 @hlock		- lock context.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xplock_lock(hxplock hlock);
	
	/**
	 unlock it.
	 
	 @hlock		- lock context.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xplock_unlock(hxplock hlock);

	/**
	 alloc a rwlock context.
	 
	 @return	- return a valid lockrw context if success, otherwise return NULL.
	 */
	_XP_API hxplockrw xprwlock_alloc(void);
	
	/**
	 destroy a rwlock.
	 
	 @hlock		- lock context.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xprwlock_destroy(hxplockrw hlock);
	
	/**
	 try to hold it on in reading-lock mode.
	 
	 @hlock		- lock context.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xprwlock_tryrdlock(hxplockrw hlock);
	
	/**
	 excute a reading-lock operating(hold it on).
	 in this case, excepted reading operations, all writing operations is not allowed.
	 
	 @hlock		- lock context.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xprwlock_rdlock(hxplockrw hlock);
	
	/**
	 try to hold it on in writing+reading-lock mode.
	 
	 @hlock		- lock context.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xprwlock_tryrwlock(hxplockrw hlock);
	
	/**
	 excute a reading+writing-lock operating(hold it on).
	 in this case, all reading and writing operations is not allowed.
	 
	 @hlock		- lock context.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xprwlock_wrlock(hxplockrw hlock);
	
	/**
	 unlock it.
	 
	 @hlock		- lock context.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xprwlock_unlock(hxplockrw hlock);
	
#ifdef __cplusplus
};
#endif

#ifdef __cplusplus

// A helper class to use xplock_xxx
struct _XP_CLS CXPLock {
	CXPLock(void) {
		xplock_init(&m_lock);
	}
	CXPLock(const CXPLock & rhs) {}
	CXPLock & operator = (const CXPLock & rhs) { return *this; }
	~CXPLock(void) {
		xplock_destroy(&m_lock);
	}
	boolean	Try(void) {
		return xplock_trylock(&m_lock) == 0;
	}
	void	Lock(void) {
		xplock_lock(&m_lock);
	}
	void	Unlock(void) {
		xplock_unlock(&m_lock);
	}
private:
	XPLOCK_ALIGN xplock_t	m_lock;
};

// A helper class that acquires the given Lock while the AutoLock is in scope.
struct _XP_CLS CXPAutolock {
	explicit CXPAutolock(CXPLock& lock) : m_lock(lock){ m_lock.Lock(); }
	~ CXPAutolock(void) {m_lock.Unlock();}
private:
	CXPLock&	m_lock;
};

// A helper class that acquires the given Lock while the AutoLock is in scope.
struct _XP_CLS CXPAutolockex {
	explicit CXPAutolockex(CXPLock *lock) : m_lock(lock){ if(m_lock) m_lock->Lock(); }
	~ CXPAutolockex(void) { if(m_lock) m_lock->Unlock();}
private:
	CXPLock*	m_lock;
};

// A helper class that acquires the given Lock while the AutoLock is in scope.
struct _XP_CLS CXPAutoTrylock {
	explicit CXPAutoTrylock(CXPLock& lock) : m_lock(lock){ m_blocked = m_lock.Try(); }
	~ CXPAutoTrylock(void) { if (m_blocked) m_lock.Unlock();}
	boolean IsLocked() { return m_blocked; }
private:
	CXPLock&	m_lock;
	boolean m_blocked;
};

// A helper class to use xprwlock_xxx
template class _XP_API xpstl::map<xpthread_id, uint32>;	//fix warning C4251
struct _XP_CLS CXPLockRW {
	CXPLockRW(void) {
		m_hlock = xprwlock_alloc();
	}
	~CXPLockRW(void) {
		if (m_hlock) {
			xprwlock_destroy(m_hlock);
			m_hlock = NULL;
		}
	}
	boolean	TryLockRD(void) {
        return xprwlock_tryrdlock(m_hlock) == 0;
	}
	boolean	TryLockWR(void) {
		return xprwlock_tryrwlock(m_hlock) == 0;
	}
	void	LockRD(void) {
        if( !IsLocked(true) ){
            //log_notice("rd lock....");
            xprwlock_rdlock(m_hlock);
        }
        //else log_notice("r d lo ck....,but not lo ck");
	}
	void	LockRW(void) {
        if( !IsLocked(false) ){
            //log_notice("rw lock....");
            xprwlock_wrlock(m_hlock);
        }
        else {
            //log_error("is already locked, now try to lockRW, why???????");
        }
	}
	void	Unlock(void) {
        if( IsNeedUnLock() ){
            //log_notice("unlock....");
            xprwlock_unlock(m_hlock);
        }
	}
private:
	hxplockrw           m_hlock;
  
    //down to keep one thread only one rdlock or one wrlock
private:
    typedef xpstl::map<xpthread_id,uint32>  CMapThreadId2Count;
    CXPLock             m_lockformap;
    CMapThreadId2Count  m_mapThreadId2Count;
    
    boolean  IsLocked(boolean bAddCountIfLocked){
        xpthread_id threadid = xpthread_selfid();
        boolean bIsLocked = false;
        
		{
			CXPAutolock lock(m_lockformap);

			if( m_mapThreadId2Count.end() != m_mapThreadId2Count.find(threadid) ){
				if( bAddCountIfLocked )
					m_mapThreadId2Count[threadid]++;
				bIsLocked = true;
			}
			else {
				m_mapThreadId2Count[threadid] = 1;
			} 
		}
        return bIsLocked;
    }
    
    boolean  IsNeedUnLock(){
        xpthread_id threadid = xpthread_selfid();
        boolean bNeed = false;

		{
			CXPAutolock lock(m_lockformap);

			if( m_mapThreadId2Count.end() != m_mapThreadId2Count.find(threadid) ){
				m_mapThreadId2Count[threadid]--;
				if( 0 == m_mapThreadId2Count[threadid] ){
					m_mapThreadId2Count.erase(threadid);
					bNeed = true;
				}
			}
		}
        return bNeed;
    }
};

// A helper class that acquires the given Lock while the AutoLockReadonly is in scope.
struct _XP_CLS CXPAutolockReadonly {
	explicit CXPAutolockReadonly(CXPLockRW& lock) : m_lock(lock){ m_lock.LockRD(); }
	~ CXPAutolockReadonly(void) {m_lock.Unlock();}
private:
	CXPLockRW&	m_lock;
};

// A helper class that acquires the given Lock while the AutolockReadWrite is in scope.
struct _XP_CLS CXPAutolockReadWrite {
	explicit CXPAutolockReadWrite(CXPLockRW& lock) : m_lock(lock){ m_lock.LockRW(); }
	~ CXPAutolockReadWrite(void) { m_lock.Unlock(); }
private:
	CXPLockRW&	m_lock;
};

#endif

#endif /*_XPLOCK_INC_*/
