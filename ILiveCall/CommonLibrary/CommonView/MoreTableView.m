//
//  MoreTableView.m
//  
//
//  Created by Alexi on 12-11-7.
//  Copyright (c) 2012年 . All rights reserved.
//
#if kSupportUnusedCommonView
#import "MoreTableView.h"

@implementation MoreTableView

#define REFUSH_HEAD_VIEW_HEIGHT 65

//@synthesize delegate = _delegate;
@synthesize tableView = _tableView;
@synthesize reloading = _reloading;

- (void)dealloc
{
//    _delegate = nil;
    _tableView = nil;
    _refreshHeaderView = nil;
    CommonSuperDealloc();
    //    [super dealloc];
}

//- (id)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame])
//    {
//        
////        self.autoresizesSubviews = YES;
////        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        
//        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
//        [self addSubview:_tableView];
//        [_tableView release];
////        _tableView.autoresizesSubviews = YES;
////        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        _tableView.backgroundColor = [UIColor clearColor];
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        
//        [self configParams];
//    }
//    return self;
//}

- (void)addOwnViews
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addSubview:_tableView];
    CommonRelease(_tableView)
//    [_tableView release];
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)configParams
{
    
}

- (void)resetMoreView
{
    _reloading = NO;
    if (nil == _refreshHeaderView)
    {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, _tableView.contentSize.height, _tableView.frame.size.width, REFUSH_HEAD_VIEW_HEIGHT)];
        _refreshHeaderView.delegate = self;
        [_tableView addSubview:_refreshHeaderView];
        CommonRelease(_refreshHeaderView);
//        [_refreshHeaderView release];
    }
    else
    {
        _refreshHeaderView.frame = CGRectMake(0.0f, _tableView.contentSize.height, _tableView.frame.size.width, REFUSH_HEAD_VIEW_HEIGHT);
    }
    
    if (_tableView.contentSize.height < _tableView.frame.size.height)
    {
        _refreshHeaderView.hidden = YES;
    }
    else
    {
        _refreshHeaderView.hidden = NO;
    }
}

- (void)relayoutFrameOfSubViews
{
    _tableView.frame = self.bounds;
    [self resetMoreView];
}

// 根据歌曲列表进行界面展现，主要是tabView的初始化操作
- (void)refreshAfterLoadMore
{
    [self stopLoadMore];
    [_tableView reloadData];

    [self resetMoreView];
}

- (void)reloadData
{
    if (_reloading)
    {
        [self stopLoadMore];
    }
    [_tableView reloadData];
    _reloading = NO;
}

- (void)onLoadOver
{
    _refreshHeaderView.isLoadOver = YES;
}

- (void)stopLoadMore
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}


#pragma mark -
#pragma mark UITableViewDataSource

#define kMoreTableViewCellIdentifier @"MoreTableViewCell"

- (UITableViewCell *)createCell:(NSString *)identifier
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMoreTableViewCellIdentifier];
    return  CommonReturnAutoReleased(cell);
}

- (void)configCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    // for the subclass to do
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kMyViewCell = @"MoreVieCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMyViewCell];
    if (nil == cell)
    {
        cell = [self createCell:kMyViewCell];
        cell.backgroundColor = [UIColor clearColor];
    }
    [self configCell:cell indexPath:indexPath];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)didSelect:(NSIndexPath *)indexPath
{
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self didSelect:indexPath];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_refreshHeaderView.hidden) {
        _refreshHeaderView.hidden = YES;
    }
    if (scrollView.contentOffset.y > 0)
    {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y > 0)
    {
        if (!_refreshHeaderView.isLoadOver)
        {
            [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
        }
    }
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)loadMore
{
    // 加载更多逻辑
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    // 在此回调函数中进行数据的获取, 然后数据获取完毕后在通知刷新页面
    // 回调外界进行界面的刷新
    [self loadMore];
    _reloading = YES;

}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading; // should return if data source model is reloading
}


@end
#endif