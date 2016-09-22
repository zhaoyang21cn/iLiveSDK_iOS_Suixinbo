//
//  AVGLShareInstance.h
//  OpenGLRestruct
//
//  Created by vigoss on 14-11-11.
//  Copyright (c) 2014年 vigoss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVGLCommon.h"

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
@class AVGLImage;
@interface AVGLShareInstance : NSObject
{
    
    EAGLContext *_context;
        
    GLuint * _textureUniforms;
    
    GLuint _rotateXMatrixUniform;
    GLuint _rotateYMatrixUniform;
    GLuint _rotateZMatrixUniform;

    GLuint _positionAttributeLocation;
    GLuint _texCoordAttributeLocation;
    
    GLuint _vertexShaderHandle;
    GLuint _fragmentShaderHandle;
    GLuint _programHandle;

    GLuint _vertexBuffer;//handle Vetex buffer object
    GLuint _indexBuffer;//handle Indice buffer object
    
    GLuint _boundsUniform;
    
    GLuint _boundsCoordXUniform;
    GLuint _boundsCoordYUniform;
    
    GLuint _drawTypeUniform;
    
    GLuint _vertexDrawTypeUniform;
    
    GLuint _displayType;
    
    GLuint _textureRotateUniform;

    GLuint _textureBoundsUniform;
    
    GLuint _textureScaleUniform;
    
    GLuint _yuvTypeUniform;

    AVGLImage * _loadingImage;
}

@property (nonatomic,retain) EAGLContext * context;

@property (nonatomic,assign) GLuint *textureUniforms;

@property (nonatomic,assign) GLuint positionAttributeLocation;
@property (nonatomic,assign) GLuint texCoordAttributeLocation;

@property (nonatomic,assign) GLuint indexBuffer;
@property (nonatomic,assign) GLuint vetexBuffer;

@property (nonatomic,assign) GLuint rotateXMatrixUniform;
@property (nonatomic,assign) GLuint rotateYMatrixUniform;
@property (nonatomic,assign) GLuint rotateZMatrixUniform;

@property (nonatomic,assign) GLuint boundsUniform;

@property (nonatomic,assign) GLuint boundsCoordXUniform;
@property (nonatomic,assign) GLuint boundsCoordYUniform;

@property (nonatomic,assign) GLuint drawTypeUniform;

@property (nonatomic,assign) GLuint vertexDrawTypeUniform;

@property (nonatomic,assign) GLuint displayType;

@property (nonatomic,assign) GLuint textureRotateUinform;
@property (nonatomic,assign) GLuint textureBoundsUniform;
@property (nonatomic,assign) GLuint textureScaleUniform;

@property (nonatomic,assign) GLuint yuvTypeUniform;

@property (nonatomic,retain) AVGLImage * loadingImage;

+(AVGLShareInstance *)shareInstance;
- (void)initOpenGL;
- (void)destroyOpenGL;
@end
