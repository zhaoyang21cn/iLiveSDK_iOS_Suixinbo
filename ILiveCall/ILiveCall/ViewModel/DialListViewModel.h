//
//  DialListViewModel.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewModelAble.h"

@interface DialSessionViewModel : NSObject<DialSessionAble>

- (NSString*)getSessionName;

- (NSDate*)getLastCallTime;

- (NSString*)getUserId;

@end


@interface DialListViewModel : NSObject<DialListAble>

- (NSArray<DialSessionAble>*)getDialList;

- (void)deleteSession:(NSString *)userId;

@end
