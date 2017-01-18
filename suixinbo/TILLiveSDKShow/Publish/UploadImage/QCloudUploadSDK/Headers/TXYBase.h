//
//  TXYBase.h
//
//  Created by Tencent on 1/19/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/***************************** 用户请求任务结构 ********************************/
/**
 *  腾讯云所有上传任务的基类
 */
@interface TXYTask : NSObject <NSCoding>
/** 上传任务的唯一标示，内部维护 */
@property (nonatomic, assign, readonly)    int64_t               taskId;
/** 上传任务的唯一流水标示 */
@property (nonatomic, strong, readonly)    NSString              *flowId;
@end

/*!
 @enum TXYFileType enum
 @abstract 文件的类型.
 */
typedef NS_ENUM(NSInteger, TXYFileType)
{
    /** 未知 */
    TXYFileTypeUnkown=0,
    /** 图片文件 */
    TXYFileTypePhoto,
    /** 音频文件 */
    TXYFileTypeAudio,
    /** 视频文件 */
    TXYFileTypeVideo,
    /** 普通文件 cos系统维护**/
    TXYFileTypeFile,
};



/**
 *  腾讯云文件上传的基类，不可直接用做上传参数，
 *  必须使用TXYPhotoUploadTask或者TXYVideoUploadTask
 */
@interface TXYUploadTask : TXYTask <NSCoding>
/** 文件的路径，用户必填 */
@property (nonatomic, readonly)    NSString            *filePath;
/** 上传的空间 */
@property (nonatomic, strong, readonly)    NSString     *bucket;

/** 签名 */
@property (nonatomic, strong, readonly)    NSString     *sign;

/** 文件上传请求后通知用户业务后台的信息，用户选填 */
@property (nonatomic, readonly)    NSString            *msgContext;
@end

/**
 * 图片文件上传任务
 */
@interface TXYPhotoUploadTask : TXYUploadTask <NSCoding>

/** 待上传的image对象 */
@property (nonatomic, strong, readonly) NSData *imageData;
/** 是否是从内存对象直接上传 */
@property (nonatomic, assign, readonly) BOOL uploadUIImage;
/** 文件名 */
@property (nonatomic, strong, readonly) NSString *fileName;

/** 图片过期的时间，单位为相对发送时间的天数，用户选填 */
@property (nonatomic, assign, readonly)    unsigned int        expiredDate;

/** 通过这个字段自定义url：domain + fileId*/
@property (nonatomic, strong, readonly)   NSString             *fileId;

/*!
 * @brief 图片上传任务初始化函数(上传本地文件)
 * @param filePath 图片路径，必填
 * @param expiredDate 过期时间，选填
 * @param msgContext  通知用户业务后台的信息，选填
 * @param bucket 上传空间的名字
 * @param fileId 通过这个字段可以自定义url
 * @return TXYPhotoUploadTask实例
 */
- (instancetype)initWithPath:(NSString *)filePath
                        sign:(NSString*)sign
                      bucket:(NSString *)bucket
                 expiredDate:(unsigned int)expiredDate
                  msgContext:(NSString *)msgContext
                      fileId:(NSString *)fileId;

/*!
 * @brief 图片上传任务初始化函数(上传内存imageData对象),由于SDK会持有该对象，建议不要使用该接口传太大的对象
 * @param imageData 图片对象的数据，必填
 * @param fileName 文件名，必填
 * @param expiredDate 过期时间，选填
 * @param msgContext  通知用户业务后台的信息，选填
 * @param bucket 上传空间的名字
 * @param fileId 通过这个字段可以自定义url
 * @return TXYPhotoUploadTask实例
 */
- (instancetype)initWithImageData:(NSData *)imageData
                         fileName:(NSString *)fileName
                             sign:(NSString *)sign
                           bucket:(NSString *)bucket
                      expiredDate:(unsigned int)expiredDate
                       msgContext:(NSString *)msgContext
                           fileId:(NSString *)fileId;
@end

@class TXYVideoFileInfo;



