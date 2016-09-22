//
//  AVFrameDispatcher.h
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-4.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVGLBaseView.h"

#import "AVGLImage.h"
/**
 *  视频帧
 */
@interface AVFrameInfo : NSObject{
    NSUInteger _data_type;
    NSUInteger _width;
    NSUInteger _height;
    NSInteger  _rotate;
    NSInteger  _source_type;
    BOOL   _is_rgb;
    BOOL   _is_check_format;
    NSUInteger _room_id;
    NSString*  _identifier;
    NSData*    _data;
}
@property (assign,nonatomic) NSUInteger data_type;
@property (assign,nonatomic) NSUInteger width;
@property (assign,nonatomic) NSUInteger height;
@property (assign,nonatomic) NSInteger  rotate;
@property (assign,nonatomic) NSInteger  source_type;
@property (assign,nonatomic) BOOL   is_rgb;

@property (assign,nonatomic) BOOL   is_check_format;
@property (assign,nonatomic) NSUInteger room_id;
@property (copy,nonatomic)   NSString*  identifier;
@property (retain,nonatomic) NSData*    data;
@end

@class QAVVideoFrame;
/**
 *  负责画面帧分发
 */
@interface AVFrameDispatcher  : NSObject
/**
 *  分发函数，上层可以重写这个函数以实现不同的渲染规则
 *
 *  @param aFrame       帧对象
 *  @param isSubFrame 是否属于子画面
 */
-(void)dispatchVideoFrame:(QAVVideoFrame *)aFrame isSubFrame:(BOOL)isSubFrame format:(ENDataFormat)format;
@end

/**
 *  将是有的帧发到一个渲染器中渲染
 */
@interface AVSingleFrameDispatcher  : AVFrameDispatcher {
    
}
@property (retain,nonatomic) AVGLBaseView* imageView;
@end





