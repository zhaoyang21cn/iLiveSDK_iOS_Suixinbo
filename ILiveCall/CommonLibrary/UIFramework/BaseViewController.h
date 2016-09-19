//
//  BaseViewController.h
//  CommonLibrary
//
//  Created by Alexi on 14-1-15.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//

#import "CommonBaseViewController.h"

@class FBKVOController;

@interface BaseViewController : CommonBaseViewController<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (void)callImagePickerActionSheet;

- (void)addIMListener;

// 对于界面上有输入框的，可以选择性调用些方法进行收起键盘
- (void)addTapBlankToHideKeyboardGesture;

@end

