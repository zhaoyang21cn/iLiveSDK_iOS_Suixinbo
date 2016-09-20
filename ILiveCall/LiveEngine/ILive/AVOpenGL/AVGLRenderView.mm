//
//  AVGLRenderView.m
//  OpenGLRestruct
//
//  Created by vigoss on 14-11-10.
//  Copyright (c) 2014年 vigoss. All rights reserved.
//

#import "AVGLRenderView.h"
#import "AVGLShareInstance.h"
#import "AVGLBaseView.h"
#import "AVGLCommon.h"

void myswap(float *a, float *b){float temp = *a; *a = *b; *b = temp;}
float myMinf(float a, float b){
    return a > b ? b : a;
}
@interface AVGLAnimationObject : NSObject
{
    int                     _animationStep;
    NSTimeInterval          _animationDuration;
    UIViewAnimationCurve    _animationCurve;
    id                      _animationDelegate;
    ENAnimationType         _animationType;
    SEL                     _animationStopSelector;
    NSTimer                 *_animationTimer;
    NSMutableArray          *_animationListener;
    NSString                *_animationKey;
    QQAVShowPanelRestruct   *_animationBaseView;
}
@property (nonatomic,assign) int                    animationSetp;
@property (nonatomic,assign) NSTimeInterval         animationDuration;
@property (nonatomic,assign) UIViewAnimationCurve   animationCurve;
@property (nonatomic,assign) id                     animationDelegate;
@property (nonatomic,assign) ENAnimationType        animationType;
@property (nonatomic,assign) SEL                    animationStopSelector;
@property (nonatomic,retain) NSTimer *              animationTimer;
@property (nonatomic,retain) NSMutableArray *       animationListener;
@property (nonatomic,copy)   NSString  *            animationKey;
@property (nonatomic,retain) QQAVShowPanelRestruct *animationBaseView;
@end

@implementation AVGLAnimationObject

@synthesize animationCurve = _animationCurve,animationDelegate = _animationDelegate,animationDuration = _animationDuration,animationSetp = _animationSetp,animationType = _animationType,animationStopSelector = _animationStopSelector, animationBaseView = _animationBaseView;

-(void)dealloc{
    if (_animationTimer) {
        [_animationTimer invalidate];
        [_animationTimer release];
        _animationTimer=nil;
    }
    if (_animationBaseView) {
        [_animationBaseView release];
        _animationBaseView = nil;
    }
    if (_animationKey) {
        [_animationKey release];
        _animationKey = nil;
    }
    if (_animationListener) {
        [_animationListener release];
        _animationListener = nil;
    }
    
    [super dealloc];
}

@end

int                         g_glAnimationStep;
NSTimeInterval              g_glAnimationDuration;
NSMutableArray *            g_glAnimationListers;
NSTimer        *            g_glAnimationTimer;

UIViewAnimationCurve        g_glAnimationCurve;
ENAnimatioState             g_glAnimationStatus;
SEL                         g_glAnimationStopSelector;
id                          g_glAnimationDelegate;
ENAnimationType             g_glAnimationType;

NSMutableDictionary         *g_glAnimationSet;
NSString                    *g_glAnimationKey;
BOOL                        g_glAnimationNeedCommitFlag;
QQAVShowPanelRestruct       *g_glAnimationBaseView;

Vertex backGroundVertex[4] =
{
    {{-1,1,0},{0,0}},
    {{-1,-1,0},{0,1}},
    {{1,-1,0},{1,1}},
    {{1,1,0},{1,0}}
};

Vertex loadintVertex[4] =
{
    {{-1,1,0},{0,0}},
    {{-1,-1,0},{0,1}},
    {{1,-1,0},{1,1}},
    {{1,1,0},{1,0}}
};

@implementation AVGLRenderView

@synthesize image = _image, frame = _frame,nickView = _nickView,delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
    {
        _textueDisplayType = Texture_Display_Type_Gaussion;
        _needDisplayLoading = YES;
        _isDisplayBlocked = NO;
        _boundWidth = 0;

        _glTextureRotateAngle = 0;
        _yRotateAngle = 180;
        _xRotateAngle = 0;
        _isDisplayStoped = NO;
        
        _nickView = [[AVGLNickView alloc] initWithFrame:CGRectZero];
        _isShowNickName = NO;
        
        [self initVertex];
        [self setupTexture];
        [self setFrame:frame];
        [self applyRotationWithDegree:90 withAxis:Rotation_Axis_Z withType:Rotation_Type_Vertex];
        [self applyRotationWithDegree:_yRotateAngle withAxis:Rotation_Axis_Y withType:Rotation_Type_Vertex];
        [self applyRotationWithDegree:0 withAxis:Rotation_Axis_X withType:Rotation_Type_Vertex];
        
        _strideBuf = NULL;
        //_stirdeW = 0;
        _bufLen = 0;

    }
    return self;
}

- (void)setupTexture
{
    //最多能产生几个textures?
    _planarTextureHandles = (GLuint *)malloc(4*sizeof(GLuint));
    
    glGenTextures(4, _planarTextureHandles);
}

- (void)updateLodingVertex
{
    float vertX = [AVGLShareInstance shareInstance].loadingImage.width / _frame.size.width/2;
    float vertY = [AVGLShareInstance shareInstance].loadingImage.height/ _frame.size.height/2;
    
    _textureBoundMatrix[0] = (1 - vertX)/2;
    _textureBoundMatrix[1] = (1 + vertX)/2;
    _textureBoundMatrix[2] = (1 - vertY)/2;
    _textureBoundMatrix[3] = (1 + vertY)/2;
    
    _textureScaleMatrix[0] = 1 / vertX;
    _textureScaleMatrix[1] = 0;
    _textureScaleMatrix[2] = 0;
    _textureScaleMatrix[3] = 1 / vertY;
}

