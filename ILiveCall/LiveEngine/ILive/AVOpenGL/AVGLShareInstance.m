//
//  AVGLShareInstance.m
//  OpenGLRestruct
//
//  Created by vigoss on 14-11-11.
//  Copyright (c) 2014年 vigoss. All rights reserved.
//

#import "AVGLShareInstance.h"
#import "AVGLRenderView.h"
//#import "IVideoNeedInfo.h"
//#import "QQLoggerMacro.h"

const GLubyte Indices[] =
{
    0, 1, 2,
    2, 3, 0
};

Vertex initVertices_[] = {
    {{1, -1, 0},{1,1}},
    {{1, 1, 0},{1,0}},
    {{-1, 1, 0},{0,0}},
    {{-1, -1, 0},{0,1}}
};

@interface AVGLShareInstance()

- (void)setupIndices;
- (void)setupVBO;
- (void)setupContext;

@end
@implementation AVGLShareInstance

@synthesize vetexBuffer = _vertexBuffer,indexBuffer = _indexBuffer;

@synthesize positionAttributeLocation = _positionAttributeLocation, texCoordAttributeLocation = _texCoordAttributeLocation;

@synthesize textureUniforms = _textureUniforms;

@synthesize context = _context;

@synthesize rotateXMatrixUniform = _rotateXMatrixUniform;
@synthesize rotateYMatrixUniform = _rotateYMatrixUniform;
@synthesize rotateZMatrixUniform = _rotateZMatrixUniform;

@synthesize boundsUniform = _boundsUniform;

@synthesize boundsCoordXUniform = _boundsCoordXUniform;
@synthesize boundsCoordYUniform = _boundsCoordYUniform;

@synthesize displayType = _displayType;

@synthesize loadingImage = _loadingImage;

@synthesize textureRotateUinform = _textureRotateUinform;
@synthesize textureBoundsUniform = _textureBoundsUniform;
@synthesize textureScaleUniform = _textureScaleUniform;

@synthesize yuvTypeUniform = _yuvTypeUniform;

@synthesize vertexDrawTypeUniform = _vertexDrawTypeUniform;
@synthesize drawTypeUniform = _drawTypeUniform;


+ (AVGLShareInstance *)shareInstance
{
    static AVGLShareInstance *g_sharedOpenGLInstance = nil;
    static dispatch_once_t g_shareOpenglOnce;
    dispatch_once(&g_shareOpenglOnce, ^{
        g_sharedOpenGLInstance = [AVGLShareInstance new];
    });
    return g_sharedOpenGLInstance;
}

- (void)initOpenGL
{
    [self setuploadingImage];
    [self setupContext];
    [self compileShaders];
    [self setupIndices];
    [self setupVBO];
}

- (void)setuploadingImage
{
    //此处涉及到的VideoNeedInfo模块较为庞大，先注释，而且后续opensdk未必需要nickname -- rodgeluo
    //UIImage * loadImage = [[VideoNeedInfo GetInstance] getImage:@"AV_Loading.png"];
    UIImage * loadImage = nil;
    AVGLImage * image = [AVGLImage new];
    image.width = loadImage.size.width;
    image.height = loadImage.size.height;
    image.data = [self getImageData:loadImage];
    image.isFullScreenShow = YES;
    image.angle = 0;
    self.loadingImage = image;
    [image release];
}

- (Byte *)getImageData:(UIImage *)image
{
    // 1
    int width = image.size.width;
    int height = image.size.height;
    
    CGImageRef spriteImage = image.CGImage;
    // 2
    //    size_t width = CGImageGetWidth(spriteImage);
    //    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *)calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4
    return spriteData;
}

- (void)setupContext{
    if([UIApplication sharedApplication].applicationState !=UIApplicationStateActive){
        //QQ_ERROR("background setupContext:%d",[UIApplication sharedApplication].applicationState);
        //comment -- rodgeluo
    }
    
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupVBO
{
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(initVertices_), initVertices_, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)setupIndices {
    glGenBuffers(1, &_indexBuffer);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    NSError* error = nil;    

    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char* shaderStringUTF8 = [shaderString UTF8String];
    
    int shaderStringLength = (int)[shaderString length];
    
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

- (void)destroyOpenGL
{
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_context) {
        [_context release];
        _context = nil;
    }
    if (_textureUniforms) {
        free(_textureUniforms);
        _textureUniforms = nil;
    }
    //Ëø????context = nil‰º??crash???Ëø??Ôº???∞Ê?‰∫???πÁ?demo‰ª£Á????Ê≤°Ê?Ëø???•Ô???ª•?ªÊ?Ëø????//    _context = nil;
    
    NSLog(@"GLVIEW DELLOC");
    glUseProgram(0);
    glDetachShader(_programHandle, _vertexShaderHandle);
    glDetachShader(_programHandle, _fragmentShaderHandle);
    
    glDeleteShader(_vertexShaderHandle);
    glDeleteShader(_fragmentShaderHandle);
    glDeleteProgram(_programHandle);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    if (_vertexBuffer != 0) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
    if (_indexBuffer != 0) {
        glDeleteBuffers(1, &_indexBuffer);
        _indexBuffer = 0;
    }
}

- (void)compileShaders {
    
    _vertexShaderHandle = [self compileShader:@"Shaderv"
                                     withType:GL_VERTEX_SHADER];
    _fragmentShaderHandle = [self compileShader:@"Shaderf"
                                       withType:GL_FRAGMENT_SHADER];
    
    // 2
    _programHandle = glCreateProgram();
    glAttachShader(_programHandle, _vertexShaderHandle);
    glAttachShader(_programHandle, _fragmentShaderHandle);
    glLinkProgram(_programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(_programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(_programHandle);
    
    // 5
    _positionAttributeLocation = glGetAttribLocation(_programHandle, "position");
    
    _texCoordAttributeLocation = glGetAttribLocation(_programHandle, "textureCoordinate");
    
    _textureUniforms = (GLuint *)malloc(4*sizeof(GLuint));
    
    _rotateXMatrixUniform = glGetUniformLocation(_programHandle, "rotateXMatrix");
    _rotateYMatrixUniform = glGetUniformLocation(_programHandle, "rotateYMatrix");
    _rotateZMatrixUniform = glGetUniformLocation(_programHandle, "rotateZMatrix");

    _textureUniforms[0] = glGetUniformLocation(_programHandle, "SamplerY");
    _textureUniforms[1] = glGetUniformLocation(_programHandle, "SamplerU");
    _textureUniforms[2] = glGetUniformLocation(_programHandle, "SamplerV");
    _textureUniforms[3] = glGetUniformLocation(_programHandle, "SamplerA");

    _boundsUniform = glGetUniformLocation(_programHandle, "layerBoundsWidth");
    
    _boundsCoordXUniform = glGetUniformLocation(_programHandle, "boundsCoordX");
    _boundsCoordYUniform = glGetUniformLocation(_programHandle, "boundsCoordY");

    _drawTypeUniform = glGetUniformLocation(_programHandle, "drawType");

    _vertexDrawTypeUniform = glGetUniformLocation(_programHandle, "vertexDrawType");
    
    _displayType = glGetUniformLocation(_programHandle, "displayType");
    
    _yuvTypeUniform = glGetUniformLocation(_programHandle, "yuvType");

    _textureRotateUinform = glGetUniformLocation(_programHandle, "textureRotateMatrix");
    
    _textureScaleUniform = glGetUniformLocation(_programHandle, "textureScaleMatrix");
    
    _textureBoundsUniform = glGetUniformLocation(_programHandle, "textureBoundsMatrix");
}

@end
