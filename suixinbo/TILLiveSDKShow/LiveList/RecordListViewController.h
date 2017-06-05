//
//  RecordListViewController.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/5/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordListViewController : UITableViewController
{
    RequestPageParamItem    *_pageItem;
    NSMutableArray          *_datas;
    UIRefreshControl        *_refreshCtl;
    BOOL _isCanLoadMore;
    UILabel *_noLiveLabel;
}

@property (nonatomic, strong) NSMutableArray *datas;

- (void)loadMore:(TCIVoidBlock)complete;
@end
