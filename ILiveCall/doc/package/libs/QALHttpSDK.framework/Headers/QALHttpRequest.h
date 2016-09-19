//
//  QALHttpRequest.h
//  QALHttpSDK
//
//  Created by wtlogin on 15/10/10.
//  Copyright (c) 2015年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QALHTTPRequestDelegate.h"
#import <QALSDK/QalSDKCallbackProtocol.h>
#import "Cache.h"
#import "SqliteBasedCache.h"





@interface QALHttpRequest : NSObject<QalReqCallbackProtocol>

//请求字段


//http请求的完整url
@property (strong,nonatomic) NSURL* request_baseURL;

//http请求方法
@property (strong,nonatomic) NSString* request_method;

//
@property (strong,nonatomic) NSMutableDictionary* request_header_dic;

@property (strong,nonatomic) NSData* request_http_body;

@property (strong,nonatomic) id<QALHTTPRequestDelegate> _cb;

@property (strong,nonatomic) NSString* request_charset;

@property (strong,nonatomic) NSMutableDictionary* request_post_dic;

@property (strong,nonatomic) NSString* request_content_type;

@property (strong,nonatomic) NSString* request_accept;

@property (strong,nonatomic) NSString* request_accept_language;

@property (strong,nonatomic) NSString* request_accept_charset;

@property (strong,nonatomic) NSString* request_user_agent;

@property (strong,nonatomic) NSString* request_cookie;

@property (strong,nonatomic) NSString* request_referer;

@property (strong,nonatomic) NSString* request_origin;

@property (strong,nonatomic) NSString* request_x_requested_with;

@property (strong,nonatomic) NSString* request_if_modified_since;

@property (strong,nonatomic) NSString* request_if_unmodified_since;

@property (strong,nonatomic) NSString* request_if_none_match;

@property (strong,nonatomic) NSString* request_if_match;

@property (strong,nonatomic) NSMutableArray* request_cache_control;

@property (strong,nonatomic) NSString* request_pragma;





//回包字段

@property int resp_status_code;

@property (strong,nonatomic) NSString* resp_content_type;

@property (strong,nonatomic) NSString* resp_location;

@property (strong,nonatomic) NSMutableData* resp_body;

@property (strong,nonatomic) NSMutableArray* resp_set_cookie;

@property (strong,nonatomic) NSMutableDictionary* resp_headers;

@property (strong,nonatomic) NSString* resp_date;

@property (strong,nonatomic) NSString* resp_server;

@property (strong,nonatomic) NSString* resp_via;

@property (strong,nonatomic) NSMutableArray* resp_x_cache;

@property (strong,nonatomic) NSMutableArray* resp_x_cache_lookup;

@property  uint32_t age;

@property (strong,nonatomic) NSString* resp_last_modified;

@property (strong,nonatomic) NSString* resp_etag;

@property (strong,nonatomic) NSMutableArray* resp_cache_control;

@property (strong,nonatomic) NSString* resp_expires;

@property (strong,nonatomic) NSString* resp_pragma;

@property (strong,nonatomic) NSString* resp_charset;


@property int64_t resp_cache_max_age;

@property int64_t resp_cache_max_stale_age;

//Cache

//@property (strong,nonatomic) SqliteBasedCache* cache;

@property (nonatomic) Entry* cache_entry;
@property uint32_t isCacheFind;
@property (strong,nonatomic) NSMutableArray* frags;
@property (nonatomic) int local_total_length;
@property (nonatomic) int curr_total_length;
@property (strong,nonatomic) NSData* frag_head;
@property (strong,nonatomic) NSLock* frag_lock;
@property (nonatomic) int seq;
@property (strong,nonatomic) NSTimer* timer;









+ (void)init;

+ (void)setCacheMaxSize:(size_t)size;

-(void) initCache;

/*
 初始化QALHttpRequest对象
 @param newURL http请求的uri
 */
- (id)initWithURL:(NSURL *)newURL;

/*
 设置请求方法
 @param newRequestMethod http请求方法:GET/POST,默认为GET
 */
- (void)setRequestMethod:(NSString *)newRequestMethod;

/*
 设置ContentType
 @param contentType http header里的contentType
 */
- (void)setContentType:(NSString*)contentType;

- (void)setAccept:(NSString*)accept;
- (void)setAcceptLanguage:(NSString*)acceptLanguage;
- (void)setAcceptCharset:(NSString*)acceptCharset;

/*
 增加自定义http header
 @param header header name
 @param value header content
 */
- (void)addRequestHeader:(NSString *)header value:(NSString *)value;

/*
 设置自定义Post Body
 @param body 自定义post body
 */
- (void)setBody:(NSData*)body;


- (void)setType:(int)type;

/*
 发起异步请求
 @
 */
- (void)startAsynchronous:(id<QALHTTPRequestDelegate>) cb;

- (void)setUserAgent:(NSString*)userAgent;

- (void)setCookie:(NSString *)cookie;

- (void)setReferer:(NSString *)referer;

- (void)setOrigin:(NSString *)origin;

- (void)setX_requested_with:(NSString *)x_requested_with;

- (void)setIf_modified_since:(NSString *)if_modified_since;

- (void)setIf_unmodified_since:(NSString *)if_unmodified_since;

- (void)setIf_match:(NSString *)if_match;

- (void)setIf_none_match:(NSString *)if_none_match;

- (void)addCache_control:(NSString *)cache_control;

- (void)setPragma:(NSString *)pragma;



//get回包字段方法


- (int)getResp_status_code;

- (NSString*)getResp_content_type;

- (NSString*)getLocation;

- (NSString*)getDate;

- (NSString*)getServer;

- (NSString*)getVia;

- (NSMutableArray*)getX_cache;

- (NSMutableArray*)getX_cache_lookup;

- (uint32_t)getAge;

- (NSString*)getLast_modified;

- (NSString*)getEtag;

- (NSMutableArray*)getResp_cache_control;

- (NSString*)getExpires;

- (NSString*)getResp_pragma;

- (NSMutableArray*)getResp_cookie;

- (NSMutableDictionary*)getResp_headers;

- (NSData*)getResp_body;

- (int64_t)getCache_max_age;

- (int64_t)getCache_max_stale_age;

- (NSString*)getRespString;


//分片相关函数

- (void)put_frags:(NSData*)frag;
- (bool)isFull;
- (void)merge_frags;
- (bool)isComplete;

- (void)onTimeout;


//json解析
@property (strong,nonatomic) NSMutableDictionary* jsonObject;














@end
