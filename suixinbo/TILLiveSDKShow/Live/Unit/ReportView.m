//
//  ReportView.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/2/6.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "ReportView.h"

@implementation ReportView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubViews];
        [self layoutSubViews];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)addSubViews
{
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = kColorWhite;
    [self addSubview:_bgView];
    
    _identifier = [[UILabel alloc] init];
    _identifier.textAlignment = NSTextAlignmentCenter;
    _identifier.backgroundColor = kColorWhite;
    [_bgView addSubview:_identifier];
    
    _reportBtn = [[UIButton alloc] init];
    _reportBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_reportBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
    _reportBtn.backgroundColor = kColorWhite;
    _reportBtn.layer.cornerRadius = 10;
    _reportBtn.layer.borderWidth = 1;
    _reportBtn.layer.borderColor = kColorBlue.CGColor;
    [_reportBtn setTitle:@"举报" forState:UIControlStateNormal];
    [_reportBtn addTarget:self action:@selector(onReport:) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_reportBtn];
}

- (void)onReport:(UIButton *)button
{
    __weak typeof(self) ws = self;
    UIAlertController *reportReasonAlert = [UIAlertController alertControllerWithTitle:@"举报原因" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [reportReasonAlert addAction:[UIAlertAction actionWithTitle:@"垃圾营销" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws showReportSucc];
    }]];
    [reportReasonAlert addAction:[UIAlertAction actionWithTitle:@"不实信息" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws showReportSucc];
    }]];
    [reportReasonAlert addAction:[UIAlertAction actionWithTitle:@"有害信息" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws showReportSucc];
    }]];
    [reportReasonAlert addAction:[UIAlertAction actionWithTitle:@"违法信息" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws showReportSucc];
    }]];
    [reportReasonAlert addAction:[UIAlertAction actionWithTitle:@"淫秽信息" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws showReportSucc];
    }]];
    [reportReasonAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [ws showReportSucc];
    }]];
    [[AppDelegate sharedAppDelegate].navigationViewController presentViewController:reportReasonAlert animated:YES completion:nil];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self setFrame:CGRectMake(0, -50, self.bounds.size.width, self.bounds.size.height)];
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)showReportSucc
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"举报成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [[AppDelegate sharedAppDelegate].navigationViewController presentViewController:alert animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)layoutSubViews
{
    CGRect rect = self.bounds;
    
    [_bgView sizeWith:CGSizeMake(rect.size.width, 50)];
    
    [_identifier sizeWith:CGSizeMake(rect.size.width/2, 44)];
    [_identifier alignParentLeftWithMargin:kDefaultMargin];
    [_identifier layoutParentVerticalCenter];
    
    [_reportBtn sizeWith:CGSizeMake(rect.size.width/4, 44)];
    [_reportBtn alignParentRightWithMargin:kDefaultMargin];
    [_reportBtn layoutParentVerticalCenter];
}

@end