/**
 * 文件上传任务
 */
@interface TXYFileUploadTask : TXYUploadTask <NSCoding>
/** 文件上传目录,相对路径 */
@property (nonatomic, readonly)    NSString            *directory;
/** 用户自定义属性，用户选填 */
@property (nonatomic, readonly)    NSString            *attrs;


/*!
 * @brief 文件上传任务初始化函数
 * @param filePath 文件路径，必填
 * @param attrs 文件属性，选填
 * @param uploadDirectory 上传文件到哪个目录
 * @param msgContext  通知用户业务后台的信息，选填
 * @return TXYFileUploadTask实例
 */
- (instancetype)initWithPath:(NSString *)filePath
                        sign:(NSString*)sign
                      bucket:(NSString *)bucket
             customAttribute:(NSString *)attrs
             uploadDirectory:(NSString*)directory
                  msgContext:(NSString *)msgContext;

@end


/**
 * 视频文件上传任务
 */
@interface TXYVideoUploadTask : TXYFileUploadTask <NSCoding>

/** 上传视频的属性，用户选填 */
@property(nonatomic, strong)     TXYVideoFileInfo     *videoInfo;


/*!
 * @brief 文件上传任务初始化函数
 * @param filePath 文件路径，必填
 * @param attrs 文件属性，选填
 * @param uploadDirectory 上传文件到哪个目录
 * @param videoInfo 视频信息
 * @param msgContext  通知用户业务后台的信息，选填
 * @return TXYFileUploadTask实例
 */
- (instancetype)initWithPath:(NSString *)filePath
                        sign:(NSString*)sign
                      bucket:(NSString *)bucket
             customAttribute:(NSString *)attrs
             uploadDirectory:(NSString*)directory
               videoFileInfo:(TXYVideoFileInfo*)videoInfo
                  msgContext:(NSString *)msgContext;


@end


/**
 *  腾讯云文件命令的基类，不可直接用做上传参数，
 *  必须使用具体子类，如TXYFileMoveCommand，TXYFileDeleteCommand或者TXYPhotoStatCommand
 */
@interface TXYCommandTask : TXYUploadTask
/** 操作URL，必填  */
@property (nonatomic, readonly)    NSString            *commandURL;

/** 如果文件url是自定义的，那么查询 */
@property (nonatomic, readonly)    NSString            *fileId;

/** 文件的类型 */
@property (nonatomic, readonly, assign)    TXYFileType          fileType;
/*!
 * @brief 初始化方法
 * @param commandURL 要操作的URL
 * @return TXYCommandTask实例
 */
- (instancetype)initWithURL:(NSString *)commandURL;


/**
 *  初始化方法
 *  如果文件的url是自定义的，那么查询必须使用fileId+bucket+fileType
 *
 *  @param fileId   文件ID
 *  @param bucket   文件所在的空间
 *  @param fileType 文件的类型
 */
- (instancetype)initWithFileId:(NSString *)fileId
                        bucket:(NSString *)bucket
                          sign:(NSString *)sign
                      fileType:(TXYFileType)fileType;

@end


/**
 *  文件复制命令
 */
@interface TXYFileCopyCommand : TXYCommandTask


@property (nonatomic, strong, readonly) NSString *destFileid;

/**
 *  初始化方法
 *  如果文件的url是自定义的，那么查询必须使用fileId+bucket+fileType
 *
 *  @param fileId       文件Id
 *  @param destFileId   复制文件的文件Id
 *  @param bucket       文件所在的空间
 *  @param fileType     文件的类型
 */
- (instancetype)initWithFileId:(NSString *)fileId
                    descFileId:(NSString *)destFileId
                        bucket:(NSString *)bucket
                          sign:(NSString *)sign
                      fileType:(TXYFileType)fileType;
@end


/**
 * 文件删除命令,视频不支持复制功能
 */
@interface TXYFileDeleteCommand : TXYCommandTask
@end


/**
 * 文件查询命令
 */
@interface TXYFileStatCommand : TXYCommandTask
@end



