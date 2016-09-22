//
//  IMAHost+AVUserAble.m
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAHost+AVUserAble.h"

@implementation IMAHost (AVUserAble)

static NSString *const kIMAHostAVCtrlState = @"kIMAHostAVCtrlState";

- (NSInteger)avCtrlState
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kIMAHostAVCtrlState);
    return [num integerValue];
}

- (void)setAvCtrlState:(NSInteger)avCtrlState
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAHostAVCtrlState, @(avCtrlState), OBJC_ASSOCIATION_RETAIN);
    DebugLog(@"Host [%p] Ctrl State : %d", self, (int)avCtrlState);
}

- (BOOL)isCurrentLiveHost:(id<AVRoomAble>)room
{
    return [[self imUserId] isEqualToString:[[room liveHost] imUserId]];
}

@end


@implementation IMAHost (AVMultiUserAble)

static NSString *const kIMAHostAVMultiUserState = @"kIMAHostAVMultiUserState";

static NSString *const kIMAHostAVInteractArea = @"kIMAHostAVInteractArea";
static NSString *const kIMAHostAVInvisibleInteractView = @"kIMAHostAVInvisibleInteractView";

- (NSInteger)avMultiUserState
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kIMAHostAVMultiUserState);
    return [num integerValue];
}

- (void)setAvMultiUserState:(NSInteger)avMultiUserState
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAHostAVMultiUserState, @(avMultiUserState), OBJC_ASSOCIATION_RETAIN);
}

- (CGRect)avInteractArea
{
    NSValue *num = objc_getAssociatedObject(self, (__bridge const void *)kIMAHostAVInteractArea);
    return [num CGRectValue];
}

- (void)setAvInteractArea:(CGRect)avInteractArea
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAHostAVInteractArea, [NSValue valueWithCGRect:avInteractArea], OBJC_ASSOCIATION_RETAIN);
}


- (UIView *)avInvisibleInteractView
{
    return  objc_getAssociatedObject(self, (__bridge const void *)kIMAHostAVInvisibleInteractView);
}

- (void)setAvInvisibleInteractView:(UIView *)avInvisibleInteractView
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAHostAVInvisibleInteractView, avInvisibleInteractView, OBJC_ASSOCIATION_ASSIGN);
}

@end
