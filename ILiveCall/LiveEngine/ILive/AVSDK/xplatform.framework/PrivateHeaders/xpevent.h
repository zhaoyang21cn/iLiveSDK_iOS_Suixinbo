/******************************************************************
 ** File 		: xpevent.h
 ** Author		: renzzhang, amoslan
 ** Date		: 2012-3-12
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: about event
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#if !defined(_XPEVENT_INC_)
#define _XPEVENT_INC_
#pragma once

#include <xptypes.h>
#include <xpexcept.h>

typedef	void* hxpevent;

#ifdef __cplusplus
extern "C" {
#endif
	
	/**
	 create a event.
	 
	 @manual_reset - indicate type of event. 
	 If this parameter is TRUE, the function creates a manual-reset event object, 
	 which requires the use of the xpevent_reset function to set the event state to nonsignaled. 
	 If this parameter is FALSE, the function creates an auto-reset event object, 
	 and system automatically resets the event state to nonsignaled after a single waiting thread has been released.
	 
	 @init_state- initialized state of event.
	 If this parameter is TRUE, the initial state of the event object is signaled; otherwise, it is nonsignaled.
	 
	 @return	- return a event handle if success, otherwise return NULL.
	 */
	_XP_API hxpevent xpevent_create(boolean manual_reset, boolean init_state);
	
	/**
	 destroy a event.
	 
	 @handle	- event handle created by xpevent_create.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xpevent_destory(hxpevent handle);
	
	/**
	 sets the specified event to the signaled state.
	 
	 @handle	- event handle.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xpevent_signal(hxpevent handle);
	
	/**
	 determines the specified event is signaled or not. 
	 
	 @handle	- event handle.
	 
	 @return	- return true the event is in the signaled state, otherwise return false.
	 */
	_XP_API boolean	xpevent_issignaled(hxpevent handle);
	
	/**
	 sets the specified event to the nonsignaled state.
	 
	 @handle	- event handle.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xpevent_reset(hxpevent handle);
	
	/**
	 wait indefinitely for the event to be signaled.
	 
	 @handle	- event handle.
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xpevent_wait(hxpevent handle);
	
	/**
	 wait up until timeout has passed for the event to be signaled.
	 
	 @handle	- event handle.
	 @timeout   - the time-out interval, in milliseconds.
	 If a nonzero value is specified, the function waits until the event is signaled or the interval elapses. 
	 If @timeout is zero, the function does not enter a wait state if the object is not signaled; it always returns immediately.
	 If @timeout is -1, the function will return only when the object is signaled. 
	 
	 @return	- return 0 if success, otherwise return error code.
	 */
	_XP_API int32	xpevent_timedwait(hxpevent handle, int64 timeout /*in miliseconds*/);
	
#ifdef __cplusplus
};
#endif

#ifdef __cplusplus

class _XP_CLS CXPEvent {
public:
	CXPEvent(boolean manual_reset = false, boolean init_state = false) { 
		m_hEvent = xpevent_create(manual_reset, init_state); 
	}
	
	virtual ~ CXPEvent(void) {
		if(m_hEvent) {
			xpevent_destory(m_hEvent); 
			m_hEvent = NULL;
		}
	}
	
	inline boolean Wait(int64 millisesonds = -1) const {
		return xpevent_timedwait(m_hEvent, millisesonds) == 0;
	}
	
	inline void Post(void) const {
		xpevent_signal(m_hEvent);
	}
	
	inline void Reset(void) {
		xpevent_reset(m_hEvent);
	}
	
	inline boolean IsSignaled(void) const {
		return xpevent_issignaled(m_hEvent);
	}
	
private:
	hxpevent	m_hEvent;
};
#endif

#endif /* _XPEVENT_INC_ */
