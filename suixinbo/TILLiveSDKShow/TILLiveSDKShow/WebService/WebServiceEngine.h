//
//  WebServiceEngine.h
//  
//
//  Created by Alexi on 14-8-5.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseRequest;


@interface WebServiceEngine : NSObject
{
    NSURLSession *_sharedSession;
}

+ (instancetype)sharedEngine;

// 异步请求Req
- (void)asyncRequest:(BaseRequest *)req;

// 异步请求Req wait:是否加HUD同步等待
- (void)asyncRequest:(BaseRequest *)req wait:(BOOL)wait;

// 异步请求Req 关显示提示语msg wait:是否加HUD同步等待
- (void)asyncRequest:(BaseRequest *)req loadingMessage:(NSString *)msg wait:(BOOL)wait;




@end
