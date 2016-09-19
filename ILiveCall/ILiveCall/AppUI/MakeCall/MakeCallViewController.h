//
//  MakeCallViewController.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewModelAble.h"
#import "MakeCallView.h"

@interface MakeCallViewController : UIViewController<MakeCallViewDelegate>
@property(nonatomic,assign) CallType callType;
@property(nonatomic,strong) NSString * peerId;

- (void)setMakeCallModel:(id<MakeCallAble>)viewModel;

@end
