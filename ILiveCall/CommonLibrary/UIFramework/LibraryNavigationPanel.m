//
//  LibraryNavigationPanel.m
//  
//
//  Created by Alexi on 3/11/14.
//  Copyright (c) 2014 Harman. All rights reserved.
//
#if kSupportLibraryPage

#import "LibraryNavigationPanel.h"

@implementation LibraryNavigationPanel



- (instancetype)initWith:(NSArray *)titles
{
    if (self = [super initWithFrame:CGRectZero])
    {
        _titles = [NSMutableArray arrayWithArray:titles];
        [self addOwnViews];
        [self configOwnViews];
        
        [self select:0];
    }
    return self;
}

- (void)addOwnViews
{
    _title = [[UILabel alloc] init];
    _title.textAlignment = NSTextAlignmentCenter;
    _title.textColor = kNavBarThemeColor;
    _title.font = kCommonSmallTextFont;
    [self addSubview:_title];
    
    _pageView = [[UIPageControl alloc] init];
    _pageView.numberOfPages = _titles.count;
    _pageView.pageIndicatorTintColor = kGrayColor;
    _pageView.currentPageIndicatorTintColor = kNavBarThemeColor;
    [_pageView addTarget:self action:@selector(onChangePage:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_pageView];
    
}

- (void)onChangePage:(UIPageControl *)pageCtrl
{
    if ([_delegate respondsToSelector:@selector(onLibraryNavigationPanel:navigateTo:)])
    {
        [_delegate onLibraryNavigationPanel:self navigateTo:pageCtrl.currentPage];
    }
}


#define kTitleHeight  30

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.bounds;
   
    CGRect titleRect = rect;
    titleRect.size.height = kTitleHeight;
    _title.frame = titleRect;
    
    titleRect.origin.y += titleRect.size.height;
    titleRect.size.height = rect.size.height - titleRect.size.height;
    _pageView.frame = titleRect;
    
}




- (void)select:(NSInteger)index
{
    if (index >= 0 && index < _titles.count)
    {
        _pageView.currentPage = index;
        _title.text = _titles[index];
    }
}



@end
#endif