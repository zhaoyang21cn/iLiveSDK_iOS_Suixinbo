//
//  TCAVCallManager.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportCallScene
#import "TCAVIMMIManager.h"

// 在TCAVIMMIManager的基础上，弱化主屏幕用户（mainUser），当收到HasCamera事件时，如果当前mainUser为nil，优先以创建房间的人，或自己为主屏

@interface TCAVCallManager : TCAVIMMIManager

// 将用户添加并显示
- (void)addRenderAndRequest:(NSArray *)imusers;

@end
#endif