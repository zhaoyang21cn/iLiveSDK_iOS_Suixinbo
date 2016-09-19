//
//  AVGLView.m
//  OpenGLRestruct
//
//  Created by vigoss on 14-11-10.
//  Copyright (c) 2014年 vigoss. All rights reserved.
//

#import "AVGLBaseView.h"

#import "AVGLShareInstance.h"

//#import "IServiceFactory.h"
//#import "IVideoNeedInfo.h"

@interface AVGLBaseView(){
    BOOL _stopDisplay;
}

- (void)display;

- (void)setupLayer;
- (void)setupRenderBuffer;
- (void)setupFrameBuffer;

@end


@implementation AVGLBaseView

@synthesize delegate = _delegate;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code[]
        
        _subViews = [[NSMutableDictionary alloc] init];
        _subViewsKey = [[NSMutableArray alloc] init];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.clipsToBounds = YES;
        _stopDisplay= YES;
        
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void) initOpenGL
{
    [[AVGLShareInstance shareInstance] initOpenGL];
    [self setupLayer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

// 1
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)flushFrame
{
    if (_timer == nil) {
        return;
    }
    [self display];
}

- (void)display
{
    if(_stopDisplay)
    {
        //nstimer如果cpu繁忙可能延时，导致切后台的时候渲染opengl crash
        return;
    }
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    @synchronized(_subViewsKey)
    {
        for (NSString * keys in _subViewsKey)
        {
            AVGLRenderView * subView = [_subViews objectForKey:keys];
            [subView drawFrame];
        }
    }
    [[AVGLShareInstance shareInstance].context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)startDisplay
{
    if (_timer != nil)
    {
        [self stopDisplay];
    }
    
    _stopDisplay=NO;
    [self display];
//    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(display) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    _timer = [[CADisplayLink displayLinkWithTarget:self selector:@selector(display)] retain];
    _timer.frameInterval = 3;
    [_timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

- (void)stopDisplay
{
    DebugLog(@"=====>>>>>>>>start stopDisplay");
    _stopDisplay = YES;
    
    if (_timer) {
        [_timer removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [_timer invalidate];
        [_timer release];
        _timer = nil;
    }
}

-(void)destroyOpenGL
{
    // 正常调用顺序是：stopDisplay---> destoryOpenGL，
    // 防止外部用户，停止直播时没有stopDisplay，还要继续调用display方法然后crash问题
    DebugLog(@"=====>>>>>>>>start DestoryOpenGL");
    [self stopDisplay];
    
    if (_frameBuffer != -1){
        glDeleteFramebuffers(1, &_frameBuffer);
    }
    if (_renderBuffer != -1){
        glDeleteRenderbuffers(1, &_renderBuffer);
    }
    for (NSString * key in _subViews) {
        AVGLRenderView * glView = _subViews[key];
        [glView destroyOpenGL];
    }
    [[AVGLShareInstance shareInstance] destroyOpenGL];
    DebugLog(@"=====>>>>>>>> DestoryOpenGL Over");

}

-(void)setupLayer
{
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
}


- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [[AVGLShareInstance shareInstance].context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,GL_RENDERBUFFER, _renderBuffer);
}


#pragma mark View逻辑相关
- (void)addSubview:(AVGLRenderView*)view forKey:(NSString *)key
{
    if ([_subViewsKey count] == 0)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(onGlViewNewAdded)])
        {
            [_delegate onGlViewNewAdded];
        }
    }
    [_subViews setObject:view forKey:key];
    [_subViewsKey addObject:key];
    
    //画面昵称。
    [self addNickName:key forView:view];
}

- (void)addNickName:(NSString *)key forView:(AVGLRenderView *)view
{
    NSArray * keys = [key componentsSeparatedByString:@"+"];
    NSString * uin = [keys objectAtIndex:0];
    NSString * nickName = [_delegate getNickName:uin];
    
    AVGLNickView * nickView = view.nickView;
    CGRect viewRect,nickRect;
    UIImage * backImage = nil;
    
    if (view.frame.size.width > GROUP_SMALL_VIEW_WIDTH)
    {
//        backImage = [[VideoNeedInfo GetInstance] getImage:@"AV_nick_big_background.png"];
//        
//        UIImage * newImage = [backImage stretchableImageWithLeftCapWidth:backImage.size.width/2 topCapHeight:backImage.size.height/2];
       
        [nickView.backGroundView setImage:nil];
        
        nickView.nickLabel.font=[UIFont systemFontOfSize:14];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGFloat stringWidth = [nickName sizeWithFont:[UIFont systemFontOfSize:14]].width + _size_W(30);
#pragma clang diagnostic pop
        viewRect  = CGRectMake(view.frame.origin.x+5, view.frame.origin.y + 25, _size_W(stringWidth >_size_W(110)?_size_W(110):stringWidth), _size_W(30));
        
        nickRect = CGRectMake(10, 0 , viewRect.size.width -_size_W(20), viewRect.size.height);
        
        nickView.nickLabel.textAlignment=NSTextAlignmentCenter;
    }
    else
    {
        //此处涉及到的VideoNeedInfo模块较为庞大，先注释，而且后续opensdk未必需要nickname -- rodgeluo
        //backImage = [[VideoNeedInfo GetInstance] getImage:@"AV_nick_small_background.png"];
        [nickView.backGroundView setImage:backImage];
        viewRect = CGRectMake(view.frame.origin.x, view.frame.origin.y+ view.frame.size.height - _size_W(40), view.frame.size.width, _size_W(40));
        nickRect = CGRectMake(_size_W(4), viewRect.size.height - 24, viewRect.size.width - _size_W(18), 24 );
        nickView.nickLabel.textAlignment=NSTextAlignmentLeft;
        nickView.nickLabel.font=[UIFont systemFontOfSize:10];
    }

    //样式
    nickView.nickLabel.textColor=[UIColor whiteColor];
    nickView.nickLabel.lineBreakMode=NSLineBreakByTruncatingTail;
    nickView.nickLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    nickView.nickLabel.shadowColor = [UIColor grayColor];

    nickView.nickLabel.backgroundColor = [UIColor clearColor];
    [nickView setBackgroundColor:[UIColor clearColor]];
    
    //文本
    [nickView.nickLabel setText:nickName];
    
    //位置
    [nickView setFrame:viewRect];
    [nickView.backGroundView setFrame:nickView.bounds];
    [nickView.nickLabel setFrame:nickRect];
    
    [self addSubview:nickView];
}

- (void)removeSubviewForKey:(NSString *)key
{
    @synchronized(_subViewsKey)
    {
        
        AVGLRenderView * renderView = [_subViews objectForKey:key];
        [AVGLRenderView removeAnimation:renderView withAnimationType:Animation_Type_Transform];
        [AVGLRenderView removeAnimation:renderView withAnimationType:Animation_Type_Rotate];
        renderView.delegate = nil;
        AVGLNickView * nickLabel = renderView.nickView;
        if (nickLabel) {
            [nickLabel removeFromSuperview];
        }

        [_subViews removeObjectForKey:key];
        
        //昵称移除。
        
        int removeIndex = -1;
        
        for (int i = 0;i< [_subViewsKey count];i++)
        {
            NSString * viewKey = _subViewsKey[i];
            
            if ([viewKey isEqualToString:key])
            {
                removeIndex = i;
            }
        }
        if (removeIndex != -1) {
            [_subViewsKey removeObjectAtIndex:removeIndex];
        }
        if ([_subViewsKey count] == 0)
        {
//            [self stopDisplay];
            if (_delegate && [_delegate respondsToSelector:@selector(onGlViewAllRemoved)])
            {
                [_delegate onGlViewAllRemoved];
            }
        }
    }
}

- (void)removeAllSubviewKeys
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:_subViewsKey];
    for (NSString *key in array)
    {
        [self removeSubviewForKey:key];
    }
}

