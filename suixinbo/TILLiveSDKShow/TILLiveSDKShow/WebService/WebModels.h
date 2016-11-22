//
//  WebModels.h
//  TCShow
//
//  Created by AlexiChen on 15/11/12.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSignItem : NSObject

@property (nonatomic, copy)   NSString     *imageSign;
@property (nonatomic, assign) NSInteger     saveSignTime;

- (BOOL)isVailed;
@end


//==================================================

// 位置信息
@interface LocationItem : NSObject

@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, copy) NSString *address;

- (BOOL)isVaild;

@end

//==================================================
// 用户基本信息
@interface TCShowUser : NSObject

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *uid;

@property (nonatomic, assign) NSInteger avCtrlState;

@property (nonatomic, assign) NSInteger avMultiUserState;       // 多人互动时IM配置

// 互动时，用户画面显示的屏幕上的区域（opengl相关的位置）
@property (nonatomic, assign) CGRect avInteractArea;

// 互动时，因opengl放在最底层，之上是的自定义交互层，通常会完全盖住opengl
// 用户要想与小画面进行交互的时候，必须在交互层上放一层透明的大小相同的控件，能过操作此控件来操作小窗口画面
@property (nonatomic, weak) UIView *avInvisibleInteractView;

- (BOOL)isVailed;


@end

//==================================================

// TODO:添加自定义的命令类型
//@interface TCShowLiveCustomAction : NSObject
//
//@property (nonatomic, assign)   NSInteger       userAction;
//@property (nonatomic, copy)     NSString        *actionParam;
//@property (nonatomic, strong)   id<IMUserAble>  user;
//
//- (NSData *)actionData;
//
//@end


@interface TCShowLiveListItem : NSObject

@property (nonatomic, strong) TCShowUser *host;
@property (nonatomic, strong) LocationItem *lbs;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cover;

@property (nonatomic, assign) NSInteger createTime;         // 创建时间
@property (nonatomic, assign) NSInteger timeSpan;           // 时长

@property (nonatomic, assign) NSInteger liveAudience;

@property (nonatomic, assign) NSInteger admireCount;        // 点赞统计
@property (nonatomic, assign) NSInteger watchCount;         // 观看人次

@property (nonatomic, copy) NSString *chatRoomId;           // 直播聊天室
@property (nonatomic, assign) int avRoomId;                 // 直播房间号

+ (instancetype)loadFromToLocal;

- (void)saveToLocal;
- (void)cleanLocalData;

- (NSDictionary *)toLiveStartJson;
- (NSDictionary *)toHeartBeatJson;

@end











