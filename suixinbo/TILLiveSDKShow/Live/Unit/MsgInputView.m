//
//  MsgInputView.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/10.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "MsgInputView.h"

#import "LiveViewController+UI.h"

@implementation MsgInputView

- (instancetype)initWith:(LiveViewController *)liveUI
{
    if (self = [super init])
    {
        self.backgroundColor = [kColorBlack colorWithAlphaComponent:0.5];
        _liveUI = liveUI;
        [self addOwnViews];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)text
{
    return _textField.text;
}

- (void)setText:(NSString *)text
{
    _textField.text = text;
}

- (void)setPlacehoholder:(NSString *)placeholder
{
    if (!placeholder || placeholder.length == 0)
    {
        _textField.placeholder = nil;
        return;
    }
    _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:kColorWhite}];
}

- (void)addOwnViews
{
    _textField = [[UITextField alloc] init];
    _textField.textColor = kColorBlack;
    _textField.font = kAppMiddleTextFont;
    _textField.returnKeyType = UIReturnKeySend;
    _textField.delegate = self;
    _textField.backgroundColor = [kColorWhite colorWithAlphaComponent:0.5];
    [self addSubview:_textField];
    
    _confirmButton = [[UIButton alloc] init];
    [_confirmButton setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_confirmButton setTitle:@"发送" forState:UIControlStateNormal];
    [_confirmButton setBackgroundImage:[UIImage imageNamed:@"btn_sendbg"] forState:UIControlStateNormal];
    [_confirmButton addTarget:self action:@selector(onClickSend) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirmButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _isInputViewActive = NO;
    [self onClickSend];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _isInputViewActive = YES;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _isInputViewActive = YES;
    
    CGRect rect = self.frame;
    [UIView animateWithDuration:0.3 animations:^{
        [self setFrame:CGRectMake(rect.origin.x, rect.origin.y-216, rect.size.width, rect.size.height)];
        [self relayoutFrameOfSubViews];
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (void)textFieldDidBeginEditing
{
    _isInputViewActive = YES;
}


- (void)setLimitLength:(NSInteger)limitLength
{
    if (limitLength > 0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nil];
    }
    _limitLength = limitLength;
}

// 监听字符变化，并处理
- (void)onTextFiledEditChanged:(NSNotification *)obj
{
    if (_limitLength > 0)
    {
        UITextField *textField = _textField;
        NSString *toBeString = textField.text;
        
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position)
        {
            if (toBeString.length > _limitLength)
            {
                [textField shake];
                NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:_limitLength];
                if (rangeIndex.length == 1)
                {
                    textField.text = [toBeString substringToIndex:_limitLength];
                }
                else
                {
                    NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, _limitLength)];
                    textField.text = [toBeString substringWithRange:rangeRange];
                }
            }
        }
    }
}

- (void)relayoutFrameOfSubViews
{
    [_confirmButton sizeWith:CGSizeMake(44, 30)];
    [_confirmButton layoutParentVerticalCenter];
    [_confirmButton alignParentRightWithMargin:kDefaultMargin];
    
    [_textField sameWith:_confirmButton];
    [_textField layoutToLeftOf:_confirmButton margin:kDefaultMargin];
    [_textField scaleToParentLeftWithMargin:kDefaultMargin];
}

- (void)onClickSend
{
    ILVLiveTextMessage *msg = [[ILVLiveTextMessage alloc] init];
    msg.type = ILVLIVE_IMTYPE_GROUP;
    msg.text = _textField.text;
    __weak typeof(_liveUI) wLiveUI = _liveUI;
    [[TILLiveManager getInstance] sendTextMessage:msg succ:^{
        NSLog(@"send msg succ");
        [wLiveUI onMessage:msg];
    } failed:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"createRoom fail.module=%@,errid=%d,errmsg=%@",module,errId,errMsg);
    }];
    _textField.text = nil;
    [_textField resignFirstResponder];
    
    CGRect rect = self.frame;
    [self resignFirstResponder];
    [self setFrame:CGRectMake(rect.origin.x, rect.origin.y+216, rect.size.width, rect.size.height)];
    self.hidden = YES ;
}

- (BOOL)isInputViewActive
{
    return _isInputViewActive;
}

- (BOOL)resignFirstResponder
{
    _isInputViewActive = NO;
    return [_textField resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    _isInputViewActive = YES;
    return [_textField becomeFirstResponder];
}

@end