- (AVGLRenderView*)getSubviewForKey:(NSString *)key
{
    return [_subViews objectForKey:key];
}

- (void)changeSubviewForKey:(NSString *)oldKey withKey:(NSString *)newKey
{
    int removeIndex = -1;
    
    for (int i = 0;i< [_subViewsKey count];i++)
    {
        NSString * viewKey = _subViewsKey[i];
        
        if ([viewKey isEqualToString:oldKey])
        {
            removeIndex = i;
            break;
        }
    }
    if (removeIndex != -1) {
        [_subViewsKey removeObjectAtIndex:removeIndex];
    }
    [_subViewsKey insertObject:newKey atIndex:removeIndex];
    
    AVGLRenderView * glView = [_subViews objectForKey:oldKey];
    [_subViews setObject:glView forKey:newKey];
    [_subViews removeObjectForKey:oldKey];
}

- (BOOL)switchSubviewForKey:(NSString *)fromKey withKey:(NSString *)toKey
{
    int fromIndex = -1;
    int toIndex = -1;
    
    for (int i = 0;i< [_subViewsKey count]; i++)
    {
        NSString * viewKey = _subViewsKey[i];
        
        if ([viewKey isEqualToString:fromKey])
        {
            fromIndex = i;
        }
        
        if ([viewKey isEqualToString:toKey])
        {
            toIndex = i;
        }
        
        
        if (fromIndex != -1 && toIndex != -1)
        {
            break;
        }
        
    }
    
    
    if (fromIndex != -1 && toIndex != -1)
    {
//        [_subViewsKey removeObjectAtIndex:fromIndex];
//        [_subViewsKey addObject:<#(nonnull id)#>];
        
        [_subViewsKey replaceObjectAtIndex:fromIndex withObject:toKey];
        [_subViewsKey replaceObjectAtIndex:toIndex withObject:fromKey];
        
        AVGLRenderView *fromglView = [[_subViews objectForKey:fromKey] retain];
        AVGLRenderView *toglView = [[_subViews objectForKey:toKey] retain];
        
        [_subViews removeObjectForKey:fromKey];
        [_subViews removeObjectForKey:toKey];
        
        [_subViews setObject:fromglView forKey:toKey];
        [_subViews setObject:toglView forKey:fromKey];
        
        [fromglView release];
        [toglView release];

        return YES;
    }
    return NO;
}

