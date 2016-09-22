#if kSupportADTransition
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

#import "ADFlipTransition.h"

#import "UIView+CaptureImage.h"

@class UITransitionView;


@implementation ADFlipTransition

- (void)performWithCompletion:(void (^)(void))completion
{
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
	[[self shadowView] removeFromSuperview];
	
	BOOL modal;
	
	CGRect destFrame;
	CGRect srcFrame = [self actualRectInView:[self sourceView]];
	
	UIViewController *srcViewController = [self sourceViewController];
	while ([srcViewController parentViewController])
    {
		srcViewController = [srcViewController parentViewController];
	}
	
	//put the destination view controller on screen
	if (CGSizeEqualToSize([self destinationSize], CGSizeZero))
    {
		//present destination view modally
		modal = YES;
		
		destFrame = [self fullScreenRect];
		
		[[[self destinationViewController] view] setFrame:destFrame];
		[[[self destinationViewController] view] setNeedsLayout];
		[[[self destinationViewController] view] layoutIfNeeded];
	}
    else
    {
		modal = NO;
		
		//add a shadow view
//		[[self shadowView] setCenter:[[srcViewController view] center]];
		[[srcViewController view] addSubview:[self shadowView]];
//        [self shadowView].frame = srcViewController.view.bounds;
		[[self shadowView] setAlpha:0];
		
		//add destination view as a child
		[srcViewController addChildViewController:[self destinationViewController]];
		[[self destinationViewController] didMoveToParentViewController:srcViewController];
		
		destFrame = [self rectAtCenterOfRect:[self fullScreenRect] withSize:[self destinationSize]];
		
		[[[self destinationViewController] view] setFrame:destFrame];
		[[srcViewController view] addSubview:[[self destinationViewController] view]];
		
		[[[[self destinationViewController] view] layer] setMasksToBounds:YES];
		[[[[self destinationViewController] view] layer] setCornerRadius:3.0f];
		[[[[self destinationViewController] view] layer] setZPosition:1000];
	}
	
	//create the destination animation view
	UIImage *destImage = [self destinationImage]?[self destinationImage]:[[[self destinationViewController] view] captureImage];
	UIImageView *destView = [[UIImageView alloc] initWithImage:destImage];
	[destView setFrame:destFrame];
	[[destView layer] setZPosition:1024];
	[[srcViewController view] addSubview:destView];
	[[[self destinationViewController] view] setHidden:YES];
	
	//create the source animation view and hide the original
	UIImage *srcImage = [self sourceImage]?[self sourceImage]:[[self sourceView] captureImage];
	UIImageView *srcView = [[UIImageView alloc] initWithImage:srcImage];
	[srcView setFrame:srcFrame];
	[[srcView layer] setZPosition:1024];
	[[srcViewController view] addSubview:srcView];
	[[self sourceView] setHidden:YES];
    
	//calculate the size of the views halfway through the animation
	CGRect halfwayFrame = [self rectBetween:srcFrame andRect:destFrame];
    
    
	
	//pre-flip the destination view halfway around and hide it
	CATransform3D preTransform = CATransform3DMakeRotation(-M_PI/2, 0, 1, 0);
	preTransform.m34 = 1.0f/-500;
	[[destView layer] setTransform:preTransform];
	[destView setFrame:halfwayFrame];
	
	//perform the first half of the animation
	CATransform3D srcTransform = CATransform3DMakeRotation(M_PI/2, 0, 1, 0);
	srcTransform.m34 = 1.0f/-500;
	[UIView animateWithDuration:[self animationDuration]/2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		[[srcView layer] setTransform:srcTransform];
		[srcView setFrame:halfwayFrame];
		if (!modal) {
			[[self shadowView] setAlpha:0.5f];
		}
	} completion:^(BOOL finished) {
		//get rid of the source animation view
		[srcView removeFromSuperview];
		[destView setHidden:NO];
		
		//perform the second half of the animation
		CATransform3D destTransform = CATransform3DMakeRotation(0, 0, 1, 0);
		destTransform.m34 = 1.0f/-500;
		[UIView animateWithDuration:[self animationDuration]/2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			[[destView layer] setTransform:destTransform];
			[destView setFrame:destFrame];
			
			if (!modal) {
				[[self shadowView] setAlpha:1];
			}
		} completion:^(BOOL finished) {
			//get rid of the destination animation view
			[destView removeFromSuperview];
			
			if (modal)
            {
				[srcViewController presentViewController:[self destinationViewController] animated:NO completion:NULL];
				[[self sourceView] setHidden:NO];
			}
			
			[[[self destinationViewController] view] setHidden:NO];
			
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
			
			self.presented = YES;
			
			if (completion) {
				completion();
			}
		}];
	}];
}


