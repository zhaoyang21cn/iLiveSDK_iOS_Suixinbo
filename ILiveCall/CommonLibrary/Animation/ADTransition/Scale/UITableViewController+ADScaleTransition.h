//
//  UITableViewController+ADScaleTransititon.h
//  CommonLibrary
//
//  Created by James on 3/7/14.
//  Copyright (c) 2014 CommonLibrary. All rights reserved.
//
#if kSupportADTransition
#import <UIKit/UIKit.h>

@interface UITableViewController (ADScaleTransition)

/**
 * Present a view controller modally from the current view controller using a
 * scale animation, beginning from a UITableViewCell.
 * @param destinationViewController The view controller to present
 * @param indexPath The location of the cell to scale from.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)scaleToViewController:(UIViewController *)destinationViewController fromItemAtIndexPath:(NSIndexPath *)indexPath withCompletion:(void (^)(void))completion;

/**
 * Present a view controller modally from the current view controller using a
 * scale animation, beginning from a UITableViewCell.
 * @param destinationViewController The view controller to present
 * @param indexPath The location of the cell to scale from.
 * @param sourceSnapshot The placeholder image for the source view. Specifying
 * nil will take a snapshot just before the animation.
 * @param destinationSnapshot The placeholder image for the destination view.
 * Specifying nil will take a snapshot just before the animation.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)scaleToViewController:(UIViewController *)destinationViewController fromItemAtIndexPath:(NSIndexPath *)indexPath withSourceSnapshotImage:(UIImage *)sourceSnapshot andDestinationSnapshot:(UIImage *)destinationSnapshot withCompletion:(void (^)(void))completion;

/**
 * Present a view controller modally from the current view controller using a
 * scale animation, beginning from a UITableViewCell.
 * @param destinationViewController The view controller to present
 * @param indexPath The location of the cell to scale from.
 * @param destinationSize The size for the destination view controller to take
 * up on the screen.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)scaleToViewController:(UIViewController *)destinationViewController fromItemAtIndexPath:(NSIndexPath *)indexPath asChildWithSize:(CGSize)destinationSize withCompletion:(void (^)(void))completion;

/**
 * Present a view controller modally from the current view controller using a
 * scale animation, beginning from a UITableViewCell.
 * @param destinationViewController The view controller to present
 * @param indexPath The location of the cell to scale from.
 * @param destinationSize The size for the destination view controller to take
 * up on the screen.
 * @param sourceSnapshot The placeholder image for the source view. Specifying
 * nil will take a snapshot just before the animation.
 * @param destinationSnapshot The placeholder image for the destination view.
 * Specifying nil will take a snapshot just before the animation.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)scaleToViewController:(UIViewController *)destinationViewController fromItemAtIndexPath:(NSIndexPath *)indexPath asChildWithSize:(CGSize)destinationSize withSourceSnapshotImage:(UIImage *)sourceSnapshot andDestinationSnapshot:(UIImage *)destinationSnapshot withCompletion:(void (^)(void))completion;

@end
#endif