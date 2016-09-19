//
//  DailViewController.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewModelAble.h"

@interface DialViewController : UITableViewController
{
    UIView * _footView;
    UIButton * _callBtn;
    id<DialUserCellAble> _dialCellModel;
}


@end
