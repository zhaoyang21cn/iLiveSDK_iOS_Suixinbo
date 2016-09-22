//
//  AVGLCustomRenderView.h
//  TCShow
//
//  Created by wilderliao on 16/9/1.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AVGLRenderView.h"

typedef enum iLiveRotationType
{
    //自动校正
    ILiveRotation_Auto = 0,
    //始终全屏显示
    ILiveRotation_FullScreen,
    //剪裁校正
    ILiveRotation_Crop,
    
}ILiveRotationType;

@interface AVGLCustomRenderView : AVGLRenderView
{
     ILiveRotationType    _iLiveRotationType;
}

@property (nonatomic,assign) ILiveRotationType iLiveRotationType;
@end
