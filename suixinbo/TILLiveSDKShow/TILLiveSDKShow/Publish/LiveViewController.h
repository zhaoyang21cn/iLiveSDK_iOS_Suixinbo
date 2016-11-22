//
//  LiveViewController.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LiveUIViewController.h"

@interface LiveViewController : UIViewController
{
    UIButton *_closeBtn;

    TCShowLiveListItem  *_liveItem;
    
    BOOL _isHost;//自己是不是主播
    
    LiveUIViewController *_liveUI;
}

- (instancetype)initWith:(TCShowLiveListItem *)item;

@end
