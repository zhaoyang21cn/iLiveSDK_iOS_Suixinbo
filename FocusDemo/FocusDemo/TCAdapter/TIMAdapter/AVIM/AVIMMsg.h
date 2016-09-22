//
//  AVIMMsg.h
//  TCShow
//
//  Created by AlexiChen on 16/4/15.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

// 直播过程中，消息列表中显示的聊天消息类型
@interface AVIMMsg : NSObject<AVIMMsgAble>
{
@protected
    id<IMUserAble>  _sender;            // 发送者
    
@protected
    NSString        *_msgText;         // 消息内容
}

@property (nonatomic, readonly) id<IMUserAble> sender;
@property (nonatomic, readonly) NSString *msgText;

- (instancetype)initWith:(id<IMUserAble>)sender message:(NSString *)text;
- (instancetype)initWith:(id<IMUserAble>)sender customElem:(TIMCustomElem *)elem;
@end



@interface AVIMCMD : NSObject<AVIMMsgAble>

@property (nonatomic, strong) id<IMUserAble> sender;            // 发送的时候可不填，IM会在TIMMessage带上发送者信息
@property (nonatomic, assign) NSInteger userAction;             // 对应AVIMCommand命令字，必填字段
@property (nonatomic, strong) NSString *actionParam;            // 自定义参数字段，可为空，为空不传

- (instancetype)initWith:(NSInteger)command;
- (instancetype)initWith:(NSInteger)command param:(NSString *)param;
#if kSupportCallScene
+ (instancetype)parseCustom:(TIMCustomElem *)elem;
#endif

// 将消息封装成Json，然后下发
- (NSData *)packToSendData;

@end


