//
//  RefreshView.m
//  CommonLibrary
//
//  Created by Alexi on 15-2-4.
//  Copyright (c) 2015年 Alexi Chen. All rights reserved.
//

#import "RefreshView.h"

@implementation HeadRefreshView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.refreshHeight = kDefaultCellHeight;
    }
    return self;
}

- (void)addOwnViews
{
    _loading = [[UILabel alloc] init];
    _loading.textAlignment = NSTextAlignmentCenter;
    _loading.textColor = kDetailTextColor;
    _loading.font = kCommonSmallTextFont;
    [self addSubview:_loading];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:_indicator];
    
    self.backgroundColor = RGB(230, 230, 230);
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.bounds;
    
    rect.origin.y += rect.size.height - self.refreshHeight;
    rect.size.height = self.refreshHeight;
    
    _loading.frame = rect;
    _indicator.frame = CGRectInset(rect, (rect.size.width - 30)/2, (rect.size.height - 30)/2);
}

- (void)willLoading
{
    if (_state == EWillLoading)
    {
        return;
    }
    
    _loading.hidden = NO;
    _indicator.hidden = YES;
    _loading.text = @"下拉即可刷新";
    _state = EWillLoading;
}

- (void)releaseLoading
{
    if (_state == EReleaseLoading)
    {
        return;
    }
    _loading.hidden = NO;
    _indicator.hidden = YES;
    _loading.text = @"松开即可更新";
    
    _state = EReleaseLoading;
}

- (void)loading
{
    if (_state == ELoading)
    {
        return;
    }
    _loading.hidden = YES;
    _indicator.hidden = NO;
    
    [_indicator startAnimating];
    _state = ELoading;
}
- (void)loadingOver
{
    if (_state == ELoadingOver)
    {
        return;
    }
    
    dispatch_async( dispatch_get_main_queue(), ^{
        _loading.hidden = YES;
        if ([_indicator isAnimating])
        {
            [_indicator stopAnimating];
            _indicator.hidden = YES;
        }
        _state = ELoadingOver;
    });
}

@end


@implementation FootRefreshView

- (void)willLoading
{
    if (_state == EWillLoading)
    {
        return;
    }
    _loading.hidden = NO;
    _indicator.hidden = YES;
    _loading.text = @"上拉即可刷新";
    _state = EWillLoading;
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.bounds;
    
    rect.size.height = self.refreshHeight;
    
    _loading.frame = rect;
    _indicator.frame = CGRectInset(rect, (rect.size.width - 30)/2, (rect.size.height - 30)/2);
}


@end

