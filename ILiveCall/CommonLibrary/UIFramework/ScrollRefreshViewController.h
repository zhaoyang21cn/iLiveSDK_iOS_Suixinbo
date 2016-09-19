//
// ScrollRefreshViewController.h
//
// @author Shiki
//

#import "ScrollBaseViewController.h"
#import "RefreshAbleView.h"

@interface ScrollRefreshViewController : BaseViewController<UIScrollViewDelegate>
{
@protected
    BOOL _canLoadMore;
    BOOL _canRefresh;
@protected
    BOOL _isDragging;
    BOOL _isRefreshing;
    BOOL _isLoadingMore;
    
@protected
    
    UIView *_noDataView;
    
    UIView<RefreshAbleView>     *_headerView;
    
    UIView<RefreshAbleView>     *_footerView;
    
    
}

// 下拉刷新
@property (nonatomic, strong) UIView<RefreshAbleView> *headerView;

@property (nonatomic, weak) UIScrollView *refreshScrollView;

// 上拉加载更多
@property (nonatomic, strong) UIView<RefreshAbleView> *footerView;


@property (nonatomic, readonly) BOOL isDragging;         // 是否在drag
@property (nonatomic, readonly) BOOL isRefreshing;       // 是否正在下拉刷新
@property (nonatomic, readonly) BOOL isLoadingMore;      // 是否正在加载更多
@property (nonatomic, assign)   BOOL canLoadMore;        // 是否加载更多
@property (nonatomic, assign)   BOOL canRefresh;         // 是否可以下接刷新




- (void)initialize;

- (void)addRefreshScrollView;

- (void)addHeaderView;

- (void)addFooterView;

- (void)layoutRefreshScrollView;

- (void)layoutHeaderRefreshView;

- (void)layoutFooterRefreshView;

// refreshheader 高度
- (CGFloat)headerRefreshHeight;

// 用于代码刷新
- (void)pinHeaderAndRefresh;
// 下拉刷新
- (void)pinHeaderView;

// 停止下接刷新
- (void)unpinHeaderView;

// 将要下拉刷新
- (void)willBeginRefresh;

// 刷新
- (BOOL)refresh;

- (void)onRefresh;

// 下拉刷新完成
- (void)refreshCompleted;

#pragma mark - Load More

// footview的高度
- (CGFloat)footerLoadMoreHeight;

// 加载更多
- (BOOL)loadMore;

- (void)onLoadMore;


// 将要加载更多
- (void)willBeginLoadingMore;

// 加载更多成时
- (void)loadMoreCompleted;

// 隐藏footview;
// YES 可见，NO不可见
- (void)setFooterViewVisibility:(BOOL)visible;

// 所有刷新都完成时
- (void)allLoadingCompleted;

- (void)reloadData;

- (void)addNoDataView;

- (void)showNoDataView;

- (BOOL)hasData;

@end
