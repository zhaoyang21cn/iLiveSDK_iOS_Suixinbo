//
//  LibraryViewController.m
//  
//
//  Created by Alexi on 3/11/14.
//  Copyright (c) 2014 Harman. All rights reserved.
//
#if kSupportLibraryPage
#import "LibraryViewController.h"

#import "UIView+CustomAutoLayout.h"
#import "UIView+Layout.h"


@interface LibraryViewController ()

@end

@implementation LibraryViewController



- (void)configParams
{
    self.libraryPages = [NSMutableArray array];
}


- (NSArray *)menuTitles
{
    return nil;
}

- (void)addOwnViews
{
    _libraryScrollView = [[LibraryScrollView alloc] init];
    _libraryScrollView.clipsToBounds = YES;
    _libraryScrollView.pageScrollDelegate = self;
    [self.view addSubview:_libraryScrollView];
    
    _navigationPanel = [[LibraryNavigationPanel alloc] initWith:[self menuTitles]];
    self.navigationItem.titleView = _navigationPanel;

}




- (void)configOwnViews
{
    self.navigationPanel.delegate = self;
    [self.navigationPanel select:0];
}

#define kNaviTitleHeight 44

- (void)layoutOnIPhone
{
    CGRect rect = self.view.bounds;
    [_navigationPanel sizeWith:CGSizeMake(rect.size.width - 60 * 2, kNaviTitleHeight)];
    [_navigationPanel layoutParentHorizontalCenter];
    [_navigationPanel relayoutFrameOfSubViews];
    

    CGRect libPageRect = rect;

    if (_libraryScrollView.pages.count == 0)
    {
        [_libraryScrollView setFrameAndLayout:libPageRect withPages:self.libraryPages];
    }
    else
    {
        [_libraryScrollView setFrameAndLayout:libPageRect];
    }
}




#pragma mark -
#pragma LibraryNavigationPanelDelegate Method
- (void)onLibraryNavigationPanel:(LibraryNavigationPanel *)panel navigateTo:(NSInteger)index
{
    [self.libraryScrollView scrollTo:index];
}


- (void)onPageScrollView:(PageScrollView *)pageView scrollToPage:(NSInteger)pageIndex
{
    [_navigationPanel select:pageIndex];
}

@end
#endif