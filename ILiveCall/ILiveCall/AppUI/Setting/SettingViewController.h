//
//  SettingViewController.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HostInfoView.h"

@interface SettingViewController : UITableViewController
{
    HostInfoView * _headerView;
    UIView * _footerView;
    UIButton * _exitBtn;
}

@end
