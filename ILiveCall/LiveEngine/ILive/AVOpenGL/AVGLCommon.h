//
//  AVGLCommon.h
//  OpenGLRestruct
//
//  Created by vigoss on 14-11-10.
//  Copyright (c) 2014年 vigoss. All rights reserved.
//

#ifndef OpenGLRestruct_AVGLCommon_h
#define OpenGLRestruct_AVGLCommon_h
#import <UIKit/UIKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


#define GL_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define GL_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define GL_ANIMATION_STEP_COUNT 20

typedef enum enDisplayType
{
    Display_Type_Texture,
    Display_Type_BackGround,
    Display_Type_Loading,
}EmDisplayType;


#ifdef __cplusplus
extern "C" {
#endif

int getScreenWidth();
int getScreenHeight();
    
CGFloat fitScreenW(CGFloat value);
    
#define SCREEN_WIDTH            getScreenWidth()
#define SCREEN_HEIGHT           getScreenHeight()
#define VIDEO_HEIGHT (SCREEN_WIDTH * 9 / 16)
    
#define _size_W(value)    fitScreenW(value)
#define GROUP_SMALL_VIEW_WIDTH _size_W(64)
#define GROUP_SMALL_VIEW_HEIGHT _size_W(48)
#define CZ_NewMutableDictionary()                                                       CZ_NewMutableDictionaryFunc()
#define CZ_NewMutableArray()                                                            CZ_NewMutableArrayFunc()

#define PREVIEW_LAYER_H   _size_W(120)//180

#define PREVIEW_LAYER_W   _size_W(80)//根据宽高比自动显示小画面宽高。

#define CZ_NewUIImageViewWithFrame(frame)                                               CZ_NewUIImageViewWithFrameFunc(frame)

#define CZ_NewUILabelWithFrame(frame)                                                   CZ_NewUILabelWithFrameFunc(frame)

NSMutableDictionary* CZ_NewMutableDictionaryFunc();

NSMutableArray* CZ_NewMutableArrayFunc();

UIImageView *CZ_NewUIImageViewWithFrameFunc(CGRect frame);

UILabel *CZ_NewUILabelWithFrameFunc(CGRect frame);

#ifdef __cplusplus
}
#endif

#endif