/***************************** 后台回包信息 ********************************/
/**
 * 后台回包的基类
 */
@interface TXYTaskRsp : NSObject
/** 任务描述代码，为retCode >= 0时标示成功，为负数表示为失败 */
@property (nonatomic, assign)    int                    retCode;
/** 任务描述信息 */
@property (nonatomic, strong)    NSString               *descMsg;
@end

@class TXYFileInfo;
/**
 * 图片上传任务的回包
 */
@interface TXYPhotoUploadTaskRsp : TXYTaskRsp
/** 成功后，后台返回图片的url，由上传模块维护 */
@property (nonatomic, strong)    NSString               *photoURL;
/** 成功后，后台返回图片文件的key*/
@property (nonatomic, strong)    NSString               *photoFileId;
/** 成功后，后台返回图片文件的信息*/
@property (nonatomic, strong)    TXYFileInfo            *photoInfo;
@end



/**
 * 普通上传任务的回包
 */
@interface TXYFileUploadTaskRsp : TXYTaskRsp
/** 成功后，后台返回文件的 access url */
@property (nonatomic, strong)    NSString               *fileURL;
/** 成功后，后台返回文件的key*/
@property (nonatomic, strong)    NSString               *fileId;

@end


/**
 * 视频上传任务的回包
 */
@interface TXYVideoUploadTaskRsp : TXYFileUploadTaskRsp
@end

/**
 *  文件复制命令的回包
 */
@interface TXYFileCopyCommandRsp : TXYTaskRsp
/** 复制图片的URL */
@property (nonatomic, strong)    NSString                *copiedURL;
/** 文件id */
@property (nonatomic, strong)    NSString                *fileId;
@end


/**
 *  文件删除命令的回包
 */
@interface TXYFileDeleteCommandRsp : TXYTaskRsp
@end


@class TXYFileInfo;
/**
 *  文件查询命令的回包
 */
@interface TXYFileStatCommandRsp : TXYTaskRsp
/** 成功时，图片基本信息 @see <TXYFileInfo> */
@property (nonatomic, strong)    TXYFileInfo       *fileInfo;
@end

@interface TXYVideoFileInfo : NSObject

/** 视频标题 */
@property (nonatomic, strong)    NSString        *title;
/** 视频描述 */
@property (nonatomic, strong)    NSString        *desc;
/** 0:先发后审 1：先审后发 */
@property (nonatomic, assign)    BOOL            isCheck;
/** 视频封面URL */
@property (nonatomic, strong)    NSString        *coverUrl;
///** 视频附加属性 */
//@property (nonatomic, strong)    NSDictionary    *reserveAttr;

@end

/**
 * 文件的基本信息
 */
@interface TXYFileInfo : NSObject

/** 查询文件的id */
@property (nonatomic, strong)    NSString        *fileId;
/** 查询文件的URL */
@property (nonatomic, strong)    NSString        *fileURL;
/** 查询文件的类型 */
@property (nonatomic, assign)    TXYFileType     fileType;
/** 查询图片的底色 */
@property (nonatomic, strong)    NSString        *photoRBG;
/** 额外的文件信息，详情参见开发文档 */
@property (nonatomic, strong)    NSDictionary    *extendInfo;

@end




/**
 * 创建目录
 */
@interface TXYCreateDir : TXYCommandTask
//是否覆盖相同名字的目录或文件
@property(nonatomic,readonly) BOOL overwrite;
//用户自定义的属性
@property(nonatomic,readonly) NSString * attrs;

- (instancetype) initWithPath:(NSString*)path;

/**
 *  初始化方法
 *
 *  @param path         目录路径（相对于bucket的路径）
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 *  @param overwrite    是否覆盖相同名字的目录或文件
 *  @param attrs        用户自定义的属性
 */
- (instancetype) initWithPath:(NSString*)path
                       bucket:(NSString*)bucket
                         sign:(NSString*)sign
                needOverWrite:(BOOL)overwrite
              customAttribute:(NSString*)attrs;
@end


