/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2012-2013 Adam Debono. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
#if kSupportADTransition
#import <UIKit/UIKit.h>

#import "ADFlipTransition.h"

/**
 * A convenience category on UIViewController to easily present and dismiss
 * using ADFlipTransition.
 */
@interface UIViewController (ADFlipTransition)

/**
 * Present a view controller modally from the current view controller using a
 * flip animation.
 * @param destinationViewController The view controller to present
 * @param sourceView A subview of the current view controller to flip from
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)flipToViewController:(UIViewController *)destinationViewController fromView:(UIView *)sourceView withCompletion:(void (^)(void))completion;

/**
 * Present a view controller modally from the current view controller using a
 * flip animation.
 * @param destinationViewController The view controller to present
 * @param sourceView A subview of the current view controller to flip from
 * @param sourceSnapshot The placeholder image for the source view. Specifying
 * nil will take a snapshot just before the animation.
 * @param destinationSnapshot The placeholder image for the destination view.
 * Specifying nil will take a snapshot just before the animation.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)flipToViewController:(UIViewController *)destinationViewController fromView:(UIView *)sourceView withSourceSnapshotImage:(UIImage *)sourceSnapshot andDestinationSnapshot:(UIImage *)destinationSnapshot withCompletion:(void (^)(void))completion;

/**
 * Present a view controller as a child view controller from the current view
 * controller using a flip animation.
 * @param destinationViewController The view controller to present
 * @param sourceView A subview of the current view controller to flip from
 * @param destinationSize The size for the destination view controller to take
 * up on the screen.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)flipToViewController:(UIViewController *)destinationViewController fromView:(UIView *)sourceView asChildWithSize:(CGSize)destinationSize withCompletion:(void (^)(void))completion;

/**
 * Present a view controller as a child view controller from the current view
 * controller using a flip animation.
 * @param destinationViewController The view controller to present
 * @param sourceView A subview of the current view controller to flip from
 * @param destinationSize The size for the destination view controller to take
 * up on the screen.
 * @param sourceSnapshot The placeholder image for the source view. Specifying
 * nil will take a snapshot just before the animation.
 * @param destinationSnapshot The placeholder image for the destination view.
 * Specifying nil will take a snapshot just before the animation.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)flipToViewController:(UIViewController *)destinationViewController fromView:(UIView *)sourceView asChildWithSize:(CGSize)destinationSize withSourceSnapshotImage:(UIImage *)sourceSnapshot andDestinationSnapshot:(UIImage *)destinationSnapshot withCompletion:(void (^)(void))completion;

/**
 * Dismiss the current modal view controller with a flip animation.
 * @discussion Only works when the current view controller has been presented
 * using one of the category convenience methods to present the view controller.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)dismissFlipWithCompletion:(void (^)(void))completion;

/**
 * Dismiss the current modal view controller with a flip animation to a cell in 
 * a UICollectionViewController or UITableViewController.
 * @discussion Only works when the current view controller has been presented
 * using one of the category convenience methods to present the view controller.
 * @param indexPath The location of the cell to flip back to.
 * @param completion A block to run on completion. Can be NULL.
 */
- (void)dismissFlipToIndexPath:(NSIndexPath *)indexPath withCompletion:(void (^)(void))completion;

@end
#endif
