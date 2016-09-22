//
//  QAVEndpoint+IMUserAble.m
//  TCShow
//
//  Created by AlexiChen on 16/4/15.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "QAVEndpoint+IMUserAble.h"

@implementation QAVEndpoint (AVMultiUserAble)

- (NSString *)imUserId
{
    return self.identifier;
}

- (NSString *)imUserIconUrl
{
    return nil;
}

- (NSString *)imUserName
{
    return nil;
}

- (NSString *)description
{
    return [self imUserId];
}


static NSString *const kQAVEndpointAVMultiUserState = @"kQAVEndpointAVMultiUserState";

static NSString *const kQAVEndpointAVInteractArea = @"kQAVEndpointAVInteractArea";
static NSString *const kQAVEndpointAVInvisibleInteractView = @"kQAVEndpointAVInvisibleInteractView";

static NSString *const kQAVEndpointAVCtrlState = @"kQAVEndpointAVCtrlState";


- (NSInteger)avCtrlState
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kQAVEndpointAVCtrlState);
    return [num integerValue];
}

- (void)setAvCtrlState:(NSInteger)avCtrlState
{
    objc_setAssociatedObject(self, (__bridge const void *)kQAVEndpointAVCtrlState, @(avCtrlState), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)avMultiUserState
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kQAVEndpointAVMultiUserState);
    return [num integerValue];
}

- (void)setAvMultiUserState:(NSInteger)avMultiUserState
{
    objc_setAssociatedObject(self, (__bridge const void *)kQAVEndpointAVMultiUserState, @(avMultiUserState), OBJC_ASSOCIATION_RETAIN);
}

- (CGRect)avInteractArea
{
    NSValue *num = objc_getAssociatedObject(self, (__bridge const void *)kQAVEndpointAVInteractArea);
    return [num CGRectValue];
}

- (void)setAvInteractArea:(CGRect)avInteractArea
{
    objc_setAssociatedObject(self, (__bridge const void *)kQAVEndpointAVInteractArea, [NSValue valueWithCGRect:avInteractArea], OBJC_ASSOCIATION_RETAIN);
}


- (UIView *)avInvisibleInteractView
{
    return  objc_getAssociatedObject(self, (__bridge const void *)kQAVEndpointAVInvisibleInteractView);
}

- (void)setAvInvisibleInteractView:(UIView *)avInvisibleInteractView
{
    objc_setAssociatedObject(self, (__bridge const void *)kQAVEndpointAVInvisibleInteractView, avInvisibleInteractView, OBJC_ASSOCIATION_ASSIGN);
}



@end


@implementation TCAVIMEndpoint



- (NSString *)imUserId
{
    return self.identifier;
}

- (NSString *)imUserIconUrl
{
    return nil;
}

- (NSString *)imUserName
{
    return self.identifier;
}

- (NSString *)description
{
    return [self imUserId];
}


- (instancetype)initWith:(QAVEndpoint *)ep
{
    if (self = [super init])
    {
        self.identifier = ep.identifier;
        self.avCtrlState += ep.isAudio ? EAVCtrlState_Mic : 0;
        self.avCtrlState += ep.isCameraVideo ? EAVCtrlState_Camera : 0;
    
    }
    return self;
}

- (instancetype)initWithID:(NSString *)uid
{
    if (uid.length == 0)
    {
        DebugLog(@"uid参不能为空");
        return nil;
    }
    
    if (self = [super init])
    {
        self.identifier = uid;
        self.avCtrlState += EAVCtrlState_Camera;
    }
    return self;
}

@end
