#ifndef _QQLOG_UTILS_H_
#define _QQLOG_UTILS_H_

#ifdef ANDROID
#include <android/log.h>
#endif

#include <stdio.h>  
#include <signal.h>
#include <pthread.h>
#include <semaphore.h>
#include <sched.h>
#include <errno.h>
#include <unistd.h>
#include <sys/time.h>
#include <string.h>
#include <stdlib.h>

#include <sys/time.h> 

#define QQ_ENABLE_LOGFILE

class function_trace{
	public:
		function_trace(const char* fn,const char* file = NULL);
		~function_trace();
		private: 
			const char* m_fn;
			const char* m_file;
#ifndef WIN32			
			struct timeval tpstart;
#endif //
};

#if 1
#define AUTO_TRACE_FUNCTION function_trace ft_(__FUNCTION__,__FILE__);
#else
#define AUTO_TRACE_FUNCTION 
#endif //

class Log2File{
public:
	Log2File();
	
	~Log2File();

	bool open(const char* path, int size);

	bool isOpened();
	 
	int write(const char* tag,const char* content);

	void close();

	void save();
private:	
	pthread_mutex_t Mutex;
	FILE *file;
	int msize;
	int writedsize;
    char m_logPath[0x200];
    long m_logCount;
};


class Log2Mem{
public:
	Log2Mem();
	
	~Log2Mem();

	bool open(int count);

	bool isOpened();
	 
	int log(const char* tag,const char* contexts);

	void dump(const char* path);
private:	
	struct string_log_line{
		char* pstr;
		string_log_line* pnext;
	};
	int mcount;
	mutable volatile int32_t mLogCount;
	string_log_line* mlogs;
	void* mStrHeap;
	void* mLogHeap;
};

#ifdef  QQ_ENABLE_LOGFILE

#ifdef __cplusplus
extern "C" void vqq_log_printf(int prio, const char* tag, const char *fmt, ...);
extern "C" void vqq_log_prints(int prio, const char* tag, const char *comments);
extern "C" void vqq_log_open(const char* strfile,int maxsize);
extern "C" void vqq_log_close();
extern "C" void vqq_log_save();
#else
void vqq_log_printf(int prio, const char* tag, const char *fmt, ...);
extern "C" void vqq_log_prints(int prio, const char* tag, const char *comments);
void vqq_log_open(const char* strfile,int maxsize);
void vqq_log_close();
void vqq_log_save();
#endif//

#else
#define vqq_log_printf __android_log_print
#define vqq_log_prints __android_log_print
#define vqq_log_open(...)
#define vqq_log_close(...)
#define vqq_log_save(...)
#endif //QQ_ENABLE_LOGFILE

#define _D(...) vqq_log_printf(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define _I(...) vqq_log_printf(ANDROID_LOG_INFO, LOG_TAG,__VA_ARGS__)
#define _W(...) vqq_log_printf(ANDROID_LOG_WARN, LOG_TAG,__VA_ARGS__)
#define _E(...) vqq_log_printf(ANDROID_LOG_ERROR,LOG_TAG, __VA_ARGS__)


#ifdef LOGE
#undef LOGE
#endif //LOGE

#ifdef LOGD
#undef LOGD
#endif //LOGD

#ifdef LOGI
#undef LOGI
#endif //LOGD
/*
#define LOGE _E
#define LOGD _D
#define LOGI _I
#define LOGW _W
*/
//redirect to share_log.txt. modified by darrenhe
/*
#define LOGE log_debug
#define LOGD log_debug
#define LOGI log_debug
#define LOGW log_debug
*/
#define LOGE(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__) 
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)  
#define LOGI(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)  
#define LOGW(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)  

#endif //_QQLOG_UTILS_H_
