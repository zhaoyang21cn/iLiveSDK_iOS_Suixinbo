/*
 *  asyncalldefine.h
 *  Engine
 *
 *  Created by amos on 10-9-26.
 *  Copyright 2010 Tencent. All rights reserved.
 *
 */
#ifndef __BIASYNCALLDEFINE_INC__
#define __BIASYNCALLDEFINE_INC__

#include <xptask.h>
#include <xpevent.h>
#include "biasyncall.h"

/*concatenate two arguments*/
#define CONCAT(arg1, arg2)		CONCAT1(arg1, arg2)
#define CONCAT1(arg1, arg2)		arg1##arg2

/*caculate count of __VA_ARGS__*/
#define __VA_ARGC__(...)		__VA_ARGC___((__VA_PREFIX##__VA_ARGS__##__VA_POSTFIX, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0))
#define __VA_ARGC___(args)		__VA_ARGC9__ args
#define __VA_PREFIX__VA_POSTFIX	9, 8, 7, 6, 5, 4, 3, 2, 1, 0
#define __VA_ARGC9__(_1, _2, _3, _4, _5, _6, _7, _8, _9, N, ...) N

#define _NE_					outofrange
/*take care of your code, don't make a xxx_outofrange error*/
/*caculate count of __VA_ARGS__ in even mode*/
#define __VA_ARGC_HALF__(...)	__VA_ARGC_HALF___((__VA_PREFIX9##__VA_ARGS__##__VA_POSTFIX9, 9, _NE_, 8, _NE_, 7, _NE_, 6, _NE_, 5, _NE_, 4, _NE_, 3, _NE_, 2, _NE_, 1, _NE_, 0, _NE_))
#define __VA_ARGC_HALF___(args)	__VA_ARGC9_HALF__ args
#define __VA_PREFIX9__VA_POSTFIX9	9, _NE_, 8, _NE_, 7, _NE_, 6, _NE_, 5, _NE_, 4, _NE_, 3, _NE_, 2, _NE_, 1, _NE_, 0, _NE_
#define __VA_ARGC9_HALF__(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, N, ...) N

#define LEFTP					(
#define RIGHTP					)
/*field defining in recursive mode*/
#define FIELD_0(...)	
#define FIELD_1(t, n)			t _##n
#ifdef _MSC_VER
#define FIELD_2(t, n, t1, ...)	t _##n; CONCAT(FIELD_, 1) LEFTP t1, __VA_ARGS__ RIGHTP
#define FIELD_3(t, n, t1, ...)	t _##n; CONCAT(FIELD_, 2) LEFTP t1, __VA_ARGS__ RIGHTP
#define FIELD_4(t, n, t1, ...)	t _##n; CONCAT(FIELD_, 3) LEFTP t1, __VA_ARGS__ RIGHTP
#define FIELD_5(t, n, t1, ...)	t _##n; CONCAT(FIELD_, 4) LEFTP t1, __VA_ARGS__ RIGHTP
#define FIELD_6(t, n, t1, ...)	t _##n; CONCAT(FIELD_, 5) LEFTP t1, __VA_ARGS__ RIGHTP
#define FIELD_7(t, n, t1, ...)	t _##n; CONCAT(FIELD_, 6) LEFTP t1, __VA_ARGS__ RIGHTP
#define FIELD_8(t, n, t1, ...)	t _##n; CONCAT(FIELD_, 7) LEFTP t1, __VA_ARGS__ RIGHTP
#define FIELD_9(t, n, t1, ...)	t _##n; CONCAT(FIELD_, 8) LEFTP t1, __VA_ARGS__ RIGHTP
#else
#define FIELD_2(t, n, t1, ...)	t _##n; FIELD_1(t1, __VA_ARGS__)
#define FIELD_3(t, n, t1, ...)	t _##n; FIELD_2(t1, __VA_ARGS__)
#define FIELD_4(t, n, t1, ...)	t _##n; FIELD_3(t1, __VA_ARGS__)
#define FIELD_5(t, n, t1, ...)	t _##n; FIELD_4(t1, __VA_ARGS__)
#define FIELD_6(t, n, t1, ...)	t _##n; FIELD_5(t1, __VA_ARGS__)
#define FIELD_7(t, n, t1, ...)	t _##n; FIELD_6(t1, __VA_ARGS__)
#define FIELD_8(t, n, t1, ...)	t _##n; FIELD_7(t1, __VA_ARGS__)
#define FIELD_9(t, n, t1, ...)	t _##n; FIELD_8(t1, __VA_ARGS__)
#endif
#define FIELDX_(N, args)		CONCAT(FIELD_, N) args
#define FIELD(...)				FIELDX_(__VA_ARGC_HALF__(__VA_ARGS__), (__VA_ARGS__))

