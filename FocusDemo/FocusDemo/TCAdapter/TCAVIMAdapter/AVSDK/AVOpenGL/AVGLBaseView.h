//
//  AVGLView.h
//  OpenGLRestruct
//
//  Created by vigoss on 14-11-10.
//  Copyright (c) 2014年 vigoss. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "AVGLRenderView.h"
#import "AVGLCommon.h"

@protocol AVGLBaseViewDelegate <NSObject>

- (void) onGlViewAllRemoved;
- (void) onGlViewNewAdded;
- (NSString *)getNickName:(NSString *)uin;
@end

@interface AVGLBaseView : UIView
{
    GLuint                  _renderBuffer;//handle render buffer object
    GLuint                  _frameBuffer;//handle frame buffer object
    

    CAEAGLLayer             *_eaglLayer;
    

    NSMutableDictionary     * _subViews;
    
    NSMutableArray          * _subViewsKey;
        
//    NSTimer                 * _timer;
    CADisplayLink           *_timer;
    
    id<AVGLBaseViewDelegate> _delegate;
}

@property (nonatomic,assign) id<AVGLBaseViewDelegate> delegate;
- (void)changeSubviewForKey:(NSString *)oldKey withKey:(NSString *)newKey;

- (BOOL)switchSubviewForKey:(NSString *)oldKey withKey:(NSString *)newKey;

- (void)addSubview:(AVGLRenderView*)view forKey:(NSString *)key;
- (void)removeSubviewForKey:(NSString *)key;
- (void)removeAllSubviewKeys;
- (AVGLRenderView *)getSubviewForKey:(NSString *)key;
- (NSString*) smallViewsHittest:(CGPoint)point;
- (BOOL) hasSmallView;

- (void)bringSubviewToFront:(NSString *)key;

- (void)stopDisplay;
- (void)startDisplay;

- (void)destroyOpenGL;

- (void) initOpenGL;

- (void)setCuttingEnable:(BOOL)enable;

- (void)setHasBlackEdge:(BOOL)hasEdge;

- (void)setBackGroundTransparent:(BOOL)isTransprent;

- (void)blockImageForKey:(NSString *)key;

- (void)switchToFloatState;

- (void)switchToFullState;

- (void)flushFrame;

- (BOOL)isDisplay;
@end
