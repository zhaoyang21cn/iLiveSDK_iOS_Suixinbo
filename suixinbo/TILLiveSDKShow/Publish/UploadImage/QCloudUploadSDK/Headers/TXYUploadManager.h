//
//  TXYUploadManager.h
//  TXYUploadSDK
//
//  Created by Tencent on 1/21/15.
//  Copyright (c) 2015 Qzone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXYBase.h"


@class TXYUploadTaskQueue;

/*!
 @enum TXYCloudType enum
 @abstract 上传的云类型.
 */
typedef NS_ENUM(NSInteger, TXYCloudType)
{
    /*! 图片云  */
    TXYCloudTypeForImage = 0,
    /*! 文件云  */
    TXYCloudTypeForFile = 1,
    /*! 视频云  */
    TXYCloudTypeForVideo = 2,
};

/*!
 @enum TXYUploadTaskState enum
 @abstract 文件上传过程中的状态.
 */
typedef NS_ENUM(NSInteger, TXYUploadTaskState)
{
    /*! 任务等待中  */
    TXYUploadTaskStateWait = 0,
    /*! 任务连接中  */
    TXYUploadTaskStateConnecting,
    /*! 任务发送中  */
    TXYUploadTaskStateSending,
    /*! 任务暂停中  */
    TTXYUploadTaskStatePause,
    /*! 任务取消  */
    TTXYUploadTaskStateCancel,
    /*! 任务失败  */
    TXYUploadTaskStateFail,
    /*! 任务成功  */
    TXYUploadTaskStateSuccess,
};

/**
 *  签名校验的返回码
 */
typedef NS_ENUM(NSInteger, TXYSignatureRetCode){
    /** 有效签名 */
    TXYSignatureRetCodeValid = 0,
    /** 签名字符串的格式有问题 */
     TXYSignatureRetCodeInvalidFormat,
    /** 签名已经过期 */
    TXYSignatureRetCodeExpired,
    /** 签名中的appid与注册是的appid不匹配 */
    TXYSignatureRetCodeAppidMismatch,
};


/*!
 * @brief 文件上传完成回调
 * @param resp 文件上传回包  @see <TXYUploadTaskRsp>
 * @param context 文件上传的上下文，包括taskId,filePath等信息
 */
typedef void (^TXYUpCompletionHandler)(TXYTaskRsp *resp, NSDictionary *context);

/*!
 * @brief 文件上传进度回调
 * @param totalSize 文件总大小
 * @param sendSize 已发送文件大小
 * @param context 文件上传的上下文，包括taskId,filePath等信息
 */
typedef void (^TXYUpProgressHandler)(int64_t totalSize, int64_t sendSize, NSDictionary *context);

/*!
 * @brief 文件上传状态变化回调
 * @param state 上传文件任务状态 @see <TXYUploadTaskState>
 * @param sendSize 已发送大小
 * @param context 文件上传的上下文，包括taskId,filePath等信息
 */
typedef void (^TXYUpStateChangeHandler)(TXYUploadTaskState state, NSDictionary *context);

/*!
 * @brief 文件操作命令完成回调
 * @param resp 文件操作命令回包  @see <TXYFileCommandRsp>
 */
typedef void (^TXYUpCommandCompletionHandler)(TXYTaskRsp *resp);


/**!
 *  上传模块的接口类，允许多实例
 */
@interface TXYUploadManager : NSObject{
@private
    NSTimer              *_monitorTimer;
    TXYUploadTaskQueue   *_fileLocalQueue;
    NSMutableArray       *_commandLocalQueue;
    NSOperationQueue     *_fileUploadQueue;
    NSOperationQueue     *_commandUploadQueue;
    TXYCloudType         _cloudType;
    
}


/*!
 * @brief 上传SDK的版本号
 */
+ (NSString *)version;


/**
 *  检验签名的合法性
 *  @param sign 待检验的签名
 *  @return 签名验证的返回码
 */
+ (TXYSignatureRetCode)checkSign:(NSString*)appId sign:(NSString *)sign;

