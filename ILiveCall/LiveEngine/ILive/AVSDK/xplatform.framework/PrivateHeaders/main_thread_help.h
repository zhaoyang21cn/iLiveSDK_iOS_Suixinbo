#pragma once

#include "biasyncalldefine.h"

class _XP_CLS MainThreadHelp {
 public:
  static MainThreadHelp* GetInstance();

  virtual bool Init() = 0; // 单例对象，只需要在主线程调用一次即可
  virtual xpthread_id GetMainThreadId() = 0;
  virtual bool PushTask(const CScopeCall& task) = 0;
};

// ASYN_CJUMP_2C_NR_UI的可读性差，新增代码一律使用VERIFY_ON_MAIN_THREAD
#define ASYN_CJUMP_2C_NR_UI(CClass, F, ...) ASYN_CJUMP_NR(CClass, F, MainThreadHelp::GetInstance()->GetMainThreadId() != xpthread_selfid(), (MainThreadHelp::GetInstance()->PushTask(call)), __VA_ARGS__)

// ASYN_CPOST_2C_NR_UI的可读性差，新增代码一律使用POST_TO_MAIN_THREAD
#define ASYN_CPOST_2C_NR_UI(CClass, F, ...) ASYN_DIRECT_JUMP_NR(CClass, F, true, (MainThreadHelp::GetInstance()->PushTask(call)), __VA_ARGS__)

/*
使用说明：等同于ASYN_CJUMP_2C_NR_UI，可读性更高
1.在工作线程调用VERIFY_ON_MAIN_THREAD，会产生一个Task Push到主线程，在主线程执行VERIFY_ON_MAIN_THREAD后面的代码
2.在主线程调用VERIFY_ON_MAIN_THREAD，会直接执行VERIFY_ON_MAIN_THREAD后面的代码
*/
#define VERIFY_ON_MAIN_THREAD(class_name, method_name, ...) ASYN_CJUMP_NR(class_name, method_name, MainThreadHelp::GetInstance()->GetMainThreadId() != xpthread_selfid(), (MainThreadHelp::GetInstance()->PushTask(call)), __VA_ARGS__)

// 外部不要直接使用__POST_TO_MAIN_THREAD
#define __POST_TO_MAIN_THREAD(CClass, F, jc, ...) \
  do { \
    ac_##CClass##F *__p__ = new ac_##CClass##F; \
    __p__->fname = #F; \
    __p__->func_nr = (any_call_nr)F##_hidden; \
    __p__->fthis = this; \
    CScopePtr<CAsynCallProxy> host = m_pAsynCallProxy; \
    CScopePtr<CAsynCallArg> arg(eDoNew); \
    arg->pac = __p__; \
    CScopeCall call((CAsynCallProxy*)host, &CAsynCallProxy::AsynCall, (CAsynCallArg*)arg); \
    ASSIGN(__VA_ARGS__); \
    jc; \
  } while(0)

/*
使用说明：等同于ASYN_CPOST_2C_NR_UI，可读性更高
POST_TO_MAIN_THREAD总会产生一个Task Push到主线程，在主线程执行class_name::method_name()方法
1.在工作线程调用POST_TO_MAIN_THREAD，效果等同于VERIFY_ON_MAIN_THREAD
2.在主线程调用POST_TO_MAIN_THREAD，会有异步执行效果
*/
#define POST_TO_MAIN_THREAD(class_name, method_name, ...) __POST_TO_MAIN_THREAD(class_name, method_name, (MainThreadHelp::GetInstance()->PushTask(call)), __VA_ARGS__)