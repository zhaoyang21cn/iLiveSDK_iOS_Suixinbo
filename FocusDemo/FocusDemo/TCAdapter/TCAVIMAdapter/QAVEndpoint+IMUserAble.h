//
//  QAVEndpoint+IMUserAble.h
//  TCShow
//
//  Created by AlexiChen on 16/4/15.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

@interface QAVEndpoint (AVMultiUserAble)<AVMultiUserAble>

@property (nonatomic, assign) NSInteger avCtrlState;            // 直播时配置

@property (nonatomic, assign) NSInteger avMultiUserState;       // 多人互动时IM配置

// 互动时，用户画面显示的屏幕上的区域（opengl相关的位置）
@property (nonatomic, assign) CGRect avInteractArea;

// 互动时，因opengl放在最底层，之上是的自定义交互层，通常会完全盖住opengl
// 用户要想与小画面进行交互的时候，必须在交互层上放一层透明的大小相同的控件，能过操作此控件来操作小窗口画面
@property (nonatomic, weak) UIView *avInvisibleInteractView;

@end


// QAVEndpoint 无法存储使用，否则会有野指针问题
@interface TCAVIMEndpoint : NSObject<AVMultiUserAble>

@property(nonatomic, copy) NSString     *identifier;   ///< 成员id。

@property (nonatomic, assign) NSInteger avCtrlState;            // 直播时配置

@property (nonatomic, assign) NSInteger avMultiUserState;       // 多人互动时IM配置

// 互动时，用户画面显示的屏幕上的区域（opengl相关的位置）
@property (nonatomic, assign) CGRect avInteractArea;

// 互动时，因opengl放在最底层，之上是的自定义交互层，通常会完全盖住opengl
// 用户要想与小画面进行交互的时候，必须在交互层上放一层透明的大小相同的控件，能过操作此控件来操作小窗口画面
@property (nonatomic, weak) UIView *avInvisibleInteractView;


- (instancetype)initWith:(QAVEndpoint *)ep;
- (instancetype)initWithID:(NSString *)uid;

@end
