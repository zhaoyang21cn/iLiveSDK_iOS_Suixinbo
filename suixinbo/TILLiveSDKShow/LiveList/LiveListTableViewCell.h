//
//  LiveListTableViewCell.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveListTableViewCell : UITableViewCell
{
@protected
    
    UIImageView     *_liveCover;
    UIButton        *_liveType;
    
    UIView          *_liveHostView;
    
    UIButton        *_liveHost;
    
    UILabel         *_liveTitle;
    UILabel         *_liveHostName;
    
    UIButton    *_liveAudience;
    UIButton    *_livePraise;
    
@protected
    __weak TCShowLiveListItem *_liveItem;
}

@property (nonatomic,strong) UIButton *liveHost;
- (void)configWith:(TCShowLiveListItem *)item;
@end
