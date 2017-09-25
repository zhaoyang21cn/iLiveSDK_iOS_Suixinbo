//
//  LiveListTableViewCell.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LiveListTableViewCell.h"

@implementation LiveListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self addOwnViews];
        self.contentView.backgroundColor = kColorWhite;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)addOwnViews
{
    _liveCover = [[UIImageView alloc] init];
    [self.contentView addSubview:_liveCover];
    
    _liveType = [[UIButton alloc] init];
    [_liveType setBackgroundImage:[UIImage imageNamed:@"live_type"] forState:UIControlStateNormal];
    [_liveCover addSubview:_liveType];
    
    _liveHostView = [[UIView alloc] init];
    _liveHostView.backgroundColor = kColorWhite;
    [self.contentView addSubview:_liveHostView];
    
    _liveHost = [[UIButton alloc] init];
    _liveHost.layer.cornerRadius = 22;
    _liveHost.layer.masksToBounds = YES;
    [_liveHostView addSubview:_liveHost];
    
    _liveTitle = [[UILabel alloc] init];
    _liveTitle.font = kAppMiddleTextFont;
    [_liveHostView addSubview:_liveTitle];
    
    _liveHostName = [[UILabel alloc] init];
    _liveHostName.font = kAppSmallTextFont;
    _liveHostName.textColor = kColorBlack60;
    [_liveHostView addSubview:_liveHostName];
    
    _liveAudience = [[UIButton alloc] init];
    [_liveAudience setImage:[UIImage imageNamed:@"visitors_red"] forState:UIControlStateNormal];
    _liveAudience.titleLabel.adjustsFontSizeToFitWidth = YES;
    _liveAudience.titleLabel.font = kAppSmallTextFont;
    [_liveAudience setTitleColor:kColorBlack60 forState:UIControlStateNormal];
    [_liveHostView addSubview:_liveAudience];
    
    _livePraise = [[UIButton alloc] init];
    [_livePraise setImage:[UIImage imageNamed:@"like_red"] forState:UIControlStateNormal];
    _livePraise.titleLabel.adjustsFontSizeToFitWidth = YES;
    _livePraise.titleLabel.font = kAppSmallTextFont;
    [_livePraise setTitleColor:kColorBlack60 forState:UIControlStateNormal];
    [_liveHostView addSubview:_livePraise];
}

- (void)configWith:(TCShowLiveListItem *)item;
{
    if (!item)
    {
        return;
    }
    [_liveCover setImage:kDefaultCoverIcon];
    [_liveHost setBackgroundImage:kDefaultUserIcon forState:UIControlStateNormal];
    if (item)
    {
        _liveHostName.text = item.uid;//host.username;
        _liveTitle.text = item.info.title;//item.title;
        [_liveAudience setTitle:[NSString stringWithFormat:@"%d",item.info.memsize] forState:UIControlStateNormal];//[NSString stringWithFormat:@"%d", (int)item.watchCount]
        [_livePraise setTitle:[NSString stringWithFormat:@"%d",item.info.thumbup] forState:UIControlStateNormal];//[NSString stringWithFormat:@"%d", (int)item.admireCount]
        //设置封面
        if (item.info.cover && item.info.cover.length > 0)
        {
            NSURL *imageUrl = [NSURL URLWithString:item.info.cover];
            NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
            _liveCover.image = [UIImage imageWithData:imageData];
        }
        __weak typeof(self)ws = self;
        //设置主播头像
        [[TIMFriendshipManager sharedInstance] GetUsersProfile:@[item.uid] succ:^(NSArray *friends) {
            if (friends.count <= 0)
            {
                return ;
            }
            TIMUserProfile *profile = friends[0];
            if (profile.faceURL && profile.faceURL.length > 0)
            {
                NSURL *avatarUrl = [NSURL URLWithString:profile.faceURL];
                NSData *avatarData = [NSData dataWithContentsOfURL:avatarUrl];
                UIImage *image = [UIImage imageWithData:avatarData];
                if ([NSThread isMainThread])
                {
                    [ws.liveHost setBackgroundImage:image forState:UIControlStateNormal];
                }
                else
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [ws.liveHost setBackgroundImage:image forState:UIControlStateNormal];
                    });
                }
            }
        } fail:nil];
    }
    else
    {
        _liveHostName.text = @"测试直播标题";
        _liveTitle.text = @"测试帐号";
        [_liveAudience setTitle:@"1000" forState:UIControlStateNormal];
        [_livePraise setTitle:@"2000" forState:UIControlStateNormal];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self relayoutFrameOfSubViews];
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.contentView.bounds;
    CGRect coverRect = rect;
    coverRect.size.height = (NSInteger)(rect.size.width * 0.618);
    _liveCover.frame = coverRect;
    
    [_liveType sizeWith:CGSizeMake(60, 30)];
    [_liveType alignParentTopWithMargin:kDefaultMargin];
    [_liveType alignParentLeftWithMargin:kDefaultMargin];
    
    coverRect.origin.y += coverRect.size.height;
    coverRect.size.height = 54;
    _liveHostView.frame = coverRect;
    
    [_liveHost sizeWith:CGSizeMake(44, 44)];
    [_liveHost layoutParentVerticalCenter];
    [_liveHost alignParentLeftWithMargin:kDefaultMargin];
    
    [_liveTitle sizeWith:CGSizeMake(0, 24)];
    [_liveTitle alignTop:_liveHost];
    [_liveTitle layoutToRightOf:_liveHost margin:kDefaultMargin];
    [_liveTitle scaleToParentRightWithMargin:kDefaultMargin];
    
    [_liveHostName sizeWith:CGSizeMake(_liveTitle.bounds.size.width/2, 20)];
    [_liveHostName alignLeft:_liveTitle];
    [_liveHostName layoutBelow:_liveTitle];
    
    [_liveAudience sizeWith:CGSizeMake(_liveTitle.bounds.size.width/4, 20)];
    [_liveAudience alignTop:_liveHostName];
    [_liveAudience layoutToRightOf:_liveHostName];
    
    [_livePraise sameWith:_liveAudience];
    [_livePraise layoutToRightOf:_liveAudience];
}

@end
