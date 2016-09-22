//
//  TCAVLiveRoomEngine+AudioTransmission.h
//  TCShow
//
//  Created by AlexiChen on 16/7/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportAudioTransmission
#import "TCAVLiveRoomEngine.h"

// 用于透传的数据

// 用于处理音频透传
@interface TCAVLiveRoomEngine (AudioTransmission)<QAVAudioDataDelegate>

// Mic透传数据:开Mic端配置，自己听到，其他人可听到
@property (nonatomic, strong) NSData *micAudioTransmissionData;
@property (nonatomic, assign) NSInteger micAudioOffset;

// 扬声器透传数据：开Speaker端配置，只有自己听到，其他人听不到
@property (nonatomic, strong) NSData *speakerAudioTransmissionData;
@property (nonatomic, assign) NSInteger speakerAudioOffset;

// 是否正在进行透传
- (BOOL)isAudioTransmissing;

// 开始Mic透传
// 在房间内（进入房间后）随时可以调用，开Mic后，有上行音频时，会自动处理。如果之前有调用，再次调用，相当于替换透传数据
// 设置之后，底层自动处理，

// pcmFilePath可为空，为空，等同于不进行透传。
// 默认使用QAVAudioFrameDesc= {48000, 2, 16}，外部传入数据时，注意对应
//
- (BOOL)startMicAudioTransmissionWithFile:(NSString *)pcmFilePath;

// pcmData可为空，为空，等同于不进行透传。不为空时
// 默认使用QAVAudioFrameDesc= {48000, 2, 16}，外部传入数据时，注意对应
- (BOOL)startMicAudioTransmission:(NSData *)pcmData;

// pcmData可为空，为空，等同于不进行透传。不为空时
// pcmdesc为pcmData对应采样率/声道数/比特率信息
- (BOOL)startMicAudioTransmission:(NSData *)pcmData pcmDesc:(struct QAVAudioFrameDesc)pcmdesc;

// 开始Speaker透传
// 在房间内（进入房间后）随时可以调用，开Speaker后，随时可以调用，如果之前忆调用，再次调用，相当于替换透传数据

// pcmFilePath可为空，为空，等同于不进行透传。
// 默认使用QAVAudioFrameDesc= {48000, 2, 16}，外部传入数据时，注意对应
- (BOOL)startSpeakerAudioTransmissionWithFile:(NSString *)pcmFilePath;

// pcmData可为空，为空，等同于不进行透传。不为空时
// 默认使用QAVAudioFrameDesc= {48000, 2, 16}，外部传入数据时，注意对应
- (BOOL)startSpeakerAudioTransmission:(NSData *)pcmData;

// pcmData可为空，为空，等同于不进行透传。不为空时
// pcmdesc为pcmData对应采样率/声道数/比特率信息
- (BOOL)startSpeakerAudioTransmission:(NSData *)pcmData pcmDesc:(struct QAVAudioFrameDesc)pcmdesc;


// 停止透传
- (void)stopAudioTransmission;

@end

#endif
