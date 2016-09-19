//
//  EGORefreshTableHeaderView.m
//  Demo
//
//修改人：禚来强 iphone开发qq群：79190809 邮箱：zhuolaiqiang@gmail.com
//


/***************************************************************************************/
#if kSupportUnusedCommonView

#define  RefreshViewHight 50.0f
#define  RefreshNeedHeight  65.0f      // 向上拉的距离，达到了就可以刷新

//#define kDownRefreshLoadOver    @"没有更多了"
//
//#define kDownReleaseToRefresh   @"松开即可更新..."
//
//#define kDownDragUpToRefresh    @"上拉即可更新..."
//
//#define kDownRefreshLoading     @"加载中..."

#import "EGORefreshTableHeaderView.h"

#import "UILabel+Common.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.3f


@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;
@synthesize isLoadOver = _isLoadOver;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        self.backgroundColor = [UIColor clearColor];
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, RefreshViewHight - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = kCommonSmallTextFont;
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentLeft;
		[self addSubview:label];
		//_lastUpdatedLabel=label;
		CommonRelease(label);
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, RefreshViewHight - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = kCommonSmallTextFont;
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		CommonRelease(label);
		
        //		CALayer *layer = [CALayer layer];
        //		layer.frame = CGRectMake(25.0f, RefreshViewHight - 27.0f, 15.0f, 27.0f);
        //		layer.contentsGravity = kCAGravityResizeAspect;
        //		layer.contents = (id)[UIImage imageNamed:@"blueArrow"].CGImage;
        //#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        //		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        //			layer.contentsScale = [[UIScreen mainScreen] scale];
        //		}
        //#endif
        //		[[self layer] addSublayer:layer];
        //		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(25.0f, RefreshViewHight - 30.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
        CommonAutoRelease(_activityView);
		
		
		[self setState:EGOOPullRefreshNormal];
		
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate
{
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:@"上午"];
		[formatter setPMSymbol:@"下午"];
		[formatter setDateFormat:@"yyyy/MM/dd HH:mm:a"];
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"最后更新: %@", [formatter stringFromDate:date]];
        
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		CommonAutoRelease(formatter);
	}
    else
    {
		_lastUpdatedLabel.text = nil;
	}
    
}

- (void)changeArea
{
//    CGSize txtSize = [_statusLabel.text sizeWithFont:_statusLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - 50, 20.0f) lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize txtSize = [_statusLabel textSizeIn:CGSizeMake(self.frame.size.width - 50, 20.0f)];
    
    CGFloat width = _activityView.isHidden ? txtSize.width : _activityView.bounds.size.width + txtSize.width;
    
    CGRect rect = CGRectZero;
    
    if (width > self.frame.size.width)
    {
        rect = CGRectInset(self.bounds, 25, (RefreshViewHight - 20)/2);
    }
    else
    {
        rect = CGRectInset(self.bounds, (self.frame.size.width - 50 - width)/2, (self.frame.size.height - txtSize.height)/2);
    }
    
    if (_activityView.isHidden)
    {
        _statusLabel.frame = rect;
    }
    else
    {
        CGRect aRect = rect;
        aRect.size.width = 20;
        _activityView.frame = aRect;
        
        aRect.origin.x += aRect.size.width;
        aRect.size.width = rect.size.width - aRect.size.width;
        _statusLabel.frame = aRect;
    }
}

- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			_statusLabel.text = !_isLoadOver ? kDownReleaseToRefresh : kDownRefreshLoadOver;
            [self changeArea];
            
            //			[CATransaction begin];
            //			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            ////			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            //			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
            //			if (_state == EGOOPullRefreshPulling) {
            //				[CATransaction begin];
            //				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            //				_arrowImage.transform = CATransform3DIdentity;
            //				[CATransaction commit];
            //			}
			
			_statusLabel.text = !_isLoadOver ? kDownReleaseToRefresh : kDownRefreshLoadOver;
            
			[_activityView stopAnimating];
            //			[CATransaction begin];
            //			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            //			_arrowImage.hidden = NO;
            //			_arrowImage.transform = CATransform3DIdentity;
            //			[CATransaction commit];
			[self changeArea];
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
            if (_isLoadOver) {
                _statusLabel.text = kDownRefreshLoadOver;
            }
            else
            {
                _statusLabel.text = kDownRefreshLoading;
                [_activityView startAnimating];
            }
            [self changeArea];
            //			[CATransaction begin];
            //			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            ////			_arrowImage.hidden = YES;
            //			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

