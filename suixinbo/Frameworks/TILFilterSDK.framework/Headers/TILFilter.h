//
//  TILFilter.h
//  TILFilterSDK
//
//  Created by kennethmiao on 17/3/14.
//  Copyright © 2017年 kennethmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TILFilterDef.h"

@interface TILFilter : NSObject
/*
 * 预处理数据
 * @param   data    帧数据
 * @param   inType  输入帧数据格式
 * @param   outType 输出帧数据格式
 * @param   size    帧数据大小
 * @param   width   帧宽
 * @param   height  帧高
 * @return  int     返回0处理成功
 */
- (int)processData:(uint8_t *)data inType:(TILDataType)inType outType:(TILDataType)outType size:(int)size width:(int)width height:(int)height;

/*
 * 设置美颜（0-10）
 * @param   level    美颜程度，0表示原图
 */
- (void)setBeautyLevel:(NSInteger)level;

/*
 * 设置美白（0-10）
 * @param   level    美白程度，0表示原图
 */
- (void)setWhitenessLevel:(NSInteger)level;

/*
 * 设置滤镜
 * @param   type  滤镜类型
 */
- (void)setFilterType:(TILFilterType)type;

/*
 * 设置滤镜
 * @param   imagePath  滤镜资源路径
 */
- (void)setFilterImage:(NSString *)imagePath;

/*
 * 设置滤镜融合度（0-10）
 * @param   level    滤镜融合度
 */
- (void)setFilterMixLevel:(NSInteger)level;

/*
 * 设置绿幕
 * @param   file  绿幕文件路径
 */
- (void)setGreenScreenFile:(NSString *)file;

/*
 * 设置大眼（0-10）（高级版本功能）
 * @param   level    大眼程度
 */
- (void)setEyeScaleLevel:(NSInteger)level;

/*
 * 设置瘦脸（0-10）（高级版本功能）
 * @param   level    瘦脸程度
 */
- (void)setFaceSlimLevel:(NSInteger)level;

/*
 * 设置动效（高级版本功能）
 * @param   templatePath  动效资源路径
 */
- (void)setMotionTemplate:(NSString *)templatePath;

/*
 * 获取版本号
 */
+ (NSString *)getVersion;
@end
