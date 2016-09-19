#include "xptypes.h"
#include "xplock.h"
//#include "xpvector.h"
#include "xpevent.h"
#include "xpthread.h"
#include "xpstream.h"
#include <vector>
#include <list>

#define LOG_THREAD_LIFETIME

class CBIBuffer;

//class  SimpleLock
//{
//private:
//	xplock_t		m_cs;
//	SimpleLock(const SimpleLock &);
//	SimpleLock & operator=(const SimpleLock &);
//public:
//	SimpleLock() {xplock_init(&m_cs); }
//	~SimpleLock() { xplock_destroy(&m_cs); }
//	void Lock() { xplock_lock(&m_cs); }
//	void UnLock() { xplock_unlock(&m_cs); }
//};
//
//class  AutoLock
//{
//private:
//	SimpleLock & m_lock;
//	AutoLock(const AutoLock &);
//	AutoLock & operator=(const AutoLock &);
//public:
//	AutoLock(SimpleLock & lock) : m_lock(lock) { m_lock.Lock(); }
//	~AutoLock() { m_lock.UnLock(); }
//};

class _XP_CLS CXPThreadModelBase
{//���ض��������Կ�������ʹ��CSimpleCircleBuffer��Ϊcache��Ŀǰ������vector�͹���
private:
	CXPLock m_lock;
	#define VEC_W_CACHE_COUNT 3
	typedef struct tagInputBufferInfo{
		std::vector<uint8> m_vecWrite;
		//uint32 m_nWrite;
		uint64 m_ullArg;
		tagInputBufferInfo() : m_ullArg(0) {}
		void clear() { m_vecWrite.clear(); m_ullArg = 0; }
		void swap(tagInputBufferInfo & rhs)
		{
			std::swap(m_ullArg, rhs.m_ullArg);
			m_vecWrite.swap(rhs.m_vecWrite);
		}
	}InputBufferInfo;

	typedef std::vector<InputBufferInfo> InputBufferList;
	InputBufferList m_lstWrite;
	InputBufferInfo m_read;
	//InputBufferInfo m_write;
	size_t m_top;

	//std::vector<uint8> m_vecWrite, m_vecRead;
	//InputBufferInfo m_vecWriteCache[VEC_W_CACHE_COUNT];
	//unsigned long mWriteIndex;
	//unsigned long mReadIndex;
	//uint32 m_nRead;

	hxpevent  m_hEvt;
	hxpthread  m_hThread;
	uint64 m_dwThreadId, m_dwWaitTime;

	xp::strutf8	m_strName;

public:
	CXPThreadModelBase(const char* szName);
	virtual ~CXPThreadModelBase();

	uint32 Start(uint32 dwWaitTime,uint32 dwArg = 0);
	uint32 Stop();
	uint32 Write(void * pNewData, uint32 nLen, uint64 ullArg = 0);
	uint32 Write(const CBIBuffer & bufData, const CBIBuffer & bufHead, uint64 ullArg = 0);
	uint32 ForceTimeOut();

protected:
	static void * Thread(void * pVoid);
	void OnThreadBase();
	virtual void OnThread(void* pData, uint32 nLen, uint32 dw0, uint64 dw1) = 0;
	//uint32 _Write(uint32 nLen, uint64 ullArg);
	size_t _NextWritePos();
	void _Rotate();

private:
	CXPThreadModelBase(const CXPThreadModelBase &);
	CXPThreadModelBase & operator = (const CXPThreadModelBase &);
};

template<class Host>
class CXPThreadModel : public CXPThreadModelBase
{
public:
	typedef void (Host::* HostFunc)(void* pData, uint32 nLen, uint32 dw0, uint64 ull1);

private:
	Host * m_pHost;
	HostFunc m_pFunc;

public:
	CXPThreadModel(Host * pHost, const char* szName) :
		CXPThreadModelBase(szName),
		m_pHost(pHost), m_pFunc(0)
	{}
	~CXPThreadModel() { m_pHost = NULL; m_pFunc = 0; }
	void Hook(HostFunc pf) { m_pFunc = pf; }

protected:
	void OnThread(void* pData, uint32 nLen, uint32 dw0, uint64 ull1)
	{
		if(!pData || !nLen || !m_pHost || !m_pFunc) return;
		(m_pHost->*m_pFunc)(pData, nLen, dw0, ull1);
	}
};