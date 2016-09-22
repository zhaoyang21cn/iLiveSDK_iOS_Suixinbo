//
//  TCAVLogManager.m
//  TCShow
//
//  Created by wilderliao on 16/8/1.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#if kTCAVLogSwitch

#import "TCAVLogManager.h"

@interface TCAVLogManager ()
{
    NSString    *_logPath;
    NSDateFormatter *_currenrTimeFormatter;
    NSDateFormatter *_logNameFormatter;
}
@end

@implementation TCAVLogManager

static TCAVLogManager *_shareInstance;

+ (instancetype)shareInstance
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _shareInstance = [[TCAVLogManager alloc] init];
        [_shareInstance initLogInfo];
    });
    return _shareInstance;
}

- (void)initLogInfo
{
    _logPath = [self getCachePath];
    
    _currenrTimeFormatter = [[NSDateFormatter alloc] init];
    [_currenrTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    _logNameFormatter = [[NSDateFormatter alloc] init];
    [_logNameFormatter setDateFormat:@"yyyyMMdd"];
    
    [self clearLog7DaysAgo];
}

- (void)clearLog7DaysAgo
{
    NSString *cachePath = [self getCachePath];
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:nil];
    
    for (NSString *filename in tmplist)
    {
        if ( ![filename containsString:@"sxblog_"] )
        {
            continue;
        }
        if ( ![[filename pathExtension] isEqualToString:@"log"] )
        {
            continue;
        }
        
        NSString *fullpath = [cachePath stringByAppendingPathComponent:filename];
        if ( ![PathUtility isExistFile:fullpath] )
        {
            continue;
        }
        
        NSDictionary *fileAttri = [PathUtility getFileAttributsAtPath:fullpath];
        NSDate *fileCreateDate = [fileAttri objectForKey:NSFileCreationDate];
        
        if ([fileCreateDate timeIntervalSinceNow] > -7 * 24 * 60 * 60)
        {
            [PathUtility deleteFileAtPath:fullpath];
        }
    }
}

- (void)logTo:(NSString *)log
{
    //0:关闭日志输出 1:输出到控制台 2:输出到日志文件 3:输出到控制台和文件
    switch (kTCAVLogSwitch)
    {
        case 0:
            break;
        case 1:
            [self logToConsole:log];
            break;
        case 2:
            [self logToFile:log];
            break;
        case 3:
            [self logToConsole:log];
            [self logToFile:log];
            break;
        default:
            break;
    }
}

- (void)logToFile:(NSString *)log
{
    [self writeFile:[NSString stringWithFormat:@"%@ %@\n", [self getCurrentTime], log]];
}

- (void)logToConsole:(NSString *)log
{
    DebugLog(@"%@", log);
}

- (NSString *)getCurrentTime
{
    NSDate *date = [NSDate date];
    
    NSString *strTime = [_currenrTimeFormatter stringFromDate:date];
    
    return strTime;
}

- (NSString *)getLogPath
{
    return _logPath;
}

- (NSString *)getCachePath
{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    return cachePath;
}

- (NSString *)logFileName
{
    //获取系统当前时间
    NSDate *date = [NSDate date];
    
    NSString *strTime = [_logNameFormatter stringFromDate:date];
    
    NSString *logFileName = [NSString stringWithFormat:@"sxblog_%@.log", strTime];
    
    return logFileName;
}

- (BOOL)isExistFile:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

- (NSString *)getLogFullPath
{
    NSString *logPath =[self getLogPath];
    NSString *filePath = [logPath stringByAppendingPathComponent:[self logFileName]];
    
    if ( ![self isExistFile:filePath] )
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return filePath;
}

- (void)writeFile:(NSString *)text
{
    NSString *filePath = [self getLogFullPath];

    NSFileHandle  *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    //定位到文件末尾
    [fileHandle seekToEndOfFile];
    
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    [fileHandle writeData:data];
    
    [fileHandle closeFile];
}

@end

#endif