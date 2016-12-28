//
//  LiveUIViewController.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "LiveUIViewController.h"

#import "MemberListCell.h"

#import "MsgTableViewCell.h"

#import "MsgInputView.h"

@interface LiveUIViewController ()<InviteInteractDelegate,BottomViewDelegate,UITableViewDelegate,UITableViewDataSource>

@end

@implementation LiveUIViewController

- (instancetype)initWith:(TCShowLiveListItem *)item
{
    if (self = [super init])
    {
        _liveItem = item;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _msgDatas = [NSMutableArray array];
    
    [self addSubViews];
    
//    [self addBlankTapGesture];
}

//- (void)addBlankTapGesture
//{
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBlankToHideInput)];
//    tap.numberOfTapsRequired = 1;
//    tap.numberOfTouchesRequired = 1;
//    [self.view addGestureRecognizer:tap];
//}

//- (void)onTapBlankToHideInput
//{
//    [UIView animateWithDuration:0.3 animations:^{
//        [_msgInputView resignFirstResponder];
//        _msgInputView.hidden = YES;
//        [_msgInputView removeFromSuperview];
//    }];
//}
- (void)addSubViews
{
    _closeBtn = [[UIButton alloc] init];
    [_closeBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeBtn];
    
    _topView = [[LiveUITopView alloc] initWith:_liveItem];
    _topView.isHost = _isHost;
    [self.view addSubview:_topView];
    
    _parView = [[LiveUIParView alloc] init];
    _parView.delegate = self;
    _parView.isHost = _isHost;
    [self.view addSubview:_parView];
    
    _bgAlphaView = [[UIView alloc] init];//initWithFrame:CGRectMake(0, -150, self.view.bounds.size.width, self.view.bounds.size.height)];
    _bgAlphaView.backgroundColor = [kColorBlack colorWithAlphaComponent:0.0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBlankToHide)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [_bgAlphaView addGestureRecognizer:tap];
    [self.view addSubview:_bgAlphaView];

    _memberListView = [[UITableView alloc] init];
    _memberListView.delegate = self;
    _memberListView.dataSource = self;
    _memberListView.tableFooterView = [[UIView alloc] init];
    _memberListView.separatorInset = UIEdgeInsetsZero;
    [_bgAlphaView addSubview:_memberListView];
    
    _members = [NSMutableArray array];
    _upVideoMembers = [NSMutableArray array];
    
    _msgTableView = [[UITableView alloc] init];
    _msgTableView.backgroundColor = [UIColor clearColor];
    _msgTableView.delegate = self;
    _msgTableView.dataSource = self;
    _msgTableView.separatorInset = UIEdgeInsetsZero;
    _msgTableView.tableFooterView = [[UIView alloc] init];//去掉多余的分割线
    [self.view addSubview:_msgTableView];
    
    _msgInputView = [[MsgInputView alloc] initWith:self];
    _msgInputView.limitLength = 32;
    _msgInputView.hidden = YES;
    [self.view addSubview:_msgInputView];
    
    _bottomView = [[LiveUIBttomView alloc] init];
    _bottomView.delegate = self;
    _bottomView.isHost = _isHost;
    [self.view addSubview:_bottomView];
}

- (void)popMsgInputView
{
    _msgInputView.hidden = NO;
    [_msgInputView becomeFirstResponder];
}

- (void)onClose:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClose)])
    {
        [self.delegate onClose];
    }
}

- (void)viewDidLayoutSubviews
{
    CGRect screenRect = self.view.bounds;
    CGFloat screenW = screenRect.size.width;
    
    [_topView sizeWith:CGSizeMake(screenW * 2/5, 50)];
    [_topView alignParentTopWithMargin:kDefaultMargin];
    [_topView alignParentLeftWithMargin:kDefaultMargin];
    
    [_closeBtn sizeWith:CGSizeMake(44, 44)];
    [_closeBtn alignParentRight];
    [_closeBtn alignVerticalCenterOf:_topView];
    
    [_parView sizeWith:CGSizeMake(screenW, 44)];
    [_parView layoutBelow:_topView margin:kDefaultMargin];
    
    [_bottomView sizeWith:CGSizeMake(screenW, 30)];
    [_bottomView alignParentBottomWithMargin:kDefaultMargin];
    
    [_msgInputView sameWith:_bottomView];
    [_msgInputView relayoutFrameOfSubViews];
    [_msgInputView layoutAbove:_bottomView margin:kDefaultMargin];
    
    [_msgTableView sizeWith:CGSizeMake(screenW * 2/3, 180)];
    [_msgTableView layoutAbove:_msgInputView margin:kDefaultMargin];
}

