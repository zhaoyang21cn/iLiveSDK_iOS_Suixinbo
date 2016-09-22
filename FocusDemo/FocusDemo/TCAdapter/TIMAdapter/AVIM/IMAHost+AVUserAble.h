//
//  IMAHost+AVUserAble.h
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAHost.h"

// 将IMHost转换成可用于直播的类型
@interface IMAHost (AVUserAble)<AVUserAble>

@property (nonatomic, assign) NSInteger avCtrlState;

- (BOOL)isCurrentLiveHost:(id<AVRoomAble>)room;

@end


@interface IMAHost (AVMultiUserAble)<AVMultiUserAble>

@property (nonatomic, assign) NSInteger avMultiUserState;

@property (nonatomic, assign) CGRect avInteractArea;

@property (nonatomic, weak) UIView *avInvisibleInteractView;

@end
