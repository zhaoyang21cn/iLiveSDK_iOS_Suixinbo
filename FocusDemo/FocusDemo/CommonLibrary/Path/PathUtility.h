//
//  PathUtility.h
//  
//
//  Created by Alexi on 12-11-4.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathUtility : NSObject

// 获取文件的文档目录路径
+ (NSString *)getFileDocumentPath:(NSString *)fileName;

// 获取文件在cache目录的路径
+ (NSString *)getFileCachePath:(NSString *)fileName;

// 获取资源文件的路径
+ (NSString *)getFileResourcePath:(NSString *)fileName;

// 将资源文件拷贝到文档目录下
+ (BOOL)copyResourceFileToDocumentPath:(NSString *)resourceName;

// 判断一个文件是否存在于document目录下
+ (BOOL)isExistFileInDocument:(NSString *)fileName;
// 判断一个文件是否存在于cache目录下
+ (BOOL)isExistFileInCache:(NSString *)fileName;

+ (BOOL)removeFolderInDocumet:(NSString *)aFolderNameInDoc;

//删除cache目录下的一个文件夹
+ (BOOL)removeFolderInCahe:(NSString *)aFolderNameInCahe;

//+ (BOOL)removeComicBookFolder:(NSInteger)bookId;

// 判断一个文件是否存在于resource目录下
+ (BOOL)isExistFileInResource:(NSString *)fileName;

// 判断一个全路径文件是否存在
+ (BOOL)isExistFile:(NSString *)aFilePath;

// 删除文件
+ (BOOL)deleteFileAtPath:(NSString *)filePath;

// 获取文件的属性集合
+ (NSDictionary *)getFileAttributsAtPath:(NSString *)filePath;

// 在document目录下创建一个目录
+ (BOOL)createDirectoryAtDocument:(NSString *)dirName;
// 在cache目录下创建一个目录
+ (BOOL)createDirectoryAtCache:(NSString *)dirName;

+ (BOOL)createDirectoryAtTemporary:(NSString *)dirName;

// 获取文档目录路径
+ (NSString *)getDocumentPath;
// 获取cache目录路径
+ (NSString *)getCachePath;

+ (NSString *)getTemporaryPath;

// 获取磁盘剩余空间的大小
+ (long long)getFreeSpaceOfDisk;

// 获取文件大小
+ (long long)getFileSize:(NSString *)filePath;

+ (BOOL)copySourceFile:(NSString *)sourceFile toDesPath:(NSString *)desPath;

+ (BOOL)moveSourceFile:(NSString *)sourceFile toDesPath:(NSString *)desPath;

+ (NSString *)reCorrentPathWithPath:(NSString *)path;

// 计算文件夹大小
+ (unsigned long long int)folderSize:(NSString *)folderPath;

//在iOS5 .1及以上防止文件被被备份到iCloud和iTunes上
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

+ (NSString *)imageCachePath;

@end
