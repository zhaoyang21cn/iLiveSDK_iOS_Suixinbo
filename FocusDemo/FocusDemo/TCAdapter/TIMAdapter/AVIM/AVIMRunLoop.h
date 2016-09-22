//
//  AVIMRunLoop.h
//  MsfSDK
//
//  Created by etkmao on 13-6-4.
//  Copyright (c) 2013年 etkmao. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AVIMRunLoop : NSObject
{
    NSThread    *_thread;
}

@property (nonatomic, readonly) NSThread *thread;

+ (AVIMRunLoop *)sharedAVIMRunLoop;
- (void)start;

@end