/*argument expanding in recursive mode*/
#define EXPAND_0(...)	
#define EXPAND_1(t, n)			__p__->_##n
#ifdef _MSC_VER
#define EXPAND_2(t, n, t1, ...)	__p__->_##n, CONCAT(EXPAND_, 1) LEFTP t1, __VA_ARGS__ RIGHTP
#define EXPAND_3(t, n, t1, ...)	__p__->_##n, CONCAT(EXPAND_, 2) LEFTP t1, __VA_ARGS__ RIGHTP
#define EXPAND_4(t, n, t1, ...)	__p__->_##n, CONCAT(EXPAND_, 3) LEFTP t1, __VA_ARGS__ RIGHTP
#define EXPAND_5(t, n, t1, ...)	__p__->_##n, CONCAT(EXPAND_, 4) LEFTP t1, __VA_ARGS__ RIGHTP
#define EXPAND_6(t, n, t1, ...)	__p__->_##n, CONCAT(EXPAND_, 5) LEFTP t1, __VA_ARGS__ RIGHTP
#define EXPAND_7(t, n, t1, ...)	__p__->_##n, CONCAT(EXPAND_, 6) LEFTP t1, __VA_ARGS__ RIGHTP
#define EXPAND_8(t, n, t1, ...)	__p__->_##n, CONCAT(EXPAND_, 7) LEFTP t1, __VA_ARGS__ RIGHTP
#define EXPAND_9(t, n, t1, ...)	__p__->_##n, CONCAT(EXPAND_, 8) LEFTP t1, __VA_ARGS__ RIGHTP
#else
#define EXPAND_2(t, n, t1, ...)	__p__->_##n, EXPAND_1(t1, __VA_ARGS__)
#define EXPAND_3(t, n, t1, ...)	__p__->_##n, EXPAND_2(t1, __VA_ARGS__)
#define EXPAND_4(t, n, t1, ...)	__p__->_##n, EXPAND_3(t1, __VA_ARGS__)
#define EXPAND_5(t, n, t1, ...)	__p__->_##n, EXPAND_4(t1, __VA_ARGS__)
#define EXPAND_6(t, n, t1, ...)	__p__->_##n, EXPAND_5(t1, __VA_ARGS__)
#define EXPAND_7(t, n, t1, ...)	__p__->_##n, EXPAND_6(t1, __VA_ARGS__)
#define EXPAND_8(t, n, t1, ...)	__p__->_##n, EXPAND_7(t1, __VA_ARGS__)
#define EXPAND_9(t, n, t1, ...)	__p__->_##n, EXPAND_8(t1, __VA_ARGS__)
#endif
#define EXPANDX_(N, args)		CONCAT(EXPAND_, N) args
#define EXPAND(...)				EXPANDX_(__VA_ARGC_HALF__(__VA_ARGS__), (__VA_ARGS__))

