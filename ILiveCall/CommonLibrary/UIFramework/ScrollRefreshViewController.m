//
// ScrollRefreshViewController.m
//
// @author Shiki
//

#import "ScrollRefreshViewController.h"

#import "UIView+Layout.h"



@interface ScrollRefreshViewController ()
{
    __weak UIScrollView *_refreshScrollView;
}



@end


@implementation ScrollRefreshViewController

- (void)initialize
{
    _canRefresh = YES;
    _canLoadMore = YES;
}


- (instancetype)init
{
    if (self = [super init])
    {
        [self initialize];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initialize];
    }
    return self;
}

- (void)addRefreshScrollView
{
    
}

- (void)addOwnViews
{
    [self addNoDataView];
    
    [self addRefreshScrollView];
    
    [self addHeaderView];
    
    [self addFooterView];
    
    
}

- (void)addHeaderView
{
}

- (void)addFooterView
{
    
}

- (void)layoutOnIPhone
{
    [self layoutRefreshScrollView];
    [self layoutHeaderRefreshView];
    [self layoutFooterRefreshView];
}

- (void)layoutRefreshScrollView
{
    _refreshScrollView.frame = self.view.bounds;
    _noDataView.frame = _refreshScrollView.frame;
}

- (void)layoutHeaderRefreshView
{
    if (_headerView)
    {
        CGRect rect = _refreshScrollView.bounds;
        [_headerView setFrameAndLayout:CGRectMake(0, -rect.size.height, rect.size.width, rect.size.height)];
    }
}


- (void)layoutFooterRefreshView
{
    if (_footerView)
    {
        CGRect rect = _refreshScrollView.bounds;
        [_footerView setFrameAndLayout:CGRectMake(0, _refreshScrollView.contentSize.height, rect.size.width, rect.size.height)];
        
        if (_canLoadMore)
        {
            [self setFooterViewVisibility:_refreshScrollView.contentSize.height >= rect.size.height];
        }
    }
}


#pragma mark - Pull to Refresh


- (void)setHeaderView:(UIView<RefreshAbleView> *)aView
{
    if (!_refreshScrollView)
    {
        return;
    }
    
    
    if (_headerView && [_headerView isDescendantOfView:_refreshScrollView])
    {
        [_headerView removeFromSuperview];
    }
    _headerView = nil;
    
    if (aView)
    {
        _headerView = aView;
        [_refreshScrollView addSubview:_headerView];
    }
}


- (CGFloat)headerRefreshHeight
{
    return [_headerView refreshHeight];
    //    if (_headView)
    //    {
    //        return _headView.frame.size.height;
    //    }
    //    else
    //    {
    //        return kDefaultRefreshHeightOffset;
    //    }
}

- (void)pinHeaderAndRefresh
{
    [self pinHeaderView];
    [self refresh];
}

- (void)pinHeaderView
{
    [UIView animateWithDuration:0.3 animations:^(void) {
        _refreshScrollView.contentInset = UIEdgeInsetsMake([self headerRefreshHeight], 0, 0, 0);
        [_headerView loading];
    }];
}


- (void)unpinHeaderView
{
    [UIView animateWithDuration:0.3 animations:^(void){
        _refreshScrollView.contentInset = UIEdgeInsetsZero;
        [_headerView loadingOver];
    } completion:^(BOOL finished) {
        [self layoutFooterRefreshView];
    }];
}


- (void)willBeginRefresh
{
    if (_canRefresh)
    {
        [self pinHeaderView];
    }
}


- (BOOL)refresh
{
    if (_isRefreshing || _isLoadingMore)
    {
        return NO;
    }
    
    [self willBeginRefresh];
    _isRefreshing = YES;
    
    [self onRefresh];
    return YES;
}

- (void)onRefresh
{
    
}


- (void)refreshCompleted
{
    _isRefreshing = NO;
    
    if (_canRefresh)
    {
        [self unpinHeaderView];
    }
}



#pragma mark - Load More