- (void)initVertex
{
    _vertexs[3].TexCoord[0] = 0;
    _vertexs[3].TexCoord[1] = 0;
    
    _vertexs[2].TexCoord[0] = 0;
    _vertexs[2].TexCoord[1] = 1;
    
    _vertexs[1].TexCoord[0] = 1;
    _vertexs[1].TexCoord[1] = 1;
    
    _vertexs[0].TexCoord[0] = 1;
    _vertexs[0].TexCoord[1] = 0;
}

- (void)setRotate:(int)angle
{
    if ([AVGLRenderView getAnimationStatus] == Animation_State_Prepare)
    {
        if ([AVGLRenderView checkAnimation:self withAnimationType:Animation_Type_Rotate])
        {
            _animationRotateDeviation = angle;
            [AVGLRenderView registerAnimation:self withAnimationType:Animation_Type_Rotate];
        }
    }
    else
    {
        [self applyRotationWithDegree:angle withAxis:Rotation_Axis_Y withType:Rotation_Type_Vertex];//刷新位置坐标。
    }
}

- (void)setAnimationStep:(CGFloat)animationStep
{
    _currentAnimationStep = animationStep;
}

- (void)setFrame:(CGRect)frame
{
    if ([AVGLRenderView getAnimationStatus] == Animation_State_Prepare)
    {
        _animationCoordDeviation[0] = frame.origin.x - _frame.origin.x;
        _animationCoordDeviation[1] = frame.origin.y - _frame.origin.y;
        _animationCoordDeviation[2] = frame.size.width - _frame.size.width;
        _animationCoordDeviation[3] = frame.size.height - _frame.size.height;
        
        _destinationFrame = frame;//记录下目标frame的位置，动画结束后，再设置一下目标frame，因为这样累加计算，最终有误差。
        
        if ([AVGLRenderView checkAnimation:self withAnimationType:Animation_Type_Transform])
        {
            [AVGLRenderView registerAnimation:self withAnimationType:Animation_Type_Transform];
        }
    }
    else
    {
        _frame = frame;
        [self updateLodingVertex];//刷新菊花坐标。
        [self updateTexCoord];//刷新裁剪坐标。
        [self updateVertexs];//刷新位置坐标。
        
        [self updateNickFrame];
        
        if (_currentAnimationStep == 0)
        {
            //如果当前没有在动画中，则要刷新一下昵称的显示和长度等逻辑
            [self updateNickView];
        }
        
    }
}

- (void) setNeedMirrorReverse:(BOOL)needMirror
{
    if (needMirror)
    {
        _yRotateAngle = 0;
        [self applyRotationWithDegree:_yRotateAngle withAxis:Rotation_Axis_Y withType:Rotation_Type_Vertex];
    }
    else
    {
        _yRotateAngle = 180;
        [self applyRotationWithDegree:_yRotateAngle withAxis:Rotation_Axis_Y withType:Rotation_Type_Vertex];
    }
}

- (void) setHasBlackEdge:(BOOL)hasEdge
{
    if (_isShowNickName)
    {
        _nickView.hidden = hasEdge;
    }
    _hasBlackEdge = hasEdge;
}

- (void) setCuttingEnable:(BOOL)enable
{
    _enableCutting = enable;
}

- (void) setNickNameHidden:(BOOL)isHidden
{
    if (_isShowNickName) {
        _nickView.hidden = isHidden;
    }
}

- (void) showNikeName
{
    _isShowNickName = YES;
    _nickView.hidden = NO;
}

- (void) hideNickName
{
    _isShowNickName = NO;
    _nickView.hidden = YES;
}

- (void) setNickName:(NSString *)nickName
{
    _nickView.nickLabel.text = nickName;
}

//更新纹理显示坐标，和显示画面的哪一部分相关
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
    _vertexs[3].TexCoord[0] = stride_x;
    _vertexs[3].TexCoord[1] = stride_y;
    
    _vertexs[2].TexCoord[0] = stride_x;
    _vertexs[2].TexCoord[1] = 1-stride_y;
    
    _vertexs[1].TexCoord[0] = 1-stride_x;
    _vertexs[1].TexCoord[1] = 1-stride_y;
    
    _vertexs[0].TexCoord[0] = 1-stride_x;
    _vertexs[0].TexCoord[1] = stride_y;
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
    _vertexs[0].Position[0] = vertX;
    _vertexs[0].Position[1] = -vertY;
    
    _vertexs[1].Position[0] = vertX;
    _vertexs[1].Position[1] = vertY;
    
    _vertexs[2].Position[0] = -vertX;
    _vertexs[2].Position[1] = vertY;
    
    _vertexs[3].Position[0] = -vertX ;
    _vertexs[3].Position[1] = -vertY ;
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
    
    _vertexs[0].Position[0] = vertX;
    _vertexs[0].Position[1] = -vertY;
    
    _vertexs[1].Position[0] = vertX;
    _vertexs[1].Position[1] = vertY;
    
    _vertexs[2].Position[0] = -vertX;
    _vertexs[2].Position[1] = vertY;
    
    _vertexs[3].Position[0] = -vertX ;
    _vertexs[3].Position[1] = -vertY ;
}



- (void)setBoundsWithWidth:(float)pixels
{
    _boundWidth = pixels;
}

