/******************************************************************
 ** File 		: xprefsink.h
 ** Author		: juanjia, juanjia@tencent.com 
 ** Date		: 2013-10-01
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: xplatform safe reference counter sink
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#ifndef _XP_REFSINK_INC_
#define _XP_REFSINK_INC_
#pragma once

#include <assert.h>
#include <xprefc.h>

/*

在构造函数中，创建 CRefSink，绑定 CHost 和 CRefSink
在析构函数总，Release，同时在析构时断开CHost与CRefSink的关联，保证CRefSinkPtr生命期结束时，CHost与CRefSink已经没有关联。

*/
template<class CRefSink>
class CRefSinkPtr
{
public:
	template<class CHost>
	CRefSinkPtr(CHost* pHost) : m_pRefSink(NULL)
	{
		assert(pHost != NULL);
		m_pRefSink = new CRefSink;
		assert(m_pRefSink != NULL);		
		m_pRefSink->SetHost(pHost);
	}

	~CRefSinkPtr() //CScopePtr will release p
	{		
		if (m_pRefSink)
		{
			m_pRefSink->SetHost(NULL);
			m_pRefSink->UnhookAll();
			m_pRefSink->Release();
			m_pRefSink = NULL;
		}
	}

	CRefSink* operator->() throw()
	{		
		assert(m_pRefSink != NULL);
		assert(m_pRefSink->GetHost() != NULL);
		return m_pRefSink;	//也可以返回一个从CRefSink继承，但是私有化了Add/Rel的子类，防止应用层对此指针AddRef/Release
	}

	operator CRefSink*() throw()
	{
		assert(m_pRefSink != NULL);
		assert(m_pRefSink->GetHost() != NULL);
		return m_pRefSink;
	}
private:
	CRefSinkPtr& operator=(const CRefSinkPtr& rhs);
	CRefSinkPtr(const CRefSinkPtr& rhs);
	CRefSink* m_pRefSink;
};


///declare refsink class
#define __DECLARE_REFSINK_BEGIN(CRefSink, IRefSink) \
template<class CHost> \
class CRefSink; \
 \
template<class CHost> \
class CRefSink##Ptr : public CRefSinkPtr<CRefSink<CHost> > \
{ \
public: \
	CRefSink##Ptr(CHost* pHost) : CRefSinkPtr<CRefSink<CHost> >(pHost) \
	{} \
}; \
 \
template<class CHost> \
class CRefSink:	public IRefSink \
{ \
public: \
	CRefSink() \
	{ \
		memset((BYTE*)&m_pHost, 0, sizeof(*this) - ((BYTE*)&m_pHost - (BYTE*)this)); \
	} \
    ~CRefSink() \
    { \
        UnhookAll(); \
    } \
 \
public: \
	void SetHost(CHost* pHost) {m_pHost = pHost;} \
	CHost* GetHost() const throw() {return this? m_pHost : NULL;}\
	void UnhookAll() \
	{ \
		CHost*	pHost = m_pHost; \
		memset((BYTE*)&m_pHost, 0, sizeof(*this) - ((BYTE*)&m_pHost - (BYTE*)this)); \
		m_pHost = pHost; \
	} \
 \
private: \
	CHost*	m_pHost; \
 \
private: \
	CRefSink& operator=(const CRefSink& rhs); \
	CRefSink(const CRefSink& rhs); 

///declare refsink member function
#define __IMPLEMENT_REFSINK_FUNCTION(func, params, values) \
public: \
	typedef void (CHost::*F##func)params; \
	\
	void Hook_##func(F##func pf##func) \
	{ \
		assert(m_pHost != NULL); \
		m_pf##func = pf##func; \
	} \
	\
	void Unhook_##func() \
	{ \
		m_pf##func	= NULL; \
	} \
	\
	void (func)params \
	{ \
		if (m_pHost && m_pf##func) \
		{ \
			((m_pHost)->*(m_pf##func))values; \
		} \
	} \
	\
private: \
	F##func	m_pf##func;

///declare refsink end
#define __DECLARE_REFSINK_END() };

/// 
#define DECLARE_REFSINK_BEGIN(CRefSink, IRefSink) __DECLARE_REFSINK_BEGIN(CRefSink, IRefSink)

///
#define IMPLEMENT_REFSINK_FUNCTION(func, params, values) __IMPLEMENT_REFSINK_FUNCTION(func, params, values)

/// 
#define DECLARE_REFSINK_END() __DECLARE_REFSINK_END()	

#endif /*_XP_REFSINK_INC_*/