/*value assigning in recursive mode*/
#define ASSIGN_0(...)	
#define ASSIGN_1(v, ...)		__p__->_##v = v
#ifdef _MSC_VER
#define ASSIGN_2(v, v1, ...)	__p__->_##v = v; CONCAT(ASSIGN_, 1) LEFTP v1, __VA_ARGS__ RIGHTP
#define ASSIGN_3(v, v1, ...)	__p__->_##v = v; CONCAT(ASSIGN_, 2) LEFTP v1, __VA_ARGS__ RIGHTP
#define ASSIGN_4(v, v1, ...)	__p__->_##v = v; CONCAT(ASSIGN_, 3) LEFTP v1, __VA_ARGS__ RIGHTP
#define ASSIGN_5(v, v1, ...)	__p__->_##v = v; CONCAT(ASSIGN_, 4) LEFTP v1, __VA_ARGS__ RIGHTP
#define ASSIGN_6(v, v1, ...)	__p__->_##v = v; CONCAT(ASSIGN_, 5) LEFTP v1, __VA_ARGS__ RIGHTP
#define ASSIGN_7(v, v1, ...)	__p__->_##v = v; CONCAT(ASSIGN_, 6) LEFTP v1, __VA_ARGS__ RIGHTP
#define ASSIGN_8(v, v1, ...)	__p__->_##v = v; CONCAT(ASSIGN_, 7) LEFTP v1, __VA_ARGS__ RIGHTP
#define ASSIGN_9(v, v1, ...)	__p__->_##v = v; CONCAT(ASSIGN_, 8) LEFTP v1, __VA_ARGS__ RIGHTP
#else
#define ASSIGN_2(v, v1, ...)	__p__->_##v = v; ASSIGN_1(v1, __VA_ARGS__)
#define ASSIGN_3(v, v1, ...)	__p__->_##v = v; ASSIGN_2(v1, __VA_ARGS__)
#define ASSIGN_4(v, v1, ...)	__p__->_##v = v; ASSIGN_3(v1, __VA_ARGS__)
#define ASSIGN_5(v, v1, ...)	__p__->_##v = v; ASSIGN_4(v1, __VA_ARGS__)
#define ASSIGN_6(v, v1, ...)	__p__->_##v = v; ASSIGN_5(v1, __VA_ARGS__)
#define ASSIGN_7(v, v1, ...)	__p__->_##v = v; ASSIGN_6(v1, __VA_ARGS__)
#define ASSIGN_8(v, v1, ...)	__p__->_##v = v; ASSIGN_7(v1, __VA_ARGS__)
#define ASSIGN_9(v, v1, ...)	__p__->_##v = v; ASSIGN_8(v1, __VA_ARGS__)
#endif
#define ASSIGNX_(N, args)		CONCAT(ASSIGN_, N) args
#define ASSIGN(...)				ASSIGNX_(__VA_ARGC__(__VA_ARGS__), (__VA_ARGS__))

/*value assigning in construct mode*/
#define VAINIT_0(...)	
#define VAINIT_1(t, n)			_##n(n),
#ifdef _MSC_VER
#define VAINIT_2(t, n, t1, ...)	_##n(n), CONCAT(VAINIT_, 1) LEFTP t1, __VA_ARGS__ RIGHTP
#define VAINIT_3(t, n, t1, ...)	_##n(n), CONCAT(VAINIT_, 2) LEFTP t1, __VA_ARGS__ RIGHTP
#define VAINIT_4(t, n, t1, ...)	_##n(n), CONCAT(VAINIT_, 3) LEFTP t1, __VA_ARGS__ RIGHTP
#define VAINIT_5(t, n, t1, ...)	_##n(n), CONCAT(VAINIT_, 4) LEFTP t1, __VA_ARGS__ RIGHTP
#define VAINIT_6(t, n, t1, ...)	_##n(n), CONCAT(VAINIT_, 5) LEFTP t1, __VA_ARGS__ RIGHTP
#define VAINIT_7(t, n, t1, ...)	_##n(n), CONCAT(VAINIT_, 6) LEFTP t1, __VA_ARGS__ RIGHTP
#define VAINIT_8(t, n, t1, ...)	_##n(n), CONCAT(VAINIT_, 7) LEFTP t1, __VA_ARGS__ RIGHTP
#define VAINIT_9(t, n, t1, ...)	_##n(n), CONCAT(VAINIT_, 8) LEFTP t1, __VA_ARGS__ RIGHTP
#else
#define VAINIT_2(t, n, t1, ...)	_##n(n), VAINIT_1(t1, __VA_ARGS__)
#define VAINIT_3(t, n, t1, ...)	_##n(n), VAINIT_2(t1, __VA_ARGS__)
#define VAINIT_4(t, n, t1, ...)	_##n(n), VAINIT_3(t1, __VA_ARGS__)
#define VAINIT_5(t, n, t1, ...)	_##n(n), VAINIT_4(t1, __VA_ARGS__)
#define VAINIT_6(t, n, t1, ...)	_##n(n), VAINIT_5(t1, __VA_ARGS__)
#define VAINIT_7(t, n, t1, ...)	_##n(n), VAINIT_6(t1, __VA_ARGS__)
#define VAINIT_8(t, n, t1, ...)	_##n(n), VAINIT_7(t1, __VA_ARGS__)
#define VAINIT_9(t, n, t1, ...)	_##n(n), VAINIT_8(t1, __VA_ARGS__)
#endif
#define VAINITX_(N, args)		CONCAT(VAINIT_, N) args
#define VAINIT(...)				VAINITX_(__VA_ARGC_HALF__(__VA_ARGS__), (__VA_ARGS__))