- (void) updateVBOWithDrawType:(EmDisplayType)drawType
{
    switch (drawType) {
        case Display_Type_BackGround:
            glBindBuffer(GL_ARRAY_BUFFER, [AVGLShareInstance shareInstance].vetexBuffer);
            glBufferData(GL_ARRAY_BUFFER, sizeof(backGroundVertex), backGroundVertex, GL_DYNAMIC_DRAW);
            glBindBuffer(GL_ARRAY_BUFFER, 0);
            break;
        case Display_Type_Loading:
            glBindBuffer(GL_ARRAY_BUFFER, [AVGLShareInstance shareInstance].vetexBuffer);
            glBufferData(GL_ARRAY_BUFFER, sizeof(backGroundVertex), loadintVertex, GL_DYNAMIC_DRAW);
            glBindBuffer(GL_ARRAY_BUFFER, 0);
            break;
        case Display_Type_Texture:
            glBindBuffer(GL_ARRAY_BUFFER, [AVGLShareInstance shareInstance].vetexBuffer);
            glBufferData(GL_ARRAY_BUFFER, sizeof(_vertexs), _vertexs, GL_DYNAMIC_DRAW);
            glBindBuffer(GL_ARRAY_BUFFER, 0);
            break;
        default:
            break;
    }
}

- (void) applyRotationWithDegree:(float)degrees withAxis:(ENRotateAxis)axis withType:(ENRotateType)rotateType
{
    float radians = degrees * 3.14159f / 180.0f;
    float s = sin(radians);
    float c = cos(radians);

    switch (axis) {
        case Rotation_Axis_X:
        {
            float zRotation[16] = { //
                c, 0, -s, 0, //
                0, 1, 0, 0,//
                s, 0, c, 0,//
                0, 0, 0, 1//
            };
            float textureRotation[4] = {
                c,s,//
                -s,c//
            };
            glUniformMatrix2fv([AVGLShareInstance shareInstance].textureRotateUinform, 1, 0, &textureRotation[0]);
            glUniformMatrix4fv([AVGLShareInstance shareInstance].rotateXMatrixUniform , 1, 0, &zRotation[0]);
        }
            break;
        case Rotation_Axis_Y:
        {
            _yRotateMatrix[0] = 1.0;
            _yRotateMatrix[5] = c;
            _yRotateMatrix[6] = s;
            _yRotateMatrix[9] = -s;
            _yRotateMatrix[10] = c;
            _yRotateMatrix[15] = 1;
            
            float textureRotation[4] = {
                1,0,//
                0,1//
            };
            glUniformMatrix2fv([AVGLShareInstance shareInstance].textureRotateUinform, 1, 0, &textureRotation[0]);
            glUniformMatrix4fv([AVGLShareInstance shareInstance].rotateYMatrixUniform , 1, 0, &_yRotateMatrix[0]);
        }
            break;
        case Rotation_Axis_Z:
        {
            if (rotateType == Rotation_Type_Vertex)
            {
                float zRotation[16] = { //
                    c, s, 0, 0, //
                    -s, c, 0, 0,//
                    0, 0, 1, 0,//
                    0, 0, 0, 1//
                };
                float textureRotation[4] = {
                    1,0,//
                    0,1//
                };
                glUniformMatrix2fv([AVGLShareInstance shareInstance].textureRotateUinform, 1, 0, &textureRotation[0]);

                glUniformMatrix4fv([AVGLShareInstance shareInstance].rotateZMatrixUniform , 1, 0, &zRotation[0]);
            }
            else
            {
                _textureRotateMatrix[0] = c;
                _textureRotateMatrix[1] = s;
                _textureRotateMatrix[2] = -s;
                _textureRotateMatrix[3] = c;
                glUniformMatrix2fv([AVGLShareInstance shareInstance].textureRotateUinform, 1, 0, &_textureRotateMatrix[0]);
                glUniformMatrix4fv([AVGLShareInstance shareInstance].rotateZMatrixUniform , 1, 0, &_yRotateMatrix[0]);
            }
        }
            break;
        default:
            break;
    }
}

- (void)drawFrame
{
    if (_isDisplayBlocked)
    {
        return;
    }
    if (_isDisplayStoped) {
        return;
    }
    [EAGLContext setCurrentContext: [[AVGLShareInstance shareInstance] context]];
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat width = _frame.size.width*scale;
    CGFloat height = _frame.size.height*scale;
    
    glViewport(_frame.origin.x*scale,((GL_SCREEN_HEIGHT>GL_SCREEN_WIDTH?GL_SCREEN_HEIGHT:GL_SCREEN_WIDTH) - _frame.size.height - _frame.origin.y)*scale, width, height);
    
    if (_onlyDisplayBackGround == YES)
    {
        [self drawBackground];
        return;
    }
    if (_textueDisplayType == Texture_Display_Type_Video_Data)
    {
        [self drawBackground];
    }
    [self drawTexture];
    if (_needDisplayLoading == YES && (_frame.size.width == GROUP_SMALL_VIEW_WIDTH || _frame.size.width == PREVIEW_LAYER_W))
    {
        [self drawLoading];
    }
}

