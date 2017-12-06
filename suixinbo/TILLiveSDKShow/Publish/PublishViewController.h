//
//  PublishViewController.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublishViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UILabel       *vcTitle;
@property (nonatomic, strong) UIButton      *closeBtn;

//封面
@property (nonatomic, strong) UIImageView   *liveCoverBg;
@property (nonatomic, strong) UIImageView   *liveCoverIcon;
@property (nonatomic, strong) UILabel       *liveCoverLabel;

@property (nonatomic, strong) UITextField   *liveTitle;
//分辨率
@property (nonatomic, strong) UIView        *roleView;
@property (nonatomic, strong) UILabel       *roleLabel;
@property (nonatomic, strong) UIButton      *roleBtn;

@property (nonatomic, strong) UIButton      *publishBtn;
@end
