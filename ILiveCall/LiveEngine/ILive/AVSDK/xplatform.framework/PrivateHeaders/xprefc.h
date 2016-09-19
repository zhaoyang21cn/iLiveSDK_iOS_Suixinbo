/******************************************************************
 ** File 		: xprefc.h
 ** Author		: Amoslan, xiaolan8318@163.com 
 ** Date		: 2012-03-13
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: xplatform reference counter
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#ifndef _XPREFC_INC_
#define _XPREFC_INC_
#pragma once

#include <xptypes.h>
#include <xpatomic.h>

/**
 @notice
 here we initialized m_iRefs as 1 when CRefCount constructed.
 we strongly recommand you use CRefCount as following code block:
 sample 1 -----(initlializing)>
 class A : public CRefCount {};
 CScopePtr<A>   a(eDoNew);

 sample 2 -----(initlializing)>
 class A : public CRefCount {};
 CScopePtr<A>   a;
 *(A**)a = new A;

 sample 3 -----(assign)>
 class A : public CRefCount {};
 A*             pa = new A;
 CScopePtr<A>   a = pa;
 pa->Release();
 
 sample 4 -----(assign)>
 class A : public CRefCount {};
 CScopePtr<A>   a1(eDoNew);
 CScopePtr<A>   a2 = a1;
 
 */

class _XP_CLS CRefCount {
public:
	virtual ~CRefCount() {}
	
	inline atomic32 RefCount() const {
		return m_iRefs;
	}
	
	virtual atomic32 AddRef() const {
		return ++m_iRefs;
	}
	
	// Returns true if the object should self-delete.
	virtual boolean Release() const {
		if (--m_iRefs == 0) {
			delete this;
			return true;
		}
		return false;
	}
    
    virtual CRefCount* SafeInstance() {
        return this;
    }
    
    //validation checking
    virtual boolean IsValid() {
        return true;
    }
	
protected:
	CRefCount(void) {
		m_iRefs = 1;
	}
	
	mutable atomic32 m_iRefs;
};

class _XP_CLS CRefCountSafe : public CRefCount {
public:
	virtual atomic32 AddRef() const OVERRIDE;
	// Returns true if the object should self-delete.
	boolean Release() const OVERRIDE;
};

typedef enum {eDoNew} ScopePtrNew;

namespace xp {
template <typename T, typename TT>
struct is_pointer {
	enum {value = false};
    static inline TT* cast(T*& p) {return static_cast<TT*>(p);}
};

template <typename T, typename TT>
struct is_pointer<T, TT*> {
	enum {value = true};
    static inline TT** cast(T*& p) {return reinterpret_cast<TT**>(&p);}
};
};

template <typename T>
class CScopePtr {
public:
    typedef T type;
    CScopePtr(void) {
        p = NULL; 
	}
    CScopePtr(T* ptr) : p(ptr) {
		if (p) {
			p->AddRef();
		}
	}
	CScopePtr(const CScopePtr<T>& src) : p(src.p) {
		if (p) {
			p->AddRef();
		}
	}
    CScopePtr(ScopePtrNew op) {
        p = new T;
    }
	~CScopePtr(void) {
		if (p) {
			p->Release();
			p = NULL;
		}
	}
    CScopePtr<T>& operator = (const CScopePtr<T>& src) {
        if (src.p) {
            src.p->AddRef();
        }
		if (p) {
			p->Release();
		}
        p = src.p;
        return *this;
    }
    CScopePtr<T>& operator = (T* newp) {
        if (newp) {
            newp->AddRef();
        }
		if (p) {
			p->Release();
		}
        p = newp;
        return *this;
    }
        
	T*	operator -> (void) {
		return p;
	}
    
	const T*	operator -> (void) const {
		return p;
	}
    
	template <typename TT>
	inline operator TT* (void) {
		return xp::is_pointer<T, TT>::cast(p);
	}
	
	template <typename TT>
	inline operator const TT* (void) const {
		return static_cast<const TT*>(p);
	}

#if defined (_MSC_VER)  || defined (_OS_LINUX_)
	inline operator bool (void) const {
		return p != NULL;
	}
#else
	inline operator void* (void) {
		return reinterpret_cast<void*>(p);
	}
#endif
    
