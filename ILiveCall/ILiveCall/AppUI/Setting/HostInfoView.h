//
//  HostInfoView.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewModelAble.h"

@interface HostInfoView : UIView
@property (nonatomic,strong) id<HostInfoAble> hostInfoModel;

- (void)setHostInfo;

@end
