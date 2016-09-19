//
//  LiveCallLoginParam.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/18.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK/ImSDK.h>

@interface LiveCallLoginParam : TIMLoginParam
@property (nonatomic,assign) NSInteger tokenTime;

- (void)updateRefreshTime;

- (BOOL)needRefresh;

@end
