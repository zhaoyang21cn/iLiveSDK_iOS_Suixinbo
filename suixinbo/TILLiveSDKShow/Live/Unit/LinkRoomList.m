//
//  LinkRoomList.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/4/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LinkRoomList.h"

@implementation LinkRoomList

- (void)configRoomList:(RoomListConfig *)config
{
    _roomListconfig = config;
    [self setFrame:config.frame];
    [self addObserver];
    [self addOwnViews];
    [self layoutViews];
    [_tableView reloadData];
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissSelf) name:kLinkRoomBtn_Notification object:nil];
}

- (void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLinkRoomBtn_Notification object:nil];
}

- (void)addOwnViews
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    _clearBg = [[UIView alloc] init];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [_clearBg addGestureRecognizer:tap];
    [self addSubview:_clearBg];
    
    _alphaBg = [[UIView alloc] init];
    _alphaBg.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
    [_clearBg addSubview:_alphaBg];
    
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsZero;
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    [_alphaBg addSubview:_tableView];
    
    UILabel *tableHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    tableHeaderLabel.text = @"主播列表";
    tableHeaderLabel.textAlignment = NSTextAlignmentCenter;
    tableHeaderLabel.backgroundColor = kColorWhite;
    tableHeaderLabel.textColor = kColorPurple;
    _tableView.tableHeaderView = tableHeaderLabel;
}

- (void)layoutViews
{
    CGRect selfRect = self.bounds;
    _clearBg.frame = selfRect;
    
    CGFloat height = 44*_roomListconfig.liveList.count + 30;
    if (height > _clearBg.frame.size.height)
    {
        height = _clearBg.frame.size.height;
    }
    [_alphaBg sizeWith:CGSizeMake(_clearBg.frame.size.width, height)];
    [_alphaBg alignParentTop];
    
    [_tableView sizeWith:_alphaBg.bounds.size];
    [_tableView alignParentTop];
}

- (void)onTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self dismissSelf];
    }
}

- (void)dismissSelf
{
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect selfRect = ws.frame;
        selfRect.origin.y -= _alphaBg.bounds.size.height;
        [ws setFrame:selfRect];
    } completion:^(BOOL finished) {
        [ws removeObserver];
        [ws removeFromSuperview];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _roomListconfig.liveList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LinkRoomListCell"];
    if (!cell)
    {
        cell = [[RoomListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LinkRoomListCell"];
    }
    TCShowLiveListItem *item = [_roomListconfig.liveList objectAtIndex:indexPath.row];
    [cell config:item];
    return cell;
}

@end

@implementation RoomListConfig
@end

@implementation RoomListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self addSubViews];
        [self layout];
    }
    return self;
}

- (void)addSubViews
{
    _userInfoLabel = [[UILabel alloc] init];
    _userInfoLabel.textAlignment = NSTextAlignmentLeft;
    _userInfoLabel.layer.cornerRadius = 5.0;
    _userInfoLabel.layer.borderColor = kColorPurple.CGColor;
    _userInfoLabel.layer.borderWidth = 0.5;
    _userInfoLabel.textColor = kColorWhite;
    _userInfoLabel.textAlignment = NSTextAlignmentCenter;
    _userInfoLabel.numberOfLines = 0;
    _userInfoLabel.font = kAppSmallTextFont;
    _userInfoLabel.backgroundColor = kColorBlue;
    [self.contentView addSubview:_userInfoLabel];
    
    _linkRommBtn = [[UIButton alloc] init];
    _linkRommBtn.layer.cornerRadius = 5.0;
    _linkRommBtn.layer.borderColor = kColorPurple.CGColor;
    _linkRommBtn.layer.borderWidth = 0.5;
    _linkRommBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_linkRommBtn setTitle:@"跨房连麦" forState:UIControlStateNormal];
    [_linkRommBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
    [_linkRommBtn addTarget:self action:@selector(onLinkRoom) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_linkRommBtn];
}

- (void)layout
{
    CGRect selfRect = self.bounds;
    CGFloat selfW = selfRect.size.width;
    
    [_userInfoLabel sizeWith:CGSizeMake(selfW * 2/5, 40)];
    [_userInfoLabel layoutParentVerticalCenter];
    [_userInfoLabel alignParentLeftWithMargin:kDefaultMargin];
    
    [_linkRommBtn sizeWith:CGSizeMake(selfW / 5, 30)];
    [_linkRommBtn layoutParentVerticalCenter];
    [_linkRommBtn alignParentRightWithMargin:kDefaultMargin];
}

- (void)onLinkRoom
{
    [[TILLiveManager getInstance] linkRoomRequest:_liveItem.uid succ:^{
        [AlertHelp tipWith:@"发送成功" wait:1];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLinkRoomBtn_Notification object:nil];
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSString *logInfo = [NSString stringWithFormat:@"module=%@,code=%d,msg=%@",module,errId,errMsg];
        [AlertHelp alertWith:@"发送失败" message:logInfo cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
    }];
}

- (void)config:(TCShowLiveListItem *)item
{
    _liveItem = item;
    _userInfoLabel.text = [NSString stringWithFormat:@"%@\n%@(%ld)",item.info.title,item.uid,(long)item.info.roomnum];
}

@end
