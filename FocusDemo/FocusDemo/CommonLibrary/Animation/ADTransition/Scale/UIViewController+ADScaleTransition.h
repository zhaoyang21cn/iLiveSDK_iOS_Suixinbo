//
//  UIViewController+ADScaleTransition.h
//  CommonLibrary
//
//  Created by James on 3/7/14.
//  Copyright (c) 2014 CommonLibrary. All rights reserved.
//
#if kSupportADTransition
#import <UIKit/UIKit.h>

#import "ADScaleTransition.h"

@interface UIViewController (ADScaleTransition)


@property (nonatomic) ADScaleTransition *presentedScaleTransition;

@property (nonatomic) ADScaleTransition *presentingScaleTransition;

/**
 * Present a view controller modally from the current view controller using a
 * scale animation.
 * @param destinationViewController The view controller to present
 * @param sourceView A subview of the current view controller to scale from
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)scaleToViewController:(UIViewController *)destinationViewController fromView:(UIView *)sourceView withCompletion:(void (^)(void))completion;

/**
 * Present a view controller modally from the current view controller using a
 * scale animation.
 * @param destinationViewController The view controller to present
 * @param sourceView A subview of the current view controller to scale from
 * @param sourceSnapshot The placeholder image for the source view. Specifying
 * nil will take a snapshot just before the animation.
 * @param destinationSnapshot The placeholder image for the destination view.
 * Specifying nil will take a snapshot just before the animation.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)scaleToViewController:(UIViewController *)destinationViewController fromView:(UIView *)sourceView withSourceSnapshotImage:(UIImage *)sourceSnapshot andDestinationSnapshot:(UIImage *)destinationSnapshot withCompletion:(void (^)(void))completion;

/**
 * Present a view controller as a child view controller from the current view
 * controller using a scale animation.
 * @param destinationViewController The view controller to present
 * @param sourceView A subview of the current view controller to scale from
 * @param destinationSize The size for the destination view controller to take
 * up on the screen.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)scaleToViewController:(UIViewController *)destinationViewController fromView:(UIView *)sourceView asChildWithSize:(CGSize)destinationSize withCompletion:(void (^)(void))completion;

/**
 * Present a view controller as a child view controller from the current view
 * controller using a scale animation.
 * @param destinationViewController The view controller to present
 * @param sourceView A subview of the current view controller to scale from
 * @param destinationSize The size for the destination view controller to take
 * up on the screen.
 * @param sourceSnapshot The placeholder image for the source view. Specifying
 * nil will take a snapshot just before the animation.
 * @param destinationSnapshot The placeholder image for the destination view.
 * Specifying nil will take a snapshot just before the animation.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)scaleToViewController:(UIViewController *)destinationViewController fromView:(UIView *)sourceView asChildWithSize:(CGSize)destinationSize withSourceSnapshotImage:(UIImage *)sourceSnapshot andDestinationSnapshot:(UIImage *)destinationSnapshot withCompletion:(void (^)(void))completion;

/**
 * Dismiss the current modal view controller with a scale animation.
 * @discussion Only works when the current view controller has been presented
 * using one of the category convenience methods to present the view controller.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)dismissScaleWithCompletion:(void (^)(void))completion;

/**
 * Dismiss the current modal view controller with a scale animation to a cell in
 * a UICollectionViewController or UITableViewController.
 * @discussion Only works when the current view controller has been presented
 * using one of the category convenience methods to present the view controller.
 * @param indexPath The location of the cell to scale back to.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)dismissScaleToIndexPath:(NSIndexPath *)indexPath withCompletion:(void (^)(void))completion;


@end
#endif