//手指屏幕上不断拖动调用此方法
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (_state == EGOOPullRefreshLoading) {
		
//		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
//		offset = MIN(offset, RefreshNeedHeight);
		scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, RefreshViewHight, 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y + (scrollView.frame.size.height) < scrollView.contentSize.height + RefreshNeedHeight && scrollView.contentOffset.y > 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshNeedHeight  && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.bottom != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
}

//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshNeedHeight && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, RefreshViewHight, 0.0f);
		[UIView commitAnimations];
		
	}
	
}

//当开发者页面页面刷新完毕调用此方法，[delegate egoRefreshScrollViewDataSourceDidFinishedLoading: scrollView];
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];
    
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
    //	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    
    CommonSuperDealloc();
    //    [super dealloc];
}


//#ifdef _FOR_DEBUG_
//
//- (BOOL)respondsToSelector:(SEL)aSelector
//{
//    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
//    return [super respondsToSelector:aSelector];
//}
//
//#endif

@end


/***************************************************************************************/


//@implementation EGODownRefreshTableHeaderView
//
//@synthesize delegate=_delegate;
//
//- (EGOPullRefreshState)getState
//{
//    return _state;
//}
//
//
//- (id)initWithFrame:(CGRect)frame {
//    if (self = [super initWithFrame:frame]) {
//		
//		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
//        
//		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
//		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//		label.font = [UIFont systemFontOfSize:12.0f];
//		label.textColor = TEXT_COLOR;
//		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
//		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
//		label.backgroundColor = [UIColor clearColor];
//		label.textAlignment = NSTextAlignmentCenter;
//		[self addSubview:label];
//		_lastUpdatedLabel=label;
//		[label release];
//		
//		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
//		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//		label.font = [UIFont boldSystemFontOfSize:13.0f];
//		label.textColor = TEXT_COLOR;
//		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
//		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
//		label.backgroundColor = [UIColor clearColor];
//		label.textAlignment = NSTextAlignmentCenter;
//		[self addSubview:label];
//		_statusLabel=label;
//		[label release];
//		
//		CALayer *layer = [CALayer layer];
//        
//        CGSize txtSize = [Localized(kUpReleaseToRefresh) sizeWithFont:_statusLabel.font constrainedToSize:CGSizeMake(self.frame.size.width, 20.0f) lineBreakMode:NSLineBreakByTruncatingTail];
//        
////        layer.frame = CGRectMake((self.frame.size.width - txtSize.width - 30)/2, _statusLabel.frame.origin.y - 8, 15.0f , 27.0f);
//        
//        layer.frame = CGRectMake((self.frame.size.width - txtSize.width - 60)/2, _statusLabel.frame.origin.y, 15.0f , 40.0f);
//        
//        //		layer.frame = CGRectMake(25.0f, frame.size.height - 27.0f, 15.0f, 27.0f);
//		layer.contentsGravity = kCAGravityResizeAspect;
//		layer.contents = (id)[UIImage imageNamed:@"blueArrow@2x"].CGImage;
//		
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
//		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
//			layer.contentsScale = [[UIScreen mainScreen] scale];
//		}
//#endif
//		
//		[[self layer] addSublayer:layer];
//		_arrowImage=layer;
//		
//		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//		view.frame = CGRectMake(25.0f, frame.size.height - 19.0f, 20.0f, 20.0f);
//		[self addSubview:view];
//		_activityView = view;
//		[view release];
//		
//		
//		[self setState:EGOOPullRefreshNormal];
//		
//    }
//	
//    return self;
//	
//}
//
//
//#pragma mark -
//#pragma mark Setters
//
////时间范围
////表达方式
////今年
////今天
////<=60分钟
////XX分钟前（最小单位1分钟前）
////>60分钟
////显示日期和时间，例：今天 15:33
////其他天
////显示日期和时间，例：12-05 15:33
////往年
////显示日期和时间，例：2009-02-05 15:33
//
//- (NSString *)getLastUpdateInfo:(NSDate *)curDate lastDate:(NSDate *)lastDate
//{
//    NSTimeInterval dateoff = [curDate timeIntervalSinceDate:lastDate];
//    if (dateoff > 0)
//    {
//        if (dateoff < 60*60)
//        {
//            NSInteger minute = (NSInteger)(dateoff/60) + 1;
//            return [NSString stringWithFormat:@"%@: %d%@", Localized(kUpRefreshLastUpdate), minute, Localized(kUpRefreshMinuteLastUpdate)];
//        }
//        else
//        {
//            NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
//            
//            NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
//            
//            NSDateComponents *components = [gregorian components:unitFlags fromDate:lastDate toDate:curDate options:0];
//            
//            if (components.year == 0 && components.month == 0 && components.day == 0)
//            {
//                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                [dateFormatter setDateStyle:NSDateFormatterFullStyle];
//                [dateFormatter setDateFormat:@"HH:mm"];
//                NSString *lastdateStr = [dateFormatter stringFromDate:curDate];
//                [dateFormatter release];
//                
//                return [NSString stringWithFormat:@"%@ %@", Localized(kUpRefreshLastUpdate), lastdateStr];
//            }
//        }
//    }
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HHmm"];
//    NSString *curDateStr = [dateFormatter stringFromDate:curDate];
//    [dateFormatter release];
//    
//    return [NSString stringWithFormat:@"%@: %@", Localized(kUpRefreshLastUpdate), curDateStr];
//    
//}
//
//- (void)refreshLastUpdatedDate
//{
//    
//	
//    
//    NSDate *date = [NSDate date];
//    NSDate *lastDate = nil;
//    if (_lastRefreshKey)
//    {
//        NSString *lastDateStr = [[NSUserDefaults standardUserDefaults] objectForKey:_lastRefreshKey];
//        lastDate = [StringUtility convertWithDateStr:lastDateStr];
//        
//        if (lastDate)
//        {
//            _lastUpdatedLabel.text = [self getLastUpdateInfo:date lastDate:lastDate];
//        }
//        else
//        {
//            _lastUpdatedLabel.text = nil;
//        }
//        
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd HHmmss"];
//        
//        NSString *curDateStr = [dateFormatter stringFromDate:date];
//        [[NSUserDefaults standardUserDefaults] setObject:curDateStr forKey:_lastRefreshKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [dateFormatter release];
//        
//        
//        return;
//    }
//	
//    _lastUpdatedLabel.text = nil;
//    
//}
//
//- (void)setState:(EGOPullRefreshState)aState{
//	
//	switch (aState) {
//		case EGOOPullRefreshPulling:
//        {
//            _statusLabel.text = Localized(kUpReleaseToRefresh);
//            
//            
//			[CATransaction begin];
//			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
//			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
//			[CATransaction commit];
//        }
//			break;
//		case EGOOPullRefreshNormal:
//        {
//			
//			if (_state == EGOOPullRefreshPulling) {
//				[CATransaction begin];
//				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
//				_arrowImage.transform = CATransform3DIdentity;
//				[CATransaction commit];
//			}
//			
//            
//            _statusLabel.text = Localized(kUpDragDownToRefresh);
//			[_activityView stopAnimating];
//            
//            CGSize txtSize = [Localized(kUpDragDownToRefresh) sizeWithFont:_statusLabel.font constrainedToSize:CGSizeMake(self.frame.size.width, 20.0f) lineBreakMode:NSLineBreakByTruncatingTail];
//            
//            _arrowImage.frame = CGRectMake((self.frame.size.width - txtSize.width - 60)/2, _statusLabel.frame.origin.y, 15.0f , 40.0f);
//            
//			[CATransaction begin];
//			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//			_arrowImage.hidden = NO;
//			_arrowImage.transform = CATransform3DIdentity;
//			[CATransaction commit];
//			
//			[self refreshLastUpdatedDate];
//        }
//			break;
//		case EGOOPullRefreshLoading:
//        {
//            _statusLabel.text = Localized(kUpRefreshLoading);
//            
//            CGSize txtSize = [Localized(kUpRefreshLoading) sizeWithFont:_statusLabel.font constrainedToSize:CGSizeMake(self.frame.size.width, 20.0f) lineBreakMode:NSLineBreakByTruncatingTail];
//            
//            _activityView.frame = CGRectMake((self.frame.size.width - txtSize.width - 100)/2, _statusLabel.frame.origin.y, 20.0f , 20.0f);
//            
//			[_activityView startAnimating];
//			[CATransaction begin];
//			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//			_arrowImage.hidden = YES;
//			[CATransaction commit];
//        }
//			break;
//		default:
//			break;
//	}
//	
//	_state = aState;
//}
//
//
//#pragma mark -
//#pragma mark ScrollView Methods
//
//- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
//    
//	if (_state == EGOOPullRefreshPulling) {
//		
//		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
//		offset = MIN(offset, RefreshNeedHeight);
//		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
//		
//	} else if (scrollView.isDragging) {
//		
//		BOOL _loading = NO;
//		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
//			_loading = [_delegate egoDownRefreshTableHeaderDataSourceIsLoading:self];
//		}
//		
//		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > - RefreshNeedHeight && scrollView.contentOffset.y < 0.0f && !_loading) {
//			[self setState:EGOOPullRefreshNormal];
//		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < - RefreshNeedHeight && !_loading) {
//			[self setState:EGOOPullRefreshPulling];
//		}
//		
//		if (scrollView.contentInset.top != 0) {
//			scrollView.contentInset = UIEdgeInsetsZero;
//		}
//		
//	}
//	
//}
//
//- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
//	BOOL _loading = NO;
//	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
//		_loading = [_delegate egoDownRefreshTableHeaderDataSourceIsLoading:self];
//	}
//	if (scrollView.contentOffset.y <= -RefreshNeedHeight  && !_loading) {
//		
//		if ([_delegate respondsToSelector:@selector(egoDownRefreshTableHeaderDidTriggerRefresh:)]) {
//			[_delegate egoDownRefreshTableHeaderDidTriggerRefresh:self];
//		}
//		
//		[self setState:EGOOPullRefreshLoading];
//		[UIView beginAnimations:nil context:NULL];
//		[UIView setAnimationDuration:0.2];
//		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
//		[UIView commitAnimations];
//		
//	}
//	
//}
//
//- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
//    
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationDuration:.3];
//	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
//	[UIView commitAnimations];
//	
//	[self setState:EGOOPullRefreshNormal];
//    
//    if (scrollView.contentOffset.y < 0 )
//    {
//        scrollView.contentOffset = CGPointZero;
//    }
//    
//}
//
//
//#pragma mark -
//#pragma mark Dealloc
//
//- (void)dealloc {
//	
//	_delegate=nil;
//	_activityView = nil;
//	_statusLabel = nil;
//	_arrowImage = nil;
//	_lastUpdatedLabel = nil;
//    
//    if (_lastRefreshKey.length) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:_lastRefreshKey];
//    }
//    [_lastRefreshKey release];
//    _lastRefreshKey = nil;
//    
//    
//    [super dealloc];
//}
//
//
//#ifdef _FOR_DEBUG_
//
//- (BOOL)respondsToSelector:(SEL)aSelector
//{
//    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
//    return [super respondsToSelector:aSelector];
//}
//
//#endif
//
//
//@end
#endif