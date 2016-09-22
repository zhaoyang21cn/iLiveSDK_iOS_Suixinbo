//
//  IMAHost.h
//  TIMAdapter
//
//  Created by AlexiChen on 16/1/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

// 当前是用户信息
@interface IMAHost : NSObject<IMHostAble>

@property (nonatomic, strong) TIMLoginParam     *loginParm;

@property (nonatomic, strong) TIMUserProfile    *profile;


// 同步自己的个人资料
- (void)asyncProfile;

@end
