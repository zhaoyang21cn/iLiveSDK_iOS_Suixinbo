//
//  COSTask.h
//  COSClient
//
//  Created by 贾立飞 on 16/8/24.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

/***************************** 用户请求任务结构 ********************************/
/*!
 * @brief COSTask 上传任务的基础类
 */
@interface COSTask : NSObject<NSCoding>

/*! @brie 上传任务的唯一标示，内部维护 */
@property (nonatomic, assign, readonly)    int64_t               taskId;

@end


/**
 *  腾讯云文件上传的基类，不可直接用做上传参数，
 */
@interface COSUploadTask : COSTask <NSCoding>

/** 文件的路径，用户必填 */
@property (nonatomic, strong)    NSString *filePath;
/** 上传的空间 */
@property (nonatomic, strong)    NSString *bucket;
/**cos 文件在云端显示文件名称 */
@property (nonatomic, strong, readwrite)    NSString    *fileName;
/** 签名 */
@property (nonatomic, strong)    NSString *sign;
/** 文件上传目录,相对路径 */
@property (nonatomic, strong)    NSString *directory;
/** 文件上传请求后通知用户业务后台的信息，用户选填 */
@property (nonatomic, strong)    NSString *attrs;

@end


/***************************** 文件上传任务 ********************************/
@interface COSObjectPutTask : COSUploadTask <NSCoding>
@property (nonatomic, assign)    BOOL  insertOnly;
@property (nonatomic, assign)    BOOL  multipartUpload;
-(instancetype)init;

/*!
 * @brief 文件上传任务初始化函数
 * @param filePath 文件路径，必填
 * @param attrs 文件属性，选填
 * @param directory 上传文件到哪个目录
 * @param insert 上传动作是插入还是覆盖
 * @return COSFileUploadTask实例
 */
- (instancetype)initWithPath:(NSString *)filePath
                        sign:(NSString*)sign
                      bucket:(NSString *)bucket
                    fileName:(NSString *)fileName
             customAttribute:(NSString *)attrs
             uploadDirectory:(NSString*)directory
                  insertOnly:(BOOL)insert;

@end


@interface COSObjectMultipartPutTask : COSUploadTask <NSCoding>

@property (nonatomic, assign)    BOOL  insertOnly;


-(instancetype)init;

/*!
 * @brief 文件上传任务初始化函数
 * @param filePath 文件路径，必填
 * @param attrs 文件属性，选填
 * @param directory 上传文件到哪个目录
 * @param insert 上传动作是插入还是覆盖
 * @return COSFileUploadTask实例
 */
- (instancetype)initWithPath:(NSString *)filePath
                        sign:(NSString*)sign
                      bucket:(NSString *)bucket
                    fileName:(NSString *)fileName
             customAttribute:(NSString *)attrs
             uploadDirectory:(NSString*)directory
                  insertOnly:(BOOL)insert;

@end


@interface COSObjectMultipartResumePutTask : COSUploadTask <NSCoding>

@property (nonatomic, assign)    BOOL  insertOnly;

/*!
 * @brief 文件上传任务初始化函数
 * @param filePath 文件路径，必填
 * @param attrs 文件属性，选填
 * @param directory 上传文件到哪个目录
 * @param insert 上传动作是插入还是覆盖
 * @return COSFileUploadTask实例
 */
- (instancetype)initWithPath:(NSString *)filePath
                        sign:(NSString*)sign
                      bucket:(NSString *)bucket
                    fileName:(NSString *)fileName
             customAttribute:(NSString *)attrs
             uploadDirectory:(NSString*)directory
                  insertOnly:(BOOL)insert;

@end

/**
 *  腾讯云文件命令的基类，不可直接用做上传参数，
 */
@interface COSCommandTask : COSUploadTask

/** 操作URL，必填
*  /[bucket_name]/[dir_name]/[file_name]
*/
@property (nonatomic, readonly)    NSString  *commandURL;


/*!
 * @brief 初始化方法
 * @param commandURL 要操作的URL
 * @return CommandTask实例
 */
- (instancetype)initWithURL:(NSString *)commandURL;


/**
 *  初始化方法
 *  如果文件的url是自定义的，那么查询必须使用fileId+bucket+fileType
 *
 *  @param fileName   文件ID
 *  @param bucket   文件所在的空间
 */
