#ifndef __UCNV_ADP_INC_
#define __UCNV_ADP_INC_
#include <dlfcn.h>
#ifdef ANDROID
typedef signed int int32_t;
typedef int32_t UErrorCode;
#define U_ZERO_ERROR 0
#define U_FAILURE(x) ((x)>U_ZERO_ERROR)
//void* pDL;
int ucnv_convert(const char *, const char *, char * , int32_t , const char *, int32_t,int32_t*);
//external int (*ucnv_convert)(const char *, const char *, char * , int32_t , const char *, int32_t,int32_t*);
//		= (int (*)(const char *, const char *, char * , int32_t , const char *, int32_t,int32_t*))dlsym(pDL, "ucnv_convert_46");
#endif
#endif
