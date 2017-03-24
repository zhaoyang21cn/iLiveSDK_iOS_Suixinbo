//
//  UserViewManager.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LiveCallView.h"

//随心播限制界面上最多有4路画面（包括1路主播和3路连麦用户的画面），本类对这些画面的位置进行管理
@interface UserViewManager : NSObject

@property (nonatomic, assign) int total;//小画面的总数（不算主画面）
@property (nonatomic, strong) NSMutableDictionary *placeholderViews;
@property (nonatomic, strong) NSMutableDictionary *renderViews;
@property (nonatomic, strong) ILiveRenderView *mainRenderView;
@property (nonatomic, strong) NSString *mainCodeUserId;
@property (nonatomic, strong) NSString *mainUserId;


- (ILiveRenderView *)addRenderView:(NSString *)userId srcType:(avVideoSrcType)type;
- (void)removeRenderView:(NSString *)userId srcType:(avVideoSrcType)type;

- (LiveCallView *)addPlaceholderView:(NSString *)userId;
- (CGRect)removePlaceholderView:(NSString *)userId;

- (ILiveRenderView *)renderviewReplacePlaceholderView:(NSString *)userId srcType:(avVideoSrcType)type;

- (BOOL)switchToMainView:(NSString *)codeUserId;

- (void)refreshViews;//刷新View

- (void)releaseManager;

//是否已经存在占位符
- (BOOL)isExistPlaceholder:(NSString *)userId;
//是否已经存在渲染视图
- (BOOL)isExistRenderView:(NSString *)userId;

- (avVideoSrcType)getUserType:(NSString *)userId;

+ (NSDictionary *)decodeUser:(NSString *)identifier;

+ (NSString *)codeUser:(NSString *)identifier type:(avVideoSrcType)type;

+ (instancetype)shareInstance;

@end
