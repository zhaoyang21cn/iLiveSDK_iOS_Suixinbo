/*!
 
 @header COSClient.h
 
 @abstract 文件上传接口
 
 @author Created by baron on 16/1/24.
 
 @version 1.2.0 16/1/24 Creation
 
 */

#import <Foundation/Foundation.h>
#import "COSTask.h"

/*!
 * @brief 文件上传完成回调
 * @param resp 文件上传回包  @see <COSTaskRsp>
 * @param context 文件上传的上下文，包括taskId
 */
typedef void (^COSUploadCompletionHandler)(COSTaskRsp *resp, NSDictionary *context);

/*!
 */
typedef void (^COSUploadProgressHandler)(int64_t bytesWritten,
                                         int64_t totalBytesWritten,
                                         int64_t totalBytesExpectedToWrite);


typedef void (^COSDownloadProgressHandler)(int64_t receiveLength,int64_t contentLength);

/*!
 * @brief 文件操作命令完成回调
 * @param resp 文件操作命令回包  @see <COSTaskRsp>
 */
typedef void (^COSCommandCompletionHandler)(COSTaskRsp *resp);



@class COSUploadTaskQueue;
@interface COSClient : NSObject
{
    @private
     NSMutableDictionary * _resumeDictionary;
     COSUploadTaskQueue * _fileLocalQueue;
     NSOperationQueue * _fileUploadQueue;
     NSOperationQueue * _commandUploadQueue;
     NSMutableArray * _commandLocalQueue;

}

@property(nonatomic,strong) COSUploadCompletionHandler completionHandler;
@property(nonatomic,strong) COSUploadProgressHandler progressHandler ;
@property(nonatomic,strong) COSCommandCompletionHandler commandCompletionHandler ;
@property(nonatomic,strong) COSDownloadProgressHandler downloadProgressHandler ;

//地域
@property (nonatomic, strong) NSString   *region;
@property (nonatomic, strong) NSString   *log;

/*!
 @abstract SDK版本号
 @return 字符串了性的版本号
 */
+ (NSString *)version;


/*!
 @abstract 开启设置后上传和下载将使用https 请求
 */
-(void)openHTTPSrequset:(BOOL)open;

/*!
 @abstract 打开SDK log
 */
+ (void)openLog:(BOOL)open;


-(NSMutableDictionary *)listResumeTask;

/**
 初始化COSClient init方法

 @param appId appId在cos业务申请的业务id
 @param region 在cos业务使用的服务器位置上海：sh 广州：gz
 @return cosclient
 */
- (instancetype)initWithAppId:(NSString*)appId  withRegion:(NSString *)region;


/*!
 @abstract 文件上传方法
 @param task 文件上传任务
 */

- (BOOL)putObject:(COSObjectPutTask *)task;


/*!
 @abstract 文件分片断点续传上传
 @param task 文件续传的任务
 */
- (BOOL)ObjectResumePutMultipart:(COSObjectMultipartResumePutTask *)task;

/*!
 @abstract 文件下载函数
 @param command 文件下载任务
 */
- (BOOL)getObject:(COSObjectGetTask *)command;

/*!
 @abstract 文件删除载函数
 @param command 文件删除命令
 */
- (BOOL)deleteObject:(COSObjectDeleteCommand *)command;

/*!
 @abstract 文件查询函数
 @param command 文件信息查询
 */
- (BOOL)getObjectMetaData:(COSObjectMetaCommand *)command;

/*!
 @abstract 文件更新函数
 @param command 文件更新命令
 */
- (BOOL)updateObject:(COSObjectUpdateCommand *)command;

/*!
 @abstract 创建目录
 @param command 创建目录命令
 */
- (BOOL)createDir:(COSCreateDirCommand *)command;

/*!
 @abstract 目录文件列表
 @param command 查看目录列表命令
 */
- (BOOL)listDir:(COSListDirCommand *)command;

/*!
 @abstract  目录更新
 @param command 更新目录信息命令
 */
-(BOOL)updateDir:(COSUpdateDirCommand *)command;

/*!
 @abstract  删除目录
 @param command 删除目录的命令
 */
- (BOOL)removeDir:(COSDeleteDirCommand *)command;

/*!
 @abstract   获取目录信息
 @param command 查看目录信息的命令
 */
- (BOOL)getDirMetaData:(COSDirmMetaCommand *)command;

/*!
 @abstract   获取Bucke信息
 @param command 获取bucket的信息的命令
 */
- (BOOL)headBucket:(COSBucketMetaCommand *)command;

/*!
 @abstract   获取Bucke信息
 @param command 获取bucket的权限的命令
 */
- (BOOL)getBucketAcl:(COSBucketAclCommand *)command;

/*!
 * @brief  取消上传任务
 * @param  taskId 上传任务id，@see <COSTask> 里的taskId
 * @note 任务已经上传完或者任务不存在，取消会失败
 */

- (BOOL)cancel:(int64_t)taskId;


/*!
 * @brief  只能暂停指定上传分片任务
 * @param  taskId 上传任务id @see <COSTask> 里的taskId
 * @return 暂停成功返回YES，添加失败返回NO
 *
 * @note 任务已经上传完或者任务不存在，暂停会失败
 */
- (BOOL)pause:(int64_t)taskId;

/*!
 * @brief  继续上传暂停分片上传任务
 * @param  taskId 上传任务id @see <COSTask> 里的taskId
 *
 * @note 分片上传的任务可以暂停并恢复上传
 */
- (void)resume:(int64_t)taskId;



@end
