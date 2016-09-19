//
//  UIViewController+ADScaleTransition.m
//  CommonLibrary
//
//  Created by James on 3/7/14.
//  Copyright (c) 2014 CommonLibrary. All rights reserved.
//
#if kSupportADTransition
#import "UIViewController+ADScaleTransition.h"

#import <objc/runtime.h>

#import "DebugMarco.h"

@implementation UIViewController (ADScaleTransition)

#pragma mark - Setters

@dynamic presentedScaleTransition;
@dynamic presentingScaleTransition;

static NSString *const kPresentedScaleTransitionKey = @"kPresentedScaleTransition";
static NSString *const kPresentingScaleTransitionKey = @"kPresentingScaleTransition";


- (ADScaleTransition *)presentedScaleTransition
{
	return objc_getAssociatedObject(self, (__bridge const void *)kPresentedScaleTransitionKey);
}

- (void)setPresentedScaleTransition:(ADScaleTransition *)presentedScaleTransition
{
	objc_setAssociatedObject(self, (__bridge const void *)kPresentedScaleTransitionKey, presentedScaleTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ADScaleTransition *)presentingScaleTransition
{
	return objc_getAssociatedObject(self, (__bridge const void *)kPresentingScaleTransitionKey);
}

- (void)setPresentingScaleTransition:(ADScaleTransition *)presentingScaleTransition
{
	objc_setAssociatedObject(self, (__bridge const void *)kPresentingScaleTransitionKey, presentingScaleTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Performing

- (void)scaleToViewController:(UIViewController *)destinationViewController fromView:(UIView *)sourceView withCompletion:(void (^)(void))completion
{
	[self scaleToViewController:destinationViewController fromView:sourceView withSourceSnapshotImage:nil andDestinationSnapshot:nil withCompletion:completion];
}

- (void)scaleToViewController:(UIViewController *)destinationViewController fromView:(UIView *)sourceView withSourceSnapshotImage:(UIImage *)sourceSnapshot andDestinationSnapshot:(UIImage *)destinationSnapshot withCompletion:(void (^)(void))completion
{
	[self scaleToViewController:destinationViewController fromView:sourceView asChildWithSize:CGSizeZero withSourceSnapshotImage:sourceSnapshot andDestinationSnapshot:destinationSnapshot withCompletion:completion];
}

- (void)scaleToViewController:(UIViewController *)destinationViewController fromView:(UIView *)sourceView asChildWithSize:(CGSize)destinationSize withCompletion:(void (^)(void))completion
{
	[self scaleToViewController:destinationViewController fromView:sourceView asChildWithSize:destinationSize withSourceSnapshotImage:nil andDestinationSnapshot:nil withCompletion:completion];
}

- (void)scaleToViewController:(UIViewController *)destinationViewController fromView:(UIView *)sourceView asChildWithSize:(CGSize)destinationSize withSourceSnapshotImage:(UIImage *)sourceSnapshot andDestinationSnapshot:(UIImage *)destinationSnapshot withCompletion:(void (^)(void))completion
{
	ADScaleTransition *transition = [[ADScaleTransition alloc] init];
	[transition setSourceView:sourceView inViewController:self withSnapshotImage:sourceSnapshot];
	[transition setDestinationViewController:destinationViewController asChildWithSize:destinationSize withSnapshotImage:destinationSnapshot];
	
	[self setPresentedScaleTransition:transition];
	[destinationViewController setPresentingScaleTransition:transition];
	
	[transition performWithCompletion:completion];
}

- (void)dismissScaleWithCompletion:(void (^)(void))completion
{
	if ([self getPresentingScaleTransition])
    {
		[[self getPresentingScaleTransition] reverse];
	}
    else
    {
		DebugLog(@"View wasn't presented by a Scale transition");
	}
}

- (void)dismissScaleToIndexPath:(NSIndexPath *)indexPath withCompletion:(void (^)(void))completion
{
	[[self getPresentingScaleTransition] updateIndexPath:indexPath];
	[self dismissScaleWithCompletion:completion];
}

- (ADScaleTransition *)getPresentingScaleTransition
{
	UIViewController *vc = self;
	while (![vc presentingScaleTransition] && [vc parentViewController])
    {
		vc = [vc parentViewController];
	}
	
	return [vc presentingScaleTransition];
}

@end
#endif

