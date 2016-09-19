#ifndef _XPIHTTPCLIENT_INCLUE_
#define _XPIHTTPCLIENT_INCLUE_

#pragma once


#include <xplist.h>
#include <xpstream.h>
#include <xprefc.h>
#include <xptask.h>
#include <xpsocket.h>

/// 下载结果代码
enum DOWNLOAD_ERRORCODE
{
	ERRORCODE_NULL          = 0,			// SUCCESS
	ERRORCODE_NOMODIFIED    = 1,	// No modified . so no update

	// error
	ERRORCODE_GENERAL       = 2,
	ERRORCODE_SERVERCLOSE   = 3,
	ERRORCODE_WRITEFAILED   = 4,
	ERRORCODE_NETWORKFAILED = 5,
	ERRORCODE_FILESIZEERROR = 6,
	ERRORCODE_FILENOFOUND   = 7,
	ERRORCODE_SERVERUNAVAIL = 8,
	ERRORCODE_USER_ABORT    = 9,
    ERRORCODE_PARAMERROR    = 10,
};

/// 事件响应Mask
enum DOWNLOAD_EVENTMASK
{
	EVENT_CONNECTING = 1,
	EVENT_CONNECTED = 2,
	EVENT_DOWNLOADSTART = 4,
	EVENT_DOWNLOADCOMPLETE = 8,
	EVENT_PROGRESS = 16,
	EVENT_ERROR = 32,
	EVENT_ALL = EVENT_CONNECTING|EVENT_CONNECTED|EVENT_DOWNLOADSTART|EVENT_DOWNLOADCOMPLETE|EVENT_PROGRESS|EVENT_ERROR
};

/// 方法
enum HTTPMETHOD
{
	HTTPMETHOD_GET,
	HTTPMETHOD_POST
};


typedef struct _SYSTIME {
    uint16 wYear;
    uint16 wMonth;
    uint16 wDayOfWeek;
    uint16 wDay;
    uint16 wHour;
    uint16 wMinute;
    uint16 wSecond;
    uint16 wMilliseconds;
} SYSTIME, *PSYSTIME, *LPSYSTIME;

class IHttpClientSink;

class IHttpClient
{
public:

    virtual ~IHttpClient(){};
	///设置信息回调
	/** 
	@param 参数：pSink			in,	回调的Sink
	*/	
	virtual void SetSink(IHttpClientSink *pSink) = 0;
    
    virtual void SetRequestTimeout(uint32 dwConnTimeout_ms, uint32 dwRecvTimeout_ms, uint32 nRetryTimes) = 0;
    
    virtual void SetUseProxy(boolean bUseProxy) = 0;//不设置，默认为false（不使用代理)
    
	virtual void SetIpAndPortToBind(const xp::strutf8& strIp, uint16 wPort) = 0;

	virtual void GetIpAndPortToBind(xp::strutf8& strIp, uint16& wPort) = 0;

    virtual void SetLogId(uint64 uLogId) = 0;
    virtual uint64 GetLogId() const = 0 ;
    
    //设置使用GBKHead
	virtual void SetUseGBKHead(boolean bUseGBKHead) = 0;

	//设置释放带Cookie
	virtual void SetWithCookie(boolean bWithCookie) = 0;
    
    //是否自动续传
	virtual void SetAutoResume(boolean bAutoResume) = 0;
    
	//设置OnRedirect syn notify 
	virtual void SetRedirectSynNotify(boolean bSyn) = 0;
    
    //设置消息屏蔽，默认只关心OnComplete
	virtual void SetEventMask(uint8 cEventMask) = 0;

	/// 设置用户特性数据
	virtual boolean SetCustomData(CRefCountSafe *pCustomData)   = 0;
	virtual boolean GetCustomData(CRefCountSafe **ppCustomData) = 0;
	virtual boolean SetCustomData(uint64 dwCustomId) = 0;
	virtual boolean GetCustomData(uint64 &dwCustomId) = 0;
    virtual boolean SetFolderItemId(int itemId) = 0;
    virtual int32 GetFolderItemId()const = 0;
    /// 向HTTP请求头部添加请求内容。用于非标准形式数据及整块信息的添加。注意非标准的数据可能会在启动下载时导致出错。标准的数据具有<field-name><:><value><\\r\\n>的格式。
	/** @param 参数：strContent	in,	用户附加信息
     */	
	virtual boolean AddInfo(const xp::strutf16 &strContent) = 0;
	virtual boolean AddInfo(const xp::strutf16 &strParamName, const xp::strutf16 &strValue) = 0;
    virtual boolean AddInfo(const xp::strutf16 &strParamName, uint32 uiValue) = 0;
    