/*change argument mode from macro to function */
#define MA2FA_0(...)	
#define MA2FA_1(t, n)			t n
#ifdef _MSC_VER
#define MA2FA_2(t, n, t1, ...)	t n, CONCAT(MA2FA_, 1) LEFTP t1, __VA_ARGS__ RIGHTP
#define MA2FA_3(t, n, t1, ...)	t n, CONCAT(MA2FA_, 2) LEFTP t1, __VA_ARGS__ RIGHTP
#define MA2FA_4(t, n, t1, ...)	t n, CONCAT(MA2FA_, 3) LEFTP t1, __VA_ARGS__ RIGHTP
#define MA2FA_5(t, n, t1, ...)	t n, CONCAT(MA2FA_, 4) LEFTP t1, __VA_ARGS__ RIGHTP
#define MA2FA_6(t, n, t1, ...)	t n, CONCAT(MA2FA_, 5) LEFTP t1, __VA_ARGS__ RIGHTP
#define MA2FA_7(t, n, t1, ...)	t n, CONCAT(MA2FA_, 6) LEFTP t1, __VA_ARGS__ RIGHTP
#define MA2FA_8(t, n, t1, ...)	t n, CONCAT(MA2FA_, 7) LEFTP t1, __VA_ARGS__ RIGHTP
#define MA2FA_9(t, n, t1, ...)	t n, CONCAT(MA2FA_, 8) LEFTP t1, __VA_ARGS__ RIGHTP
#else
#define MA2FA_2(t, n, t1, ...)	t n, MA2FA_1(t1, __VA_ARGS__)
#define MA2FA_3(t, n, t1, ...)	t n, MA2FA_2(t1, __VA_ARGS__)
#define MA2FA_4(t, n, t1, ...)	t n, MA2FA_3(t1, __VA_ARGS__)
#define MA2FA_5(t, n, t1, ...)	t n, MA2FA_4(t1, __VA_ARGS__)
#define MA2FA_6(t, n, t1, ...)	t n, MA2FA_5(t1, __VA_ARGS__)
#define MA2FA_7(t, n, t1, ...)	t n, MA2FA_6(t1, __VA_ARGS__)
#define MA2FA_8(t, n, t1, ...)	t n, MA2FA_7(t1, __VA_ARGS__)
#define MA2FA_9(t, n, t1, ...)	t n, MA2FA_8(t1, __VA_ARGS__)
#endif
#define MA2FAX_(N, args)		CONCAT(MA2FA_, N) args
#define MA2FA(...)				MA2FAX_(__VA_ARGC_HALF__(__VA_ARGS__), (__VA_ARGS__))

