//
//  SqliteBasedCache.h
//  SqliteBasedCache
//
//  Created by 林潇聪 on 15/10/26.
//  Copyright © 2015年 林潇聪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Cache.h"

const uint32_t MAGIC_NUMBER = 0x20151026;

@interface SqliteBasedCache : NSObject <Cache> {
    NSString *_rootDir;
    NSString *_dbPath;
    long     _maxCacheSize;
    BOOL     _isInitialized;
    sqlite3  *_db;
}

+ (id) getInstance;
- (void) initialize;
- (void) setMaxSize:(size_t)maxSize;

@end