- (void) drawTexture
{
    
    [self updateVBOWithDrawType:Display_Type_Texture];
    
    [self applyRotationWithDegree:_image.angle withAxis:Rotation_Axis_Z withType:Rotation_Type_Vertex];//每个画面的坐标都不同，所以这里也要各自都刷一遍
    

    //
    // 1
    glBindBuffer(GL_ARRAY_BUFFER, [AVGLShareInstance shareInstance].vetexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, [AVGLShareInstance shareInstance].indexBuffer);
    //
    //    // 2
    glVertexAttribPointer([AVGLShareInstance shareInstance].positionAttributeLocation, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (void*)offsetof(Vertex, Position));
    glEnableVertexAttribArray([AVGLShareInstance shareInstance].positionAttributeLocation);
    
    glVertexAttribPointer([AVGLShareInstance shareInstance].texCoordAttributeLocation, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (void*)offsetof(Vertex, TexCoord));
    glEnableVertexAttribArray([AVGLShareInstance shareInstance].texCoordAttributeLocation);
    
    glUniform1i([AVGLShareInstance shareInstance].drawTypeUniform, 0);
    glUniform1i([AVGLShareInstance shareInstance].vertexDrawTypeUniform, 0);
    
    glUniformMatrix4fv([AVGLShareInstance shareInstance].rotateYMatrixUniform , 1, 0, &_yRotateMatrix[0]);

    glUniform1f([AVGLShareInstance shareInstance].boundsUniform, _boundWidth/_frame.size.width);

    [self applyRotationWithDegree:_xRotateAngle withAxis:Rotation_Axis_X withType:Rotation_Type_Vertex];

    if (_textueDisplayType == Texture_Display_Type_Video_Data )
    {
        glUniform1i([AVGLShareInstance shareInstance].displayType, 0);
        
        int planarCount = 0;
        if (_image.dataFormat == Data_Format_I420)
        {
            glUniform1i([AVGLShareInstance shareInstance].yuvTypeUniform, 0);
            planarCount = 3;
        }
        else
        {
            glUniform1i([AVGLShareInstance shareInstance].yuvTypeUniform, 1);
            planarCount = 2;
        }

        for (int i=0; i<planarCount; i++)
        {
            glActiveTexture(GL_TEXTURE0+i);
            glBindTexture(GL_TEXTURE_2D, _planarTextureHandles[i]);
            glUniform1i([AVGLShareInstance shareInstance].textureUniforms[i], i);
        }
    }
    else
    {
        glUniform1i([AVGLShareInstance shareInstance].displayType, 1);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _planarTextureHandles[0]);
        glUniform1i([AVGLShareInstance shareInstance].textureUniforms[0], 0);
    }
    // 3
    glDrawElements(GL_TRIANGLES, 6,GL_UNSIGNED_BYTE, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
}
- (void) drawBackground
{
    return;
    [self updateVBOWithDrawType:Display_Type_BackGround];
    
    [self applyRotationWithDegree:_image.angle withAxis:Rotation_Axis_Z withType:Rotation_Type_Vertex];//每个画面的坐标都不同，所以这里也要各自都刷一遍

    glBindBuffer(GL_ARRAY_BUFFER, [AVGLShareInstance shareInstance].vetexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, [AVGLShareInstance shareInstance].indexBuffer);
    
    glVertexAttribPointer([AVGLShareInstance shareInstance].positionAttributeLocation, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (void*)offsetof(Vertex, Position));
    glEnableVertexAttribArray([AVGLShareInstance shareInstance].positionAttributeLocation);
    
    glVertexAttribPointer([AVGLShareInstance shareInstance].texCoordAttributeLocation, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (void*)offsetof(Vertex, TexCoord));
    glEnableVertexAttribArray([AVGLShareInstance shareInstance].texCoordAttributeLocation);
    
    glUniform1i([AVGLShareInstance shareInstance].drawTypeUniform, 1);
    glUniform1i([AVGLShareInstance shareInstance].vertexDrawTypeUniform, 1);

    glUniform1f([AVGLShareInstance shareInstance].boundsUniform, _boundWidth/_frame.size.width);

    glDrawElements(GL_TRIANGLES, 6,GL_UNSIGNED_BYTE, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
}

- (void) drawLoading
{
    return;
    [self updateVBOWithDrawType:Display_Type_Loading];
    
    glBindBuffer(GL_ARRAY_BUFFER, [AVGLShareInstance shareInstance].vetexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, [AVGLShareInstance shareInstance].indexBuffer);
    
    [self applyRotationWithDegree:[self getAutoRotateAngle] withAxis:Rotation_Axis_Z withType:Rotation_Type_Texture];//每个画面的坐标都不同，所以这里也要各自都刷一遍

    glVertexAttribPointer([AVGLShareInstance shareInstance].positionAttributeLocation, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (void*)offsetof(Vertex, Position));
    glEnableVertexAttribArray([AVGLShareInstance shareInstance].positionAttributeLocation);
    
    glVertexAttribPointer([AVGLShareInstance shareInstance].texCoordAttributeLocation, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (void*)offsetof(Vertex, TexCoord));
    glEnableVertexAttribArray([AVGLShareInstance shareInstance].texCoordAttributeLocation);
    
    glUniform1i([AVGLShareInstance shareInstance].drawTypeUniform, 0);
    glUniform1i([AVGLShareInstance shareInstance].vertexDrawTypeUniform, 1);

    glUniform1i([AVGLShareInstance shareInstance].displayType, 2);
    
    glUniformMatrix2fv([AVGLShareInstance shareInstance].textureScaleUniform, 1, 0, &_textureScaleMatrix[0]);
    glUniformMatrix2fv([AVGLShareInstance shareInstance].textureBoundsUniform , 1, 0, &_textureBoundMatrix[0]);

    glActiveTexture(GL_TEXTURE0+3);
    glBindTexture(GL_TEXTURE_2D, _planarTextureHandles[3]);
    glUniform1i([AVGLShareInstance shareInstance].textureUniforms[3], 3);

    glEnable( GL_BLEND );   // 启用混合
    glBlendFunc( GL_SRC_ALPHA , GL_ONE_MINUS_SRC_ALPHA ); // 是最常使用的
    

    glDrawElements(GL_TRIANGLES, 6,GL_UNSIGNED_BYTE, 0);
    
    glDisable(GL_BLEND);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
}

- (float) getAutoRotateAngle
{
    if (_glTextureRotateAngle < 120)
        _glTextureRotateAngle ++;
    else
        _glTextureRotateAngle = 0;
    return _glTextureRotateAngle * 3;
}

- (void) textureNV12: (Byte*)imageData
          widthType: (int) width
         heightType: (int) height
              index: (int) index
{
    glBindTexture(GL_TEXTURE_2D, _planarTextureHandles[index]);
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D( GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, width, height, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, imageData );
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void) textureYUV: (Byte*)imageData
          widthType: (int) width
         heightType: (int) height
              index: (int) index
{
    glBindTexture(GL_TEXTURE_2D, _planarTextureHandles[index]);
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D( GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, imageData );
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void) textureRGB: (Byte*)imageData
          widthType: (int) width
         heightType: (int) height
              index: (int) index
{
    glBindTexture(GL_TEXTURE_2D, _planarTextureHandles[index]);
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData );
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)setDisplayBlock:(BOOL)isBlock
{
    _isDisplayBlocked = isBlock;
}

