//
//  RecvCallView.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecvCallViewDelegate <NSObject>
@required
- (void)onExitCall:(NSString*)tips;

@end

@interface RecvCallView : UIView<RecvCallListener>

- (void)setRecvCallModel:(id<RecvCallAble>)viewModel andDelegate:(id<RecvCallViewDelegate>)delegate;

@end
