//
//  TIMUserProfile+IMUserAble.m
//  TCShow
//
//  Created by AlexiChen on 16/4/15.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TIMUserProfile+IMUserAble.h"

@implementation TIMUserProfile (IMUserAble)

// 两个用户是否相同，可通过比较imUserId来判断
// 用户IMSDK的identigier
- (NSString *)imUserId
{
    return self.identifier;
}

// 用户昵称
- (NSString *)imUserName
{
    return  self.nickname.length > 0 ? self.nickname : self.identifier;
}

// 用户头像地址
- (NSString *)imUserIconUrl
{
    return [NSString isEmpty:self.faceURL] ? nil : self.faceURL;
}

- (BOOL)isEqual:(id)object
{
    BOOL isEqual = [super isEqual:object];
    if (!isEqual)
    {
        if ([object conformsToProtocol:@protocol(IMUserAble)])
        {
            id<IMUserAble> io = (id<IMUserAble>)object;
            isEqual = [[self imUserId] isEqualToString:[io imUserId]];
        }
    }
    return isEqual;
}

static NSString *const kTIMUserProfileAVMultiUserState = @"kTIMUserProfileAVMultiUserState";

static NSString *const kTIMUserProfileAVInteractArea = @"kTIMUserProfileAVInteractArea";
static NSString *const kTIMUserProfileAVInvisibleInteractView = @"kTIMUserProfileAVInvisibleInteractView";

static NSString *const kTIMUserProfileAVCtrlState = @"kTIMUserProfileAVCtrlState";
- (NSInteger)avCtrlState
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kTIMUserProfileAVCtrlState);
    return [num integerValue];
}

- (void)setAvCtrlState:(NSInteger)avCtrlState
{
    objc_setAssociatedObject(self, (__bridge const void *)kTIMUserProfileAVCtrlState, @(avCtrlState), OBJC_ASSOCIATION_RETAIN);
}


- (NSInteger)avMultiUserState
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kTIMUserProfileAVMultiUserState);
    return [num integerValue];
}

- (void)setAvMultiUserState:(NSInteger)avMultiUserState
{
    objc_setAssociatedObject(self, (__bridge const void *)kTIMUserProfileAVMultiUserState, @(avMultiUserState), OBJC_ASSOCIATION_RETAIN);
}

- (CGRect)avInteractArea
{
    NSValue *num = objc_getAssociatedObject(self, (__bridge const void *)kTIMUserProfileAVInteractArea);
    return [num CGRectValue];
}

- (void)setAvInteractArea:(CGRect)avInteractArea
{
    objc_setAssociatedObject(self, (__bridge const void *)kTIMUserProfileAVInteractArea, [NSValue valueWithCGRect:avInteractArea], OBJC_ASSOCIATION_RETAIN);
}


- (UIView *)avInvisibleInteractView
{
    return  objc_getAssociatedObject(self, (__bridge const void *)kTIMUserProfileAVInvisibleInteractView);
}

- (void)setAvInvisibleInteractView:(UIView *)avInvisibleInteractView
{
    objc_setAssociatedObject(self, (__bridge const void *)kTIMUserProfileAVInvisibleInteractView, avInvisibleInteractView, OBJC_ASSOCIATION_ASSIGN);
}

@end


@implementation TIMGroupMemberInfo (IMUserAble)

// 两个用户是否相同，可通过比较imUserId来判断
// 用户IMSDK的identigier
- (NSString *)imUserId
{
    return self.member;
}

// 用户昵称
- (NSString *)imUserName
{
    return self.nameCard.length > 0 ? self.nameCard : self.member;
}

// 用户头像地址
- (NSString *)imUserIconUrl
{
    return nil;
}

- (BOOL)isEqual:(id)object
{
    BOOL isEqual = [super isEqual:object];
    if (!isEqual)
    {
        if ([object conformsToProtocol:@protocol(IMUserAble)])
        {
            id<IMUserAble> io = (id<IMUserAble>)object;
            isEqual = [[self imUserId] isEqualToString:[io imUserId]];
        }
    }
    return isEqual;
}



static NSString *const kTIMGroupMemberInfoAVMultiUserState = @"kTIMGroupMemberInfoAVMultiUserState";

static NSString *const kTIMGroupMemberInfoAVInteractArea = @"kTIMGroupMemberInfoAVInteractArea";
static NSString *const kTIMGroupMemberInfoAVInvisibleInteractView = @"kTIMGroupMemberInfoAVInvisibleInteractView";

static NSString *const kTIMGroupMemberInfoAVCtrlState = @"kTIMGroupMemberInfoAVCtrlState";
- (NSInteger)avCtrlState
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kTIMGroupMemberInfoAVMultiUserState);
    return [num integerValue];
}

- (void)setAvCtrlState:(NSInteger)avCtrlState
{
    objc_setAssociatedObject(self, (__bridge const void *)kTIMGroupMemberInfoAVMultiUserState, @(avCtrlState), OBJC_ASSOCIATION_RETAIN);
}


- (NSInteger)avMultiUserState
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kTIMGroupMemberInfoAVMultiUserState);
    return [num integerValue];
}

- (void)setAvMultiUserState:(NSInteger)avMultiUserState
{
    objc_setAssociatedObject(self, (__bridge const void *)kTIMGroupMemberInfoAVMultiUserState, @(avMultiUserState), OBJC_ASSOCIATION_RETAIN);
}

- (CGRect)avInteractArea
{
    NSValue *num = objc_getAssociatedObject(self, (__bridge const void *)kTIMGroupMemberInfoAVInteractArea);
    return [num CGRectValue];
}

- (void)setAvInteractArea:(CGRect)avInteractArea
{
    objc_setAssociatedObject(self, (__bridge const void *)kTIMGroupMemberInfoAVInteractArea, [NSValue valueWithCGRect:avInteractArea], OBJC_ASSOCIATION_RETAIN);
}


- (UIView *)avInvisibleInteractView
{
    return  objc_getAssociatedObject(self, (__bridge const void *)kTIMGroupMemberInfoAVInvisibleInteractView);
}

- (void)setAvInvisibleInteractView:(UIView *)avInvisibleInteractView
{
    objc_setAssociatedObject(self, (__bridge const void *)kTIMGroupMemberInfoAVInvisibleInteractView, avInvisibleInteractView, OBJC_ASSOCIATION_ASSIGN);
}

@end
