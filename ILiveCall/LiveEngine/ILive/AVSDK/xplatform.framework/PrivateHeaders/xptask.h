/******************************************************************
 ** File 		: xptask.h
 ** Author		: amoslan
 ** Date		: 2012-3-29
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: xplatform task
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#if !defined(_XPTASK_INC_)
#define _XPTASK_INC_
#pragma once

#include <xptypes.h>
#include <xpexcept.h>
#include <xpthread.h>
#include <xprefc.h>
#include <xpepump.h>
#include <xplock.h>

#ifdef __cplusplus

#define INVALID_TASKID		0

typedef uint32	task_id;

typedef enum etask_mode {
	etask_once		= 0,	/*excute once*/
	etask_repeat	= 1		/*excute until canceled*/
}etask_mode;

class _XP_CLS CXPTaskBase : public CRefCountSafe {
public:
	CXPTaskBase(const utf8* name, int sleepMS = 10, ethread_priority type = ethr_priority_normal);
	virtual ~ CXPTaskBase(void);
	
	/*push task to current thread*/
	static task_id	PushTask(const CScopeCall& task);
	static task_id	PushDelayTask(const CScopeCall& task, int64 period, etask_mode mode);
	
	/*push task to specified thread*/
	static task_id	PushTask(CXPTaskBase* target, const CScopeCall& task);
	static task_id	PushDelayTask(CXPTaskBase* target, const CScopeCall& task, int64 period /*in miliseconds*/, etask_mode mode);

	/*cancel task from current thread*/
	static boolean	CancelTask(task_id id);
	/*cancel task from specified thread*/
	static boolean	CancelTask(CXPTaskBase* target, task_id id);

	/*get the curretn run thread task */
	static CXPTaskBase* GetCurrentTask();
    
    const utf8*     GetName(void) const;
	
	boolean	Start(void);
	boolean	Stop(void);
	boolean IsStarted();
	
	inline operator hxpthread (void) {
		return m_hThread;
	}
	
	xpthread_id getthreadid(){
		return m_threadid;
	}
	
protected:
#if defined(_OS_IOS_)
    virtual int64 Eachloop(void);
#else
	virtual boolean Eachloop(void);
#endif
    virtual void    OnStart(void);
    virtual void    OnStop(void);
	
private:
	virtual void Runloop(void);
	static void* ThreadProc(void* param);
#if defined(_OS_IOS_)
    virtual void    Signal(void);
    virtual void    Waiting(int64 miliseconds);
#endif
protected:
	ethread_priority	m_eType;
	xpthread_id			m_threadid;
	hxpthread			m_hThread;
	CXPLock				m_lock;
	void*				m_internal;
    int                 m_sleepMS;
	boolean				m_bIsStop;
};

#if defined(_OS_WIN_)

class _XP_CLS CXPTaskWin : public CXPTaskBase
{
public:
	CXPTaskWin(const utf8* name, ethread_priority type = ethr_priority_normal);
protected:
	void    OnStart(void);
	void    OnStop(void);
};

#endif

typedef CXPTaskBase	CXPTaskDefault;
_XP_CLS CXPTaskBase * XPTaskCreate(utf8 * name, ethread_priority type = ethr_priority_normal);

class _XP_CLS CXPTaskIO : public CXPTaskBase {
public:
	CXPTaskIO(const utf8* name, int sleepMS = 10, ethread_priority type = ethr_priority_normal);
	virtual ~ CXPTaskIO(void);
	
	static hxpfevent GetFevent(void);
	
private:
#if defined(_OS_IOS_)
   
#else
	virtual boolean Eachloop(void);
#endif
#if defined(_OS_IOS_)
    virtual void    Signal(void);
    virtual void    Waiting(int64 miliseconds);
#endif
private:
	hxpfevent	m_hFevent;
};

#endif

#endif /* _XPTASK_INC_ */
