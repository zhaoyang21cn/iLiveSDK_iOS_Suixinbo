//
//  TableSearchViewController.h
//  CommonLibrary
//
//  Created by AlexiChen on 16/2/18.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TableRefreshViewController.h"

//
//@interface UISearchController (ReplaceCancelText)
//- (void)replaceCancelText;
//@end


@interface TableSearchResultViewController : TableRefreshViewController<UISearchResultsUpdating, UISearchBarDelegate>

@end


@interface TableSearchViewController : TableRefreshViewController
{
@protected
    UISearchController          *_searchController;
@protected
    // 搜索结果界面
    UIViewController<UISearchResultsUpdating, UISearchBarDelegate> *_searchResultViewController;

}

- (Class)searchResultControllerClass;


- (void)addSearchController;




@end
