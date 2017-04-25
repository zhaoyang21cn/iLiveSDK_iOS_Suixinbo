//
//  LiveViewController+Audio.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/4/6.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveViewController+Audio.h"
#import <objc/runtime.h>

static NSString *const kVoiceType = @"kVoiceType";

@implementation LiveViewController (Audio)

- (NSNumber *)voiceType
{
    return objc_getAssociatedObject(self, (__bridge const void *)kVoiceType);
}

- (void)setVoiceType:(NSNumber *)type
{
    objc_setAssociatedObject(self, (__bridge const void *)kVoiceType, type, OBJC_ASSOCIATION_ASSIGN);
}

- (void)initAudio
{
    self.voiceType = @(0);
    // 设置音频处理回调
    [[[ILiveSDK getInstance] getAVContext].audioCtrl setAudioDataEventDelegate:self];
    [[[ILiveSDK getInstance] getAVContext].audioCtrl registerAudioDataCallback:QAVAudioDataSource_VoiceDispose];
}

- (QAVResult)audioDataComes:(QAVAudioFrame *)audioFrame type:(QAVAudioDataSourceType)type
{
    return QAV_OK;
}

- (QAVResult)audioDataShouInput:(QAVAudioFrame *)audioFrame type:(QAVAudioDataSourceType)type
{
    return QAV_OK;
}

- (QAVResult)audioDataDispose:(QAVAudioFrame *)audioFrame type:(QAVAudioDataSourceType)type
{
    QAVContext *context = [[ILiveSDK getInstance] getAVContext];
    [context.audioCtrl setVoiceType:(QAVVoiceType)[self.voiceType integerValue]];
    return QAV_OK;
}

- (void)changeVoiceType:(QAVVoiceType)type
{
    self.voiceType = @(type);
}

@end
