//
//  LiveCallView.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveCallView : UIView

@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *hangUpBtn;

@property (nonatomic, strong) NSTimer *timeoutTimer;

@end
