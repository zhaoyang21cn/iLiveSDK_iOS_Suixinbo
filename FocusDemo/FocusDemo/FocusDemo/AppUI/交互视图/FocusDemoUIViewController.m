//
//  FocusDemoUIViewController.m
//  FocusDemo
//
//  Created by wilderliao on 16/9/18.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "FocusDemoUIViewController.h"

@implementation FocusDemoUIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delaysTouchesBegan = YES;
    
    UITapGestureRecognizer *doubletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
    doubletap.numberOfTapsRequired = 2;
    doubletap.delaysTouchesBegan = YES;
    
    [singleTap requireGestureRecognizerToFail:doubletap];
    
    [self.view addGestureRecognizer:singleTap];
    [self.view addGestureRecognizer:doubletap];
    
    _focusView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"focusbutton"]];
    [_focusView setHidden:YES];
    [_focusView setBackgroundColor:[UIColor clearColor]];
    [_focusView setFrame:CGRectMake(self.view.bounds.size.width/2 - 50, self.view.bounds.size.height * 1/2 - 50, 100, 100)];
    [self.view addSubview:_focusView];

}

- (void)onClose:(ImageTitleButton *)button
{
    [_liveController alertExitLive];
}

- (void)onDoubleTap:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.view];
    
    [_focusView.layer removeAllAnimations];
    
    __weak FocusDemoUIViewController *ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [ws layoutFoucsView:point];
    });
    
    static BOOL isscale = YES;
    CGFloat rate = isscale ? 1.0 : -2.0;
    [ self zoomPreview:rate];
    isscale = !isscale;
}

+(BOOL)isIphone4S:(UIViewController*)controller
{
    if (controller.view.bounds.size.height <= 480)
    {
        DebugLog(@"is 4s, width:%f", controller.view.bounds.size.width);
        return YES;
    }
    return NO;
}

-(void)zoomPreview:(float)rate
{
    // 以下是获取AVCaptureSession演示摄像头缩放的。iphone4s暂时不支持。
    if ([FocusDemoUIViewController isIphone4S:self])
    {
        return;
    }
    //to do
    QAVVideoCtrl *videoCtrl = [_roomEngine getVideoCtrl];
    AVCaptureSession *session = [videoCtrl getCaptureSession];
    if (session)
    {
        for( AVCaptureDeviceInput *input in session.inputs)
        {
            
            NSError* error = nil;
            AVCaptureDevice*device = input.device;
            
            if ( ![device hasMediaType:AVMediaTypeVideo] )
                continue;
            
            BOOL ret = [device lockForConfiguration:&error];
            if (error)
            {
                DebugLog(@"ret = %d",ret);
            }
            
            if (device.videoZoomFactor == 1.0)
            {
                CGFloat current = 2.0;
                if (current < device.activeFormat.videoMaxZoomFactor)
                {
                    [device rampToVideoZoomFactor:current withRate:10];
                }
            }
            else
            {
                [device rampToVideoZoomFactor:1.0 withRate:10];
            }
            [device unlockForConfiguration];
            break;
        }
    }
}

- (void)onSingleTap:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self.view];
    
    [_focusView.layer removeAllAnimations];
    
    __weak FocusDemoUIViewController *ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [ws layoutFoucsView:point];
    });
    
    QAVVideoCtrl *videoCtrl = [_roomEngine getVideoCtrl];
    AVCaptureSession *session = [videoCtrl getCaptureSession];
    
    CGPoint capturePoint = [self layerPointOfInterestForPoint:point];
    
    if (session)
    {
        NSArray *inputs = session.inputs;
        
        for (AVCaptureDeviceInput *input in inputs)
        {
            AVCaptureDevice *captureDevice= input.device;
            
            NSError *error;
            
            CGPoint point = captureDevice.focusPointOfInterest;
            DebugLog(@"modifyCaptureProperty point = {%f,%f}",point.x,point.y);
            
            BOOL isLock = [captureDevice lockForConfiguration:&error];
            if (!isLock)
            {
                DebugLog(@"锁定锁定出错:%@",error.localizedDescription);
            }
            else
            {
                [session beginConfiguration];
                
                if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
                {
                    [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                }
                else
                {
                    DebugLog(@"聚焦失败");
                }
                
                //聚焦点的位置
                if ([captureDevice isFocusPointOfInterestSupported])
                {
                    [captureDevice setFocusPointOfInterest:capturePoint];
                }
                //曝光模式
                if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose])
                {
                    [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
                }
                else
                {
                    DebugLog(@"曝光模式修改失败");
                }
                
                //曝光点的位置
                if ([captureDevice isExposurePointOfInterestSupported])
                {
                    [captureDevice setExposurePointOfInterest:capturePoint];
                }
                
                [captureDevice unlockForConfiguration];
                [session commitConfiguration];
            }
        }
    }
}


//功能：将交互视图上的点映射成渲染视图的点
//本demo只实现了全屏下的聚焦和缩放功能，所以在转换时使用的liveViewController.livePreview.imageView，如果用户要将交互视图上的点映射为小画面的，这里需要替换成小画面上方的透明视图，在随心播中，小画面上的透明视图对应为TCShowMultiSubView对象
- (CGPoint)layerPointOfInterestForPoint:(CGPoint)point
{
    FocusDemoViewController *liveViewController = (FocusDemoViewController *)_liveController;
    
    CGRect rect = [liveViewController.livePreview.imageView relativePositionTo:[UIApplication sharedApplication].keyWindow];
    
    BOOL isContain = CGRectContainsPoint(rect, point);
    
    if (isContain)
    {
        CGFloat x = (point.x - rect.origin.x)/rect.size.width;
        CGFloat y = (point.y - rect.origin.y)/rect.size.height;
        
        CGPoint layerPoint = CGPointMake(x, y);
        
        return layerPoint;
    }
    
    return CGPointMake(0, 0);
}


- (void)layoutFoucsView:(CGPoint)point
{
    DebugLog(@"(------%f,%f-----)",point.x, point.y);
    
    CGFloat focusViewWidth = _focusView.frame.size.width;
    CGFloat focueviewHeight = _focusView.frame.size.height;
    
    [_focusView setFrame:CGRectMake(point.x - focusViewWidth/2, point.y - focueviewHeight/2, focusViewWidth, focueviewHeight)];
    _focusView.hidden = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        _focusView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        _focusView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        if (!finished)
        {
            DebugLog(@"fail 0.5");
            _focusView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            _focusView.alpha = 1;
        }
        else
        {
            [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                _focusView.alpha = 0;
            } completion:^(BOOL finished) {
                
                _focusView.hidden = YES;
                _focusView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                
                if (!finished)
                {
                    DebugLog(@"fail 2.0");
                    _focusView.alpha = 0;
                }
                
            }];
        }
    }];
}
@end
