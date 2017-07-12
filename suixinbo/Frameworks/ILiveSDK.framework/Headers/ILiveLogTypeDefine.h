//
//  ILiveLogTypeDefine.h
//  ILiveSDK
//
//  Created by kennethmiao on 17/3/13.
//  Copyright © 2017年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 日志级别
 */
typedef NS_ENUM(NSInteger, ILiveLogLevel)
{
    ILive_LOG_NONE                = 0,
    ILive_LOG_ERROR               = 1,
    ILive_LOG_WARN                = 2,
    ILive_LOG_INFO                = 3,
    ILive_LOG_DEBUG               = 4,
};

/*
 * 日志上报错误码
 */
typedef NS_ENUM(NSInteger, ILiveLogUploadCode){
    ILLU_OK                     = 0,        //成功
    ILLU_ERR_PARAM              = 8101,     //参数错误
    ILLU_ERR_FILE_NOT_EXIST     = 8102,     //文件不存在
    ILLU_ERR_ZIP_FAILED         = 8103,     //文件压缩失败
    ILLU_ERR_SIGN_FAILED        = 8104,     //请求sign失败
    ILLU_ERR_PARSE_FAILED       = 8105,     //信息解析失败
    ILLU_ERR_UPLOAD_FAILED      = 8106,     //cos上传失败
    ILLU_ERR_FINISH_FAILED      = 8107,     //上报失败
};

/*
 * 上报回调函数
 * @param retCode  错误码
 * @param retMsg   错误信息
 * @param logKey   log唯一标识
 */
typedef void (^ILiveLogUploadResultBlock) (int retCode, NSString* retMsg, NSString* logKey);