/*async-api definition*/  //warning silas
#define ASYN_API(CClass,F, ...)		\
typedef struct tag_ac_##CClass##F : public ac_base_##CClass {FIELD(__VA_ARGS__);}ac_##CClass##F;\
static inline boolean F##_hidden(ac_base_##CClass* base) {\
	tag_ac_##CClass##F* __p__ = (tag_ac_##CClass##F*)base;\
	return __p__->fthis->F(EXPAND(__VA_ARGS__));\
}

#define ASYN_API_NR(CClass,F, ...)		\
typedef struct tag_ac_##CClass##F : public ac_base_##CClass {FIELD(__VA_ARGS__);}ac_##CClass##F;\
static inline void F##_hidden(ac_base_##CClass* base) {\
	tag_ac_##CClass##F* __p__ = (tag_ac_##CClass##F*)base;\
	__p__->fthis->F(EXPAND(__VA_ARGS__));\
}


#define ASYN_CJUMP_2C_MAINTHREAD(CClass,F, ...)	ASYN_CJUMP(CClass,F, Assistant::Help::GetMainThreadId() != xpthread_selfid(), (CXPTaskDefault::PushTask(Assistant::Help::GetMainThread(),call)), __VA_ARGS__)
#define SYNC_CJUMP_2C_MAINTHREAD(CClass,F, ...)	SYNC_CJUMP(CClass,F, Assistant::Help::GetMainThreadId() != xpthread_selfid(), (CXPTaskDefault::PushTask(Assistant::Help::GetMainThread(),call)), __VA_ARGS__)

#define ASYN_CJUMP_2C_TO(CClass,F,TASK, ...)		ASYN_CJUMP(CClass,F, TASK->getthreadid() != xpthread_selfid(), (CXPTaskDefault::PushTask(TASK,call)), __VA_ARGS__)
#define SYNC_CJUMP_2C_TO(CClass,F,TASK, ...)		SYNC_CJUMP(CClass,F, TASK->getthreadid() != xpthread_selfid(), (CXPTaskDefault::PushTask(TASK,call)), __VA_ARGS__)

#define ASYN_CJUMP_2C_NR_MAINTHREAD(CClass,F, ...)	ASYN_CJUMP_NR(CClass,F, Assistant::Help::GetMainThreadId() != xpthread_selfid(), (CXPTaskDefault::PushTask(Assistant::Help::GetMainThread(),call)), __VA_ARGS__)
#define SYNC_CJUMP_2C_NR_MAINTHREAD(CClass,F, ...)	SYNC_CJUMP_NR(CClass,F, Assistant::Help::GetMainThreadId() != xpthread_selfid(), (CXPTaskDefault::PushTask(Assistant::Help::GetMainThread(),call)), __VA_ARGS__)

// ASYN_CJUMP_2C_NR_TO的可读性差，新增代码一律使用VERIFY_ON_WORKER_THREAD
#define ASYN_CJUMP_2C_NR_TO(CClass,F,TASK, ...)	 ASYN_CJUMP_NR(CClass,F, TASK->getthreadid() != xpthread_selfid(), (CXPTaskDefault::PushTask(TASK,call)), __VA_ARGS__)
#define SYNC_CJUMP_2C_NR_TO(CClass,F,TASK, ...)	 SYNC_CJUMP_NR(CClass,F, TASK->getthreadid() != xpthread_selfid(), (CXPTaskDefault::PushTask(TASK,call)), __VA_ARGS__)

/** These Two Macro Dangerous! Dead Loop!!!!!!!, 使用方法和上面的宏定义不一样，需要在外面调用宏定义 */
#define ASYN_CJUMP_2C_TOSELF(CClass,F,...)			 ASYN_DIRECT_JUMP(CClass,F, true, (CXPTaskDefault::PushTask(call)), __VA_ARGS__)
#define ASYN_CJUMP_2C_TO_TASK(CClass,F,TASK,...)	 ASYN_DIRECT_JUMP(CClass,F, true, (CXPTaskDefault::PushTask(TASK,call)), __VA_ARGS__)