- (void)setDisplayStop:(BOOL)isStop
{
    //切换悬浮窗以后，小画面3秒后隐藏逻辑
    _isDisplayStoped = isStop;
}
//绑定图像数据接口
- (void)setImage:(AVGLImage *)image
{
    _onlyDisplayBackGround = NO;
    
    switch (image.viewStatus)
    {
        case VIDEO_VIEW_LOADING:
            _needDisplayLoading = YES;
            break;
        case VIDEO_VIEW_DRAWING:
            _needDisplayLoading = NO;
            _textueDisplayType = Texture_Display_Type_Video_Data;
            break;
        case VIDEO_VIEW_NORMAL:
            _needDisplayLoading = NO;
            _textueDisplayType = Texture_Display_Type_Gaussion;
            break;
        case VIDEO_VIEW_BACKGROUND:
            _onlyDisplayBackGround = YES;
            break;
        default:
            break;
    }

    BOOL isNeedUpdateVertex = NO;
    if (_image != nil)
    {
        if (_image.width != image.width || _image.height != image.height)
        {
            //如果图像宽高长度变化
            isNeedUpdateVertex = YES;//有旋转的时候，就要更新一下顶点坐标。
        }
        if (_image.angle != image.angle) {
            isNeedUpdateVertex = YES;//有旋转的时候，就要更新一下顶点坐标。
        }
    }
    else
    {
        isNeedUpdateVertex = YES;
    }
    
    if (_needDisplayLoading == YES)
    {
        AVGLImage * loadImage = [AVGLShareInstance shareInstance].loadingImage;
        [self textureRGB:loadImage.data widthType:loadImage.width heightType:loadImage.height index:3];
    }
    else
    {
        if (_image != nil)
        {
            [_image release];
        }
        _image = [image retain];

        _StridedTexCoord = 1.0f;
        
        Byte * yPlane =  _image.data;
        Byte * uPlane =  _image.data + _image.width*_image.height;
        Byte * vPlane =  _image.data + _image.width*_image.height * 5 / 4;
        
        if (_image.width % 8 != 0){
            [self strideImage:yPlane u:uPlane v:vPlane];
        }
        
        if (_textueDisplayType == Texture_Display_Type_Video_Data)
        {
            //绘制视频数据是yuv420的
            if (_image.dataFormat == Data_Format_I420)
            {
                [self textureYUV:yPlane widthType:_image.width heightType:_image.height index:0];
                [self textureYUV:uPlane widthType:_image.width/2 heightType:_image.height/2 index:1];
                [self textureYUV:vPlane widthType:_image.width/2 heightType:_image.height/2 index:2];
            }
            else
            {
                [self textureYUV:yPlane widthType:_image.width heightType:_image.height index:0];
                [self textureNV12:uPlane widthType:_image.width/2 heightType:_image.height/2 index:1];
            }
        }
        else
        {
            //绘制头像数据是rgb32的
            [self textureRGB:_image.data widthType:_image.width heightType:_image.height index:0];
        }
    }
    if (isNeedUpdateVertex)
    {
        [self updateTexCoord];//刷新裁剪坐标
        [self updateVertexs];//刷新顶点坐标。
    }
}

- (void)strideImage:(Byte*&)yOut u:(Byte*&)uOut v:(Byte*&)vOut{
    
    if (_image.width % 8 == 0)
        //不需要做stride
        return;
    
    const int w = _image.width + _image.width % 8; //strided width
    int h = _image.height;
    
    int len = w*h*3/2;
    
    if (_strideBuf && len != _bufLen){
        delete []_strideBuf;
        _strideBuf = NULL;
    }
    if (!_strideBuf){
        _strideBuf = new Byte[len];
        _bufLen = len;
    }
    
    Byte* pY = _strideBuf; //new Byte [w*h];
    Byte* pU = _strideBuf + w*h;  //new Byte [w*h/4];
    Byte* pV = _strideBuf + w*h*5/4; //new Byte [w*h/4];
    
    memset(pY, 0, w*h);
    memset(pU, 128, w*h/4);
    memset(pV, 128, w*h/4);
    
    for(int n = 0; n < _image.height; n++){
        memcpy(pY+n*w, _image.data + n*_image.width, _image.width);
    }
    
    for(int n = 0; n < _image.height/ 2; n++){
        memcpy(pU+n*w/2,_image.data + _image.width*_image.height+ n* _image.width/2, _image.width/2);
    }
    
    for(int n = 0; n < _image.height/ 2; n++){
        memcpy(pV+n*w/2,_image.data + _image.width*_image.height* 5 / 4+ n* _image.width/2, _image.width/2);
    }
    
    _StridedTexCoord = (float)_image.width / w;
    
    _image.width = w;
    
    yOut = pY;
    uOut = pU;
    vOut = pV;
    

}

