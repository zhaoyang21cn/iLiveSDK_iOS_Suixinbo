/*
 *  biasyncall.h
 *  BaseIM
 *
 *  Created by amos on 12-04-11.
 *  Copyright 2012 tencent. All rights reserved.
 *
 */

#ifndef __BIASYNCALL_INC__
#define __BIASYNCALL_INC__

#pragma once

#include <xprefc.h>

class CAsynCallProxy;

class _XP_CLS CAsynCall
{
public:
	
	CAsynCall();
	virtual ~CAsynCall();
	
protected:
	
	CAsynCallProxy* m_pAsynCallProxy;
};


typedef struct : public CRefCountSafe
{
	void* pac;
} CAsynCallArg;

class _XP_CLS CAsynCallProxy : public CRefCountSafe
{	
public:
	
	CAsynCallProxy();
	~CAsynCallProxy();
	void SetHost(void * pHost);
	int32 AsynCall(CAsynCallArg *pArg);
	
private:
	void*  m_pHost;
};

#endif