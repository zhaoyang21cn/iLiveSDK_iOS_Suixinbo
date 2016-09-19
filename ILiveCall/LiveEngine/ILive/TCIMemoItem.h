//
//  TCIMemoItem.h
//  ILiveSDK
//
//  Created by AlexiChen on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QAVSDK/QAVCommon.h>

@interface TCIMemoItem : NSObject

// 记录Id
@property (nonatomic, copy) NSString *identifier;

// 是否有发音频。
@property(nonatomic, assign) BOOL isAudio;

// 是否有发来自摄像头或外部视频捕获设备的视频。
@property(nonatomic, assign) BOOL isCameraVideo;

// 是否有发来自屏幕的视频。
@property(nonatomic, assign) BOOL isScreenVideo;

// 视频显示区域
@property (nonatomic, assign) CGRect showRect;

// 创建占位记录
- (instancetype)initWithShowRect:(CGRect)rect;

// 创建真实记录
- (instancetype)initWith:(NSString *)uid showRect:(CGRect)rect;

- (BOOL)isPlaceholder;

- (BOOL)isValid;

@end