    /// 清除头信息
	virtual void ClearRequestHeader() = 0;
    
    /// 向Form添加一个域及其值
	virtual void AddFormData(const xp::strutf16 &strFieldName, const xp::strutf16 &strValue) = 0;

    /// 清空Form内容
	virtual void ResetFormData() = 0;

    ///是否正在运行中(下载或上传任务为结束)
	virtual boolean IsRunning() = 0;
    
	///下载到文件
	/** 
	@param 参数：strURL			in,	Http下载的Url
	@param 参数：strFileName		in,	下载后保存的文件名
	@param 参数：pLastModifyTime	in,	文件文件上次接收的时间戳
	@param 参数：bResume         in,	是否断点续传
	*/	
	virtual boolean Download(const xp::strutf8 &strUrl,const xp::strutf8 &strFileName,SYSTIME *pLastModifyTime = NULL,boolean bResume = false) = 0;
    virtual boolean Download(const xp::strutf16 &strURL, const xp::strutf16 &strFileName, SYSTIME *pLastModifyTime = NULL, boolean bResume = false) = 0;
    virtual boolean Download(const xp::strutf16 &strBaseUrl, const xp::strutf16 &strPort, const xpstl::list<xp::strutf8> &lstHosts, const xp::strutf16 &strFileName
                             , SYSTIME *pLastModifyTime = NULL,boolean bResume = false) = 0;
	///下载到内存Buffer中
	/** 
	@param 参数：strURL			in,	Http下载的Url
	@param 参数：pLastModifyTime	in,	文件文件上次接收的时间戳
	*/	
	virtual boolean DownloadToBuffer(const xp::strutf16 &strURL, SYSTIME *pLastModifyTime = NULL) = 0;

    virtual boolean HttpRequestToBuffer(const xp::strutf16 &strURL, HTTPMETHOD nMethod, const uint8 *pRequestBuf, uint32 uRequestBufLen) = 0;
    virtual boolean HttpRequestToBuffer(const xp::strutf16 &strBaseUrl, const xp::strutf16 &strPort, const xpstl::list<xp::strutf8> &lstHosts, HTTPMETHOD nMethod, const uint8* pRequestBuf, uint32 uRequestBufLen) = 0;
	
    virtual void Post(const char *host, uint16 port,  const xp::strutf8 &strHead,  const xp::strutf8 &strContent) = 0;
    ///上传文件
	/** 
	@param 参数：strURL			in,	Htt上传的Url
	@param 参数：strFileName		in,	上传的文件名
	*/
	virtual boolean Upload(const xp::strutf16 &strURL, const xp::strutf16 &strFileName) = 0;

	///上传Buffer
	/** 
	@param 参数：strURL			in,	Htt上传的Url
	@param 参数：pBuf				in,	上传的Buffer
	@param 参数：uBufLen			in,	上传的文件长度
	*/
	virtual boolean Upload(const xp::strutf8 &strUrl,const uint8* pBuf,uint32 uBufLen) = 0;
    virtual boolean Upload(const xp::strutf16 &strURL, const uint8* pBuf, uint32 uBufLen) = 0;

    virtual boolean UploadFormData(const xp::strutf16 &strUrl,utf16* lpField,utf16* lpFileName) = 0;
	virtual boolean UploadFormData(const xp::strutf16 &strUrl,const utf16* lpField,const uint8* pBuf,uint32 uBufLen,const utf16* lpFileName = NULL) = 0;

    
	//取消下载
	virtual void CancelDownload() = 0;
    
 	/// 得到裸应答头
	virtual boolean GetRawResponseHeader(xp::strutf16 &strResponseHead) = 0;

