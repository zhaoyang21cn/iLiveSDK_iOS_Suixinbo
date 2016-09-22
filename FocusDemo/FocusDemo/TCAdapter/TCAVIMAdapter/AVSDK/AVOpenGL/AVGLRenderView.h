//
//  AVGLRenderView.h
//  OpenGLRestruct
//
//  Created by vigoss on 14-11-10.
//  Copyright (c) 2014年 vigoss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AVGLImage.h"
//#import "QQAVCommon.h"

@class QQAVShowPanelRestruct;

@interface AVGLNickView : UIView
{
    UIImageView * _backGroundView;
    UILabel     * _nickLabel;
}

@property (nonatomic,retain)UIImageView * backGroundView;
@property (nonatomic,retain)UILabel     * nickLabel;

@end
@protocol AVGLRenderViewProtocol <NSObject>

- (BOOL)isControllPanelShow;
- (void)showAllSmallNickName;
@end

typedef enum enAnimationState
{
    Animation_State_None,
    Animation_State_Prepare,
    Animation_State_On,
}ENAnimatioState;

typedef enum enAnimationType
{
    Animation_Type_Transform,
    Animation_Type_Scale,
    Animation_Type_Rotate,
    Animation_Type_Fade
}ENAnimationType;

typedef enum enNickViewPosition
{
    NickViewPosition_LeftUp,
    NickViewPosition_MiddleUp,
    NickViewPosition_MiddleDown
}ENNickViewPosition;

typedef enum enRotateAxis
{
    Rotation_Axis_X,
    Rotation_Axis_Y,
    Rotation_Axis_Z,

}ENRotateAxis;
typedef enum enRotateType
{
    Rotation_Type_Vertex,
    Rotation_Type_Texture,
    
}ENRotateType;

typedef struct
{
    float Position[3];
    float TexCoord[2];
} Vertex;

@interface AVGLRenderView : NSObject
{
    AVGLImage * _image;
    Vertex      _vertexs[4];
    CGRect      _frame;
    int         _glTextureRotateAngle;
    
    id<AVGLRenderViewProtocol> _delegate;
    
    CGFloat     _yRotateAngle;
    CGFloat     _xRotateAngle;
    
    float      _yRotateMatrix[16];
    
    float      _textureRotateMatrix[4];
    float      _textureBoundMatrix[4];
    float      _textureScaleMatrix[4];
    
    GLuint      *_planarTextureHandles;
    
    CGFloat     _boundWidth;
    
    BOOL        _enableCutting;
    BOOL        _hasBlackEdge;
    
    CGFloat     _animationCoordDeviation[4];
    CGFloat     _animationRotateDeviation;
    CGFloat     _animationAlphaDeviation;
    
    CGRect      _destinationFrame;
    
    ENTextureDisplayType _textueDisplayType;
    BOOL        _needDisplayLoading;
    CGFloat     _textureYUVType;//0表示i420  1表示nv12

    BOOL        _isDisplayBlocked;//大画面且为屏幕分享，直接屏蔽。
    BOOL        _isDisplayStoped;//这个和block不一样，给悬浮窗口逻辑用的。
    
    BOOL        _onlyDisplayBackGround;//只绘制背景
    
    CGFloat     _currentAnimationStep;
    
    AVGLNickView     *_nickView;//昵称label.
    BOOL        _isShowNickName;
    
    //对于纹理宽度不被8整除的要做下stride.
    Byte*       _strideBuf;
    int         _bufLen;
    float        _StridedTexCoord;
}

@property (nonatomic,retain) AVGLImage * image;
@property (nonatomic,assign) CGRect      frame;
@property (nonatomic,retain) AVGLNickView   * nickView;
@property (nonatomic,assign) id<AVGLRenderViewProtocol> delegate;
@property (nonatomic,assign) BOOL        isFloat;
@property (nonatomic)        ENNickViewPosition nickPosition;
- (void)destroyOpenGL;

- (id)initWithFrame:(CGRect)frame;

- (void)setImage:(AVGLImage *)image;

- (void)setFrame:(CGRect)frame;
- (void)setRotate:(int)angle;

- (void)setBoundsWithWidth:(float)pixels;

- (void)setDisplayBlock:(BOOL)isBlock;

- (void)setDisplayStop:(BOOL)isStop;

- (void)drawFrame;

//需要显示昵称
- (void)showNikeName;

//不需要显示昵称
- (void)hideNickName;

//设置昵称的显示
- (void)setNickNameHidden:(BOOL)isHidden;

//设置昵称
- (void)setNickName:(NSString *)nickName;

//给动画控制器调用的。
- (void)animationAtStepIndex:(int)index withAnimationType:(ENAnimationType)animationType;

- (void) setCuttingEnable:(BOOL)enable;

- (void) setHasBlackEdge:(BOOL)hasEdge;

- (void) setNeedMirrorReverse:(BOOL)needMirror;

- (void) setAnimationStep:(CGFloat)animationStep;

#pragma mark 动画相关
+ (void)registerAnimation:(AVGLRenderView *)renderView withAnimationType:(ENAnimationType)animationType;
+ (void)beginAnimations:(NSString *)animationID context:(void *)context;
// additional context info passed to will start/did stop selectors. begin/commit can be nested
+ (void)setAnimationDuration:(NSTimeInterval)duration;              // default = 0.2
+ (void)setAnimationCurve:(UIViewAnimationCurve)curve;              // default = UIViewAnimationCurveEaseInOut
+ (void)setAnimationDelegate:(id)delegate;                          // delegate
+ (void)setAnimationDidStopSelector:(SEL)selector;                  // default = NULL.
+ (void)setAnimationBaseView:(QQAVShowPanelRestruct *)baseView;
+ (void)commitAnimations;

+ (void)removeAnimation:(AVGLRenderView *)renderView withAnimationType:(ENAnimationType)animationType;

+ (ENAnimatioState)getAnimationStatus;  // starts up any animations when the top level animation is commited

+ (CGFloat)getStepLengthAtIndex:(int)index withAnimationType:(ENAnimationType)animationType;

+ (void)removeAllAnimation;

+ (BOOL)isAnimating;

- (void)updateNickView;

@end


