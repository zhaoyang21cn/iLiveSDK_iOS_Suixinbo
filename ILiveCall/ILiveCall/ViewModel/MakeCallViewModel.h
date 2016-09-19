//
//  MakeCallViewModel.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewModelAble.h"
#import "EngineHeaders.h"

@interface MakeCallViewModel : NSObject<MakeCallAble>

@property(nonatomic,weak) id<MakeCallListener> listener;

@end
