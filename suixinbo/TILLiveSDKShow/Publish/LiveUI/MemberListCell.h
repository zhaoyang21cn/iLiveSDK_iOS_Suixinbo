//
//  MemberListCell.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberListCell : UITableViewCell
{
    UILabel     *_identifier;
    UIButton    *_connectBtn;
}

- (void)configId:(NSString *)identifier;
@end

