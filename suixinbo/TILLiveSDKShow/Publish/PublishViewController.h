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
@property (nonatomic, strong) UIImageView   *liveCover;
@property (nonatomic, strong) UITextField   *liveTitle;
//分辨率
@property (nonatomic, strong) UIView        *roleView;
@property (nonatomic, strong) UILabel       *roleLabel;
@property (nonatomic, strong) UIButton      *roleBtn;

@property (nonatomic, strong) UIButton      *publishBtn;
@end
