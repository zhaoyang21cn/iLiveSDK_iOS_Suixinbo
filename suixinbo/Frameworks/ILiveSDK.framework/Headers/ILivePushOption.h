//
//  ILivePushOption.h
//  ILiveSDK
//
//  Created by AlexiChen on 2016/10/24.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK/IMSdkComm.h>

@class ILiveChannelInfo;

@interface ILivePushOption : NSObject

/** 旁路直播频道信息 */
@property (nonatomic, strong) ILiveChannelInfo *channelInfo;

/** 编码格式 */
@property(nonatomic, assign) AVEncodeType   encodeType;

/** 录制文件类型（AV_RECORD_FILE_TYPE_NONE则不开启录制） */
@property(nonatomic,assign) AVRecordFileType recrodFileType;

@end



@interface ILiveChannelInfo : NSObject

/** (必选)直播频道的名称 */
@property(nonatomic, copy)   NSString  *channelName;

/** (可选)直播频道的描述 */
@property(nonatomic, copy)   NSString  *channelDesc;

@end
