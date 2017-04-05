//
//  BaseRequest.h
//  
//
//  Created by Alexi on 14-8-4.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RequestPageParamItem : NSObject

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger pageSize;

@property (nonatomic, assign) BOOL canLoadMore;

- (NSDictionary *)serializeSelfPropertyToJsonObject;

@end

// =========================================

@class BaseRequest;
@class BaseResponse;
@class BaseResponseData;

typedef void (^RequestCompletionHandler)(BaseRequest *request);

@interface BaseRequest : NSObject
{
@protected
    BaseResponse            *_response;
    RequestCompletionHandler _succHandler;
    RequestCompletionHandler _failHandler;
}

@property (nonatomic, strong) BaseResponse *response;
@property (nonatomic, copy) RequestCompletionHandler succHandler;
@property (nonatomic, copy) RequestCompletionHandler failHandler;


- (instancetype)initWithHandler:(RequestCompletionHandler)succHandler;

- (instancetype)initWithHandler:(RequestCompletionHandler)succHandler failHandler:(RequestCompletionHandler)fail;

- (NSString *)hostUrl;
- (NSString *)url;

- (NSDictionary *)packageParams;

// 拼装成Json请求包
- (NSData *)toPostJsonData;

// 收到响应后作解析响应处理
- (void)parseResponse:(NSObject *)respJsonObject;

// 配置_response对应的类
- (Class)responseClass;

- (Class)responseDataClass;

// 解析返回的字典结构json
- (void)parseDictionaryResponse:(NSDictionary *)bodyDic;
- (BaseResponseData *)parseResponseData:(NSDictionary *)dataDic;


// 解析返回的数组结构json
- (void)parseArrayResponse:(NSArray *)bodyArray;



@end


@interface BaseResponseData : NSObject
@end



@interface BaseResponse : NSObject<NSObject>

// 对应json中返回的字段
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, copy) NSString *errorInfo;
@property (nonatomic, strong) BaseResponseData *data;

// 请求是否成功
- (BOOL)success;

// 请求失败时对应的提示语
- (NSString *)message;

@end

// =========================================
