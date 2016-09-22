//
//  IMAPlatform+TestSpeed.h
//  TCShow
//
//  Created by wilderliao on 16/7/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kIsMeasureSpeed
#import "IMAPlatform.h"

@interface IMAPlatform (TestSpeed)<TIMAVMeasureSpeederDelegate>

@property (nonatomic, strong) TIMAVMeasureSpeeder *measureSpeeder;

- (void)requestTestSpeed;

@end
#endif