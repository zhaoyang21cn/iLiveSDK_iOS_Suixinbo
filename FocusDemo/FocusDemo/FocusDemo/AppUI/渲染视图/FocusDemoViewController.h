//
//  FocusDemoViewController.h
//  FocusDemo
//
//  Created by wilderliao on 16/9/18.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "TCAVMultiLiveViewController.h"

@interface FocusDemoViewController : TCAVMultiLiveViewController
{
    UIView *view1;
    AVCaptureVideoPreviewLayer *previewLayer;
    UIImageView     *_focusView;
}
@end