//动画接口
- (void)animationAtStepIndex:(int)index withAnimationType:(ENAnimationType)animationType
{
    CGFloat stepLength = [AVGLRenderView getStepLengthAtIndex:index withAnimationType:animationType];
    CGFloat coefficient = 1.0;
    
//    if (_currentAnimationStep < GL_ANIMATION_STEP_COUNT)
//    {
//         coefficient = GL_ANIMATION_STEP_COUNT / (GL_ANIMATION_STEP_COUNT - _currentAnimationStep);
//    }
    _currentAnimationStep = index;
    switch (animationType)
    {
        case Animation_Type_Transform:
        {
            CGFloat x = _frame.origin.x + coefficient * stepLength * _animationCoordDeviation[0];
            CGFloat y = _frame.origin.y + coefficient * stepLength * _animationCoordDeviation[1];
            CGFloat w = _frame.size.width + coefficient * stepLength * _animationCoordDeviation[2];
            CGFloat h = _frame.size.height + coefficient * stepLength * _animationCoordDeviation[3];
            
            CGRect newRect = CGRectMake(x, y, w, h);
            
            [self setFrame:newRect];
            [self updateTexCoord];//view的宽高变化了，也要更新画面的显示区域（裁剪区域）
        }
            break;
        case Animation_Type_Rotate:
        {
            _yRotateAngle = _yRotateAngle + stepLength * _animationRotateDeviation;
            if(_yRotateAngle == 360)
                _yRotateAngle = 0;
            [self applyRotationWithDegree:_yRotateAngle withAxis:Rotation_Axis_Y withType:Rotation_Type_Vertex];
        }
            break;
        default:
            break;
    }
}
- (void)updateNickFrame
{
    CGRect viewRect;
    switch (self.nickPosition) {
        case NickViewPosition_MiddleUp:
        {
            _nickView.nickLabel.font=[UIFont systemFontOfSize:14];
            
            NSString * nickName = _nickView.nickLabel.text;
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            CGFloat stringWidth = [nickName sizeWithFont:[UIFont systemFontOfSize:14]].width + _size_W(30);
#pragma clang diagnostic pop
            viewRect  = CGRectMake(_frame.origin.x+5, _frame.origin.y + 25, _size_W(stringWidth >_size_W(110)?_size_W(110):stringWidth), _size_W(30));
        }
            break;
        case NickViewPosition_MiddleDown:
        {
            viewRect = CGRectMake(_frame.origin.x, _frame.origin.y+ _frame.size.height - _size_W(40), _frame.size.width, _size_W(40));
        }
            break;
        case NickViewPosition_LeftUp:
        {
            
            _nickView.nickLabel.font=[UIFont systemFontOfSize:12];
            
            NSString * nickName = _nickView.nickLabel.text;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            CGFloat stringWidth = [nickName sizeWithFont:[UIFont systemFontOfSize:12]].width + _size_W(10);
#pragma clang diagnostic pop
            viewRect  = CGRectMake(_frame.origin.x+5, _frame.origin.y + 5, _size_W(stringWidth >_size_W(40)?_size_W(40):stringWidth), [UIFont systemFontOfSize:12].lineHeight);
            
        }
            break;
            
        default:
            break;
    }
    [_nickView setFrame:viewRect];
}

- (void)updateNickView
{
    CGRect viewRect,nickRect;
    UIImage * backImage = nil;
    switch (self.nickPosition) {
        case NickViewPosition_MiddleUp:
        {
            [_nickView.backGroundView setImage:nil];
            
            _nickView.nickLabel.font=[UIFont systemFontOfSize:14];
            
            NSString * nickName = _nickView.nickLabel.text;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            CGFloat stringWidth = [nickName sizeWithFont:[UIFont systemFontOfSize:14]].width + _size_W(30);
#pragma clang diagnostic pop
            viewRect  = CGRectMake(_frame.origin.x+5, _frame.origin.y + 25, _size_W(stringWidth >_size_W(110)?_size_W(110):stringWidth), _size_W(30));
            
            nickRect = CGRectMake(10, 0 , viewRect.size.width -_size_W(20), viewRect.size.height);
            
            _nickView.nickLabel.textAlignment=NSTextAlignmentCenter;
        }
            break;
        case NickViewPosition_MiddleDown:
        {
            //comment by rodgeluo
            //backImage = [[VideoNeedInfo GetInstance] getImage:@"AV_nick_small_background.png"];
            [_nickView.backGroundView setImage:backImage];
            viewRect = CGRectMake(_frame.origin.x, _frame.origin.y+ _frame.size.height - _size_W(40), _frame.size.width, _size_W(40));
            nickRect = CGRectMake(_size_W(4), viewRect.size.height - 20, viewRect.size.width - _size_W(8), 20 );
            _nickView.nickLabel.textAlignment=NSTextAlignmentLeft;
            _nickView.nickLabel.font=[UIFont systemFontOfSize:10];
        }
            break;
        case NickViewPosition_LeftUp:
        {
            [_nickView.backGroundView setImage:nil];
            
            _nickView.nickLabel.font=[UIFont systemFontOfSize:12];
            
            NSString * nickName = _nickView.nickLabel.text;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            CGFloat stringWidth = [nickName sizeWithFont:[UIFont systemFontOfSize:12]].width + _size_W(10);
#pragma clang diagnostic pop
            viewRect  = CGRectMake(_frame.origin.x+5, _frame.origin.y + 5, _size_W(stringWidth >_size_W(40)?_size_W(40):stringWidth), [UIFont systemFontOfSize:12].lineHeight);
            
            nickRect = CGRectMake(0, 0 , viewRect.size.width, viewRect.size.height);
            
            _nickView.nickLabel.textAlignment= NSTextAlignmentLeft;

        }
            break;

        default:
            break;
    }
    
    [_nickView.nickLabel setFrame:nickRect];
    
    [_nickView setFrame:viewRect];
    
    [_nickView.backGroundView setFrame:_nickView.bounds];

}
//动画接口
- (void)animationEndWithAnimationType:(ENAnimationType)animationType
{
    _currentAnimationStep = 0;
    switch (animationType)
    {
        case Animation_Type_Transform:
        {
            [self setFrame:_destinationFrame];
            [self updateNickView];
            BOOL  isControlShow = 0,isSmallView = _frame.size.width == GROUP_SMALL_VIEW_WIDTH,isBlock = _isDisplayBlocked;
            if (_delegate)
            {
                isControlShow = [_delegate isControllPanelShow];
            }
            
            if (_hasBlackEdge == NO )
            {
                if ((isSmallView && (!isBlock || isControlShow))
                    || (!isSmallView && !isControlShow) || self.isFloat == YES)
                {
                    if (_isShowNickName)
                    {
                        if ([_delegate respondsToSelector:@selector(showAllSmallNickName)])
                        {
                            [_delegate showAllSmallNickName];
                        }
                    }
                }
            }
            
            [self updateTexCoord];//view的宽高变化了，也要更新画面的显示区域（裁剪区域）
        }
            break;
        case Animation_Type_Rotate:
        {
        }
            break;
        default:
            break;
    }
}

