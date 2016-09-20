//
//  AVGLCustomRenderView.m
//  TCShow
//
//  Created by wilderliao on 16/9/1.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AVGLCustomRenderView.h"

void myswap(float *a, float *b){float temp = *a; *a = *b; *b = temp;}
float myMinf(float a, float b){
    return a > b ? b : a;
}

@implementation AVGLCustomRenderView

@synthesize iLiveRotationType = _iLiveRotationType;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _iLiveRotationType = ILiveRotation_FullScreen;
    }
    return self;
}

- (void)updateTexCoord
{
    float stride_x = 0.0;
    float stride_y = 0.0;
    
    float viewWidth = _frame.size.width;
    float viewHeight = _frame.size.height;
    float dstWidth = _image.width;
    float dstHeight = _image.height;
    
    if (dstWidth < dstHeight)
        return [self updateTexCoord2];
    //myswap(&dstHeight, &dstWidth);
    if (viewWidth ==0 || viewHeight == 0 || dstWidth == 0 || dstHeight == 0) {
        return;
    }
    if (_textueDisplayType == Texture_Display_Type_Video_Data)
    {
        if (_image.isFullScreenShow == NO)
        {
            if (_hasBlackEdge != YES)
            {
                //多人通话,数据没有黑边
                if (viewWidth == GROUP_SMALL_VIEW_WIDTH)
                {
                    //小画面只需要裁剪。
                    if (viewWidth/viewHeight > dstHeight/dstWidth)
                    {
                        stride_x += (1 - (float)viewHeight/viewWidth * dstHeight/dstWidth)/2;
                    }
                    else
                    {
                        stride_y += (1 - (float)viewWidth/viewHeight * dstWidth/dstHeight)/2;
                    }
                }
            }
        }
        else
        {
            if (_hasBlackEdge == YES)
            {
                float widTest = (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT * _image.width/_image.height;
                if (widTest > 1) {
                    //PC端 720P的情况下，应该要X轴做裁剪
                    if (self.isFloat)
                    {
                        stride_x += (1 - (float)PREVIEW_LAYER_H/PREVIEW_LAYER_W*_image.height/_image.width)/2;
                    }
                    else
                    {
                        stride_x += (1 - (float)GL_SCREEN_HEIGHT/GL_SCREEN_WIDTH*_image.height/_image.width)/2;
                    }
                }
                else
                {
                    //两人正常情况下编码的分辨率比例为2：3，由于底层做了根据屏幕宽高比，对画面显示黑边，银次上层需要做裁剪。
                    stride_y += (1 - (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT * _image.width/_image.height)/2;
                    if (self.isFloat)
                    {
                        //浮窗的画面比例也和主屏幕不一样，所以要特殊处理
                        stride_x += (1 - (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT*PREVIEW_LAYER_H/PREVIEW_LAYER_W)/2;
                    }
                    else
                    {
                        if (viewWidth == PREVIEW_LAYER_W)
                        {
                            //小画面
                            stride_x += (1 - (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT*viewHeight/viewWidth)/2;
                        }
                    }
                }
            }
            else
            {
                //多人大画面
                if (_enableCutting == YES)
                {
                    float widTest = (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT * _image.width/_image.height;
                    if (widTest > 1) {
                        //PC端 720P的情况下，应该要X轴做裁剪
                        if (self.isFloat)
                        {
                            stride_x += (1 - (float)PREVIEW_LAYER_H/PREVIEW_LAYER_W*_image.height/_image.width)/2;
                        }
                        else
                        {
                            stride_x += (1 - (float)GL_SCREEN_HEIGHT/GL_SCREEN_WIDTH*_image.height/_image.width)/2;
                        }
                    }
                    else
                    {
                        //如果允许裁剪，说明是普通画面
                        stride_y += (1 - (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT * _image.width/_image.height)/2;
                        if (self.isFloat && viewWidth != GROUP_SMALL_VIEW_WIDTH)
                        {
                            //浮窗的画面比例也和主屏幕不一样，所以要特殊处理
                            stride_x += (1 - (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT*PREVIEW_LAYER_H/PREVIEW_LAYER_W)/2;
                        }
                        else
                        {
                            if (viewWidth == GROUP_SMALL_VIEW_WIDTH)
                            {
                                //小画面
                                stride_x += (1 - (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT*viewHeight/viewWidth)/2;
                            }
                        }
                    }
                }
                else
                {
                    //如果不允许裁剪，说明是拨片儿
                    if (viewWidth == GROUP_SMALL_VIEW_WIDTH)
                    {
                        //多人的小画面，要裁剪成正方形
                        if (viewWidth/viewHeight > dstHeight/dstWidth)
                        {
                            stride_x += (1 - (float)viewHeight/viewWidth * dstHeight/dstWidth)/2;
                        }
                        else
                        {
                            stride_y += (1 - (float)viewWidth/viewHeight * dstWidth/dstHeight)/2;
                        }
                    }
                }
            }
        }
    }
    else
    {
        //        stride_y += (1 - (float)viewWidth/viewHeight * _image.width/_image.height)/2;
    }
    
    if (_iLiveRotationType == ILiveRotation_Crop)
    {
        //renderView 的高大于宽时，以高为基准计算
        if (viewWidth < viewHeight)
        {
            //远程画面才会裁剪,暂时用dataFormat判断是否为远程画面
            if (_image.angle == 0 || _image.angle == -180)
            {
                stride_x = (1- (viewWidth/viewHeight * dstHeight/dstWidth))/2;
                stride_y = 0;
            }
            
            if (_image.angle == 270 || _image.angle == -90 || _image.angle == 90)
            {
                stride_x = 0;
                stride_y = (1- (viewWidth/viewHeight * dstWidth/dstHeight))/2;
            }
        }
        else//renderView 的宽大于高时，以宽为基准计算
        {
            //远程画面才会裁剪,暂时用dataFormat判断是否为远程画面
            if (_image.angle == 0 || _image.angle == -180)
            {
                stride_x = 0;
                stride_y = (1 - dstWidth/viewWidth * viewHeight/dstHeight)/2;
            }
            
            if (_image.angle == 270 || _image.angle == -90 || _image.angle == 90)
            {
                stride_x = (1 - dstHeight/viewWidth * viewHeight/dstWidth)/2;//(1 - viewWidth/dstHeight)/2;
                stride_y = 0;
            }
        }
        
    }
    _vertexs[3].TexCoord[0] = stride_x;
    _vertexs[3].TexCoord[1] = stride_y;
    
    _vertexs[2].TexCoord[0] = stride_x;
    _vertexs[2].TexCoord[1] = 1-stride_y;
    
    _vertexs[1].TexCoord[0] = 1-stride_x;
    _vertexs[1].TexCoord[1] = 1-stride_y;
    
    _vertexs[0].TexCoord[0] = 1-stride_x;
    _vertexs[0].TexCoord[1] = stride_y;
}

- (void)updateTexCoord2
{
    float stride_x = 0.0;
    float stride_y = 0.0;
    
    float viewWidth = _frame.size.width;
    float viewHeight = _frame.size.height;
    float dstWidth = _image.width;
    float dstHeight = _image.height;
    
    if (dstWidth < dstHeight)
        //myswap(&dstHeight, &dstWidth);
        if (viewWidth ==0 || viewHeight == 0 || dstWidth == 0 || dstHeight == 0) {
            return;
        }
    
    if (_textueDisplayType == Texture_Display_Type_Video_Data)
    {
        if (_image.isFullScreenShow == NO)
        {
            if (_hasBlackEdge != YES)
            {
                //多人通话,数据没有黑边
                if (viewWidth == GROUP_SMALL_VIEW_WIDTH)
                {
                    //小画面只需要裁剪。
                    if (viewWidth/viewHeight > dstHeight/dstWidth)
                    {
                        stride_x += (1 - (float)viewHeight/viewWidth * dstHeight/dstWidth)/2;
                    }
                    else
                    {
                        stride_y += (1 - (float)viewWidth/viewHeight * dstWidth/dstHeight)/2;
                    }
                }
            }
        }
        else
        {
            if (_hasBlackEdge == YES)
            {
                float widTest = (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT * _image.width/_image.height;
                if (widTest > 1) {
                    //PC端 720P的情况下，应该要X轴做裁剪
                    if (self.isFloat)
                    {
                        stride_x += (1 - (float)PREVIEW_LAYER_H/PREVIEW_LAYER_W*_image.height/_image.width)/2;
                    }
                    else
                    {
                        stride_x += (1 - (float)GL_SCREEN_HEIGHT/GL_SCREEN_WIDTH*_image.height/_image.width)/2;
                    }
                }
                else
                {
                    //两人正常情况下编码的分辨率比例为2：3，由于底层做了根据屏幕宽高比，对画面显示黑边，银次上层需要做裁剪。
                    stride_y += (1 - (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT * _image.width/_image.height)/2;
                    if (self.isFloat)
                    {
                        //浮窗的画面比例也和主屏幕不一样，所以要特殊处理
                        stride_x += (1 - (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT*PREVIEW_LAYER_H/PREVIEW_LAYER_W)/2;
                    }
                    else
                    {
                        if (viewWidth == PREVIEW_LAYER_W)
                        {
                            //小画面
                            stride_x += (1 - (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT*viewHeight/viewWidth)/2;
                        }
                    }
                }
            }
            else
            {
                //多人大画面
                if (_enableCutting == YES)
                {
                    float widTest = (float)GL_SCREEN_HEIGHT/GL_SCREEN_WIDTH * _image.width/_image.height;
                    if (widTest > 1) {
                        //PC端 720P的情况下，应该要X轴做裁剪
                        if (self.isFloat)
                        {
                            //暂时不处理float的
                            //stride_x += (1 - (float)PREVIEW_LAYER_H/PREVIEW_LAYER_W*_image.height/_image.width)/2;
                        }
                        else
                        {
                            stride_x += (1.0f - (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT*_image.height/_image.width)/2;
                        }
                    }
                    else
                    {
                        //如果允许裁剪，说明是普通画面
                        stride_y += (1.0f - (float)GL_SCREEN_HEIGHT/GL_SCREEN_WIDTH * _image.width/_image.height )/2;
                        
                        if (self.isFloat && viewWidth != GROUP_SMALL_VIEW_WIDTH)
                        {
                            //暂时不处理float的
                            //浮窗的画面比例也和主屏幕不一样，所以要特殊处理
                            //stride_x += (1 - (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT*PREVIEW_LAYER_H/PREVIEW_LAYER_W)/2;
                        }
                        else
                        {
                            if (viewWidth == GROUP_SMALL_VIEW_WIDTH)
                            {
                                //小画面
                                stride_x += (1 - (float)GL_SCREEN_WIDTH/GL_SCREEN_HEIGHT*viewHeight/viewWidth)/2;
                            }
                        }
                    }
                }
                //                else
                //                {
                //                    //如果不允许裁剪，说明是拨片儿
                //                    if (viewWidth == GROUP_SMALL_VIEW_WIDTH)
                //                    {
                //                        //多人的小画面，要裁剪成正方形
                //                        if (viewWidth/viewHeight > dstHeight/dstWidth)
                //                        {
                //                            stride_x += (1 - (float)viewHeight/viewWidth * dstHeight/dstWidth)/2;
                //                        }
                //                        else
                //                        {
                //                            stride_y += (1 - (float)viewWidth/viewHeight * dstWidth/dstHeight)/2;
                //                        }
                //                    }
                //                }
            }
        }
    }
    else
    {
        //        stride_y += (1 - (float)viewWidth/viewHeight * _image.width/_image.height)/2;
    }
    
    if (_iLiveRotationType == ILiveRotation_Crop)
    {
        //renderView 的高大于宽时，以高为基准计算
        if (viewWidth < viewHeight)
        {
            //远程画面才会裁剪,暂时用dataFormat判断是否为远程画面
            if (_image.angle == 0 || _image.angle == -180)
            {
                stride_x = (1- (viewWidth/viewHeight * dstHeight/dstWidth))/2;
                stride_y = 0;
            }
            
            if (_image.angle == 270 || _image.angle == -90 || _image.angle == 90)
            {
                stride_x = 0;
                stride_y = (1- (viewWidth/viewHeight * dstWidth/dstHeight))/2;
            }
        }
        else//renderView 的宽大于高时，以宽为基准计算
        {
            //远程画面才会裁剪,暂时用dataFormat判断是否为远程画面
            if (_image.angle == 0 || _image.angle == -180)
            {
                stride_x = 0;
                stride_y = (1 - dstWidth/viewWidth * viewHeight/dstHeight)/2;
            }
            
            if (_image.angle == 270 || _image.angle == -90 || _image.angle == 90)
            {
                stride_x = (1 - dstHeight/viewWidth * viewHeight/dstWidth)/2;//(1 - viewWidth/dstHeight)/2;
                stride_y = 0;
            }
        }
        
    }
    
    _vertexs[3].TexCoord[0] = stride_x;
    _vertexs[3].TexCoord[1] = stride_y;
    
    _vertexs[2].TexCoord[0] = stride_x;
    _vertexs[2].TexCoord[1] = 1-stride_y;
    
    _vertexs[1].TexCoord[0] = 1-stride_x;
    _vertexs[1].TexCoord[1] = 1-stride_y;
    
    _vertexs[0].TexCoord[0] = 1-stride_x;
    _vertexs[0].TexCoord[1] = stride_y;
    
    
    
    
    
    if (_StridedTexCoord < 1.0f){
        for(int n = 0; n < 3;n++){
            _vertexs[n].TexCoord[0] = myMinf(_vertexs[n].TexCoord[0], _StridedTexCoord);
        }
    }
    
}

//更新纹理显示定点，和画面再哪里显示相关
- (void)updateVertexs
{
    CGFloat frameW = _frame.size.width;
    CGFloat frameH = _frame.size.height;
    
    float vertX = -1;
    float vertY = -1;
    
    //如果是一个横屏一个竖屏，需要计算显示区域
    
    float dstHeight = _image.height;
    float dstWidth = _image.width;
    
    if (dstWidth < dstHeight){
        return [self updateVertexs2];
        // myswap(&dstWidth, &dstHeight);
    }
    
    if (_textueDisplayType == Texture_Display_Type_Video_Data)
    {
        if (NO == _image.isFullScreenShow && dstHeight !=0 && dstWidth != 0 ) {
            //说明方向不一致
            if (_hasBlackEdge == NO)
            {
                //多人
                if (frameW > GROUP_SMALL_VIEW_WIDTH)
                {
                    //小画面不需要留黑边，直接做中间的裁剪。大画面
                    float WToH = (float)dstHeight / dstWidth;
                    if (self.isFloat)
                    {
                        //如果是浮窗,宽高变形了
                        vertY = - (float)PREVIEW_LAYER_W / PREVIEW_LAYER_H * dstHeight /dstWidth;
                    }
                    else
                    {
                        if (WToH < 1.5)
                        {
                            //正常都是这样的
                            vertY = - (float)frameW / frameH * dstHeight /dstWidth;
                        }
                    }
                }
            }
            else
            {
                //两人小画面和大画面逻辑一致
                float WToH = (float)dstHeight / dstWidth;
                if (WToH < 1.5)
                {
                    //正常都是这样的
                    vertY = - (float)frameW / frameH * dstHeight /dstWidth;
                }
            }
        }
        else
        {
            if (_hasBlackEdge == NO&&_enableCutting == NO)
            {
                //方向一致是，多人大画面由于不裁剪，为了保持画面不变形，需要修改顶点坐标，让画面上下留黑边。
                if (self.isFloat)
                {
                    //如果是浮窗,宽高变形了
                    vertX = - (float)PREVIEW_LAYER_W/PREVIEW_LAYER_H*dstWidth/dstHeight;
                    
                }
                else
                {
                    
                    if (frameW > GROUP_SMALL_VIEW_WIDTH)
                    {
                        vertX = - (float)frameW/frameH*dstWidth/dstHeight;
                    }
                }
            }
        }
    }
    
    if (_iLiveRotationType == ILiveRotation_Crop)
    {
        vertX = -1;
        vertY = -1;
    }
    
    _vertexs[0].Position[0] = vertX;
    _vertexs[0].Position[1] = -vertY;
    
    _vertexs[1].Position[0] = vertX;
    _vertexs[1].Position[1] = vertY;
    
    _vertexs[2].Position[0] = -vertX;
    _vertexs[2].Position[1] = vertY;
    
    _vertexs[3].Position[0] = -vertX ;
    _vertexs[3].Position[1] = -vertY ;
}

//更新纹理显示定点，和画面再哪里显示相关
- (void)updateVertexs2
{
    CGFloat frameW = _frame.size.width;
    CGFloat frameH = _frame.size.height;
    
    float vertX = -1;
    float vertY = -1;
    
    //如果是一个横屏一个竖屏，需要计算显示区域
    
    float dstHeight = _image.height;
    float dstWidth = _image.width;
    
    if (dstWidth < dstHeight){
        //myswap(&dstWidth, &dstHeight);
    }
    
    if (_textueDisplayType == Texture_Display_Type_Video_Data)
    {
        if (NO == _image.isFullScreenShow && dstHeight !=0 && dstWidth != 0 ) {
            //说明方向不一致
            if (_hasBlackEdge == NO)
            {
                //多人
                if (frameW > GROUP_SMALL_VIEW_WIDTH)
                {
                    //小画面不需要留黑边，直接做中间的裁剪。大画面
                    float WToH = (float)dstHeight / dstWidth;
                    if (self.isFloat)
                    {
                        //如果是浮窗,宽高变形了
                        vertY = - (float)PREVIEW_LAYER_W / PREVIEW_LAYER_H * dstHeight /dstWidth;
                    }
                    else
                    {
                        if (dstHeight > dstWidth){
                            vertX = - (float)frameW / frameH * dstWidth /dstHeight;
                        }else
                        {
                            //正常都是这样的
                            vertY = - (float)frameW / frameH * dstHeight /dstWidth;
                        }
                    }
                }
            }
            else
            {
                //两人小画面和大画面逻辑一致
                if (dstHeight > dstWidth){
                    vertX = - (float)frameW / frameH * dstWidth /dstHeight;
                }else
                {
                    float WToH = (float)dstHeight / dstWidth;
                    if (WToH < 1.5)
                    {
                        //正常都是这样的
                        vertY = - (float)frameW / frameH * dstHeight /dstWidth;
                    }
                }
                
            }
        }
        else
        {
            if (_hasBlackEdge == NO&&_enableCutting == NO)
            {
                //方向一致是，多人大画面由于不裁剪，为了保持画面不变形，需要修改顶点坐标，让画面上下留黑边。
                if (self.isFloat)
                {
                    //如果是浮窗,宽高变形了
                    vertX = - (float)PREVIEW_LAYER_W/PREVIEW_LAYER_H*dstWidth/dstHeight;
                    
                }
                else
                {
                    
                    if (frameW > GROUP_SMALL_VIEW_WIDTH)
                    {
                        vertX = - (float)frameW/frameH*dstWidth/dstHeight;
                    }
                }
            }
        }
    }
    //vertX = 0.3f;
    
    if (_iLiveRotationType == ILiveRotation_Crop)
    {
        vertX = -1;
        vertY = -1;
    }
    
    _vertexs[0].Position[0] = vertX;
    _vertexs[0].Position[1] = -vertY;
    
    _vertexs[1].Position[0] = vertX;
    _vertexs[1].Position[1] = vertY;
    
    _vertexs[2].Position[0] = -vertX;
    _vertexs[2].Position[1] = vertY;
    
    _vertexs[3].Position[0] = -vertX ;
    _vertexs[3].Position[1] = -vertY ;
}


@end
