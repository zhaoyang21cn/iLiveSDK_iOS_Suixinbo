//
//  DialSessionCell.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewModelAble.h"

@interface DialSessionCell : UITableViewCell
@property(nonatomic,copy) NSIndexPath * indexPath;

- (void)setSessionInfo:(id<DialSessionAble>)sessInfo;

- (id<DialSessionAble>)getSessInfo;

@end