- (void)setFooterView:(UIView<RefreshAbleView> *)aView
{
    if (!_refreshScrollView)
    {
        return;
    }
    
    
    if (_footerView && [_footerView isDescendantOfView:_refreshScrollView])
    {
        [_footerView removeFromSuperview];
    }
    _footerView = nil;
    
    if (aView)
    {
        _footerView = aView;
        [_refreshScrollView addSubview:_footerView];
    }
}


- (void)willBeginLoadingMore
{
    [UIView animateWithDuration:0.3 animations:^(void) {
        _refreshScrollView.contentInset = UIEdgeInsetsMake(0, 0, [self footerLoadMoreHeight], 0);
    }];
}


- (void)loadMoreCompleted
{
    _isLoadingMore = NO;
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        _refreshScrollView.contentInset = UIEdgeInsetsZero;
        [_footerView loadingOver];
    } completion:^(BOOL finished) {
        [self layoutFooterRefreshView];
    }];
    
    
    
}


- (BOOL)loadMore
{
    if (_isRefreshing || _isLoadingMore)
    {
        return NO;
    }
    
    [self willBeginLoadingMore];
    _isLoadingMore = YES;
    
    [self onLoadMore];
    return YES;
}

- (void)onLoadMore
{
    
}


- (CGFloat)footerLoadMoreHeight
{
    return [_footerView refreshHeight];
    //    if (_footerView)
    //    {
    //        return _footerView.frame.size.height;
    //    }
    //    else
    //    {
    //        return kDefaultRefreshHeightOffset;
    //    }
}


- (void)setFooterViewVisibility:(BOOL)visible
{
    _footerView.hidden = !visible;
    
    //    if (visible && _refreshScrollView.tableFooterView != _footerView)
    //    {
    //        _refreshScrollView.tableFooterView = _footerView;
    //    }
    //    else if (!visible)
    //    {
    //        _refreshScrollView.tableFooterView = nil;
    //    }
}



#pragma mark -


- (void)allLoadingCompleted
{
    if (_isRefreshing)
    {
        [self refreshCompleted];
    }
    
    if (_isLoadingMore)
    {
        [self loadMoreCompleted];
    }
    
    
}



#pragma mark - UIScrollViewDelegate


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_isRefreshing)
    {
        return;
    }
    
    _isDragging = YES;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_headerView && !_isRefreshing && _isDragging && scrollView.contentOffset.y < 0)
    {
        CGFloat headerHeight = [self headerRefreshHeight];
        
        BOOL releaseLoading = scrollView.contentOffset.y < -headerHeight;
        if (releaseLoading)
        {
            [_headerView releaseLoading];
        }
        else
        {
            CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
            offset = MIN(offset, headerHeight);
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0);
            [_headerView willLoading];
        }
    }
    else if (_footerView && !_footerView.hidden && !_isLoadingMore && _canLoadMore)
    {
        if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height)
        {
            CGFloat footRefreshHeight = [self footerLoadMoreHeight];
            if ( scrollView.contentOffset.y + scrollView.frame.size.height < scrollView.contentSize.height + footRefreshHeight)
            {
                CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
                offset = MIN(offset, footRefreshHeight);
                scrollView.contentInset = UIEdgeInsetsMake(0, 0, offset, 0);
                
                [_footerView willLoading];
                
            }
            else
            {
                [_footerView releaseLoading];
            }
        }
        
        
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_isRefreshing)
    {
        return;
    }
    
    _isDragging = NO;
    
    
    if (scrollView.contentOffset.y < 0)
    {
        if (_canRefresh)
        {
            if (_headerView && scrollView.contentOffset.y <= - [self headerRefreshHeight])
            {
                BOOL ref = [self refresh];
                if (ref)
                {
                    [_headerView loading];
                }
            }
            else
            {
                [self refreshCompleted];
            }
        }
    }
    else
    {
        if (_canLoadMore)
        {
            if (_footerView && !_footerView.hidden && scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height + [self footerLoadMoreHeight])
            {
                if ([self loadMore])
                {
                    [_footerView loading];
                }
            }
            else
            {
                [self loadMoreCompleted];
            }
        }
        
    }
}



#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)reloadData
{
    
}

- (void)showNoDataView
{
    
}

- (void)addNoDataView
{
    
}

- (BOOL)hasData
{
    return YES;
}

@end
