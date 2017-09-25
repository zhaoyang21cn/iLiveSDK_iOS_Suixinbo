//
//  MsgInputView.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/10.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LiveViewController;

@interface MsgInputView : UIView<UITextFieldDelegate>

{
@protected
    UITextField     *_textField;
    UIButton        *_confirmButton;
    
@protected
    BOOL            _isInputViewActive;
    LiveViewController *_liveUI;
}

@property (nonatomic, assign) NSInteger limitLength;    // 限制长度，> 0 时有效
@property (nonatomic, copy) NSString *text;

- (instancetype)initWith:(LiveViewController *)liveUI;

- (BOOL)isInputViewActive;

- (void)setPlacehoholder:(NSString *)placeholder;

- (void)relayoutFrameOfSubViews;

- (BOOL)resignFirstResponder;

- (BOOL)becomeFirstResponder;

@end
