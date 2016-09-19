/******************************************************************
 ** File 		: xpnet.h
 ** Author		: gavinhuang
 ** Date		: 2012-03-02
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: net interface
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#if !defined(_XPNET_INC_)
#define _XPNET_INC_

#include <xptypes.h>
#include <xpexcept.h>
#include "xpvector.h"
#include "xpstring.h"

#if defined(ARCH_CPU_32_BITS)
	typedef int32 xpsocket;
#elif defined(ARCH_CPU_64_BITS)
	typedef int64 xpsocket;
#else
#	error Please add support for your architecture in xptypes.h
#endif

#ifdef _OS_WIN_
#	ifndef SO_REUSEPORT
#		define SO_REUSEPORT SO_REUSEADDR
#	endif
#endif

#define XPINVALID_SOCKET -1

#define XPNET_IPARRAYSIZE 10

#if defined(_OS_IOS_)

#define XPNET_IPSTACK_NONE 0
#define XPNET_IPSTACK_IPV4 1
#define XPNET_IPSTACK_IPV6 2
#define XPNET_IPSTACK_DUAL 3

#endif

typedef struct xpnet_iparray
{
	uint32 count;
	uint32 ip_array[XPNET_IPARRAYSIZE];
} xpnet_iparray;

typedef struct xpnet_endpoint {
    uint32  ipv4;
    uint16  port;
} xpnet_endpoint;

#ifdef __cplusplus
extern "C" {
#endif
	
	//net common
	_XP_API void	xpnet_init();
	_XP_API uint32  xpnet_getwanip();
    _XP_API void    xpnet_setwanip(uint32 dwWanIP);
	_XP_API uint32	xpnet_getlocalip(boolean bSelectLanIPFirst=false);
	_XP_API boolean xpnet_getlocaliplist(xpstl::vector<xpstl::string>* vecIpList);    
	_XP_API uint32	xpnet_gethostbyname(const utf8* domain,boolean &bsupport);
	_XP_API boolean	xpnet_gethostbyname_ex(const utf8* domain,xpnet_iparray &iparray,boolean &bsupport);
	
    _XP_API uint32  xpnet_getbroadcast(uint32 &uLocalIp, uint32 &uNetmask);
    _XP_API boolean xpnet_ipinnet(uint32 ip, uint32 uNetMask, uint32 broadcast);
    
	_XP_API uint16	xpnet_hton16(uint16 v);
	_XP_API uint16	xpnet_ntoh16(uint16 v);
	_XP_API uint32	xpnet_hton32(uint32 v);
	_XP_API uint32	xpnet_ntoh32(uint32 v);
	_XP_API uint64	xpnet_hton64(uint64 v);
	_XP_API uint64	xpnet_ntoh64(uint64 v);
	
	_XP_API utf8*	xpnet_iptostr(uint32 ip);
	_XP_API uint32  xpnet_strtoip(const utf8* ip);
	
	//socket common
	_XP_API xpsocket xpsocket_create(boolean istcp, boolean reuse = false);
	_XP_API xpsocket xpsocket_create_block(boolean istcp,int32 rtm,int32 ttm);
	_XP_API boolean	xpsocket_close(xpsocket s);
	_XP_API boolean	xpsocket_isvalid(xpsocket s);
	_XP_API boolean	xpsocket_setsendbufsize(xpsocket s,int32 size);
	_XP_API boolean	xpsocket_setrecvbufsize(xpsocket s,int32 size);
	_XP_API boolean xpsocket_getsendbufsize(xpsocket s,int32 &size);
	_XP_API boolean xpsocket_getrecvbufsize(xpsocket s,int32 &size);
	
	_XP_API boolean xpsocket_setnodelay(xpsocket s,boolean bistoset);
    _XP_API boolean xpsocket_setmulticastttl(xpsocket s, int ttl);
    _XP_API boolean xpsocket_joingroup(xpsocket s, const char *mcastAddr, const char *ifAddr);
	//socket tcp
	_XP_API boolean	xpsocket_connect(xpsocket s,const utf8* addr,uint16 port);
	_XP_API boolean	xpsocket_bind(xpsocket s,int32 ip,uint16 port);
	_XP_API boolean	xpsocket_listen(xpsocket s,int32 backlog);
	_XP_API xpsocket xpsocket_accept(xpsocket s);
	_XP_API int32	xpsocket_send(xpsocket s,const void* data,uint32 len);
	_XP_API int32	xpsocket_recv(xpsocket s,void* data,uint32 len);
	_XP_API uint32	xpsocket_getunreaddatalen(xpsocket s);
	_XP_API boolean	xpsocket_getpeername(xpsocket s,uint32 &ip,uint16 &port);
	_XP_API boolean	xpsocket_getsockname(xpsocket s,uint32 &ip,uint16 &port);
#if defined(_OS_IOS_)
    //IPv4 & IPv6 Stack Test
    _XP_API boolean xpnet_isipv4(const utf8* ip);
    _XP_API boolean xpnet_ipv4toipv6(const utf8* ipv4,utf8 *ipv6,uint32 ipv6len);
    _XP_API int32   xpnet_getipstack();
    _XP_API boolean xpsocket_isipv4(xpsocket s);
#endif
	//socket udp
	_XP_API int32	xpsocket_recvfrom(xpsocket s,void* data,uint32 len,uint32 &fromip,uint16 &fromport);
	
	_XP_API int32   xpnet_getlasterror();
	
#ifdef _OS_WIN8_	
	_XP_API boolean	xpsocket_set_iptable(uint32* iptable, uint32 count);
#endif

#ifdef __cplusplus
};
#endif

_XP_API int32	xpsocket_sendto(xpsocket s,const void* data,uint32 len,const utf8* addr,uint16 port);
_XP_API int32	xpsocket_sendto(xpsocket s,const void* data,uint32 len,uint32 uAddr,uint16 port);


#endif /*_FILE*NAME_INC_*/
