//
//  AVIMMsg.m
//  TCShow
//
//  Created by AlexiChen on 16/4/15.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AVIMMsg.h"

@implementation AVIMMsg

- (instancetype)initWith:(id<IMUserAble>)sender message:(NSString *)text
{
    if (self = [super init])
    {
        _sender = sender;
        _msgText = text;
    
    }
    return self;
}

- (instancetype)initWith:(id<IMUserAble>)sender customElem:(TIMCustomElem *)elem
{
    if (self = [super init])
    {
        _sender = sender;
        
        
        // TODO：子类处理自定义内容
        
    }
    return self;
}

- (void)prepareForRender
{
    // TODO:子类将用于显示的内容在此方法中数据缓存起来，不要在主线程中去计算（当IM消息量很大时，在主线程中去计算，主线程会抢占AVSDK采集线程，导致直播效果差）
}

- (NSInteger)msgType
{
    return AVIMCMD_Text;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"sender = %@ text = %@", [_sender imUserId], _msgText];
}

@end


@implementation AVIMCMD

- (instancetype)initWith:(NSInteger)command
{
    if (self = [super init])
    {
        _userAction = command;
    }
    return self;
}
- (instancetype)initWith:(NSInteger)command param:(NSString *)param
{
    if (self = [super init])
    {
        _userAction = command;
        _actionParam = param;
    }
    return self;
}
#if kSupportCallScene
+ (instancetype)parseCustom:(TIMCustomElem *)elem
{
    NSData *data = elem.data;
    if (data)
    {
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        AVIMCMD *parse = [NSObject parse:[AVIMCMD class] jsonString:dataStr];
        if (parse.msgType > AVIMCMD_None)
        {
            NSDictionary *dic = [parse.actionParam objectFromJSONString];
            parse.callInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
            return parse;
        }
    }
    
    DebugLog(@"自定义消息不是AVIMCMD类型");
    return nil;
    
}
#endif

- (NSData *)packToSendData
{
    NSMutableDictionary *post = [NSMutableDictionary dictionary];
    [post setObject:@(_userAction) forKey:@"userAction"];
    
    if (_actionParam && _actionParam.length > 0)
    {
        [post setObject:_actionParam forKey:@"actionParam"];
    }
    
    if ([NSJSONSerialization isValidJSONObject:post])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:post options:NSJSONWritingPrettyPrinted error:&error];
        if(error)
        {
            DebugLog(@"[%@] Post Json Error: %@", [self class], post);
            return nil;
        }
        
        DebugLog(@"AVIMCMD content is %@", post);
        return data;
    }
    else
    {
        DebugLog(@"[%@] AVIMCMD is not valid: %@", [self class], post);
        return nil;
    }
}

- (void)prepareForRender
{
    // 因不用于显示，作空实现
    // do nothing
}

- (NSInteger)msgType
{
    return _userAction;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"sender = %@ action = %d", [_sender imUserId], (int)_userAction];
}
@end







