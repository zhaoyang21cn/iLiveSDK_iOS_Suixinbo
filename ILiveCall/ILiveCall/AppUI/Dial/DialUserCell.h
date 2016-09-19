//
//  DailUserCell.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewModelAble.h"

@interface DialUserCell : UITableViewCell
@property(nonatomic,copy) NSIndexPath * indexPath;

- (void)setDialUserModel:(id<DialUserCellAble>)dialModel;

- (id<DialUserCellAble>)getDialUserModel;

@end
