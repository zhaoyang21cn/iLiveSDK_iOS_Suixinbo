//
//  LiveUITopView.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveUITopView : UIView
{
    //top view
    UIImageView *_avatarView;        //主播头像
    UIButton    *_netStatusBtn;      //网络质量
    UIButton    *_liveStatusBtn;     //直播质量
    UILabel     *_timeLabel;         //直播时间(如果是观众端，_timeView用来显示主播id)
    UIButton    *_liveAudienceBtn;   //观看人数
    UIButton    *_livePraiseBtn;     //点赞人数
    
    TCShowLiveListItem  *_liveItem;
}

@property (nonatomic, assign) BOOL isHost; //自己是不是主播

- (instancetype)initWith:(TCShowLiveListItem *)item;

@end