typedef NS_ENUM(NSInteger, TXYObjectType)
{
    /** 目录 */
    TXYObjectDir = 0,
    /** 文件 */
    TXYObjectFile,
    /** Buckeet */
    TXYObjectBucket,
    /** 视频 */
    TXYObjectVideo,
};

/**
 * 删除目录或文件
 */
@interface TXYDelete : TXYCommandTask
//对象类型，目录/文件/Bucket
@property(nonatomic,readonly)TXYObjectType objectType;
- (instancetype) initWithPath:(NSString*)path;

/**
 *  初始化方法
 *
 *  @param path         目录路径（相对于bucket的路径）
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 *  @param objectType   类型
 */
- (instancetype) initWithPath:(NSString*)path
                       bucket:(NSString*)bucket
                         sign:(NSString*)sign
                   objectType:(TXYObjectType)objectType;
@end


/**
 * 查询目录或者文件
 */
@interface TXYStat : TXYCommandTask
//文件类型
@property(nonatomic,readonly)TXYObjectType objectType;

- (instancetype) initWithPath:(NSString*)path;

/**
 *  初始化方法
 *
 *  @param path         目录路径（相对于bucket的路径）
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 *  @param objectType   类型
 */
- (instancetype) initWithPath:(NSString*)path
                       bucket:(NSString*)bucket
                         sign:(NSString*)sign
                   objectType:(TXYObjectType)objectType;
@end



typedef NS_ENUM(NSInteger, TXYListPattern)
{
    /**目录和文件都拉取**/
    TXYListBoth= 0,
    /** 只拉取目录 */
    TXYListDirOnly,
    /** 只拉取文件 */
    TXYListFileOnly,
};

/**
 * 更新目录或者文件
 */
@interface TXYUpdate: TXYCommandTask
//用户自定义的属性
@property(nonatomic,strong) NSString *attrs;
//类型
@property(nonatomic,assign) TXYObjectType objectType;
//视频信息
@property(nonatomic,strong) TXYVideoFileInfo *videoFileInfo;

/**
 *  初始化方法
 *
 *  @param path         目录路径（相对于bucket的路径）
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 *  @param objectType   类型
 *  @param attrs        用户自定义的属性
 */
- (instancetype) initWithPath:(NSString*)path
                       bucket:(NSString*)bucket
                         sign:(NSString*)sign
                   objectType:(TXYObjectType)objectType
              customAttribute:(NSString*)attrs;

/**
 *  更新视频参数的方法（仅用于视频）
 *
 *  @param path         目录路径（相对于bucket的路径）
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 *  @param attrs        用户自定义的属性
 */
- (instancetype) initWithPath:(NSString *)path
                       bucket:(NSString *)bucket
                         sign:(NSString *)sign
              customAttribute:(NSString *)attrs
                videoFileInfo:(TXYVideoFileInfo *)videoFileInfo;
@end


/**
 * 遍历目录下的文件
 */
@interface TXYListDir: TXYCommandTask
//一次拉取多少条记录
@property(nonatomic,readonly) NSUInteger num;
//拉取方式
@property(nonatomic,readonly) TXYListPattern pattern;
//0正序， 1反序
@property(nonatomic,readonly) BOOL order;
//分页浏览的上下文
@property(nonatomic,readonly) NSString *pageContext;

/**
 *  初始化方法
 *
 *  @param path         目录路径（相对于bucket的路径）
 *  @param bucket       文件所在的空间
 *  @param sign         签名
 *  @param pattern      拉取方式
 *  @param order        0正序，1反序
 *  @param context      分页浏览的上下文
 */
- (instancetype) initWithPath:(NSString*)path
                       bucket:(NSString*)bucket
                         sign:(NSString*)sign
                       number:(NSUInteger)num
                  listPattern:(TXYListPattern)pattern
                        order:(BOOL)order
                  pageContext:(NSString*)context;
@end


/**
 * 按目录前缀匹配搜索
 */
@interface TXYSearch: TXYCommandTask
//一次拉取多少条记录
@property(nonatomic,readonly) NSUInteger num;