- (void)onInteract
{
    __weak LiveUIViewController *ws = self;
    
    NSString *imgroupid = [[ILiveRoomManager getInstance] getIMGroupId];
    [[TIMGroupManager sharedInstance] GetGroupMembers:imgroupid succ:^(NSArray *members) {
        
        [ws popMemberList:members];
    } fail:^(int code, NSString *msg) {
        NSLog(@"get group member fail ,code=%d,msg=%@",code,msg);
    }];
}

- (void)popMemberList:(NSArray *)members
{
    //群成员很大时，次处存在性能问题，可以单独维护房间成员，不用每次都获取。
    [_members removeAllObjects];
    
    NSString *loginId = [[ILiveLoginManager getInstance] getLoginId];
    for (TIMGroupMemberInfo *info in members)
    {
        if (![info.member isEqualToString:loginId])
        {
            [_members addObject:info];
        }
    }
    
    [_bgAlphaView setFrame:CGRectMake(0, -150, self.view.bounds.size.width, self.view.bounds.size.height)];
    _bgAlphaView.hidden = NO;
    
    [_memberListView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    [_memberListView reloadData];
    
    [UIView animateWithDuration:0.5 animations:^{
        [_bgAlphaView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }];
}

- (void)onTapBlankToHide
{
    [UIView animateWithDuration:0.5 animations:^{
        [_bgAlphaView setFrame:CGRectMake(0, -150, self.view.bounds.size.width, self.view.bounds.size.height)];
        [_memberListView setFrame:CGRectMake(0, -150, self.view.bounds.size.width, 150)];
    } completion:^(BOOL finished) {

        _bgAlphaView.hidden = YES;
    }];
}

- (void)onMessage:(ILVLiveTextMessage *)msg
{
    [_msgDatas addObject:msg];
    
    if (_msgDatas.count >= 500)
    {
        NSRange range = NSMakeRange(400, 100);//只保留最新的100条消息
        NSArray *temp = [_msgDatas subarrayWithRange:range];
        [_msgDatas removeAllObjects];
        [_msgDatas addObjectsFromArray:temp];
    }
    
    [_msgTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _msgTableView)
    {
        return _msgDatas.count;
    }
    else if (tableView == _memberListView)
    {
        return _members.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _msgTableView)
    {
        return 30;
    }
    else if (tableView == _memberListView)
    {
        return 44;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _msgTableView)
    {
        MsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveTextMessageCell"];
        
        if (cell == nil)
        {
            cell = [[MsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LiveTextMessageCell"];
        }
        ILVLiveTextMessage *msg = _msgDatas[indexPath.row];
        
        [cell configMsg:msg.sendId ? msg.sendId : [[ILiveLoginManager getInstance] getLoginId] msg:msg.text];
        return cell;
    }
    else if (tableView == _memberListView)
    {
        MemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveRoomMemberListCell"];
        
        if (cell == nil)
        {
            cell = [[MemberListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LiveRoomMemberListCell"];
        }
        
        TIMGroupMemberInfo *info = [_members objectAtIndex:indexPath.row];
        BOOL isConnect = [self isConnect:info.member];
        [cell configId:info.member isConnect:isConnect];
        
        return cell;
    }
    return nil;
}

- (BOOL)isConnect:(NSString *)identifier
{
    BOOL isConnect = NO;
    for (NSString *userId in _upVideoMembers)
    {
        if ([userId isEqualToString:identifier])
        {
            isConnect = YES;
            break;
        }
    }
    return isConnect;
}

@end
