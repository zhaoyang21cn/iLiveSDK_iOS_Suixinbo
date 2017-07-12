//
//  ILiveFunc.h
//  ILiveSDK
//
//  Created by wilderliao on 17/3/17.
//  Copyright © 2017年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

//ILiveSDK通用的一些工具方法类

//生成云图Sig(从客户端拉取点播后台的录制列表时需要用到，secretId与secretKey，用户应严格保管，避免泄露)
@interface ILiveGenerateSig : NSObject

//公共参数
@property (nonatomic, strong) NSString *action;      //方法名
@property (nonatomic, assign) uint nonce;            //随机正整数
@property (nonatomic, strong) NSString *region;      //实例所在区域
@property (nonatomic, strong) NSString *secretId;    //密钥Id
@property (nonatomic, assign) NSInteger timestamp;   //当前时间戳

@property (nonatomic, strong) NSString *reqHost;     //请求主机域名
@property (nonatomic, strong) NSString *reqPath;     //请求路径
@property (nonatomic, assign) BOOL supportGet;       //是否支持GET方法获取 YES:GET NO:POST ,默认GET

@property (nonatomic, strong) NSString *secretKey;   //密钥
/**
 生成未经URL编码的签名串

 @param param 接口特有参数,key为参数名，value为参数值
 @return 未经编码的签名串
 */
- (NSString *)generateSig:(NSDictionary *)param;
//生成的签名串是URL编码的

/**
 生成URL编码的签名串
 @param param 接口特有参数，key为参数名，value为参数值
 @return URL编码的签名串
 */
- (NSString *)generateURLSig:(NSDictionary *)param;

@end
