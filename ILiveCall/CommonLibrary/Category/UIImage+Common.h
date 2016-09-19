//
//  UIImage+Common.h
//  CommonLibrary
//
//  Created by Alexi on 13-11-6.
//  Copyright (c) 2013年 ywchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Common)

- (UIImage *)fixOrientation;

- (UIImage *)thumbnailWithSize:(CGSize)asize;

- (UIImage *)rescaleImageToSize:(CGSize)size;

- (UIImage *)cropImageToRect:(CGRect)cropRect;

- (CGSize)calculateNewSizeForCroppingBox:(CGSize)croppingBox;

- (UIImage *)cropCenterAndScaleImageToSize:(CGSize)cropSize;

- (UIImage *)cropToSquareImage;

// path为图片的键值
- (void)saveToCacheWithKey:(NSString *)key;

+ (UIImage *)loadFromCacheWithKey:(NSString *)key;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)randomColorImageWith:(CGSize)size;

- (UIImage *)croppedImage:(CGRect)bounds;

@end



#if kSupportUIImageNonCommon

//========================================

@interface UIImage (Cut)

- (UIImage *)clipImageWithScaleWithsize:(CGSize)asize;
- (UIImage *)clipImageWithScaleWithsize:(CGSize)asize roundedCornerImage:(NSInteger)roundedCornerImage borderSize:(NSInteger)borderSize;
@end

//========================================

@interface UIImage (Resize)



- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize transparentBorder:(NSUInteger)borderSize cornerRadius:(NSUInteger)cornerRadius interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize transform:(CGAffineTransform)transform drawTransposed:(BOOL)transpose interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageInRect:(CGRect)rect transform:(CGAffineTransform)transform drawTransposed:(BOOL)transpose interpolationQuality:(CGInterpolationQuality)quality;

- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

@end

//========================================

@interface UIImage (RoundedCorner)

- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;

@end

//========================================
@interface UIImage (SplitImageIntoTwoParts)
+ (NSArray*)splitImageIntoTwoParts:(UIImage*)image;
@end

#endif

