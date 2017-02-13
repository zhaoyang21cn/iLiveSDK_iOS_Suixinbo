//
//  RecListTableViewController.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/4.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecListTableViewController : UITableViewController
{
    RequestPageParamItem    *_pageItem;
    NSMutableArray *_data;
    BOOL _isCanLoadMore;
    UIRefreshControl        *_refreshCtl;
}

@property (nonatomic, strong) NSMutableArray *data;

@end
