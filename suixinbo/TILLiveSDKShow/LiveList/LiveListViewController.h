//
//  LiveListViewController.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveListViewController : UITableViewController
{
    RequestPageParamItem    *_pageItem;
    NSMutableArray          *_datas;
    UIRefreshControl        *_refreshCtl;
    BOOL _isCanLoadMore;
    UILabel *_noLiveLabel;
}

@end