- (instancetype)initWithFile:(NSString *)fileName
                      bucket:(NSString *)bucket
                   directory:(NSString*)dir
                        sign:(NSString *)sign;

@end

/**
 * 文件删除命令
 
 */
@interface COSObjectDeleteCommand : COSCommandTask

@end



//源站文件独立于bucket的权限
typedef NS_ENUM(NSInteger, COSAuthorityType)
{
    /**采用bucket的权限 */
    eInvalidAuth = 0,
    /**文件私有读写的权限 */
    eWRPrivateAuth = 1,
    /**文件私有写公有读的权限 */
    eWPrivateRPublicAuth = 2,
};


//文件是否被禁止
typedef NS_ENUM(NSInteger, COSForbidType)
{
    /**不禁止文件 */
    forbidNo = 0,
    /**禁止文件的读访问 */
    forbidRead = 0x01,
    /**禁止文件的写访问 */
    forbidWrite = 0x02,
};


/**
 * 文件更新
 */
@interface COSObjectUpdateCommand : COSCommandTask

//文件禁止类型//@property (nonatomic,assign) COSForbidType forbid;
//文件读写权限
@property(nonatomic,assign) COSAuthorityType authorityType;
//Custom_headers数据集合
@property(nonatomic,strong) NSDictionary * customHeader;

/*!
 * @brief 初始化方法
 * @return COSObjectUpdateCommand实例
 */

@end



/**
 * 文件查询命令
 */
@interface COSObjectMetaCommand : COSCommandTask



/*!
 * @brief 初始化方法
 * @return COSObjectMetaCommand实例
 */

@end



/***************************** 目录操作命令 ********************************/

/**
 * 创建目录
 */
@interface COSCreateDirCommand : COSCommandTask


///**
// *  初始化方法
// * @return COSCreateDirCommand实例
// */
//- (instancetype) init;

/**
 *  初始化方法
 *
 *  @param dir      目录路径（相对于bucket的路径）
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 *  @param attrs        用户自定义的属性
 * @return COSCreateDirCommand实例
 */
- (instancetype) initWithDir:(NSString*)dir
                       bucket:(NSString*)bucket
                         sign:(NSString*)sign
              attribute:(NSString*)attrs;
@end

/**
 * 目录列表
 */
@interface COSListDirCommand: COSCommandTask

/*! @brief
 * 返回的数目，默认为1000，最大1000
 */
@property(nonatomic,assign) NSUInteger num;

/*! @brief
 * 透传字段，查看第一页，则传空字符串。若需要翻页，需要将前一页返回值中的context透传到参数中。
 */
@property(nonatomic,strong) NSString *pageContext;

/*! @brief
 * 前缀查询。
 */
@property(nonatomic,strong) NSString *prefix;

/**
 *  初始化方法
 *
 *  @param path         目录路径（相对于bucket的路径）
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 *  @param context      分页浏览的上下文
 */
- (instancetype) initWithDir:(NSString*)path
                       bucket:(NSString*)bucket
                      prefix: (NSString *)prefix
                         sign:(NSString*)sign
                       number:(NSUInteger)num
                  pageContext:(NSString*)context;
@end

//typedef NS_ENUM(NSInteger, COSObjectType)
//{
//    /** 目录 */
//    TXYObjectDir = 0,
//    /** 文件 */
//    TXYObjectFile,
//    /** Bucket */
//    TXYObjectBucket,
//};

/**
 * 目录更新
 */
@interface COSUpdateDirCommand: COSCommandTask

/**
 *  初始化方法
 *
 *  @param path         目录路径（相对于bucket的路径）
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 *  @param attrs   类型
 */
- (instancetype) initWithDir:(NSString*)path
                      bucket:(NSString*)bucket
                        sign:(NSString*)sign
                   attribute:(NSString*)attrs;
@end

/**
 * 查询目录
 */
@interface COSDirmMetaCommand : COSCommandTask


/**
 *  初始化方法
 *
 *  @param path         目录路径（相对于bucket的路径）
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 */
- (instancetype) initWithDir:(NSString*)path
                       bucket:(NSString*)bucket
                         sign:(NSString*)sign;
@end

/**
 * 查询Bucket
 */
@interface COSBucketMetaCommand : COSCommandTask


/**
 *  初始化方法
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 */
- (instancetype) initWithBucket:(NSString*)bucket
                           sign:(NSString*)sign;
@end


/**
 * 查询Bucket 权限
 */
