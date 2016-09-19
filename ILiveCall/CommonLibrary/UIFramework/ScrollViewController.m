//
//  ScrollViewController.m
//  CommonLibrary
//
//  Created by Alexi on 4/2/14.
//  Copyright (c) 2014 Alexi. All rights reserved.
//

#import "ScrollViewController.h"


@interface ScrollViewController ()

@end

@implementation ScrollViewController

- (void)loadView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen  mainScreen].bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _scrollView.backgroundColor = kAppBakgroundColor;
    self.view = _scrollView;
}

- (void)layoutSubviewsFrame
{
    [super layoutSubviewsFrame];
    [self configContentSize];
}

- (void)configContentSize
{
    // TODO: 设置ContentSize
}

@end
