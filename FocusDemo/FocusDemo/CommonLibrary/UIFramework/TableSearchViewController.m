//
//  TableSearchViewController.m
//  CommonLibrary
//
//  Created by AlexiChen on 16/2/18.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TableSearchViewController.h"

@implementation TableSearchResultViewController

- (void)addHeaderView
{
    
}

- (void)addFooterView
{
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
}







@end


@interface TableSearchViewController () <UISearchControllerDelegate>

@end


@implementation TableSearchViewController

- (Class)searchResultControllerClass
{
    return [TableSearchResultViewController class];
}

- (void)addSearchController
{
    _searchResultViewController = [[[self searchResultControllerClass] alloc] init];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_searchResultViewController];
    _searchController.delegate = self;
    _searchController.searchResultsUpdater = _searchResultViewController;
    
    // 必须要让searchBar自适应才会显示
    [_searchController.searchBar sizeToFit];
    _searchController.searchBar.delegate = _searchResultViewController;
    [_searchController.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _searchController.searchBar.backgroundImage = [UIImage imageWithColor:kAppBakgroundColor];
    //把searchBar 作为 tableView的头视图
    self.tableView.tableHeaderView = _searchController.searchBar;
    
    self.definesPresentationContext = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.tabBarController.tabBar.translucent = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = kAppBakgroundColor;
    
    [self addSearchController];
}


- (void)willPresentSearchController:(UISearchController *)searchController
{
    [self unpinHeaderView];
    
    [searchController.searchResultsController layoutSubviewsFrame];
    
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    [searchController.searchResultsController layoutSubviewsFrame];
}


@end
