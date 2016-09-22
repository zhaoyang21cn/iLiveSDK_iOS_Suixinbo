//
//  LibraryViewController.h
//  
//
//  Created by Alexi on 3/11/14.
//  Copyright (c) 2014 Harman. All rights reserved.
//
#if kSupportLibraryPage
#import "BaseViewController.h"

#import "LibraryNavigationPanel.h"
#import "PageScrollView.h"
#import "LibraryScrollView.h"



@interface LibraryViewController : BaseViewController<LibraryNavigationPanelDelegate, PageScrollViewDelegate>
{
@protected
    LibraryNavigationPanel  *_navigationPanel;
    LibraryScrollView       *_libraryScrollView;

@protected
    NSMutableArray          *_libraryPages;

    
}

@property (nonatomic, strong) LibraryNavigationPanel    *navigationPanel;
@property (nonatomic, strong) LibraryScrollView         *libraryScrollView;
@property (nonatomic, strong) NSMutableArray            *libraryPages;

- (NSArray *)menuTitles;

@end
#endif