- (void)destroyOpenGL
{
    glDeleteTextures(4, _planarTextureHandles);
    free(_planarTextureHandles);
    _planarTextureHandles = NULL;
}

- (void)dealloc
{
    if (_image){
        [_image release];
        _image = nil;
    }
    if (_nickView) {
        [_nickView release];
        _nickView = nil;
    }
    
    if (_strideBuf)
        delete[] _strideBuf;
    
    [super dealloc];
}

#pragma mark 动画相关
+ (void)removeAnimation:(AVGLRenderView *)renderView withAnimationType:(ENAnimationType)animationType
{
    NSString * key = [NSString stringWithFormat:@"%d",animationType];
    AVGLAnimationObject * object = [g_glAnimationSet objectForKey:key];
    if (object)
    {
        if (object.animationType == animationType)
        {
            [object.animationListener removeObject:renderView];
        }
    }
}

+ (BOOL)checkAnimation:(AVGLRenderView *)renderView withAnimationType:(ENAnimationType)animationType
{
    g_glAnimationKey = [NSString stringWithFormat:@"%d",animationType];
    
    AVGLAnimationObject * object = [g_glAnimationSet objectForKey:g_glAnimationKey];
    if (object)
    {
        if (![object.animationListener containsObject:renderView])
        {
            object.animationStopSelector = g_glAnimationStopSelector;
            object.animationDelegate = g_glAnimationDelegate;
            [object.animationListener addObject:renderView];
        }
        [renderView setAnimationStep:object.animationSetp];
        return NO;
    }
    g_glAnimationNeedCommitFlag = YES;
    return YES;
}

+ (void)registerAnimation:(AVGLRenderView *)renderView withAnimationType:(ENAnimationType)animationType
{
    if (g_glAnimationStatus == Animation_State_None)
    {
        return;
    }
    if(g_glAnimationListers == nil)
    {
        g_glAnimationListers = CZ_NewMutableArray();
    }
    g_glAnimationType = animationType;
    
    [g_glAnimationListers addObject:renderView];
}

+ (void)beginAnimations:(NSString *)animationID context:(void *)context
{
    
    NSLog(@"animationID:%@",animationID);
    g_glAnimationNeedCommitFlag = NO;
    g_glAnimationStatus = Animation_State_Prepare;

}

+ (void)setAnimationDidStopSelector:(SEL)selector
{
    g_glAnimationStopSelector = selector;
}

+ (void)setAnimationDelegate:(id)delegate
{
    g_glAnimationDelegate = delegate;
}

+ (void)setAnimationDuration:(NSTimeInterval)duration
{
    g_glAnimationDuration = duration;
}

//暂时只支持UIViewAnimationCurveLinear。
+ (void)setAnimationCurve:(UIViewAnimationCurve)curve
{
    g_glAnimationCurve = curve;
}

+ (void)setAnimationBaseView:(QQAVShowPanelRestruct *)baseView;
{
    g_glAnimationBaseView = baseView;
}
+ (void)commitAnimations
{
    if (g_glAnimationStatus != Animation_State_Prepare) {
        return;
    }
    if (g_glAnimationNeedCommitFlag == NO)
    {
        [AVGLRenderView resetAnimation];
        return;
    }
    g_glAnimationStatus = Animation_State_On;
    
    AVGLAnimationObject * animationObject = [AVGLAnimationObject new];
    animationObject.animationCurve = g_glAnimationCurve;
    animationObject.animationDelegate = g_glAnimationDelegate;
    animationObject.animationDuration = g_glAnimationDuration;
    animationObject.animationStopSelector= g_glAnimationStopSelector;
    animationObject.animationSetp = 0;
    animationObject.animationListener = g_glAnimationListers;
    animationObject.animationType = g_glAnimationType;
    animationObject.animationKey = g_glAnimationKey;
    animationObject.animationBaseView = g_glAnimationBaseView;
    animationObject.animationTimer = [NSTimer scheduledTimerWithTimeInterval:g_glAnimationDuration/GL_ANIMATION_STEP_COUNT target:self selector:@selector(onRenderTimer:) userInfo:g_glAnimationKey repeats:YES];
    if (g_glAnimationSet == nil)
    {
        g_glAnimationSet = CZ_NewMutableDictionary();
    }
    [g_glAnimationSet setObject:animationObject forKey:g_glAnimationKey];
    [animationObject release];
    [self resetAnimation];
}

