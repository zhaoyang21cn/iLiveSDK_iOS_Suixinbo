//
//  PublishViewController.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublishViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImageView   *liveCover;
@property (nonatomic, strong) UITextField   *liveTitle;
@property (nonatomic, strong) UIButton      *publishBtn;
@end
