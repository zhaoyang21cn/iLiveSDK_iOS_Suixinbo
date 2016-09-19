//
//  Cache.h
//  DiskBasedCache
//
//  Created by 林潇聪 on 15/10/21.
//  Copyright © 2015年 林潇聪. All rights reserved.
//

#import  <Foundation/Foundation.h>


@interface Entry: NSObject
    @property(nonatomic) int resp_status_code;
    @property(nonatomic, copy) NSString* resp_content_type;
    @property(nonatomic, copy) NSString* resp_location;
    @property(nonatomic, strong) NSMutableArray* resp_set_cookie;
    @property(nonatomic, copy) NSString* resp_date;
    @property(nonatomic, copy) NSString* resp_server;
    @property(nonatomic, copy) NSString* resp_via;
    @property(nonatomic, strong) NSMutableArray* resp_x_cache;
    @property(nonatomic, strong) NSMutableArray* resp_x_cache_lookup;
    @property(nonatomic, copy) NSString* resp_last_modified;
    @property(nonatomic, copy) NSString* resp_etag;
    @property(nonatomic, strong) NSMutableArray* resp_cache_control;
    @property(nonatomic, copy) NSString* resp_expires;
    @property(nonatomic, copy) NSString* resp_pragma;
    @property(nonatomic) int64_t resp_age;
    @property(nonatomic) int64_t resp_cache_max_age;
    @property(nonatomic) int64_t resp_cache_max_stale_age;
    @property(nonatomic) time_t ttl;      // 过期的时间戳
    @property(nonatomic) time_t softTtl;  // 需要刷新的时间戳
    @property(nonatomic, copy) NSString* resp_content_charset;
    @property(nonatomic, strong) NSMutableDictionary* responseHeaders;
    @property(nonatomic, strong) NSMutableData* body;
@end

@protocol Cache <NSObject>

- (Entry*) get:(NSString*)key;
- (void) put:(NSString*)key Entry:(Entry*)entry;
- (void) access:(NSString*)key;  // update access time
- (BOOL) isRefreshNeeded:(Entry*)entry;
- (BOOL) isExpired:(Entry*)entry;
- (void) remove:(NSString*)key;
- (void) clear;

@end