//分页浏览的上下文
@property(nonatomic,readonly) NSString *pageContext;

- (instancetype) initWithPath:(NSString*)path
                       bucket:(NSString*)bucket
                         sign:(NSString*)sign
                       number:(NSUInteger)num
                  pageContext:(NSString*)context;
@end

typedef NS_ENUM(NSInteger, TXYVideoFormat)
{
    /** 手机 */
    eF10 = 10,
    /** 标清 */
    eF20 = 20,
    /** 高清 */
    eF30 = 30,
};


typedef NS_ENUM(NSInteger, TXYTranscodeStat)
{
    eInvalid = 0,
    eTranscoding = 1,
    eTranscodeDone = 2,
    eTranscodeFail = 3,
};

typedef NS_ENUM(NSInteger, TXYCosVideoStatus)
{
    eDefault = 0,
    eUploading = 1,
    eCheckPass = 2,
    eCheckNotPass = 3,
    eCheckFail = 4,
};



/**
 * 视频文件的属性
 */
@interface TXYVideoListInfo : NSObject
// 不同码率转码状态
@property(nonatomic,strong) NSDictionary *transcodeStatus;
// 视频文件状态
@property(nonatomic,assign) TXYCosVideoStatus videoStatus;
// 视频时长
@property(nonatomic,assign) NSInteger timeLength;
// 转码视频url列表
@property(nonatomic,strong) NSDictionary *playUrl;
// 视频信息
@property(nonatomic,strong) TXYVideoFileInfo *videoInfo;
@end

/**
 * 单个目录文件的属性
 */
@interface TXYFileDirInfo : NSObject
//文件名和目录名
@property(nonatomic,strong) NSString *name;
//文件的大小
@property(nonatomic,assign) long long fileSize;
//文件的长度
@property(nonatomic,assign) long long fileLength;
//文件自定义属性
@property(nonatomic,strong) NSString *attrs;
//文件的摘要sha
@property(nonatomic,strong) NSString *sha;
//文件的创建时间
@property(nonatomic,assign) NSUInteger ctime;
//文件的修改时间
@property(nonatomic,assign) NSInteger mtime;
//文件的访问url
@property(nonatomic,strong) NSString *accessUrl;
//文件目录类型
@property(nonatomic,assign) TXYObjectType objectType;
//文件目录云端的路径
@property(nonatomic,strong) NSString *startPath;
//视频的信息
@property(nonatomic,strong) TXYVideoListInfo *videoListInfo;
@end

/**
 *  创建目录命令的回包
 */
@interface TXYCreateDirCommandRsp : TXYTaskRsp
//文件是否被覆盖
@property(nonatomic,assign) BOOL overwrite;
//文件的创建时间
@property(nonatomic,assign) NSInteger ctime;
//文件的访问url
@property(nonatomic,strong) NSString * accessUrl;
@end
/**
 *文件目录详情命令的回包
 */
@interface TXYStatCommandRsp : TXYTaskRsp
//单个文件目录信息
@property(nonatomic,strong) TXYFileDirInfo *fileDirInfo;
@end
/**
 *文件目录删除命令的回包
 */
@interface TXYDeleteCommandRsp : TXYTaskRsp

@end
/**
 *文件目录更新命令的回包
 */
@interface TXYUpdateCommandRsp : TXYTaskRsp

@end
/**
 *目录浏览命令的回包
 */
@interface TXYListDirCommandRsp : TXYTaskRsp
//目录个数
@property(nonatomic,assign) NSUInteger dirCount;
//文件个数
@property(nonatomic,assign) NSUInteger fileCount;
//文件目录属性列表
@property(nonatomic,strong) NSArray *fileDirInfoList;
//分页浏览目录的上下文，后台返回
@property(nonatomic,strong) NSString *pageContext;
//有无下一页数据
@property(nonatomic,assign) BOOL hasMore;
@end

@interface TXYSearchCommandRsp : TXYListDirCommandRsp

@end











