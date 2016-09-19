#pragma once

/** 
@file      
@brief	    Http	
@version	2009/01/10 Gavinhuang Create
*/

#include <xpihttpclient.h>
#include <xplist.h>
#include <xpmap.h>
#include <xpasyncall.h>
#include <xptask.h>
#include <xpsocket.h>
#include <xptimer.h>
#include "httptcpconnector.h"

class CDataReader;
class CDataWriter;
class CHttpCookieReadWriter;
class CHttpChunker;
class CHttpTcpConnector;
//class CHttpTCPConnectorSink;

class CXPHttpClient :
	public IHttpClient,
	public CHttpTCPConnectorSink,
	public CXPITCPSocketSink,
	public CXPTimer
{
public:
    define_normal_source(CXPHttpClient);
	CXPHttpClient(CXPTaskDefault* pclientSink_callback_task = NULL);
	virtual ~CXPHttpClient();

    //IHttpClient
public:
    
    void    SetSink(IHttpClientSink *pSink);
    void    SetRequestTimeout(uint32 dwConnTimeout_ms, uint32 dwRecvTimeout_ms, uint32 nRetryTimes);
    void    SetUseProxy(boolean bUseProxy);
	void    SetIpAndPortToBind(const xp::strutf8& strIp, uint16 wPort);
	void    GetIpAndPortToBind(xp::strutf8& strIp, uint16& wPort);
    uint64  GetLogId() const { return m_uLogId;}
    void    SetLogId(uint64 uLogId) { m_uLogId = uLogId; };
	
	boolean Download(const xp::strutf8 &strUrl,const xp::strutf8 &strFileName,SYSTIME *pLastModifyTime = NULL,boolean bResume = false);
    boolean Download(const xp::strutf16 &strUrl,const xp::strutf16 &strFileName,SYSTIME *pLastModifyTime = NULL,boolean bResume = false);
    boolean Download(const xp::strutf16 &strBaseUrl, const xp::strutf16 &strPort, const xpstl::list<xp::strutf8> &lstHosts, const xp::strutf16 &strFileName, SYSTIME *pLastModifyTime = NULL,boolean bResume = false);
	boolean DownloadToBuffer(const xp::strutf16 &strUrl,SYSTIME *pLastModifyTime = NULL);

	boolean Upload(const xp::strutf16 &strUrl,const xp::strutf16 &strFileName);
	boolean Upload(const xp::strutf8 &strUrl,const uint8* pBuf,uint32 uBufLen);
	boolean Upload(const xp::strutf16 &strUrl,const uint8* pBuf,uint32 uBufLen);
	boolean UploadFormData(const xp::strutf16 &strUrl,utf16* lpField,utf16* lpFileName);
	boolean UploadFormData(const xp::strutf16 &strUrl,const utf16* lpField,const uint8* pBuf,uint32 uBufLen,const utf16* lpFileName = NULL);

	boolean AddInfo(const xp::strutf16 &strContent);
	boolean AddInfo(const xp::strutf16 &strParamName, const xp::strutf16 &strValue);
	boolean AddInfo(const xp::strutf16 &strParamName, uint32	dwValue);
	boolean AddInfo(const xp::strutf16 &strParamName, const uint8 *pcBuf, uint32 dwLength);
	boolean QueryInfo(const xp::strutf16 & strParamName, xp::strutf16 &strRet,boolean bTrim = true);
	boolean QueryInfo(const xp::strutf8 & strParamName, xp::strutf8 &strRet,boolean bTrim = true);
	boolean QueryInfo(const xp::strutf16 &strParamName,	uint32 &dwRet);

	boolean GetLastModifyTime(SYSTIME &tTime);

    void    AddFormData(const xp::strutf16 &strFieldName, const xp::strutf16 &strValue);
	void    ResetFormData();

	boolean GetDownloadedFilePath(xp::strutf16 &strQNCFileName);
    boolean GetDownloadedBuffer(uint8 **ppResponseBuf,uint32 *pdwLength);

	/// 设置用户特性数据
	boolean SetCustomData(CRefCountSafe *pCustomData);
	boolean GetCustomData(CRefCountSafe **ppCustomData);
	boolean SetCustomData(uint64 dwCustomId);
	boolean GetCustomData(uint64 &dwCustomId);
    boolean SetFolderItemId(int itemId);
    int32 GetFolderItemId()const;

	/// 取消下载
	void CancelDownload();

	/// 得到裸应答头
	boolean GetRawResponseHeader(xp::strutf16 &strResponseHead);

	/// 清楚头信息
	void ClearRequestHeader();

	/// 设置先用IE的代理信息(废弃掉，全部采用QQ登陆时的设置)
	void SetUseIEProxy(boolean bUseIEProxy);

	/// 移动文件
	boolean MoveDownloadFile(xp::strutf8 &strDestPath, boolean bDelSrc);

	/// 是否自动续传
	void SetAutoResume(boolean bAutoResume);

	/// 设置消息屏蔽，默认只关心OnComplete
	void SetEventMask(uint8 cEventMask);

	/// 得到返回的状态码
	uint32 GetStatusCode();

	/// 得到应答的文件名
	boolean GetResponseFileName(xp::strutf16 &strFileName);

	///是否正在运行中(下载或上传任务为结束)
	boolean IsRunning();

	//设置使用GBKHead
	void SetUseGBKHead(boolean bUseGBKHead);

	//设置释放带Cookie
	void SetWithCookie(boolean bWithCookie);

	//设置OnRedirect syn notify 
	void SetRedirectSynNotify(boolean bSyn);

	boolean HttpRequestToBuffer(const xp::strutf16 &strUrl,HTTPMETHOD nMethod,const uint8* pRequestBuf,uint32 uRequestBufLen);
    boolean HttpRequestToBuffer(const xp::strutf16 &strBaseUrl, const xp::strutf16 &strPort, const xpstl::list<xp::strutf8> &lstHosts, HTTPMETHOD nMethod, const uint8* pRequestBuf, uint32 uRequestBufLen);

    void Post(const char *host, uint16 port,  const xp::strutf8 &strHead, const xp::strutf8 &strContent);
    
	//上传一个文件，与Upload()不同的是，该接口函数会将server的返回信息写入内存，而不是本地文件
	//同时，本函数支持上传进度的通知
	boolean UploadWithBufferResponse(xp::strutf16 &strUrl,xp::strutf16 &strFileName, uint64 uStartPos = 0);

public:
    
    typedef struct st_http_request_info
    {
        //url & method
        xp::strutf8 strurl;
        xp::strutf8 strurlport;
        xpstl::list<xp::strutf8> lstHosts;
        HTTPMETHOD  nMethod;
        
        //tosend
        xp::stream  bufToSend;
        xp::strutf8 strFileToSend;
        
        //toread
        xp::strutf8 strFileToRecv;
        
        //param
        boolean     bWithLastTime;
        SYSTIME     tmLastTime;
        boolean     bResume;

		//formdata
		boolean        bMultiPartFormData;	///<互联网媒体类型传输[multipart/form-data上传中使用]
        uint64         uStartPosition;
        st_http_request_info();
        st_http_request_info& operator = (const st_http_request_info& other);
    } st_http_request_info;

    virtual void StartHttpThread();
    virtual void StopHttpThread(boolean bForce = true);
    void        Request(const st_http_request_info &rqinfo);
    
    virtual void RetryConnect();
	virtual void RedirectConnect();
	void		 CloseReuseTCP();

	//CHttpTCPConnectorSink
	void		OnConnected(boolean bSuccess,xpsocket s);
	
	
private:
	void		RetryConnect(boolean bForceNoProxy);
	void		ConnectToServer(boolean retryNoProxy);
	boolean		Reset();

	boolean		CrackUrl(const utf8* lpUrl);
    boolean     CrackUrl(const xp::strutf8 &strBaseUrl, const xp::strutf8 &strPort, const xpstl::list<xp::strutf8> &lstHosts);
	boolean		EncodeBuffer(uint8 *pcBuf, xp::strutf16 &strBuf);

	void		SaveRequestModifiedTime(const SYSTIME *ptTime);
	boolean		BuildRqHead(xp::strutf8 &strRqHead);

	boolean		GetDownloadedFilePath(xp::strutf8 &strQNCFileName);
	boolean		QueryInfoWithoutEnter(const xp::strutf8 & strParamName, xp::strutf8 &strRet,boolean bTrim = true);

private:

    void        SetSocketRecvBufSize();
	void		GetContentLength();
	boolean		ReadData(boolean &bComplete);
	boolean		WriteContentData(uint8* pBuf,uint32 dwLen,boolean &bComplete);

	boolean		IsRedirectResponse();
	boolean		IsOKResponse();
	boolean		AnalyseResponseData(boolean &bComplete);
	boolean		AnalyseResponseHead();
	boolean		GetLocationUrl();
	boolean		GetResponseStatusCodeFromHead();
	boolean		GetContentInfoFromHead();
	boolean		IsWithUnsafeChar(const utf8* lpUrl);

    virtual boolean CanReuseTcp();
	virtual void    ConnectToServer();

	void		GenerateRandomBoundaryString(xp::strutf8 &strBoundary,int nLength = 6);
	char *		concat_url(const char *base, const char *relurl);
	boolean		IsAbsoluteURL(const utf8* pRedirectURI);

public:

	void NotifyComplete(int nError);
    void ProcessRedirected(xp::strutf8 &strRedirectedAddr);
    
	void NotifyOnConnecting(xp::strutf16 &strServerAddr);
	void NotifyOnConnected();
	void NotifyOnDownloadStart(uint32 dwResumeuint8s, uint32 dwFileuint8s);
    void NotifyProgress(boolean bForceNotify);
	void NotifyOnProgress(uint64 dwProgress, uint64 dwProgressMax,uint32 uSpeedbyte_s,uint64 uTransferIncrementLen);
	void NotifyOnDownloadComplete(uint32 dwErrorCode);
	void NotifyOnRedirected(xp::strutf16 &strRedirectedAddr);
	void NotifyOnReConnect();
	
	void OnConnectSuccess();
	void SendData(boolean &bHaveDataSend);
	
	void OnRecv(CXPITCPSocket* pTCPSocket);
	void OnSend(CXPITCPSocket* pTCPSocket);
	void OnClose(CXPITCPSocket* pTCPSocket);
	
	void OnTimer(uint32 uId);
	//void StopThreadWhenIdle(void);
protected:

	//头信息
	typedef xpstl::map<xp::strutf8, xp::strutf8> CMapHeadInfo;

	//应答接收Buf
	struct tagUserInfo
	{
		CMapHeadInfo             mapHttpHeadInfo;	///<用户加入标准Http头信息
		xp::strutf8              strCustomHeadInfo;	///<用户加入自定义Http头
		CScopePtr<CRefCountSafe> pCustomData;		///<用户加入特别数据
		uint64                   uCustomId;
        int                      folderItemId;
	};

	//应答接收Buf
	struct tagResponseInfo
	{
		uint8*	pTmpRecvBuf;			///<下载过程中的临时接收缓存
		uint32	dwTmpRecvTotalLen;		///<应答临时接收Buf的长度
		uint32	dwTmpRecvCurPos;		///<应答临时接收Buf当前写入的位置

		xp::strutf8	strResponseHead;	///<Http应答协议头
		uint32  dwResponseStatusCode;	///<Http应答放回码 200 OK or 404 or 306....
		uint32  dwContentLength;		///<Http应答协议体长度(非块传输时有)[总长度，断点续传时要修正]

		boolean	bChunked;				///<是否采用Chunk方式接收
		boolean	bWithChunkTrailer;		///<是否Chunk尾部
	};

	struct tagRequestInfo
	{
        xp::strutf8                      strHost;
        xpstl::list<xp::strutf8>        lstHosts;
		uint16                          wPort;				///<连接的Port
		xp::strutf8						strRqMethod;		///<请求的方法
		xp::strutf8						strURL;				///<请求的URL
		xp::strutf8						strURI;				///<请求的基本路径
		xp::strutf8						strRqModifiedTm;	///<时间戳

		int                             nRetryTimes;		///<重试次数
		int                             nRedirTimes;		///<定向次数

		boolean                         bMultiPartFormData;	///<互联网媒体类型传输[multipart/form-data上传中使用]
		xp::strutf8						strBoundary;		///<采用multipart/form-data传输的分界线
		xp::strutf8						strFormDatas;		///<FormDatas
	};

	boolean						m_bRunning;         ///<是否当前处于运行状态中
    boolean                     m_bCompleted;
	tagRequestInfo				m_oRequestInfo;		///<请求相关信息
	tagResponseInfo				m_oResponseInfo;	///<接收应答相关
	tagUserInfo					m_oUserInfo;		///<用户加入信息相关

	CDataReader*                m_pRqDataReader;	///< 请求数据读取器(读取请求的文件或Buf)
	CDataWriter*                m_pRpDataWriter;	///< 应答数据写入器(写入文件或则Buf)
	CHttpCookieReadWriter*		m_pCookieReadWriter;///< Cookie读写器		
	CHttpTCPConnector*			m_pTcpConnector;	///< TCP连接器	
	CHttpChunker*				m_pChunker;			///< 块接收管理器

    uint32                      m_uNextTimeToNotifyProgress;
	boolean						m_bAutoResume;		///<是否自动续传
	boolean						m_bReuseTCP;		
	xp::strutf8					m_strsockIP; 
	uint16						m_wsockPort;

	xp::strutf8					m_strIp2Bind;//绑定本机指定网卡的IP地址上
	uint16						m_wPort2Bind;

	boolean						m_UseGBKHead;		///<采用GBK头
	boolean						m_bWithCookie;		///<是否带Cookie
	boolean						m_bSynNotifyRedirect;//notify redirect use syn model
	uint8						m_cNotifyEventMask;

	//下一步动作指定
	enum emNextToStep
	{
		NEXTSTEP_NONE       = 0,
		NEXTSTEP_RECONNECT	= 1,
		NEXTSTEP_EXIT		= 2,
	};

	emNextToStep				m_eNextStep;		///< 下一步动作指示
	uint32						m_dwErrorCode;		///< 运行状态
	IHttpClientSink*            m_pSink;
	
    CScopePtr<CXPTaskBase>      m_pMainTask;
	CScopePtr<CXPTaskIO>		m_pTask;
	CXPITCPSocket*				m_pSocket;
	boolean						m_bSocketAttached;
	
	
	xp::strutf8					m_strRqHead;
	uint32						m_nHeadSendPos;
	boolean						m_bSendMultiPartFormDataTail;
	uint32						m_dwContentLen;
    uint32                      m_nRetryTimes;
    
    boolean                     m_bNeedBuildRq;
    CXPLock                     m_lockForTask;

protected:
	uint64				m_uLogId;			///< LogId由于区别每一个Url的拉取过程
    uint32              m_dwConnTimeout;
    uint32              m_dwRecvTimeout;
    boolean             m_bUseProxy;
private:
	boolean				m_bNeedRetryNoProxy;
};