	inline bool operator ! (void) const {
		return (p == NULL);
	}
#if defined (_OS_IOS_) || defined (TARGET_OS_MAC)
    inline operator uintptr_t (void) const {
        return reinterpret_cast<uintptr_t>(p);
    }
#endif
    
    inline bool operator < (const CScopePtr& dst) const {
        return p < dst.p;
    }

	inline T* & refptr() { return p; }

    inline bool CopyTo(T** ppT)
    { 
        if (ppT == NULL)
            return false;
        *ppT = p;
        if (p)
            p->AddRef();
        return true;
    }
private:
	T*	p;
};

/**
 @notice:
 is_base_of is only valid outside of T's declaration block, so do not use is_base_of as following sample:
 class T_for_example : public TT_for_example {
 ...
    bool is = is_base_of<T_for_example, TT_for_example>::value;
    'is' aways be zero under macos
 ...
 };
 -----
 please codes like following:
 class T_for_example : public TT_for_example {
 ...
 };
 bool is = is_base_of<T_for_example, TT_for_example>::value;
 */
namespace xp {
template <typename T, typename TT>
struct is_base_of {
    struct yes_type {enum {value = true}; char padding[1];};
    struct no_type {enum {value = false}; int padding[2];};
    static yes_type is_base_of_test(TT*);
    static no_type is_base_of_test(...);
    enum {value = (sizeof(is_base_of_test(static_cast<T*>(0))) == sizeof(yes_type))};
};
};

template <typename T, bool Is = xp::is_base_of<T, CRefCount>::value, typename RT = CRefCount>
class CScopeHolder : public RT {
public:
    CScopeHolder(T* _p) : p(_p) {}
    ~CScopeHolder(void) {}
private:
	T*	p;
private:
    boolean IsValid(void) {
        return p != NULL;
    }
    /**be carefull to use this pointer*/
    CRefCount*  SafeInstance(void) {
        return reinterpret_cast<CRefCount*>(NULL);
    }
public:
    void    Detach(void) {
        p = NULL;
    }
};

template <typename T, typename RT>
class CScopeHolder<T, true, RT> : public RT {
public:
    CScopeHolder(T* _p) : p(_p) {
        if (p) {
            p->AddRef();
        }
    }
    ~CScopeHolder(void) {
        if (p) {
            p->Release();
            p = NULL;
        }
    }
private:
	T*	p;
private:
    boolean IsValid(void) {
        return p != NULL;
    }
    CRefCount*  SafeInstance(void) {
        return static_cast<CRefCount*>(p);
    }
public:
    void    Detach(void) {
        if (p) {
            p->Release();
            p = NULL;
        }
    }
};

template <typename T, bool Is = xp::is_base_of<T, CRefCount>::value, typename RT = CRefCount>
class CScopeSource {
public:
    CScopeSource(T* p = NULL) {
        //holder = new CScopeHolder<T, Is, RT>(p);
		union {
			CScopeSource* __this;
			char* _pv;
		}_convertor = {this};
        holder = new CScopeHolder<T, Is, RT>(reinterpret_cast<T*>(_convertor._pv -  T::offset_of_source()));
    }
    ~CScopeSource(void) {
        holder->Detach();
        holder->Release();
    }
	CScopeHolder<T, Is, RT>*    holder;
};

#define _OFFSET(t,f)            ((size_t)&(((t*)1)->f) - 1)//warning by silas

#define define_scope_source(T)  \
private:\
CScopeSource<T, true, CRefCountSafe> init_scope_source; \
template <typename T, bool Is, typename RT> friend class CScopeSource;\
static inline int32 offset_of_source(void) {return _OFFSET(T, init_scope_source);}\
public:\
CRefCount* SafeInstance(void) {return init_scope_source.holder;}

