//
//  RecvCallViewController.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewModelAble.h"
#import "RecvCallView.h"

@interface RecvCallViewController : UIViewController<RecvCallViewDelegate>

- (void)setRecvCallModel:(id<RecvCallAble>)viewModel;

@end