- (BOOL) hasSmallView {
    return _subViews && (_subViews.count>1);
}

- (void)bringSubviewToFront:(NSString *)key
{
    @synchronized(_subViewsKey)
    {
        int removeIndex = -1;
        for (int i = 0;i< [_subViewsKey count];i++)
        {
            NSString * viewKey = _subViewsKey[i];
            
            if ([viewKey isEqualToString:key])
            {
                removeIndex = i;
            }
        }
        if (removeIndex != -1)
        {
            [_subViewsKey removeObjectAtIndex:removeIndex];
            [_subViewsKey addObject:key];
        }
    }
}
- (void)setHasBlackEdge:(BOOL)hasEdge
{
    for (NSString * keys in _subViewsKey)
    {
        AVGLRenderView * subView = [_subViews objectForKey:keys];
        [subView setHasBlackEdge:hasEdge];
    }
}

- (void)setCuttingEnable:(BOOL)enable
{
    for (NSString * keys in _subViewsKey)
    {
        AVGLRenderView * subView = [_subViews objectForKey:keys];
        [subView setCuttingEnable:enable];
    }
}

- (void)blockImageForKey:(NSString *)key
{
    AVGLRenderView * renderView;
    for (NSString * glViewKey in _subViews)
    {
        renderView = [_subViews objectForKey:glViewKey];

        if ([glViewKey isEqualToString:key])
        {
            [renderView setDisplayBlock:YES];
        }
        else
        {
            [renderView setDisplayBlock:NO];
        }
    }
}

- (void)switchToFloatState
{
    @synchronized(_subViewsKey)
    {
        for (NSString * keys in _subViewsKey)
        {
            AVGLRenderView * subView = [_subViews objectForKey:keys];
            subView.isFloat = YES;
        }
    }
}

- (void)switchToFullState
{
    @synchronized(_subViewsKey)
    {
        for (NSString * keys in _subViewsKey)
        {
            AVGLRenderView * subView = [_subViews objectForKey:keys];
            subView.isFloat = NO;
        }
    }
}

#pragma mark for layout
- (NSString*) smallViewsHittest:(CGPoint)point
{
    BOOL isFirstTest = YES;
    //这里，如果大画面没有绘制，则数组第一个就是小画面。
    for (NSString * key in _subViewsKey) {
        if (isFirstTest) {
            isFirstTest = NO;
            continue;
        }
        AVGLRenderView * subView = [_subViews objectForKey:key];
        if (CGRectContainsPoint(subView.frame, point)) {
            return key;
        }
    }
    return nil;
}
- (void)setBackGroundTransparent:(BOOL)isTransprent
{
    _eaglLayer.opaque = !isTransprent;
}

- (void)dealloc
{
    if ([AVGLShareInstance shareInstance].loadingImage != nil)
    {
        free([AVGLShareInstance shareInstance].loadingImage.data);
        [AVGLShareInstance shareInstance].loadingImage.data = nil;
    }
    if (_subViews)
    {
        [_subViews removeAllObjects];
        [_subViews release];
        _subViews = nil;
    }
    if (_subViewsKey) {
        [_subViewsKey removeAllObjects];
        [_subViewsKey release];
        _subViewsKey = nil;
    }
    [super dealloc];
}

- (BOOL)isDisplay{
    return !_stopDisplay;
}
@end