/*jump conditionally*/
#define ASYN_CJUMP(CClass,F, exp, jc, ...)	\
	if( exp ) {\
		ac_##CClass##F *__p__ = new ac_##CClass##F;\
		__p__->fname = #F;\
		__p__->func = (any_call)F##_hidden;\
		__p__->fthis = this;\
		CScopePtr<CAsynCallProxy> host = m_pAsynCallProxy;\
		CScopePtr<CAsynCallArg>	arg(eDoNew);\
		arg->pac = __p__;\
		CScopeCall call((CAsynCallProxy*)host, &CAsynCallProxy::AsynCall, (CAsynCallArg*)arg);\
		ASSIGN(__VA_ARGS__);\
		jc;\
		return true;\
	}

#define ASYN_CJUMP_NR(CClass,F, exp, jc, ...)	\
	if( exp ) {\
		ac_##CClass##F *__p__ = new ac_##CClass##F;\
		__p__->fname = #F;\
		__p__->func_nr = (any_call_nr)F##_hidden;\
		__p__->fthis = this;\
		CScopePtr<CAsynCallProxy> host = m_pAsynCallProxy;\
		CScopePtr<CAsynCallArg>	arg(eDoNew);\
		arg->pac = __p__;\
		CScopeCall call((CAsynCallProxy*)host, &CAsynCallProxy::AsynCall, (CAsynCallArg*)arg);\
		ASSIGN(__VA_ARGS__);\
		jc;\
		return;\
	}

#define ASYN_DIRECT_JUMP_NR(CClass,F, exp, jc, ...)	\
    if( exp ) {\
    ac_##CClass##F *__p__ = new ac_##CClass##F;\
    __p__->fname = #F;\
    __p__->func_nr = (any_call_nr)F##_hidden;\
    __p__->fthis = this;\
    CScopePtr<CAsynCallProxy> host = m_pAsynCallProxy;\
    CScopePtr<CAsynCallArg>	arg(eDoNew);\
    arg->pac = __p__;\
    CScopeCall call((CAsynCallProxy*)host, &CAsynCallProxy::AsynCall, (CAsynCallArg*)arg);\
    ASSIGN(__VA_ARGS__);\
    jc;\
    }

#define ASYN_DIRECT_JUMP(CClass,F, exp, jc, ...)	\
	if( exp ) {\
	ac_##CClass##F *__p__ = new ac_##CClass##F;\
	__p__->fname = #F;\
	__p__->func = (any_call)F##_hidden;\
	__p__->fthis = this;\
	CScopePtr<CAsynCallProxy> host = m_pAsynCallProxy;\
	CScopePtr<CAsynCallArg>	arg(eDoNew);\
	arg->pac = __p__;\
	CScopeCall call((CAsynCallProxy*)host, &CAsynCallProxy::AsynCall, (CAsynCallArg*)arg);\
	ASSIGN(__VA_ARGS__);\
	jc;\
	}


/*async-api call*/
#define ASYN_CALL(CClass,lp)			(*((ac_base_##CClass*)lp)->func)((ac_base_##CClass*)lp); \
	delete (ac_base_##CClass*)lp;

/*2012-01-02 amos, syncing mode support*/
/*sync-api definition*/    //warning silas
#define SYNC_API(CClass,F, ...)  \
	typedef struct tag_ac_##CClass##F : public ac_base_##CClass {tag_ac_##CClass##F(MA2FA(__VA_ARGS__)):VAINIT(__VA_ARGS__) event(NULL){}; FIELD(__VA_ARGS__); CXPEvent* event; boolean* prt; }ac_##CClass##F;\
	static inline boolean F##_hidden(ac_base_##CClass* base) {\
	tag_ac_##CClass##F* __p__ = (tag_ac_##CClass##F*)base;\
	*__p__->prt = __p__->fthis->F(EXPAND(__VA_ARGS__));\
	boolean bRlt = *__p__->prt;\
	__p__->event->Post();\
	return bRlt;\
}