	//得到服务器应答的内容(之前调用DownloadToBuffer才可以调用改函数)
	virtual boolean GetDownloadedBuffer(uint8 **ppResponseBuf,uint32 *pdwLength) = 0;
    
    //得到服务器应答存放的文件名[如果有应答内容，则上传下载都可能有该文件
    virtual boolean GetDownloadedFilePath(xp::strutf16 &strFileName) = 0;
    
	virtual boolean QueryInfo(const xp::strutf16 &strParamName, xp::strutf16 &strRet, boolean bTrim = true) = 0;
    
	/// 从HTTP回复头部获取数字字符串，并转换成DWORD
	/** @param strParamName	in,	参数名，不带冒号
     @param dwRet	in,		保存从HTTP头部得到的DWORD值
     */
	virtual boolean QueryInfo(const xp::strutf16 &strParamName,	uint32 &dwRet) = 0;
	virtual boolean QueryInfo(const xp::strutf8 & strParamName, xp::strutf8 &strRet,boolean bTrim ) = 0;
	/// 得到返回的状态码
	virtual uint32 GetStatusCode() = 0;

	/// 得到应答的文件名
	virtual boolean GetResponseFileName(xp::strutf16 &strFileName) = 0;
	virtual boolean UploadWithBufferResponse(xp::strutf16 &strUrl,xp::strutf16 &strFileName, uint64 uStartPos = 0) = 0;
};

class  IHttpClientSink  
{

protected:
	IHttpClientSink(){};
	virtual ~IHttpClientSink(){};

public:

	/// 开始连接服务器
	/** @param pDownload in,		download对象
		@param lpszServerAddr in,	服务器地址
	*/
	virtual void OnConnecting(IHttpClient *pDownload, const xp::strutf16 &strServerAddr){};
	
	/// 连接服务器成功
	/** @param pDownload in,		download对象
	 *
	 */
	virtual void OnConnected(IHttpClient *pDownload){};

	/// 开始下载文件
	/** @param pDownload in,		download对象
		@param dwResumeuint8s in,	开始下载的文件位置. 断点续传时候使用
		@param dwFileuint8s in,		文件的大小
	*/
	virtual void OnDownloadStart(IHttpClient *pDownload, uint32 dwResumeuint8s, uint32 dwFileuint8s){};

	/// 下载进度
	/** @param pDownload in,		download对象
		@param dwProgress in,		已经下载的大小. 
		@param dwProgressMax in,	文件的总大小
	*/					
	virtual void OnProgress(IHttpClient *pDownload, uint64 dwProgress, uint64 dwProgressMax,uint32 uSpeed_Byte_S,uint64 uTransferIncrementLen){};


	/// 连接重定向
	/** @param pDownload in,				download对象
		@param lpszRedirectedAddr in,		重定向后新的url. 
	*/
	virtual void OnRedirected(IHttpClient *pDownload, xp::strutf16 &strRedirectedAddr){};

	
	/// 下载结束, 包括下载成功和所有失败. 最重要函数，继承类必须实现	
	/** 
		需要在此函数中调用pDownload->MoveDownload File来保存文件
		@param pDownload in,		download对象
		@param dwErrorCode in,		状态代码( CTXHttpDownload::DOWNLOAD_ERRORCODE )，取值ERRORCODE_NULL或ERRORCODE_NOMODIFIED
									表示HTTP下载成功（含服务器返回无改动），其他可能
									取值同OnError的nCode取值，表示与服务器交互出错。 
	*/	
	virtual void OnDownloadComplete(IHttpClient *pDownload, uint32 dwErrorCode) = 0;
};


_XP_API IHttpClient* xp_create_httpclient(CXPTaskDefault* pclientSink_callback_task = NULL);
_XP_API IHttpClient* xp_create_httpclientforoutsidecnn(CXPITCPSocket* toAttachSocket,CXPTaskIO* pSelfTask,CXPTaskDefault* pclientSink_callback_task = NULL);
_XP_API CXPITCPSocket* xp_detach_httpclientforoutsidecnn(IHttpClient* httpClient);
#if !defined(_OS_ANDROID_)
_XP_API IHttpClient* xp_create_httpclientforreversecnn(CXPIReverseTcpSocketCreater* creater,CXPTaskDefault* pclientSink_callback_task);
#endif
#endif