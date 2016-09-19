
#include <xplog.h>

extern utf8*    g_logpath;


boolean sysgot(char** ppmsg, int32 *plen);
void	bilog(esyslog_type level, const char* module, int line, const char* message,int contentoffset);
void	flushlog();