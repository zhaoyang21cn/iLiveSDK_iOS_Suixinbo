//
//  LiveUITopView.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ReportView.h"

@protocol LiveUITopDelegate <NSObject>

- (void)onClickIcon;

@end

@interface LiveUITopView : UIView
{
    //top view
    UIImageView *_avatarView;        //主播头像
    UIButton    *_netStatusBtn;      //网络质量
    UIButton    *_liveStatusBtn;     //直播质量
    UILabel     *_timeLabel;         //直播时间(如果是观众端，_timeView用来显示主播id)
    UIButton    *_liveAudienceBtn;   //观看人数
    UIButton    *_livePraiseBtn;     //点赞人数
    
    UILabel     *_roomId;//房间id
    ReportView  *_reportView;
    TCShowLiveListItem  *_liveItem;
}

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, assign) BOOL isHost; //自己是不是主播
@property (nonatomic, strong) UILabel     *timeLabel;
@property (nonatomic, assign) NSInteger liveTime;
@property (nonatomic, strong) NSTimer *liveTimer;
@property (nonatomic, weak) id<LiveUITopDelegate> delegate;
@property (nonatomic, assign) CGRect restoreRect;

- (instancetype)initWith:(TCShowLiveListItem *)item isHost:(BOOL)isHost;

@end