+ (void)resetAnimation
{
    if (g_glAnimationListers)
    {
        [g_glAnimationListers release];
        g_glAnimationListers = nil;
    }
    if (g_glAnimationBaseView) {
        g_glAnimationBaseView = nil;
    }
    g_glAnimationKey = nil;
    g_glAnimationCurve = UIViewAnimationCurveEaseIn;
    g_glAnimationDelegate = nil;
    g_glAnimationStatus = Animation_State_None;
    g_glAnimationStopSelector = nil;
    g_glAnimationDuration = 0.0f;
    g_glAnimationStep = 0;
}

+ (void)removeAllAnimation
{
    if (g_glAnimationSet)
    {
        for (NSString * key in g_glAnimationSet) {
            AVGLAnimationObject * animationObj = [g_glAnimationSet objectForKey:key];
            if (animationObj) {
                if (animationObj.animationTimer) {
                    [animationObj.animationTimer invalidate];
                }
                if (animationObj.animationListener) {
                    [animationObj.animationListener removeAllObjects];
                    animationObj.animationListener = nil;
                }
                if (animationObj.animationBaseView) {
                    animationObj.animationBaseView = nil;
                }
            }
        }
        [g_glAnimationSet removeAllObjects];
        [g_glAnimationSet release];
        g_glAnimationSet = nil;
    }
    
    [g_glAnimationListers removeAllObjects];
    
    g_glAnimationCurve = UIViewAnimationCurveEaseIn;
    g_glAnimationDelegate = nil;
    g_glAnimationStatus = Animation_State_None;
    g_glAnimationStopSelector = nil;
    g_glAnimationDuration = 0.0f;
    g_glAnimationStep = 0;
}

+ (BOOL)isAnimating
{
    return [g_glAnimationSet count]>0;
}

+ (ENAnimatioState)getAnimationStatus
{
    return g_glAnimationStatus;
}

+ (CGFloat)getStepLengthAtIndex:(int)index withAnimationType:(ENAnimationType)animationType
{
    CGFloat stepLength;
    NSString * key = [NSString stringWithFormat:@"%d",animationType];
    AVGLAnimationObject * object = [g_glAnimationSet objectForKey:key];
    switch (object.animationCurve)
    {
        case UIViewAnimationCurveLinear:
            stepLength = 1.0/GL_ANIMATION_STEP_COUNT;
            break;
        case UIViewAnimationCurveEaseInOut:
            stepLength = 1.0/1540.0 * index * (21 - index);
            break;
        default:
            stepLength = 1.0/GL_ANIMATION_STEP_COUNT;
            break;
            break;
    }
    return stepLength;
}

+ (void)onRenderTimer:(NSTimer *)timer
{
    NSString * key = timer.userInfo;
    AVGLAnimationObject * animationObject = [g_glAnimationSet objectForKey:key];
    
    int animationStep = animationObject.animationSetp;
    animationStep ++;
    animationObject.animationSetp = animationStep;
    
    if (animationStep < GL_ANIMATION_STEP_COUNT +1)
    {
        QQAVShowPanelRestruct * baseView = animationObject.animationBaseView;
        if (baseView) {
            [baseView flushFrame];
        }
        
        for (AVGLRenderView * animationView in animationObject.animationListener)
        {
            [animationView animationAtStepIndex:animationStep withAnimationType:animationObject.animationType];
        }
    }
    else
    {
        for (AVGLRenderView * animationView in animationObject.animationListener)
        {
            [animationView animationEndWithAnimationType:animationObject.animationType];
        }
        
        if (animationObject.animationDelegate != nil)
        {
            //这里的delegate 是要retain吗？否则如果 对象已经释放了，这里的timer还在走。
            [animationObject.animationDelegate performSelector:animationObject.animationStopSelector withObject:nil afterDelay:0.0f];
            //            [g_glAnimationDelegate performSelector:g_glAnimationStopSelector withObject:nil];
            animationObject.animationDelegate = nil;
        }
        if (animationObject.animationTimer)
        {
            [animationObject.animationTimer invalidate];
        }
        if (animationObject.animationListener)
        {
            [animationObject.animationListener removeAllObjects];
            animationObject.animationListener = nil;
        }
        if (animationObject.animationBaseView) {
            animationObject.animationBaseView = nil;
        }
        [g_glAnimationSet removeObjectForKey:animationObject.animationKey];
    }
}

- (void)setIsFloat:(BOOL)isFloat
{
    _isFloat = isFloat;
    [self updateTexCoord];
    [self updateVertexs];
}


@end


@implementation AVGLNickView

@synthesize backGroundView = _backGroundView,nickLabel = _nickLabel;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _backGroundView = CZ_NewUIImageViewWithFrame(frame);
        _nickLabel = CZ_NewUILabelWithFrame(CGRectZero);
        [self addSubview:_backGroundView];
        [self addSubview:_nickLabel];
    }
    return self;
}
- (void)dealloc
{
    if (_backGroundView) {
        [_backGroundView removeFromSuperview];
        [_backGroundView release];
        _backGroundView = nil;
    }
    if (_nickLabel) {
        [_nickLabel removeFromSuperview];
        [_nickLabel release];
        _nickLabel = nil;
    }
    [super dealloc];
}

@end