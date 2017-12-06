//
//  SpeedTest.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/11/10.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpeedTest : NSObject <ILiveSpeedTestDelegate>

+ (instancetype)shareInstance;
- (void)startTest;
@end
