//
//  EGORefreshTableHeaderView.h
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//修改人：禚来强 iphone开发qq群：79190809 邮箱：zhuolaiqiang@gmail.com
//

#if kSupportUnusedCommonView
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	EGOOPullRefreshPulling = 0,
	EGOOPullRefreshNormal,
	EGOOPullRefreshLoading,	
} EGOPullRefreshState;

/***************************************************************************/
@class EGORefreshTableHeaderView;
//@class EGODownRefreshTableHeaderView;


@protocol EGORefreshTableHeaderDelegate<NSObject>

@required
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view;
//- (void)egoDownRefreshTableHeaderDidTriggerRefresh:(EGODownRefreshTableHeaderView*)view;

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view;
//- (BOOL)egoDownRefreshTableHeaderDataSourceIsLoading:(EGODownRefreshTableHeaderView*)view;
@optional
- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view;

//- (NSDate*)egoDownRefreshTableHeaderDataSourceLastUpdated:(EGODownRefreshTableHeaderView*)view;
@end

/***************************************************************************/

@interface EGORefreshTableHeaderView : UIView
{
	EGOPullRefreshState _state;

	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
//	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	
    BOOL _isLoadOver;

}

@property (nonatomic, DelegateAssign) id<EGORefreshTableHeaderDelegate> delegate;
@property (nonatomic, assign) BOOL isLoadOver;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;



@end

///***************************************************************************/
//
//@interface EGODownRefreshTableHeaderView : UIView {
//	
//	id _delegate;
//	EGOPullRefreshState _state;
//	UILabel *_lastUpdatedLabel;
//	UILabel *_statusLabel;
//	CALayer *_arrowImage;
//	UIActivityIndicatorView *_activityView;
//    
//    NSString *_lastRefreshKey;
//	
//    
//}
//
//@property (nonatomic, assign) id <EGORefreshTableHeaderDelegate> delegate;
//@property (nonatomic, copy) NSString *lastRefreshKey;
//
//- (void)refreshLastUpdatedDate;
//- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
//- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
//- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
//
//- (void)setState:(EGOPullRefreshState)aState;
//
//- (EGOPullRefreshState)getState;
//@end
//
///***************************************************************************/
#endif