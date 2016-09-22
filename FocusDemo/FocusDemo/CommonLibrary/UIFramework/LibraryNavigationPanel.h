//
//  LibraryNavigationPanel.h
//  
//
//  Created by Alexi on 3/11/14.
//  Copyright (c) 2014 Harman. All rights reserved.
//
#if kSupportLibraryPage
#import <UIKit/UIKit.h>


@class LibraryNavigationPanel;

@protocol LibraryNavigationPanelDelegate <NSObject>

- (void)onLibraryNavigationPanel:(LibraryNavigationPanel *)panel navigateTo:(NSInteger)index;

@end

@interface LibraryNavigationPanel : UIView
{
@protected
    __weak id<LibraryNavigationPanelDelegate> _delegate;
    
    NSMutableArray *_titles;
    UILabel        *_title;
    UIPageControl  *_pageView;
    

}

@property (nonatomic, weak) id<LibraryNavigationPanelDelegate> delegate;


- (instancetype)initWith:(NSArray *)titles;

- (void)select:(NSInteger)index;

@end
#endif