#define define_normal_source(T)  \
private:\
CScopeSource<T, false, CRefCountSafe> init_normal_source; \
template <typename T, bool Is, typename RT> friend class CScopeSource;\
static inline int32 offset_of_source(void) {return _OFFSET(T, init_normal_source);}\
public:\
CRefCount* SafeInstance(void) {return init_normal_source.holder;}\
typedef struct xp_task_call_base_##T : public xp_task_call_base\
{\
    T*          fthis;\
    void*       _event;\
} xp_task_call_base_##T;\
int32 xp_asyn_call(CCallTaskArg* arg)\
{\
    xp_task_call_base* pac = arg->pCall;\
    (*pac->func)(pac);\
    return 0;\
}\

typedef bool (*xp_any_call)(void* p);
typedef void (*xp_any_call_nr)(void* p);

typedef struct xp_task_call_base
{
	const char*	fname;
	union {
		xp_any_call	func;
		xp_any_call_nr	func_nr;
	};
	virtual ~xp_task_call_base(){};
} xp_task_call_base;

typedef struct : public CRefCountSafe {
	uint64 uParam1;//here
    uint64 uParam2;
}CCallArg;

typedef struct tagCallTaskArg: public CRefCountSafe {
public:
	xp_task_call_base* pCall;
    tagCallTaskArg(){pCall = NULL;}
    ~tagCallTaskArg(){if(pCall) delete pCall;};
}CCallTaskArg;

#define TASK_CALL_PARAM(task,host,entry,param1,param2) \
{\
CScopePtr<CCallArg> arg(eDoNew);\
arg->uParam1 = param1;\
arg->uParam2 = param2;\
CScopeCall call(host,entry,(CCallArg*)arg); \
CXPTaskDefault::PushTask(task,call);\
}

#define TASK_CALL(task,host,entry) \
{\
CScopePtr<CCallArg> arg(eDoNew);\
arg->uParam1 = 0;\
arg->uParam2 = 0;\
CScopeCall call(host,entry,(CCallArg*)arg); \
CXPTaskDefault::PushTask(task,call);\
}


class _XP_CLS CScopeCall {
	typedef CRefCount*	ScopeHost;
    class CClassAny{};
	typedef CClassAny*	ScopeAny;
	typedef CRefCount*	ScopeArg;
	typedef int32 (CClassAny::*ScopeCall)(ScopeArg /*arg*/);
public:
	CScopeCall(void){m_phost = NULL; m_preal = NULL; m_call = NULL; m_arg = NULL; m_prslt = NULL;}
	CScopeCall(const CScopeCall& src);
	~ CScopeCall(void);

	template <class TIMPL, typename TA>
	CScopeCall(TIMPL* ptr, int32 (TIMPL::*entry)(TA*), TA* arg, uint32* presult = NULL) : m_prslt(presult) {
		union {
			int32 (TIMPL::*_entry)(TA*);
			ScopeCall	_value;
		}_fn_converting = {entry};
		m_phost	= ptr->SafeInstance();
		m_preal	= reinterpret_cast<ScopeAny>(ptr);
		m_call	= reinterpret_cast<ScopeCall> (_fn_converting._value);
		m_arg	= static_cast<ScopeArg> (arg);
		if (m_phost) {
			m_phost->AddRef();
		}
		if (m_arg) {
			m_arg->AddRef();
		}
	}
	
	template <class TIMPL, typename TA>
	CScopeCall(TIMPL* ptr, int32 (TIMPL::*entry)(TA*), CScopePtr<TA>& arg, uint32* presult = NULL) : m_prslt(presult) {
		union {
			int32 (TIMPL::*_entry)(TA*);
			ScopeCall	_value;
		}_fn_converting = {entry};
		m_phost	= ptr->SafeInstance();
		m_preal	= reinterpret_cast<ScopeAny>(ptr);
		m_call	= reinterpret_cast<ScopeCall> (_fn_converting._value);
		m_arg	= static_cast<ScopeArg> ((TA*)arg);
		if (m_phost) {
			m_phost->AddRef();
		}
		if (m_arg) {
			m_arg->AddRef();
		}
	}

