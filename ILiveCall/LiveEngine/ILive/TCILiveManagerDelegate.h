//
//  TCILiveManagerDelegate.h
//  ILiveSDK
//
//  Created by AlexiChen on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCILiveManagerDelegate <NSObject>

@required

// 返回没有自动处理的无程视频处理流程identifier
- (void)onRecvSemiAutoCameraVideo:(NSArray *)identifierList;

@end
