//
//  ScrollPageView.h
//  CommonLibrary
//
//  Created by Alexi on 15/4/21.
//  Copyright (c) 2015年 Alexi Chen. All rights reserved.
//
#if kSupportLibraryPage
#import <UIKit/UIKit.h>

#import "MenuAbleItem.h"

@class PageMenuScrollView;

@interface PageMenuItem : NSObject
{
@protected
    id<MenuAbleItem>    _menu;
    UIView              *_page;
}

- (instancetype)initWith:(id<MenuAbleItem>)menu page:(UIView *)page;

@end


@interface PageMenuScrollView : UIView<UIScrollViewDelegate>
{
    NSArray         *_menuPages;
    
    UIScrollView    *_menuScrollView;
    NSMutableArray  *_menuButtons;
    UIView          *_selectIndexView;
    
    UIScrollView    *_pageScrollView;

    
    NSUInteger      _selectedIndex;
    
    BOOL            _canScrollMenu;

}

- (instancetype)initWithPageMenus:(NSArray *)menuPages;


@end

#endif
