//
//  DialListViewModel.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "DialListViewModel.h"
#import "EngineHeaders.h"

@interface DialSessionViewModel()
@property (nonatomic,strong) TIMConversation * sess;
@end

@implementation DialSessionViewModel

- (NSString*)getSessionName
{
    return [_sess getReceiver];
}

- (NSString*)getUserId
{
    return [_sess getReceiver];
}

- (NSDate*)getLastCallTime
{
    NSArray * msgs = [_sess getLastMsgs:20];
    for (TIMMessage * msg in msgs) {
        return [msg timestamp];
    }
    
    return [NSDate date];
}

@end

@implementation DialListViewModel

- (NSArray<DialSessionAble>*)getDialList
{
    NSMutableArray<DialSessionAble> * arr = [[NSMutableArray<DialSessionAble> alloc] init];
    
    NSArray * sesslist = [[TIMManager sharedInstance] getConversationList];
    for (TIMConversation * sess in sesslist) {
        if ([sess getType] != TIM_C2C) {
            continue;
        }
        DialSessionViewModel * viewModel = [[DialSessionViewModel alloc] init];
        viewModel.sess = sess;
        
        [arr addObject:viewModel];
    }
    
    return arr;
}

- (void)deleteSession:(NSString*)userId
{
    [[TIMManager sharedInstance] deleteConversation:TIM_C2C receiver:userId];
}

@end
