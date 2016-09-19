//
//  ADTransition.m
//  CommonLibrary
//
//  Created by James on 3/7/14.
//  Copyright (c) 2014 CommonLibrary. All rights reserved.
//
#if kSupportADTransition
#import "ADTransition.h"

@implementation ADTransition

- (id)init {
	if (self = [super init]) {
		_sourceViewController = nil;
		_sourceView = nil;
		_sourceImage = nil;
		
		_destinationViewController = nil;
		_destinationSize = CGSizeZero;
		_destinationImage = nil;
		
		_animationDuration = 0.5;
		_presented = NO;
		
		_shadowView = [[UIView alloc] init];
        _shadowView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[[self shadowView] setFrame:CGRectMake(0, 0, 1024, 1024)];
		[[self shadowView] setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
		
		_shadowTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadowViewTapped:)];
		[[self shadowView] addGestureRecognizer:[self shadowTapGesture]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
	}
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setters

//*********//
- (void)setSourceView:(UIView *)sourceView inViewController:(UIViewController *)sourceViewController {
	[self setSourceView:sourceView inViewController:sourceViewController withSnapshotImage:nil];
}

- (void)setSourceView:(UIView *)sourceView inViewController:(UIViewController *)sourceViewController withSnapshotImage:(UIImage *)sourceImage {
	_sourceViewController = sourceViewController;
	_sourceView = sourceView;
	_sourceImage = sourceImage;
}

//***********//

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (void)setSourceIndexPath:(NSIndexPath *)indexPath inCollectionViewController:(UICollectionViewController *)sourceViewController {
	[self setSourceIndexPath:indexPath inCollectionViewController:sourceViewController withSnapshotImage:nil];
}

- (void)setSourceIndexPath:(NSIndexPath *)indexPath inCollectionViewController:(UICollectionViewController *)sourceViewController withSnapshotImage:(UIImage *)sourceImage {
	UICollectionView *collectionView = [sourceViewController collectionView];
	if (![[collectionView indexPathsForVisibleItems] containsObject:indexPath]) {
		[collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally|UICollectionViewScrollPositionCenteredVertically animated:NO];
		[collectionView reloadData];
		[collectionView setNeedsLayout];
		[collectionView layoutIfNeeded];
	}
	
	UICollectionViewCell *cell = [[sourceViewController collectionView] cellForItemAtIndexPath:indexPath];
	[self setSourceView:cell inViewController:sourceViewController withSnapshotImage:sourceImage];
}
#endif

- (void)setSourceIndexPath:(NSIndexPath *)indexPath inTableViewController:(UITableViewController *)sourceViewController {
	[self setSourceIndexPath:indexPath inTableViewController:sourceViewController withSnapshotImage:nil];
}

- (void)setSourceIndexPath:(NSIndexPath *)indexPath inTableViewController:(UITableViewController *)sourceViewController withSnapshotImage:(UIImage *)sourceImage {
	UITableViewCell *cell = [[sourceViewController tableView] cellForRowAtIndexPath:indexPath];
	[self setSourceView:cell inViewController:sourceViewController withSnapshotImage:sourceImage];
}

- (void)updateIndexPath:(NSIndexPath *)indexPath {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
	if ([[self sourceViewController] isKindOfClass:[UICollectionViewController class]]) {
		[self setSourceIndexPath:indexPath inCollectionViewController:(UICollectionViewController *)[self sourceViewController] withSnapshotImage:[self sourceImage]];
	} else
#endif
        if ([[self sourceViewController] isKindOfClass:[UITableViewController class]]) {
            UITableView *tableView = [(UITableViewController *)[self sourceViewController] tableView];
            if (![[tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            }
            
            [self setSourceIndexPath:indexPath inTableViewController:(UITableViewController *)[self sourceViewController] withSnapshotImage:[self sourceImage]];
        }
}

//***********//

- (void)setDestinationViewController:(UIViewController *)destinationViewController {
	[self setDestinationViewController:destinationViewController asChildWithSize:CGSizeZero];
}

- (void)setDestinationViewController:(UIViewController *)destinationViewController withSnapshotImage:(UIImage *)destinationImage {
	[self setDestinationViewController:destinationViewController asChildWithSize:CGSizeZero withSnapshotImage:destinationImage];
}

//***********//

- (void)setDestinationViewController:(UIViewController *)destinationViewController asChildWithSize:(CGSize)destinationSize {
	[self setDestinationViewController:destinationViewController asChildWithSize:destinationSize withSnapshotImage:nil];
}

- (void)setDestinationViewController:(UIViewController *)destinationViewController asChildWithSize:(CGSize)destinationSize withSnapshotImage:(UIImage *)destinationImage {
	_destinationViewController = destinationViewController;
	_destinationSize = destinationSize;
	_destinationImage = destinationImage;
}

- (void)shadowViewTapped:(UITapGestureRecognizer *)sender
{
	if ([self presented]) {
		[self reverse];
	}
}

- (void)reverse {
	[self reverseWithCompletion:NULL];
}

#pragma mark -

- (CGRect)rectBetween:(CGRect)firstRect andRect:(CGRect)secondRect
{
	CGRect betweenRect = CGRectZero;
	betweenRect.origin.x = (firstRect.origin.x + secondRect.origin.x) / 2;
	betweenRect.origin.y = (firstRect.origin.y + secondRect.origin.y) / 2;
	betweenRect.size.width = (firstRect.size.width + secondRect.size.width) / 2;
	betweenRect.size.height = (firstRect.size.height + secondRect.size.height) / 2;
	
	return betweenRect;
}

- (CGRect)actualRectInView:(UIView *)view
{
    
    CGPoint p = view.frame.origin;
    
    UIView *superView = view.superview;
    while (superView) {
        p.x += superView.frame.origin.x;
        p.y += superView.frame.origin.y;
        superView = superView.superview;
    }
    
    return CGRectMake(p.x, p.y, view.bounds.size.width, view.bounds.size.height);
    
    
//    CGPoint center = view.center;
//    
//    CGPoint winCenter = [view convertPoint:center toView:[AppDelegate sharedAppDelegate].window];
//    
//    
//	CGRect frame = [view frame];
//	UIView *superview = [view superview];
//    
//	while (superview && ![superview.superview isKindOfClass:[UIWindow class]])
//    {
//        UIView *superSuperView = [superview superview];
//		CGRect newFrame = [superSuperView convertRect:frame fromView:superview];
//		if (CGRectEqualToRect(newFrame, CGRectZero))
//        {
//			break;
//		}
//		frame = newFrame;
//        
//		superview = superSuperView;
//	}
//	
//	return frame;
    
//	Class transition = NSClassFromString(@"UITransitionView");
//	Class layoutContainer = NSClassFromString(@"UILayoutContainerView");
//	
//	CGRect frame = [view frame];
//	UIView *superview = [view superview];
//    
//	while (superview && ![superview isKindOfClass:transition] && ![superview isKindOfClass:layoutContainer])
//    {
//        UIView *superSuperView = [superview superview];
//		CGRect newFrame = [superSuperView convertRect:frame fromView:superview];
//		if (CGRectEqualToRect(newFrame, CGRectZero))
//        {
//			break;
//		}
//		frame = newFrame;
//        
//		superview = superSuperView;
//	}
//	
//	return frame;
}

- (CGRect)fullScreenRect
{
    return CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
//	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//	
//	CGRect rect = [window frame];
//    
//////	if ([[UIApplication sharedApplication] statusBarStyle] == UIStatusBarStyleBlackOpaque)
//////    {
////		CGFloat height = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])?[[UIApplication sharedApplication] statusBarFrame].size.height:[[UIApplication sharedApplication] statusBarFrame].size.width;
////		
////		if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
////        {
////			rect = [self switchRectOrientation:rect];
////		}
////		
////		rect.origin.y += height;
////		rect.size.height -= height;
//////	}
//	
//	return rect;
}

- (CGRect)switchRectOrientation:(CGRect)rect
{
	return CGRectMake(rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
}

- (CGRect)rectAtCenterOfRect:(CGRect)rect withSize:(CGSize)size
{
	size.width = MIN(size.width, rect.size.width);
	size.height = MIN(size.height, rect.size.height);
	return CGRectMake((rect.size.width-size.width)/2+rect.origin.x, (rect.size.height-size.height)/2+rect.origin.y, size.width, size.height);
}

#pragma mark - Events

- (void)deviceOrientationDidChange:(NSNotification *)note
{
//	if (!CGSizeEqualToSize([self destinationSize], CGSizeZero) && [self presented])
//    {
//    [[[self destinationViewController] view] setFrame:[self rectAtCenterOfRect:[self fullScreenRect] withSize:[self destinationSize]]];
    
    if ([self.destinationViewController respondsToSelector:@selector(layoutSubviewsFrame)]) {
        [self.destinationViewController performSelector:@selector(layoutSubviewsFrame) withObject:nil];
    }
    
//		[UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration] animations:^{
//            if (self.shadowView.superview) {
//                self.shadowView.frame = self.shadowView.superview.bounds;
//            }
//		}];
//	}
}

#pragma mark - Animations

- (void)perform {
	[self performWithCompletion:NULL];
}

- (void)performWithCompletion:(void (^)(void))completion
{
    // TODO:by subclass owerwrite
}

- (void)reverseWithCompletion:(void (^)(void))completion
{
    // TODO: by subclass owerwrite
}

@end
#endif