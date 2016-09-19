//
//  DailUserCell.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "DialUserCell.h"

@implementation DialUserCell
{
    UITextField * _inputUser;
    id<DialUserCellAble> _dialModel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _inputUser = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        [_inputUser setClearButtonMode:UITextFieldViewModeAlways];
        [_inputUser setBackgroundColor:kClearColor];
        [_inputUser setBorderStyle:UITextBorderStyleLine];
        [_inputUser setAutocorrectionType:UITextAutocorrectionTypeNo];
        [_inputUser setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_inputUser addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventAllEditingEvents];
        [self.contentView addSubview:_inputUser];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_inputUser alignParentCenter];
    [_inputUser scaleToParentLeftWithMargin:20];
    [_inputUser scaleToParentRightWithMargin:20];
}

- (void)setDialUserModel:(id<DialUserCellAble>)dialModel
{
    _dialModel = dialModel;
}

- (id<DialUserCellAble>)getDialUserModel
{
    return _dialModel;
}

- (void)textChanged:(UITextField*)sender
{
    [_dialModel onDialUserChanged:sender.text path:_indexPath];
}

@end