@interface COSBucketAclCommand : COSCommandTask


/**
 *  初始化方法
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 */
- (instancetype) initWithBucket:(NSString*)bucket
                           sign:(NSString*)sign;
@end

/**
 * 删除目录
 */
@interface COSDeleteDirCommand : COSCommandTask

/**
 *  初始化方法
 *
 *  @param path         目录路径（相对于bucket的路径）
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 */
- (instancetype) initWithDir:(NSString*)path
                       bucket:(NSString*)bucket
                        sign:(NSString*)sign;

@end

/***************************** 文件下载任务 ********************************/
@interface COSObjectGetTask : COSUploadTask <NSCoding>

-(instancetype)init;

/*!
 * @brief 文件上传任务初始化函数
 * @param filePath 文件路径，必填
 */
- (instancetype)initWithUrl:(NSString *)filePath;

@end
/***************************** 后台回包基础类********************************/
/**
 * 后台回包的基类
 */
@interface COSTaskRsp : NSObject
/** 任务描述代码，为retCode >= 0时标示成功，为负数表示为失败 */
@property (nonatomic, assign)    int                    retCode;
/** 任务描述信息 */
@property (nonatomic, strong)    NSString               *descMsg;

@property (nonatomic, strong)    NSDictionary           *data;
/** 成功后，后台返回文件数据*/
@property (nonatomic, strong)    NSDictionary           *fileData;

@end

/***************************** 后台回包信息类********************************/
/**
 * 普通上传任务的回包
 */
@interface COSObjectUploadTaskRsp : COSTaskRsp

/** 成功后，后台返回文件的 CDN url */
@property (nonatomic, strong)    NSString               *acessURL;
/** 成功后，后台返回文件的 源站 url */
@property (nonatomic, strong)    NSString               *sourceURL;
/** 成功后，后台返回文件的https url */
@property (nonatomic, strong)    NSString               *httpsURL;

@end

/**
 * 文件删除任务的回包
 */
@interface COSObjectDeleteTaskRsp : COSTaskRsp

@end

/**
 * 文件更新任务的回包
 */
@interface COSObjectUpdateTaskRsp : COSTaskRsp

@end

/**
 * 普通上传任务的回包
 */
@interface COSObjectMetaTaskRsp : COSTaskRsp
/** 成功后，后台返回文件的meta信息*/
//@property (nonatomic, strong)    NSDictionary           *data;
@end
/**
 * 普通上传任务的回包
 */
@interface COSDirMetaTaskRsp : COSTaskRsp
/** 成功后，后台返回文件的meta信息*/
//@property (nonatomic, strong)    NSDictionary           *data;
@end


/**
 * 普通上传任务的回包
 */
@interface COSCreatDirTaskRsp : COSTaskRsp
/** 成功后，后台返回文件的meta信息*/
//@property (nonatomic, strong)    NSDictionary           *data;
@end

/**
 * 普通上传任务的回包
 */
@interface COSUpdateDirTaskRsp : COSTaskRsp
/** 成功后，后台返回文件的meta信息*/
//@property (nonatomic, strong)    NSDictionary           *data;
@end

/**
 * 普通上传任务的回包
 */
@interface COSdeleteDirTaskRsp : COSTaskRsp
/** 成功后，后台返回文件的meta信息*/
//@property (nonatomic, strong)    NSDictionary           *data;
@end


/**
 * bucke信息查询的回包
 */
@interface COSBucketMetaRsp : COSTaskRsp
/** 成功后，后台返回文件的meta信息*/
//@property (nonatomic, strong)    NSDictionary           *data;
@end

/**
 * bucke权限查询的回包
 */
@interface COSBucketAclRsp : COSTaskRsp

/** 成功后，后台返回文件的meta信息*/
@property (nonatomic, strong)    NSString           *authority;

@end


/**
 * 普通上传任务的回包
 */
@interface COSDirListTaskRsp : COSTaskRsp

/** 翻页的标志*/
@property (nonatomic, strong)    NSString         *context;
/** true：list结束；false：还有数据*/
@property (nonatomic, strong)    NSString         *listover;
/** list 数组*/
@property (nonatomic, strong)    NSArray          *infos;
@end

/**
 * 普通上传任务的回包
 */
@interface COSGetObjectTaskRsp : COSTaskRsp

/** 下载数据*/
@property (nonatomic, strong)    NSMutableData         *object;
@end


