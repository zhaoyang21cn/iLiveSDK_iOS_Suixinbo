//
//  ILiveRecordOption.h
//  ILiveSDK
//
//  Created by wilderliao on 16/10/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK/IMSdkComm.h>

@interface ILiveRecordOption : NSObject

/** 录制生成的文件名,如果包含空格则需要使用rawurlencode,长度在40个字符以内 */
@property(nonatomic, copy) NSString    *fileName;

/** 录制类型 */
@property(nonatomic,assign) AVRecordType recordType;

/** 视频标签的NSString*列表 */
@property(nonatomic, strong) NSArray     *tags;

/** 视频分类ID （目前暂不支持，填 0）*/
@property(nonatomic,assign) UInt32       classId;

/** 是否转码 （目前暂不支持，不用填写）*/
@property(nonatomic,assign) BOOL         isTransCode;

/** 是否截图 （目前暂不支持，不用填写）*/
@property(nonatomic,assign) BOOL         isScreenShot;

/** 是否打水印 （目前暂不支持，不用填写）*/
@property(nonatomic,assign) BOOL         isWaterMark;

/** SDK对应的业务类型 （当前版本填 AVSDK_TYPE_NORMAL）*/
@property(nonatomic,assign) AVSDKType    avSdkType;

@end

