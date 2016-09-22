//
//  TCAVLiveRoomEngine+AudioTransmission.m
//  TCShow
//
//  Created by AlexiChen on 16/7/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportAudioTransmission
#import "TCAVLiveRoomEngine+AudioTransmission.h"

@implementation TCAVLiveRoomEngine (AudioTransmission)

static NSString *const kTCAVLiveRoomEngineMicAudioTransmissionData = @"kTCAVLiveRoomEnginemicAudioTransmissionData";
static NSString *const kTCAVLiveRoomEngineSpeakerAudioTransmissionData = @"kTCAVLiveRoomEngineSpeakerAudioTransmissionData";

static NSString *const kTCAVLiveRoomEngineMicAudioOffset = @"kTCAVLiveRoomEngineMicAudioOffset";
static NSString *const kTCAVLiveRoomEngineSpeakerAudioOffset = @"kTCAVLiveRoomEngineSpeakerAudioOffset";

- (NSData *)micAudioTransmissionData
{
    return objc_getAssociatedObject(self, (__bridge const void *)kTCAVLiveRoomEngineMicAudioTransmissionData);
}

- (void)setMicAudioTransmissionData:(NSData *)micAudioTransmissionData
{
    objc_setAssociatedObject(self, (__bridge const void *)kTCAVLiveRoomEngineMicAudioTransmissionData, micAudioTransmissionData, OBJC_ASSOCIATION_RETAIN);
}


- (NSData *)speakerAudioTransmissionData
{
    return objc_getAssociatedObject(self, (__bridge const void *)kTCAVLiveRoomEngineSpeakerAudioTransmissionData);
}

- (void)setSpeakerAudioTransmissionData:(NSData *)speakerAudioTransmissionData
{
    objc_setAssociatedObject(self, (__bridge const void *)kTCAVLiveRoomEngineSpeakerAudioTransmissionData, speakerAudioTransmissionData, OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)micAudioOffset
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kTCAVLiveRoomEngineMicAudioOffset);
    return [num integerValue];
}

- (void)setMicAudioOffset:(NSInteger)micAudioOffset
{
    objc_setAssociatedObject(self, (__bridge const void *)kTCAVLiveRoomEngineMicAudioOffset, @(micAudioOffset), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)speakerAudioOffset
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kTCAVLiveRoomEngineSpeakerAudioOffset);
    return [num integerValue];
}

- (void)setSpeakerAudioOffset:(NSInteger)speakerAudioOffset
{
    objc_setAssociatedObject(self, (__bridge const void *)kTCAVLiveRoomEngineSpeakerAudioOffset, @(speakerAudioOffset), OBJC_ASSOCIATION_RETAIN);
}


- (BOOL)isAudioTransmissing
{
    return self.micAudioTransmissionData || self.speakerAudioTransmissionData;
}

- (BOOL)startMicAudioTransmission:(NSData *)pcmData pcmDesc:(struct QAVAudioFrameDesc)pcmdesc
{
    
    if (![self beforeTryCheck:nil])
    {
        return NO;
    }
    
    if ([self isRoomRunning] && _avContext)
    {
        if (pcmData)
        {
            [_avContext.audioCtrl setAudioDataEventDelegate:self];
            [_avContext.audioCtrl registerAudioDataCallback:QAVAudioDataSource_MixToSend];
            
            [_avContext.audioCtrl setAudioDataFormat:QAVAudioDataSource_MixToSend desc:pcmdesc];
        }
        else
        {
            [_avContext.audioCtrl unregisterAudioDataCallback:QAVAudioDataSource_MixToSend];
        }
        
    }
    
    self.micAudioOffset = 0;
    self.micAudioTransmissionData = pcmData;
    return YES;
    
   
}

- (BOOL)startMicAudioTransmission:(NSData *)pcmData
{
    struct QAVAudioFrameDesc desc = {48000, 2, 16};
    return [self startMicAudioTransmission:pcmData pcmDesc:desc];
}

- (BOOL)startMicAudioTransmissionWithFile:(NSString *)pcmFilePath
{
    BOOL isExist = [PathUtility isExistFile:pcmFilePath];
    if (!isExist)
    {
        return [self startMicAudioTransmission:nil];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:pcmFilePath];
    return [self startMicAudioTransmission:data];
}

