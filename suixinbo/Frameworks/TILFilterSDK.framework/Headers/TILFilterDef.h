//
//  TILFilterDef.h
//  TILFilterSDK
//
//  Created by kennethmiao on 17/6/2.
//  Copyright © 2017年 kennethmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 * 支持的滤镜
 */
typedef NS_ENUM(NSInteger, TILFilterType)
{
    TILFilterType_None      = 0,    //无滤镜
    TILFilterType_white     = 1,    //美白
    TILFilterType_QingXin   = 2,    //清新
    TILFilterType_LangMan   = 3,    //浪漫
    TILFilterType_WeiMei    = 4,    //唯美
    TILFilterType_FenNen    = 5,    //粉嫩
    TILFilterType_HuaiJiu   = 6,    //怀旧
    TILFilterType_LanDiao   = 7,    //蓝调
    TILFilterType_QingLiang = 8,    //清亮
    TILFilterType_RiXi      = 9,    //日系
};
/*
 * 输入格式
 */
typedef NS_ENUM(NSInteger, TILDataType)
{
    TILDataType_None      = 0,
    TILDataType_NV12      = 1,
    TILDataType_I420      = 2,
};

