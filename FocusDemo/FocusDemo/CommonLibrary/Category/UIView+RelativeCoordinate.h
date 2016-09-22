//
//  UIView+RelativeCoordinate.h
//  CommonLibrary
//
//  Created by Alexi on 5/21/14.
//  Copyright (c) 2014 Alexi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (RelativeCoordinate)

- (BOOL)isSubContentOf:(UIView *)aSuperView;

- (CGRect)relativePositionTo:(UIView *)aSuperView;

@end