#define SYNC_API_NR(CClass,F, ...)		\
typedef struct tag_ac_##CClass##F : public ac_base_##CClass {tag_ac_##CClass##F(MA2FA(__VA_ARGS__)):VAINIT(__VA_ARGS__) event(NULL){}; FIELD(__VA_ARGS__); CXPEvent* event;}ac_##CClass##F;\
static inline void F##_hidden(ac_base_##CClass* base) {\
	tag_ac_##CClass##F* __p__ = (tag_ac_##CClass##F*)base;\
	__p__->fthis->F(EXPAND(__VA_ARGS__));\
	__p__->event->Post();\
}

#define SYN_CJUMP_2C_TO(CClass,F,TASK, ...)		SYN_CJUMP(CClass,F, TASK->getthreadid() != xpthread_selfid(), (CXPTaskDefault::PushTask(TASK,call)), __VA_ARGS__)

/*jump conditionally*/ //warning silas
#define SYNC_CJUMP(CClass,F, exp, jc, ...)	\
	if( exp ) {\
		CXPEvent* event = new CXPEvent;\
		boolean brt = false;\
		ac_##CClass##F *__p__ = new ac_##CClass##F(__VA_ARGS__);\
		__p__->fname = #F;\
		__p__->func = (any_call)F##_hidden;\
		__p__->fthis = this;\
		__p__->event = event;\
		__p__->prt = &brt;\
		CScopePtr<CAsynCallProxy> host = m_pAsynCallProxy;\
		CScopePtr<CAsynCallArg>	arg(eDoNew);\
		arg->pac = __p__;\
		CScopeCall call((CAsynCallProxy*)host, &CAsynCallProxy::AsynCall, (CAsynCallArg*)arg);\
		jc;\
		event->Wait();\
		delete event; event = NULL;\
		return brt;\
	}

#define SYNC_CJUMP_NR(CClass,F, exp, jc, ...)	\
	if( exp ) {\
		CXPEvent* event = new CXPEvent;\
		ac_##CClass##F *__p__ = new ac_##CClass##F(__VA_ARGS__);\
		__p__->fname = #F;\
		__p__->func_nr = (any_call_nr)F##_hidden;\
		__p__->fthis = this;\
		__p__->event = event;\
		CScopePtr<CAsynCallProxy> host = m_pAsynCallProxy;\
		CScopePtr<CAsynCallArg>	arg(eDoNew);\
		arg->pac = __p__;\
		CScopeCall call((CAsynCallProxy*)host, &CAsynCallProxy::AsynCall, (CAsynCallArg*)arg);\
		jc;\
		event->Wait();\
		delete event; event = NULL;\
		return;\
	}

/*struct to hold all arguments passed to async-api*/
#define ASYN_BASE_DEFINE(CClass)  \
typedef struct tag_ac_base_##CClass : public  tag_ac_base\
{\
	CClass*		fthis;\
} ac_base_##CClass;

typedef bool (*any_call)(void*);
typedef void (*any_call_nr)(void*);

typedef struct tag_ac_base
{
	const char*	fname;
	union {
		any_call	func;
		any_call_nr	func_nr;
	};
	virtual ~tag_ac_base(){};
} ac_base;


/*
使用说明：等同于ASYN_CJUMP_2C_NR_TO，可读性更高
1.在主线程调用VERIFY_ON_WORKER_THREAD，会产生一个Task Push到工作线程，在工作线程执行VERIFY_ON_WORKER_THREAD后面的代码
2.在工作线程调用VERIFY_ON_WORKER_THREAD，会直接执行VERIFY_ON_WORKER_THREAD后面的代码
*/
#define VERIFY_ON_WORKER_THREAD(class_name, method_name, work_task, ...) ASYN_CJUMP_NR(class_name, method_name, work_task->getthreadid() != xpthread_selfid(), (CXPTaskDefault::PushTask(work_task, call)), __VA_ARGS__)

#endif /*__ASYNCALL_INC__*/
