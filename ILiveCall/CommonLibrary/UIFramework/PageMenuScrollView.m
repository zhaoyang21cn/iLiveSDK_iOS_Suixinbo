//
//  PageMenuScrollView.m
//  CommonLibrary
//
//  Created by Alexi on 15/4/21.
//  Copyright (c) 2015年 Alexi Chen. All rights reserved.
//
#if kSupportLibraryPage
#import "PageMenuScrollView.h"

#import "MenuButton.h"

#import "UIView+Layout.h"
#import "UIView+CustomAutoLayout.h"

@interface PageMenuItem ()

@property (nonatomic, strong) id<MenuAbleItem> menu;
@property (nonatomic, strong) UIView *page;

@end

@implementation PageMenuItem

- (instancetype)initWith:(id<MenuAbleItem>)menu page:(UIView *)page
{
    if (self = [super init])
    {
        self.menu = menu;
        self.page = page;
    }
    return self;
}


@end

@implementation PageMenuScrollView

- (instancetype)initWithPageMenus:(NSArray *)menuPages
{
    if (self = [super initWithFrame:CGRectZero])
    {
        _menuPages = [NSArray arrayWithArray:menuPages];
        _menuButtons = [NSMutableArray array];
        [self addOwnViews];
        [self configOwnViews];
    }
    return self;
}

- (void)onClickedMenu:(id<MenuAbleItem>)menuView
{
    
}

- (void)addOwnViews
{
    _menuScrollView = [[UIScrollView alloc] init];
    [self addSubview:_menuScrollView];
    
    _pageScrollView = [[UIScrollView alloc] init];
    _pageScrollView.pagingEnabled = YES;
    _pageScrollView.delegate = self;
    [self addSubview:_pageScrollView];
    
    
    __weak id ws = self;
    for (PageMenuItem *item in _menuPages)
    {
        id<MenuAbleItem> menu = [item menu];
        MenuButton *button = [[MenuButton alloc] initWithMenu:menu];
        [button setClickAction:^(id<MenuAbleItem> btn) {
            [ws onClickedMenu:btn];
        }];
        [_menuScrollView addSubview:button];
        [_menuButtons addObject:button];
        
        UIView *page = [item page];
        [_pageScrollView addSubview:page];
        
    }
    
    _selectIndexView = [[UIView alloc] init];
    _selectIndexView.backgroundColor = kNavBarThemeColor;
    [_menuScrollView addSubview:_selectIndexView];
}

- (void)changeMenuButtonsToNormalState
{
    for (UIButton *vButton in _menuButtons)
    {
        vButton.selected = NO;
    }
}

- (void)changeSelectedIndex:(BOOL)animated
{
    UIButton *btn = [_menuButtons objectAtIndex:_selectedIndex];
    CGRect rect = btn.frame;
    rect.origin.y += rect.size.height - 3;
    rect.size.height = 3;
    if (animated)
    {
        [UIView animateWithDuration:0.25 animations:^{
            _selectIndexView.frame = rect;
        }];
    }
    else
    {
        _selectIndexView.frame = rect;
    }
    
    [self changeMenuButtonsToNormalState];
    btn.selected = YES;
    [self moveScrolViewToIndex:_selectedIndex];
}

-(void)moveScrolViewToIndex:(NSInteger)aIndex
{
    if (aIndex >= 0 && _menuButtons.count < aIndex) {
        return;
    }
    
    if (!_canScrollMenu)
    {
        return;
    }
    
    UIButton *btn = [_menuButtons objectAtIndex:aIndex];
    
    CGRect rect = btn.frame;

    if (rect.origin.x + rect.size.width > _menuScrollView.contentOffset.x + _menuScrollView.bounds.size.width ||rect.origin.x < _menuScrollView.contentOffset.x)
    {
        [_menuScrollView scrollRectToVisible:rect animated:YES];
    }
}

#define kMenuHeight 40

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.bounds;
    
    CGRect menuSVRect = rect;
    menuSVRect.size.height = kMenuHeight;
    
    _menuScrollView.frame = menuSVRect;
    
    rect.origin.y += kMenuHeight;
    rect.size.height -= kMenuHeight;
    
    CGFloat menuWidth = menuSVRect.size.width / _menuButtons.count;
    if (menuWidth < 100)
    {
        _canScrollMenu = YES;
        // 可滑动
        menuWidth = 100;
    }
    else
    {
        _canScrollMenu = NO;
    }
    
    [_menuScrollView gridViews:_menuButtons inColumn:_menuButtons.count size:CGSizeMake(menuWidth, kMenuHeight) margin:CGSizeMake(0, 0) inRect:_menuScrollView.bounds];
    [_menuScrollView setContentSize:CGSizeMake(menuWidth * _menuButtons.count, 0)];
    
    _selectIndexView.bounds = CGRectMake(0, 0, menuWidth, kMenuHeight);
    [self changeSelectedIndex:NO];
    
    _pageScrollView.frame = rect;
    
    rect = _pageScrollView.bounds;
    
    for (PageMenuItem *item in _menuPages)
    {
        UIView *view = [item page];
        [view setFrameAndLayout:rect];
        rect.origin.x += rect.size.width;
    }
    [_pageScrollView setContentSize:CGSizeMake(rect.size.width * _menuPages.count, rect.size.height)];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_pageScrollView == scrollView)
    {
    
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_pageScrollView == scrollView)
    {
        int page = (scrollView.contentOffset.x + scrollView.bounds.size.width/2) / 320;
        if (_selectedIndex == page)
        {
            return;
        }
        _selectedIndex = page;
        [self changeSelectedIndex:YES];
        
    }
    
}

@end
#endif