- (BOOL)startSpeakerAudioTransmission:(NSData *)pcmData pcmDesc:(struct QAVAudioFrameDesc)pcmdesc
{
    if (![self beforeTryCheck:nil])
    {
        return NO;
    }
    if ([self isRoomRunning] && _avContext)
    {
        if (pcmData)
        {
            [_avContext.audioCtrl setAudioDataEventDelegate:self];
            [_avContext.audioCtrl registerAudioDataCallback:QAVAudioDataSource_MixToPlay];
            [_avContext.audioCtrl setAudioDataFormat:QAVAudioDataSource_MixToPlay desc:pcmdesc];
        }
        else
        {
            [_avContext.audioCtrl unregisterAudioDataCallback:QAVAudioDataSource_MixToPlay];
        }
    }
    
    self.speakerAudioOffset = 0;
    self.speakerAudioTransmissionData = pcmData;
    return YES;

}

// 开始Speaker透传
// 开Mic后，随时可以调用，如果之前忆调用，再次调用，相当于替换透传数据
- (BOOL)startSpeakerAudioTransmission:(NSData *)pcmData
{
    struct QAVAudioFrameDesc desc = {48000, 2, 16};
    return [self startSpeakerAudioTransmission:pcmData pcmDesc:desc];
}
- (BOOL)startSpeakerAudioTransmissionWithFile:(NSString *)pcmFilePath
{
    BOOL isExist = [PathUtility isExistFile:pcmFilePath];
    if (!isExist)
    {
        return [self startSpeakerAudioTransmission:nil];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:pcmFilePath];
    return [self startSpeakerAudioTransmission:data];
}

- (void)stopAudioTransmission
{
    if (_avContext)
    {
        [_avContext.audioCtrl unregisterAudioDataCallbackAll];
    }
}


- (QAVResult)audioDataComes:(QAVAudioFrame *)audioFrame type:(QAVAudioDataSourceType)type
{
    // 个人理解：主要用户保存直播中的音频数据，实际中处理得较少
    return QAV_OK;
}

- (void)handle:(QAVAudioFrame **)frameRef withPCM:(NSData *)data offset:(NSInteger *)offset
{
    const QAVAudioFrame *aFrame = *frameRef;
    NSInteger off = *offset;
    NSInteger length = [aFrame.buffer length];
    if (length)
    {
        NSMutableData *pdata = [NSMutableData data];
        const Byte *btyes = [data bytes];
        
        while (pdata.length < length)
        {
            if (off + length > data.length)
            {
                const Byte *byteOff = btyes + off;
                [pdata appendBytes:byteOff length:data.length - off];
                off = 0;
            }
            else
            {
                const Byte *byteOff = btyes + off;
                [pdata appendBytes:byteOff length:length];
                off += length;
            }
        }
        
        if (pdata.length == length)
        {
            *offset = off;
            
            const void *abbytes = [aFrame.buffer bytes];
            memcpy((void *)abbytes, [pdata bytes], length);
        }
    }
}

- (QAVResult)audioDataShouInput:(QAVAudioFrame *)audioFrame type:(QAVAudioDataSourceType)type
{
    // 混音输入（Mic和Speaker）的主要回调
    
    if (type == QAVAudioDataSource_MixToSend)
    {
        if (self.micAudioTransmissionData)
        {
            NSInteger off = self.micAudioOffset;
            [self handle:&audioFrame withPCM:self.micAudioTransmissionData offset:&off];
            self.micAudioOffset = off;
        }
    }
    else if (type == QAVAudioDataSource_MixToPlay)
    {
        if (self.speakerAudioTransmissionData)
        {
            NSInteger off = self.speakerAudioOffset;
            [self handle:&audioFrame withPCM:self.speakerAudioTransmissionData offset:&off];
            self.speakerAudioOffset = off;
        }
    }
//    NSLog(@"%@", audioFrame.buffer);
    return QAV_OK;
}

- (QAVResult)audioDataDispose:(QAVAudioFrame *)audioFrame type:(QAVAudioDataSourceType)type
{
    // 个人理解：调试其他问题时，没发现此处回调有什么不一样，猜想可以用作作变声处理
    return QAV_OK;
}
@end

#endif
