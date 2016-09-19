//
//  UITableViewController+ADScaleTransition.m
//  CommonLibrary
//
//  Created by James on 3/7/14.
//  Copyright (c) 2014 CommonLibrary. All rights reserved.
//
#if kSupportADTransition
#import "UITableViewController+ADScaleTransition.h"

@implementation UITableViewController (ADScaleTransition)

- (void)scaleToViewController:(UIViewController *)destinationViewController fromItemAtIndexPath:(NSIndexPath *)indexPath withCompletion:(void (^)(void))completion {
	[self scaleToViewController:destinationViewController fromItemAtIndexPath:indexPath withSourceSnapshotImage:nil andDestinationSnapshot:nil withCompletion:completion];
}

- (void)scaleToViewController:(UIViewController *)destinationViewController fromItemAtIndexPath:(NSIndexPath *)indexPath withSourceSnapshotImage:(UIImage *)sourceSnapshot andDestinationSnapshot:(UIImage *)destinationSnapshot withCompletion:(void (^)(void))completion {
	[self scaleToViewController:destinationViewController fromItemAtIndexPath:indexPath asChildWithSize:CGSizeZero withSourceSnapshotImage:sourceSnapshot andDestinationSnapshot:destinationSnapshot withCompletion:completion];
}

- (void)scaleToViewController:(UIViewController *)destinationViewController fromItemAtIndexPath:(NSIndexPath *)indexPath asChildWithSize:(CGSize)destinationSize withCompletion:(void (^)(void))completion {
	[self scaleToViewController:destinationViewController fromItemAtIndexPath:indexPath asChildWithSize:destinationSize withSourceSnapshotImage:nil andDestinationSnapshot:nil withCompletion:completion];
}

- (void)scaleToViewController:(UIViewController *)destinationViewController fromItemAtIndexPath:(NSIndexPath *)indexPath asChildWithSize:(CGSize)destinationSize withSourceSnapshotImage:(UIImage *)sourceSnapshot andDestinationSnapshot:(UIImage *)destinationSnapshot withCompletion:(void (^)(void))completion {
	ADScaleTransition *transition = [[ADScaleTransition alloc] init];
	[transition setSourceIndexPath:indexPath inTableViewController:self withSnapshotImage:sourceSnapshot];
	[transition setDestinationViewController:destinationViewController asChildWithSize:destinationSize withSnapshotImage:destinationSnapshot];
	
	[self setPresentedScaleTransition:transition];
	[destinationViewController setPresentingScaleTransition:transition];
	
	[transition performWithCompletion:completion];
}


@end
#endif
