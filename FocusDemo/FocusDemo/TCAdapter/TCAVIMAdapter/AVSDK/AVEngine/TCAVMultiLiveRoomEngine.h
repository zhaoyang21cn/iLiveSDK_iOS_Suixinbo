//
//  TCAVMultiLiveRoomEngine.h
//  TCShow
//
//  Created by AlexiChen on 16/4/11.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVLiveRoomEngine.h"

// TCAVLiveRoomEngine 一般只存在请求一路画面(重复请求asyncRequestHostView的时候，因为其内部有重试机制，QAVEndpoint requestViewList 的参数不会改)，所以基本上直接可以用block回调就过了
// TCAVMultiLiveRoomEngine 可能会请求多次（每次参数不一致），会导致QAVEndpoint requestViewList参数发生变化，这样就需要用更新后的参数再请求一次

@class TCAVMultiLiveRoomEngine;

@protocol TCAVMLRERequestViewDelegate <NSObject>

@required
// succ：返回最后一次请求QAVEndpoint requestViewList的成功或失败
// 外部通过engine.multiUser 来判断
- (void)onAVMLRoomEngine:(TCAVMultiLiveRoomEngine *)engine requestView:(BOOL)succ;

@end

/*
 * TCAVMultiLiveRoomEngine 主要处理一个人做主播与互动观众在线上进行互动场景，其他观众在线同时观看(主播与互动观众)，主播上传音频以音频，观人只能看和听，主播与观众间存在小窗口互动(可以视频以及语音)场景
 */
@interface TCAVMultiLiveRoomEngine : TCAVLiveRoomEngine<QAVChangeDelegate>
{
@protected
    NSMutableArray      *_multiUser;                // 最多不能超过四个，本地如果开摄像头的话，最多三个，本地用户id不要放进来
@protected
    BOOL                _hasEnabelCamera;           // 是否已打开过摄像头
}

@property (nonatomic, readonly) NSMutableArray *multiUser;
@property (nonatomic, weak) id<TCAVMLRERequestViewDelegate> requestViewDelegate;
@property (nonatomic, assign) BOOL hasEnabelCamera;

// 还可以请求画面的数量
- (NSInteger)canRequestMore;

// 以下方法作重试处理，传nil也会触发QAVEndpoint requestViewList
// 异步请求用户user的画面
- (void)asyncRequestViewOf:(id<AVMultiUserAble>)user;

// 一次请求多个
- (void)asyncRequestMultiViewsOf:(NSArray *)users;

// 异步取消user的画面
- (void)asyncCancelRequestViewOf:(id<AVMultiUserAble>)user;
- (void)asyncCancelRequestMultiViewsOf:(NSArray *)user;

// 异步取消所有人的画面
- (void)asyncCancelAllRequestView;

// 最大请求数
- (NSInteger)maxRequestViewCount;

// 具体与Spear配置相关，请注意设置
// completion为异步回调，注意内存泄露
- (void)changeToInteractAuthAndRole:(CommonCompletionBlock)completion;

// 当前是互动观众时，下麦时，使用
// completion为异步回调，注意内存泄露
- (void)changeToNormalGuestAuthAndRole:(CommonCompletionBlock)completion;

@end


@interface TCAVMultiLiveRoomEngine (ProtectedMethod)

// 请求画面最大重试次数
- (NSInteger)requestViewMaxTryCount;


// 增加此方法方便用户处理在直播过程中通过配置不同的角色名，控制直播效果
// TCAdapter中使用的默认值，具体如何操作，可看Demo中的配置
// 具体示例参考TCShowMultiLiveRoomEngine
- (NSString *)interactUserRole;

@end

