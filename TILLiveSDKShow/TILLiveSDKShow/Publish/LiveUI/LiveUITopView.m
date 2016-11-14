//
//  LiveUITopView.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LiveUITopView.h"
#import "LiveViewController.h"

@implementation LiveUITopView

- (instancetype)initWith:(TCShowLiveListItem *)item
{
    if (self = [super init])
    {
        _liveItem = item;
        self.backgroundColor = [kColorBlack colorWithAlphaComponent:0.5];
        self.layer.cornerRadius = 25;
        [self addTopSubViews];
        [self addNotification];
    }
    return self;
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onParisePlus) name:kUserParise_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudiencePlus) name:kUserJoinRoom_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudienceLess) name:kUserExitRoom_Notification object:nil];
}

- (void)addTopSubViews
{
    //top view
    _avatarView = [[UIImageView alloc] initWithImage:kDefaultUserIcon];
    _avatarView.layer.cornerRadius = 22;
    _avatarView.layer.masksToBounds = YES;
    [self addSubview:_avatarView];
    
    _netStatusBtn = [[UIButton alloc] init];
    [_netStatusBtn setBackgroundImage:[UIImage imageNamed:@"net3"] forState:UIControlStateNormal];
    [self addSubview:_netStatusBtn];
    
    _liveStatusBtn = [[UIButton alloc] init];
    _liveStatusBtn.layer.cornerRadius = 5;
    _liveStatusBtn.backgroundColor = kColorGreen;
    [self addSubview:_liveStatusBtn];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.adjustsFontSizeToFitWidth = YES;
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    //TODO host?
    _timeLabel.text = @"00:00";
    [self addSubview:_timeLabel];
    
    _liveAudienceBtn = [[UIButton alloc] init];
    [_liveAudienceBtn setTitle:[NSString stringWithFormat:@"%ld",(long)_liveItem.admireCount] forState:UIControlStateNormal];
    [_liveAudienceBtn setImage:[UIImage imageNamed:@"visitor_white"] forState:UIControlStateNormal];
    _liveAudienceBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _liveAudienceBtn.titleLabel.font = kAppSmallTextFont;
    [_liveAudienceBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self addSubview:_liveAudienceBtn];
    
    _livePraiseBtn = [[UIButton alloc] init];
    [_livePraiseBtn setTitle:[NSString stringWithFormat:@"%ld",(long)_liveItem.watchCount] forState:UIControlStateNormal];
    [_livePraiseBtn setImage:[UIImage imageNamed:@"like_white"] forState:UIControlStateNormal];
    _livePraiseBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _livePraiseBtn.titleLabel.font = kAppSmallTextFont;
    [_livePraiseBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self addSubview:_livePraiseBtn];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_avatarView sizeWith:CGSizeMake(44, 44)];
    [_avatarView layoutParentVerticalCenter];
    [_avatarView alignParentLeftWithMargin:3];
    
    [_netStatusBtn sizeWith:CGSizeMake(20, 20)];
    [_netStatusBtn layoutToRightOf:_avatarView margin:5];
    [_netStatusBtn alignParentTopWithMargin:kDefaultMargin];
    
    [_liveStatusBtn sizeWith:CGSizeMake(22, 10)];
    [_liveStatusBtn layoutToRightOf:_avatarView margin:5];
    [_liveStatusBtn alignParentBottomWithMargin:kDefaultMargin];
    
    [_timeLabel sizeWith:CGSizeMake(15, 15)];
    [_timeLabel alignTop:_avatarView];
    [_timeLabel layoutToRightOf:_netStatusBtn margin:3];
    [_timeLabel scaleToParentRightWithMargin:10];
    _timeLabel.text = _isHost ? @"00:00" : @"hostId";
    
    [_liveAudienceBtn sizeWith:CGSizeMake(_timeLabel.bounds.size.width/2, _timeLabel.bounds.size.height)];
    [_liveAudienceBtn alignLeft:_timeLabel];
    [_liveAudienceBtn alignBottom:_avatarView];
    
    [_livePraiseBtn sameWith:_liveAudienceBtn];
    [_livePraiseBtn layoutToRightOf:_liveAudienceBtn];
}

- (void)onParisePlus
{
    int curParise = [_livePraiseBtn.titleLabel.text intValue];
    curParise++;
    [_livePraiseBtn setTitle:[NSString stringWithFormat:@"%d",curParise] forState:UIControlStateNormal];
}

- (void)onAudiencePlus
{
    int curAudience = [_liveAudienceBtn.titleLabel.text intValue];
    curAudience++;
    [_liveAudienceBtn setTitle:[NSString stringWithFormat:@"%d",curAudience] forState:UIControlStateNormal];
}

- (void)onAudienceLess
{
    int curAudience = [_liveAudienceBtn.titleLabel.text intValue];
    curAudience--;
    [_liveAudienceBtn setTitle:[NSString stringWithFormat:@"%d",curAudience] forState:UIControlStateNormal];
}

@end
