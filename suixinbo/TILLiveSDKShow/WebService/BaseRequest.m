//
//  BaseRequest.m
//
//
//  Created by Alexi on 14-8-4.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//

#import "BaseRequest.h"

#import "NSObject+Json.h"

@implementation RequestPageParamItem

- (instancetype)init
{
    if (self = [super init])
    {
        _pageIndex = 0;
        _pageSize = 20;
        _canLoadMore = YES;
    }
    return self;
}

- (NSDictionary *)serializeSelfPropertyToJsonObject
{
    return @{@"pageIndex" : @(_pageIndex), @"pageSize" : @(_pageSize)};
}


@end


// =========================================

@implementation BaseRequest

- (void)dealloc
{
    NSLog(@"=========[%@] release成功>>>>>>>>>", NSStringFromClass([self class]));
}

- (instancetype)initWithHandler:(RequestCompletionHandler)succHandler
{
    if (self = [self init])
    {
        self.succHandler = succHandler;
    }
    return self;
}

- (instancetype)initWithHandler:(RequestCompletionHandler)succHandler failHandler:(RequestCompletionHandler)fail
{
    if (self = [self initWithHandler:succHandler]) {
        self.failHandler = fail;
    }
    return self;
}

- (NSString *)hostUrl
{
//    return @"https://sxb.qcloud.com/sxb_new/index.php?";
    return @"https://sxb.qcloud.com/sxb_dev/index.php?";
}

- (NSString *)url
{
    return nil;
}


- (BaseResponse *)response
{
    if (!_response)
    {
        _response = [[[self responseClass] alloc] init];
    }
    return _response;
}


- (NSDictionary *)packageParams
{
    return nil;
}
- (NSData *)toPostJsonData
{
    NSDictionary *dic = [self packageParams];
    // 转成Json数据
    if ([NSJSONSerialization isValidJSONObject:dic])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        if(error)
        {
            NSLog(@"[%@] Post Json Error: %@", [self class], dic);
        }
        else
        {
            NSLog(@"[%@] Post Json : %@", [self class], dic);
        }
        return data;
    }
    else
    {
        NSLog(@"[%@] Post Json is not valid: %@", [self class], dic);
    }
    return nil;
}


- (void)parseResponse:(NSObject *)respJsonObject
{
    if (respJsonObject)
    {
        NSLog(@"==========[%@]开始解析响应>>>>>>>>>", self);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // 子线程解析数据
            if (_succHandler)
            {
                // todo handle body
                if ([respJsonObject isKindOfClass:[NSDictionary class]])
                {
                    [self parseDictionaryResponse:(NSDictionary *)respJsonObject];
                }
                else if ([respJsonObject isKindOfClass:[NSArray class]])
                {
                    [self parseArrayResponse:(NSArray *)respJsonObject];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSString *msg = [NSString stringWithFormat:@"返回数据格式有误--> %@",respJsonObject];
                        [[ILiveSDK getInstance] iLiveLog:@"DEV" level:ILive_LOG_DEBUG pos:@"Baserequest->parseResponse" msg:msg ext:nil];
                            // 说明返回内容有问题
                            if (_failHandler)
                            {
                                _failHandler(self);
                            }
                        NSLog(@"==========[%@]开始解析响应完成>>>>>>>>>", self);
                    });
                }
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_response success])
                    {
                        if (_succHandler)
                        {
                            _succHandler(self);
                        }
                    }
                    else
                    {
                        NSString *msg = [NSString stringWithFormat:@"返回的数据有业务错误--> %@",[_response message]];
                        [[ILiveSDK getInstance] iLiveLog:@"DEV" level:ILive_LOG_DEBUG pos:@"Baserequest->parseResponse" msg:msg ext:nil];
                            // 返回的数据有业务错误
                            if (_failHandler)
                            {
                                _failHandler(self);
                            }
                    }
                    NSLog(@"==========[%@]开始解析响应完成>>>>>>>>>", self);
                });
            }
        });
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"返回数据为空--> %@",[self class]];
        [[ILiveSDK getInstance] iLiveLog:@"DEV" level:ILive_LOG_DEBUG pos:@"Baserequest->parseResponse" msg:msg ext:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 说明返回内容有问题
            if (_failHandler)
            {
                _failHandler(self);
            }
        });
    }
}

- (Class)responseClass;
{
    return [BaseResponse class];
}

- (Class)responseDataClass
{
    return [BaseResponseData class];
}

- (void)parseDictionaryResponse:(NSDictionary *)bodyDic
{
    _response = [[[self responseClass] alloc] init];
    _response.errorCode = [bodyDic[@"errorCode"] integerValue];
    _response.errorInfo = bodyDic[@"errorInfo"];
    
    NSDictionary *data = bodyDic[@"data"];
    _response.data = [self parseResponseData:data];
}

- (BaseResponseData *)parseResponseData:(NSDictionary *)dataDic
{
    return [NSObject parse:[self responseDataClass] dictionary:dataDic];
}

- (void)parseArrayResponse:(NSArray *)bodyDic
{
    
}

@end

// =========================================


@implementation BaseResponseData

@end


@implementation BaseResponse

- (instancetype)init
{
    if (self = [super init])
    {
        // 默认成功
        _errorCode = 0;
    }
    return self;
}

- (BOOL)success
{
    return _errorCode == 0;
}
- (NSString *)message
{
    return _errorInfo;
}

@end

// =========================================
