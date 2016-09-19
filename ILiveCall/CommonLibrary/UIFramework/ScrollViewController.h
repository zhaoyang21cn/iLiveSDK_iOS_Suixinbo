//
//  ScrollViewController.h
//  CommonLibrary
//
//  Created by Alexi on 4/2/14.
//  Copyright (c) 2014 Alexi. All rights reserved.
//

#import "BaseViewController.h"

@interface ScrollViewController : BaseViewController
{
@protected
    UIScrollView *_scrollView;
}

- (void)configContentSize;

@end