/*!
 * @brief 得到用户设备号的一个唯一ID,向腾讯云反馈问题的时候，提供这个id
 * @return 设备号ID
 */
+ (NSString *)getDeviceUniqueIdentifier;

/**
 *  @brief 把上传本地log给QCloud，遇到用户反馈的时候，可以帮助排查问题
 *
 *  @param beginDate 开始的日期，SDK只保持最多7天的日志，所以开始时间必须在当前日期7天之内。
 *  @param days     相对于开始日期，上传多少天的日志。最多不超过7天。
 * 
 *  @note beginDate这个参数为nil，将会自动上传最近一天的日志，days被忽略
 */
+ (BOOL)uploadLogFromDate:(NSDate *)beginDate numOfdays:(NSUInteger)days;

/*!
 * @brief TXYUploadManager构造函数
 * @param cloudType, 文件云，图片云、视频云
 * @param persistenceId TXYUploadManager实例对应的持久化id,id必须全局唯一,persistenceId为nil时，上传任务不持久化
 * @appId 用户注册的appId
 * @sigin 签名信息
 * @return TXYUploadManager实例
 */
- (instancetype)initWithCloudType:(TXYCloudType)cloudType persistenceId:(NSString *)persistenceId appId:(NSString*)appId;

/*!
 * @brief 上传视频或者图片任务,需要保证已经注册了appID和sign信息
 * @param task 待上传任务
 * @param complete 上传完成后的回调函数
 * @param progress 上传进度的回调函数
 * @param stateChange 上传任务状态变化回调函数
 * @return 添加成功返回YES，添加失败返回NO
 *
 * @note 对于历史上传任务，恢复执行必须调这个接口，重新传入回调
 */
- (BOOL)upload:(TXYUploadTask *)task
      complete:(TXYUpCompletionHandler)complete
      progress:(TXYUpProgressHandler)progress
   stateChange:(TXYUpStateChangeHandler)stateChange;

/*!
 * @brief  暂停指定上传任务
 * @param  taskId 上传任务id @see <TXYUploadTask> 里的taskId
 * @return 暂停成功返回YES，添加失败返回NO
 *
 * @note 任务已经上传完或者任务不存在，暂停会失败，暂停成功之后会通知TXYUploadTaskStatePause变化
 */
- (BOOL)pause:(int64_t)taskId;

/*!
 * @brief 暂停所有上传任务，需要使用resumeAll恢复任务，pauseAll
 */
- (void)pauseAll;

/*!
 * @brief  重新发送指定上传任务
 * @param  taskId 上传任务id @see <TXYUploadTask> 里的taskId
 * 
 * @note 失败和暂停的任务都可以调用该接口恢复执行，恢复历史任务使用使用upload接口
 */
- (void)resume:(int64_t)taskId;

/*!
 * @brief  重新发送所有上传任务
 *
 * @note 恢复所有失败和暂停的任务，历史任务不能调用此接口，而应该调用upload
 */
- (void)resumeAll;

/*!
 * @brief  取消上传任务
 * @param  taskId 上传任务id，@see <TXYUploadTask> 里的taskId
 * @return 取消成功返回YES，添加失败返回NO
 *
 * @note 任务已经上传完或者任务不存在，取消会失败，删除成功之后会通知TTXYUploadTaskStateCancel变化
 */
- (BOOL)cancel:(int64_t)taskId;

/*!
 * @brief 取消所有上传任务
 */
- (void)clear;

/*!
 * @brief  得到所有上传任务
 * @return 返回所有上传任务的数组，数据的元素是TXYUploadTask。
 */
- (NSArray *)uploadTasks;

/*!
 * @brief 发送文件操作命令，等待异步回调
 * @param command 上传命令
 * @param complete 命令发送的完成回调
 * @return 添加成功返回YES，失败返回NO。
 */
- (BOOL)sendCommand:(TXYCommandTask *)command
           complete:(TXYUpCommandCompletionHandler)complete;



/******************************** Demo 使用的接口 *****************************/

+ (void)switchEnvironment:(BOOL)isTest;

//+ (void)enableFileCloud:(BOOL)enable;
//
//+ (BOOL)supportFileCloud;

@end

