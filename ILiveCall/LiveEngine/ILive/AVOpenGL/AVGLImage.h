//
//  AVGLImage.h
//  OpenGLRestruct
//
//  Created by vigoss on 14-11-10.
//  Copyright (c) 2014年 vigoss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVGLCommon.h"
//#import "VideoViewInfoModel.h"

typedef enum VideoViewStatus {
    VIDEO_VIEW_NORMAL       = 0,//高斯模糊态
    VIDEO_VIEW_LOADING      = 1,//加载画面态
    VIDEO_VIEW_DRAWING      = 2,//绘制画面态
    VIDEO_VIEW_BACKGROUND   = 3,//绘制黑色背景
    VIDEO_VIEW_NORMAL_WITH_WORDING = 4,//有查看画面的背景图。
}VideoViewStatus;

typedef enum enTextureDisplayType
{
    Texture_Display_Type_Gaussion,
    Texture_Display_Type_Video_Data,
}ENTextureDisplayType;
typedef enum enDataFormat
{
    Data_Format_NV12,
    Data_Format_I420,
    Data_Format_RGB32,
}ENDataFormat;

@interface AVGLImage : NSObject
{
    int         _imageWidth;// image width
    int         _imageHeight; //image height
    
    int         _angle;
    
    Byte *      _imageData;//Y ,U, V three chanel data
    
    BOOL        _isFullScreenShow;//
    
    VideoViewStatus _viewStatus; //表示当前显示的状态，高斯，loading，和绘制。
    ENDataFormat _dataFormat;//要渲染的数据格式。

}
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) Byte * data;
@property (nonatomic, assign) int angle;
@property (nonatomic, assign) BOOL isFullScreenShow;
@property (nonatomic, assign) VideoViewStatus viewStatus;
@property (nonatomic, assign) ENDataFormat dataFormat;
@end
