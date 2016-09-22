//
//  ADScaleTransition.m
//  CommonLibrary
//
//  Created by James on 3/7/14.
//  Copyright (c) 2014 CommonLibrary. All rights reserved.
//
#if kSupportADTransition
#import "ADScaleTransition.h"

@implementation ADScaleTransition


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
		[[srcViewController view] addSubview:[self shadowView]];
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
	
    self.destinationViewController.view.frame = srcFrame;
    
    [UIView animateWithDuration:[self animationDuration] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.destinationViewController.view.frame = destFrame;
        if (!modal)
        {
            [[self shadowView] setAlpha:1];
        }
        
        [[self sourceView] setHidden:!modal];
    } completion:^(BOOL finished) {
        
        
        if (modal)
        {
            [srcViewController presentViewController:[self destinationViewController] animated:NO completion:NULL];
            
        }
        
        
        [[[self destinationViewController] view] setHidden:NO];
        
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        self.presented = YES;
        
        if (completion) {
            completion();
        }
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
	
	if (modal) {
		[[self destinationViewController] dismissViewControllerAnimated:NO completion:NULL];
	} else {
		[[[self destinationViewController] view] removeFromSuperview];
		[[self destinationViewController] willMoveToParentViewController:nil];
		[[self destinationViewController] removeFromParentViewController];
	}
	
    destView.frame = destFrame;
	[UIView animateWithDuration:[self animationDuration] delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
		[destView setFrame:srcFrame];
		
		if (!modal)
        {
			[[self shadowView] setAlpha:0];
		}
        
	} completion:^(BOOL finished) {
        
		[destView removeFromSuperview];
        [[self sourceView] setHidden:modal];
        
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
}

@end
#endif
