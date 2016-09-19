/*
 *  xptimer.h
 *  BaseIM
 *
 *  Created by gavinhuang on 12-3-30.
 *  Copyright 2012 tencent. All rights reserved.
 *
 */

#if !defined(_XPTIMER_INC_)
#define _XPTIMER_INC_
#pragma once

#include <xptask.h>
#include <xptask.h>


class CXPRealTimer;

class _XP_CLS CXPTimerBase
{
public:
	~CXPTimerBase(){};
	virtual void OnTimer(uint32 uId) = 0;
	
protected:
	CXPRealTimer* m_pRealTimer;
};

class _XP_CLS CXPTimer : public CXPTimerBase
{
public:
	
	CXPTimer(boolean bEnableMultiThread = false,CXPTaskDefault* pTask = NULL);
	virtual	 ~CXPTimer();
	
	void	SetTimerTask(CXPTaskBase* pTask);	
	void    SetTimer(uint32 nInterval_ms,uint32 uId = 0,boolean bOnce = false);
	void	SetTimerAtTask(CXPTaskDefault* pTask,uint32 nInterval_ms,uint32 uId = 0,boolean bOnce = false);
	
	void	KillTimer(uint32 uId = -1);//if uid == -1 ,will kill all timer in this CTimer
	
private:
	
	CScopePtr<CXPTaskDefault> m_pDefaultTask;
};


class _XP_CLS CXPTimer_MultiThread: public CXPTimerBase
{
public:
	
	CXPTimer_MultiThread();
	virtual	 ~CXPTimer_MultiThread();	
	void	SetTimer(CXPTaskDefault* pTask,uint32 nInterval_ms,uint32 uId = 0,boolean bOnce = false);
	void	KillTimer(uint32 uId = -1);//if uid == -1 ,will kill all timer in this CTimer
};

#endif