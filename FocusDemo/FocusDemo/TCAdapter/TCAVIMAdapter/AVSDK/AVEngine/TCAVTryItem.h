//
//  TCAVTryItem.h
//  TCShow
//
//  Created by AlexiChen on 16/5/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCAVTryItem : NSObject

@property (nonatomic, readonly) NSInteger   tryIndex;       // 作备标识
@property (nonatomic, assign) BOOL          isTrying;       // 是否正在Try
@property (nonatomic, assign) NSInteger     hasTryCount;    // 已重试次数
@property (nonatomic, assign) NSInteger     maxTryCount;    // 最大重试次数，默认1
@property (nonatomic, strong) id            result;         

- (instancetype)initWith:(NSInteger)index;

@end