	template <class TIMPL, typename TA>
	CScopeCall(CScopePtr<TIMPL>& host, int32 (TIMPL::*entry)(TA*), CScopePtr<TA>& arg, uint32* presult = NULL) : m_prslt(presult) {
		union {
			int32 (TIMPL::*_entry)(TA*);
			ScopeCall	_value;
		}_fn_converting = {entry};
		m_phost	= host->SafeInstance();
		m_preal	= reinterpret_cast<ScopeAny>((TIMPL*)host);
		m_call	= reinterpret_cast<ScopeCall> (_fn_converting._value);
		m_arg	= static_cast<ScopeArg> ((TA*)arg);
		if (m_phost) {
			m_phost->AddRef();
		}
		if (m_arg) {
			m_arg->AddRef();
		}
	}
	
	CScopeCall&	operator = (const CScopeCall& src);
	
	/*excute it*/
	int32	operator () (void);
    
    ScopeArg    getArg(void) {return m_arg;}
    void        setArg(ScopeArg arg) {
        if (arg) {
            arg->AddRef();
        }
        if (m_arg) {
            m_arg->Release();
            m_arg = NULL;
        }
        m_arg	= arg;
    }
    
private:
	ScopeHost	m_phost;
	ScopeAny	m_preal;
	ScopeCall	m_call;
	ScopeArg	m_arg;
	uint32*		m_prslt;
};


/* scope interface impl
 *
 CScopeInterface is designed to resolve mutil-inherited problem like following :
 class IB : public CRefCount { virtual void b(void) = 0;};
 class IC : public CRefCount { virtual void c(void) = 0;};
 class D : public B, public C {void b(void){} void c(void){}}; //mutil-inherited problem
 CSopePtr<D> oD;
 
 how to resolve:
 class IB { virtual void b(void) = 0;};
 class IC { virtual void c(void) = 0;};
 class D : public B, public C, public CRefCount {void b(void){} void c(void){}}; //
 CScopeInterface<D> oD;
 *
 */

template <typename T>
struct CScopeInterface {
    CScopeInterface(void) {
        _interface = NULL;
    }
	template <typename TT>
    CScopeInterface(TT* p) {
        _life       = p->SafeInstance();
        _interface  = dynamic_cast<T*>(p);
    }
    CScopeInterface(CRefCount* r, T* i) {
        _life       = r;
        _interface  = i;
    }
	template <typename TT>
    CScopeInterface(const CScopePtr<TT>& src) {
        _life       = const_cast<CRefCount*>((const CRefCount*)(src));
        _interface  = const_cast<T*>(dynamic_cast<const T*>((const TT*)(src)));
    }
	template <typename TT>
    CScopeInterface(const CScopeInterface<TT>& src) {
        _life       = const_cast<CRefCount*>((const CRefCount*)(src));
        _interface  = const_cast<T*>(dynamic_cast<const T*>((const TT*)(src)));
    }
    
	template <typename TT>
    CScopeInterface<T>& operator = (TT* p) {
        _life       = p->SafeInstance();
        _interface  = dynamic_cast<T*>(p);
        return *this;
    }
    
	template <typename TT>
    CScopeInterface<T>& operator = (const CScopePtr<TT>& src) {
        _life       = const_cast<CRefCount*>((const CRefCount*)(src));
        _interface  = const_cast<T*>(dynamic_cast<const T*>((const TT*)(src)));
        return *this;
    }
    
	template <typename TT>
    CScopeInterface<T>& operator = (const CScopeInterface<TT>& src) {
        _life       = const_cast<CRefCount*>((const CRefCount*)(src));
        _interface  = const_cast<T*>(dynamic_cast<const T*>((const TT*)(src)));
        return *this;
    }
    
	inline operator T* (void) {
		return _interface;
	}
    
	inline operator const T* (void) const {
		return _interface;
	}

    T*	operator -> (void) {
		return _interface;
	}
    
	const T*	operator -> (void) const {
		return _interface;
	}
    
    void clear(void) {
        _life = NULL;
        _interface = NULL;
    }
    
    operator const CRefCount* (void) const {
        return _life;
    }
    
#if defined (_MSC_VER)  || defined (_OS_LINUX_)
	inline operator bool (void) const {
		return _interface != NULL;
	}
#else
	inline operator const void* (void) const {
		return reinterpret_cast<void*>(_interface);
	}
#endif
    
protected:
    CScopePtr<CRefCount>    _life;
    T*  _interface;
};

#endif /*_XPREFC_INC_*/