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

- (instancetype)initWith:(TCShowLiveListItem *)item isHost:(BOOL)isHost
{
    if (self = [super init])
    {
        _isHost = isHost;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFreshAudience) name:kUserMemChange_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchRoomRefresh:) name:kUserSwitchRoom_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTopPure:) name:kPureDelete_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTopNoPure:) name:kNoPureDelete_Notification object:nil];
}

- (void)onTopPure:(NSNotification *)noti
{
    CGRect selfFrame = self.frame;
    _restoreRect = selfFrame;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect moveToRect = CGRectMake(selfFrame.origin.x, -(selfFrame.origin.y+selfFrame.size.height), selfFrame.size.width, selfFrame.size.height);
        [self setFrame:moveToRect];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)onTopNoPure:(NSNotification *)noti
{
    self.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        [self setFrame:_restoreRect];
    } completion:^(BOOL finished) {
    }];
}

- (void)switchRoomRefresh:(NSNotification *)noti
{
    _liveItem = (TCShowLiveListItem *)noti.object;
    _isHost = NO;
    _roomId.text = [NSString stringWithFormat:@"%ld",(long)_liveItem.info.roomnum];
    _timeLabel.text = _liveItem.uid;
    [self onFreshAudience];
}

- (void)addTopSubViews
{
    //top view
    _avatarView = [[UIImageView alloc] initWithImage:kDefaultUserIcon];
    //下载主播头像
    __weak typeof(self)ws = self;
    //设置主播头像
    [[TIMFriendshipManager sharedInstance] GetUsersProfile:@[_liveItem.uid] succ:^(NSArray *friends) {
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
            dispatch_sync(dispatch_get_main_queue(), ^{
                [ws.avatarView setImage:image];
            });
        }
    } fail:nil];
    _avatarView.layer.cornerRadius = 22;
    _avatarView.layer.masksToBounds = YES;
    [self addSubview:_avatarView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarClick:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    _avatarView.userInteractionEnabled = YES;
    [_avatarView addGestureRecognizer:tap];
    
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
    _timeLabel.text = _isHost ? @"00:00" : _liveItem.uid;
    _timeLabel.textColor = kColorWhite;
    [self addSubview:_timeLabel];
    
    _liveTime = 0;
    
    if (_isHost)
    {   
        [_liveTimer invalidate];
        _liveTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onLiveTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_liveTimer forMode:NSRunLoopCommonModes];
    }
    
    _liveAudienceBtn = [[UIButton alloc] init];
    [_liveAudienceBtn setTitle:[NSString stringWithFormat:@"%d",_liveItem.info.memsize] forState:UIControlStateNormal];//[NSString stringWithFormat:@"%ld",(long)_liveItem.admireCount]
    [_liveAudienceBtn setImage:[UIImage imageNamed:@"visitor_white"] forState:UIControlStateNormal];
    _liveAudienceBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _liveAudienceBtn.titleLabel.font = kAppSmallTextFont;
    [_liveAudienceBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self addSubview:_liveAudienceBtn];
    
    _livePraiseBtn = [[UIButton alloc] init];
    [_livePraiseBtn setTitle:[NSString stringWithFormat:@"%d",_liveItem.info.thumbup] forState:UIControlStateNormal];//[NSString stringWithFormat:@"%ld",(long)_liveItem.watchCount]
    [_livePraiseBtn setImage:[UIImage imageNamed:@"like_white"] forState:UIControlStateNormal];
    _livePraiseBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _livePraiseBtn.titleLabel.font = kAppSmallTextFont;
    [_livePraiseBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self addSubview:_livePraiseBtn];
    
    _roomId = [[UILabel alloc] init];
    _roomId.text = [NSString stringWithFormat:@"%ld",(long)_liveItem.info.roomnum];
    _roomId.textColor = kColorWhite;
    [self addSubview:_roomId];
}

- (void)onAvatarClick:(UIButton *)button
{
    if (_isHost)
    {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickIcon)])
    {
        [self.delegate onClickIcon];
    }
}

- (void)onLiveTimer
{
    _liveTime++;
    NSString *durStr = nil;
    if (_liveTime > 3600)
    {
        int h = (int)_liveTime/3600;
        int m = (int)(_liveTime - h *3600)/60;
        int s = (int)_liveTime%60;
        durStr = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
    }
    else
    {
        int m = (int)_liveTime/60;
        int s = (int)_liveTime%60;
        durStr = [NSString stringWithFormat:@"%02d:%02d", m, s];
    }
    _timeLabel.text = durStr;
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

    [_liveAudienceBtn sizeWith:CGSizeMake(_timeLabel.bounds.size.width/2, _timeLabel.bounds.size.height)];
    [_liveAudienceBtn alignLeft:_timeLabel];
    [_liveAudienceBtn alignBottom:_avatarView];
    
    if (_isHost)
    {
        [_livePraiseBtn sameWith:_liveAudienceBtn];
        [_livePraiseBtn layoutToRightOf:_liveAudienceBtn];
    }
    
    [_roomId sizeWith:CGSizeMake(150, 30)];
    [_roomId layoutToRightOf:_timeLabel margin:20];
    [_roomId layoutParentVerticalCenter];
}

- (void)onParisePlus
{
    if (_isHost)
    {
        _liveItem.info.thumbup++;
        [_livePraiseBtn setTitle:[NSString stringWithFormat:@"%d",_liveItem.info.thumbup] forState:UIControlStateNormal];
    }
}

- (void)onAudiencePlus
{
    int curAudience = [_liveAudienceBtn.titleLabel.text intValue];
    curAudience++;
    [_liveAudienceBtn setTitle:[NSString stringWithFormat:@"%d",curAudience] forState:UIControlStateNormal];
}

- (void)onFreshAudience
{
    [_liveAudienceBtn setTitle:[NSString stringWithFormat:@"%d",_liveItem.info.memsize] forState:UIControlStateNormal];
}
@end
