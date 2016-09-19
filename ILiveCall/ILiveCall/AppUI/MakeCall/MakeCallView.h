//
//  MakeCallView.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MakeCallViewDelegate <NSObject>
@required
- (void)onExitCall:(NSString*)tips;

@end

@interface MakeCallView : UIView<MakeCallListener>

- (void)setMakeCallModel:(id<MakeCallAble>)viewModel andDelegate:(id<MakeCallViewDelegate>)delegate;

@end
