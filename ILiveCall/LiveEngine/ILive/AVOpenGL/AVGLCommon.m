//
//  AVGLCommon.m
//  QAVSDKDemo
//
//  Created by rodgeluo on 15/9/23.
//  Copyright (c) 2015年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVGLCommon.h"


int getScreenWidth()
{
    static int s_scrWidth = 0;
    if (s_scrWidth == 0){
        UIScreen* screen = [UIScreen mainScreen];
        CGRect screenFrame = screen.bounds;
        s_scrWidth = MIN(screenFrame.size.width, screenFrame.size.height);
        
        //解决在ipad中app启动时[UIScreen mainScreen].bounds.size.width于768px的问题
        if (s_scrWidth >= 768) {
            s_scrWidth = 320 * (s_scrWidth / 768.0f);
        }
    }
    
    return s_scrWidth;
}

int getScreenHeight()
{
    static int s_scrHeight = 0;
    if (s_scrHeight == 0){
        UIScreen* screen = [UIScreen mainScreen];
        CGRect screenFrame = screen.bounds;
        s_scrHeight = MAX(screenFrame.size.height, screenFrame.size.width);
        
        //解决在ipad中app启动时[UIScreen mainScreen].bounds.size.height于1024x的问题
        if (s_scrHeight >= 1024) {
            s_scrHeight = 480 * (s_scrHeight / 1024.0f);
        }
    }
    return s_scrHeight;
}

//以iPhone5s屏幕宽度为基准
CGFloat fitScreenW(CGFloat value)
{
    CGFloat tValue = value;
    int rValue =(tValue/320.0f)*getScreenWidth();
    return rValue;
}

NSMutableDictionary* CZ_NewMutableDictionaryFunc()
{
    return [NSMutableDictionary new];
}

NSMutableArray* CZ_NewMutableArrayFunc()
{
    return [NSMutableArray new];
}

UIImageView *CZ_NewUIImageViewWithFrameFunc(CGRect frame)
{
    return [[UIImageView alloc] initWithFrame:frame];
}

UILabel *CZ_NewUILabelWithFrameFunc(CGRect frame)
{
    return [[UILabel alloc] initWithFrame:frame];
}