- (void)reverseWithCompletion:(void (^)(void))completion
{
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
	BOOL modal;
	
	UIViewController *srcViewController = [self sourceViewController];
	while ([srcViewController parentViewController]) {
		srcViewController = [srcViewController parentViewController];
	}
	
	CGRect destFrame;
	if (CGSizeEqualToSize([self destinationSize], CGSizeZero))
    {
		modal = YES;
		destFrame = [self fullScreenRect];
	}
    else
    {
		modal = NO;
		destFrame = [[[self destinationViewController] view] frame];
	}
    
	CGRect srcFrame = [self actualRectInView:[self sourceView]];
	
	//create the destination animation view
	UIImage *destImage = [self destinationImage]?[self destinationImage]:[[[self destinationViewController] view] captureImage];
	UIImageView *destView = [[UIImageView alloc] initWithImage:destImage];
	[destView setFrame:destFrame];
	[[destView layer] setZPosition:1024];
	[[srcViewController view] addSubview:destView];
	
	//remove the destination view from screen
	if (modal) {
		[[self destinationViewController] dismissViewControllerAnimated:NO completion:NULL];
	} else {
		[[[self destinationViewController] view] removeFromSuperview];
		[[self destinationViewController] willMoveToParentViewController:nil];
		[[self destinationViewController] removeFromParentViewController];
	}
	
	//create the source animation view and hide the original
	[[self sourceView] setHidden:NO];
	UIImage *srcImage = [self sourceImage]?[self sourceImage]:[[self sourceView] captureImage];
	UIImageView *srcView = [[UIImageView alloc] initWithImage:srcImage];
	[srcView setFrame:srcFrame];
	[[srcView layer] setZPosition:1024];
	[[srcViewController view] addSubview:srcView];
	[[self sourceView] setHidden:YES];
	
	//calculate the halfway point
	CGRect halfwayFrame = [self rectBetween:srcFrame andRect:destFrame];
	
	//pre-flip the source animation view halfway around and hide it
	CATransform3D preTransform = CATransform3DMakeRotation(M_PI/2, 0, 1, 0);
	preTransform.m34 = 1.0f/-500;
	[srcView setHidden:YES];
	[[srcView layer] setTransform:preTransform];
	[srcView setFrame:halfwayFrame];
	
	//perform the first half of the animation
	CATransform3D destTransform = CATransform3DMakeRotation(-M_PI/2, 0, 1, 0);
	destTransform.m34 = 1.0f/-500;
	[UIView animateWithDuration:[self animationDuration]/2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		[[destView layer] setTransform:destTransform];
		[destView setFrame:halfwayFrame];
		
		if (!modal) {
			[[self shadowView] setAlpha:0.5f];
		}
	} completion:^(BOOL finished) {
		//get rid of the destination animation view
		[destView removeFromSuperview];
		
		//perform the second half of the animation
		[srcView setHidden:NO];
		CATransform3D srcTransform = CATransform3DMakeRotation(0, 0, 1, 0);
		srcTransform.m34 = 1.0f/-500;
		[UIView animateWithDuration:[self animationDuration]/2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			[[srcView layer] setTransform:srcTransform];
			[srcView setFrame:srcFrame];
			
			if (!modal) {
				[[self shadowView] setAlpha:0];
			}
		} completion:^(BOOL finished) {
			[srcView removeFromSuperview];
			[[self sourceView] setHidden:NO];
			
			if (!modal) {
				[[self shadowView] removeFromSuperview];
			}
			
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
			
			self.presented = NO;
			
			if (completion) {
				completion();
			}
		}];
	}];
}

@end
#endif