//
//  LiveViewController+Audio.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/4/6.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveViewController+Audio.h"

@implementation LiveViewController (Audio)

- (void)initAudio
{
    [[[ILiveSDK getInstance] getAVContext].audioCtrl registerAudioDataCallback:QAVAudioDataSource_VoiceDispose];
}

- (void)changeVoiceType:(QAVVoiceType)type
{
    QAVContext *context = [[ILiveSDK getInstance] getAVContext];
    [context.audioCtrl setVoiceType:type];
}

@end
