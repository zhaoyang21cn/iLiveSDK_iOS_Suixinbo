//
//  LiveViewController+AVListener.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveViewController.h"

@interface MyTapGesture : UITapGestureRecognizer

@property (nonatomic, copy) NSString *codeId;
@end

@interface LiveViewController (AVListener)<ILVLiveAVListener>

@end
