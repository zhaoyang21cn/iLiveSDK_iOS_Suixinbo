//
//  IMAPlatform+Login.h
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAPlatform.h"

@interface IMAPlatform (Login)

- (void)login:(TIMLoginParam *)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

// 配置进入主界面后的要拉取的数据
- (void)configOnLoginSucc:(TIMLoginParam *)param completion:(CommonVoidBlock)block;

@end
