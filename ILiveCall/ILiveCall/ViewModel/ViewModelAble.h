//
//  ViewModelAble.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#ifndef ViewModelAble_h
#define ViewModelAble_h

#import "TCICallManager.h"

typedef NS_ENUM(NSInteger,CallType) {
    CALL_TYPE_NONE      = 0,
    CALL_TYPE_AUDIO     = 1,
    CALL_TYPE_VIDEO     = 2,
};

@protocol RecvCallListener <NSObject>
@required

- (void)onConnSucc;

- (void)onConnTimeout;

- (void)onConnFailed;

- (void)onPeerHangup;

@end

@protocol RecvCallAble <NSObject>
@required

@property(nonatomic,weak) id<RecvCallListener> listener;

- (void)accept;

- (void)refuse;

- (void)hangup;

- (CallType)getCallType;

- (BOOL)isAccepted;

- (NSString*)getPeer;

- (AVGLBaseView *)createAVGLViewIn:(UIViewController *)vc;

- (AVGLRenderView *)addRenderFor:(NSString *)uid atFrame:(CGRect)rect;

- (AVGLRenderView *)addSelfRender:(CGRect)rect;

@end

@protocol MakeCallListener <NSObject>
@required
- (void)onStartConn;

- (void)onConnAccepted;

- (void)onConnTimeout;

- (void)onConnRejected;

- (void)onConnFailed;

- (void)onPeerHangup;

@end

@protocol MakeCallAble <NSObject>
@required

@property(nonatomic,weak) id<MakeCallListener> listener;

- (void)dialUserWithAudio:(NSString*)userId;

- (void)dialUserWithVideo:(NSString*)userId;

- (void)hangup;

- (CallType)getCallType;

- (NSString*)getPeer;

- (BOOL)isWaitConn;

- (AVGLBaseView *)createAVGLViewIn:(UIViewController *)vc;

- (AVGLRenderView *)addRenderFor:(NSString *)uid atFrame:(CGRect)rect;

- (AVGLRenderView *)addSelfRender:(CGRect)rect;

@end

@protocol DialUserCellAble <NSObject>
@required

- (void)onDialUserChanged:(NSString*)userId path:(NSIndexPath*)path;

- (NSString*)getDialUser;

@end


@protocol HostInfoAble <NSObject>
@required

- (NSString*)getHostId;

- (NSString*)getHostNick;

@end

@protocol DialSessionAble <NSObject>
@required

- (NSString*)getSessionName;

- (NSDate*)getLastCallTime;

- (NSString*)getUserId;

@end

@protocol DialListAble <NSObject>
@required

- (NSArray<DialSessionAble>*)getDialList;

- (void)deleteSession:(NSString*)userId;

@end

@protocol SettingAble <NSObject>
@required

- (void)logout;

@end

#endif /* ViewModelAble_h */
