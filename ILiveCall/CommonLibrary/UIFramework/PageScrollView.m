//
//  PageScrollView.m
//  CommonLibrary
//
//  Created by Alexi Chen on 3/5/13.
//  Copyright (c) 2013 AlexiChen. All rights reserved.
//

#import "PageScrollView.h"

#import "UIView+Layout.h"

#import "IOSDeviceConfig.h"
#import "UIView+CustomAutoLayout.h"
#import "NSString+Common.h"

@interface PageScrollView ()




@end


@implementation PageScrollView


-(void)addScrollView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc] init];
//    _pageControl.numberOfPages = _images.count;
//    _pageControl.currentPage = 0;
//    [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_pageControl];
    _pageControl.hidden = YES;

}

- (void)setPageIndex:(NSInteger)pageIndex
{
    _pageIndex = pageIndex;
    _pageControl.currentPage = pageIndex;
}


- (void)changeToPage:(NSInteger)page manual:(BOOL)isManual
{
    [self loadPage:page - 1 feedBack:NO];
    [self loadPage:page feedBack:isManual];
    [self loadPage:page + 1 feedBack:NO];
    
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:NO];
    
    _pageControlUsed = YES;
}


- (void)changePage:(id)sender
{
    NSInteger page = _pageControl.currentPage;
    [self changeToPage:page manual:NO];
}

- (void)addOwnViews
{
    [self addScrollView];
}

- (void)roratePages
{
    for (NSInteger page = 0; page < _pages.count; page++)
    {
        UIView *view = [_pages objectAtIndex:page];
        if (view.superview != nil)
        {
            CGRect rect = _scrollView.bounds;
            rect.origin.x = rect.size.width * page;
            [view setFrameAndLayout:rect];
        }
    }

}


- (void)setFrameAndLayout:(CGRect)rect withPages:(NSArray *)pages
{
    if (!pages) {
        return;
    }
    if (_pages != pages)
    {
         self.pages = pages;
    }
    
   
    [self setFrameAndLayout:rect];
    // 设置scrollView相关的内容
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _pages.count, _scrollView.frame.size.height);
    
    _pageControl.numberOfPages = self.pages.count;
    _pageControl.currentPage = _pageIndex;

    [self roratePages];
    
    
    [self loadPage:_pageIndex - 1 feedBack:NO];
    [self loadPage:_pageIndex feedBack:NO];
    [self loadPage:_pageIndex + 1 feedBack:NO];
    
//    [self loadPage:_pageIndex feedBack:NO];
    CGPoint p = _scrollView.contentOffset;
    p.x = _pageIndex * _scrollView.frame.size.width;
    _scrollView.contentOffset = p;
    
    if (_pageIndex >= 0 && _pageIndex < _pages.count)
    {
        if (_pageScrollDelegate && [_pageScrollDelegate respondsToSelector:@selector(onPageScrollView:scrollToPage:)])
        {
            [_pageScrollDelegate onPageScrollView:self scrollToPage:_pageIndex];
        }
    }
    
}

#define kPageIndicatorHeight 10

- (CGRect)pageIndicatorRect
{
    CGRect rect = self.bounds;
    
    rect.origin.y += rect.size.height - kPageIndicatorHeight;
    rect.size.height = kPageIndicatorHeight;
    rect = CGRectInset(rect, 9, (kPageIndicatorHeight - 5)/2);
    CGFloat pw = rect.size.width / _pages.count;
    
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor(((_scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1);
    
    rect.origin.x += page * pw;
    rect.size.width = pw;
    return rect;
}

- (void)relayoutFrameOfSubViews
{
    _scrollView.frame = self.bounds;
    
    [_pageControl layoutParentHorizontalCenter];
    
    if ([[IOSDeviceConfig sharedConfig] isIPhone4])
    {
        [_pageControl alignParentBottomWithMargin:30];
    }
    else
    {
        [_pageControl alignParentBottomWithMargin:50];
    }
    
}

- (void)loadPage:(NSInteger)page feedBack:(BOOL)need
{
    if (page < 0) {
        return;
    }
    
    if (page >= _pages.count) {
        return;
    }
    
    if (_pages.count == 0) {
        return;
    }
    
    UIView *view = [_pages objectAtIndex:page];
    
    if (view.superview == nil)
    {
        CGRect rect = _scrollView.bounds;
        rect.origin.x = rect.size.width * page;
        [view setFrameAndLayout:rect];
        [_scrollView addSubview:view];
    }
    else
    {
        CGRect rect = _scrollView.bounds;
        rect.origin.x = rect.size.width * page;
        [view setFrameAndLayout:rect];
    }
    
    if (need)
    {
        if (_pageIndex >= 0 && _pageIndex < _pages.count)
        {
            if (_pageScrollDelegate && [_pageScrollDelegate respondsToSelector:@selector(onPageScrollView:scrollToPage:)])
            {
                [_pageScrollDelegate onPageScrollView:self scrollToPage:_pageIndex];
            }
        }
    }
    
}

- (void)scrollTo:(NSInteger)pageIndex
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    CGPoint p = _scrollView.contentOffset;
    p.x = pageIndex * pageWidth;
    _scrollView.contentOffset = p;
    
//    DebugLog(@"%@", NSStringFromCGPoint(p));
    self.pageIndex = pageIndex;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_pageControlUsed)
    {
        return;
    }
//    DebugLog(@"scrollViewDidScroll");
    CGFloat pageWidth = _scrollView.frame.size.width;
    NSInteger pi = floor(((_scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1);

    
    if (_pageIndex == pi) {
        return;
    }
    else
    {
        self.pageIndex = pi;
        [self loadPage:_pageIndex - 1 feedBack:NO];
        [self loadPage:_pageIndex feedBack:YES];
        [self loadPage:_pageIndex + 1 feedBack:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

- (void)setPageFrame:(NSInteger)page
{
    if (page < 0) {
        return;
    }
    
    if (page >= _pages.count) {
        return;
    }
    
    if (_pages.count == 0) {
        return;
    }
    
    UIView *view = [_pages objectAtIndex:page];
    
    if (view.superview == nil)
    {
        CGRect rect = _scrollView.bounds;
        rect.origin.x = rect.size.width * page;
        [view setFrameAndLayout:rect];
        [_scrollView addSubview:view];
    }
}

- (NSInteger)pageCount
{
    return [_pages count];
}

@end
