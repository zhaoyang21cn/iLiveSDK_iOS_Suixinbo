//
//  IMAPlatform+TestSpeed.m
//  TCShow
//
//  Created by wilderliao on 16/7/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#if kIsMeasureSpeed
#import "IMAPlatform+TestSpeed.h"
#import <arpa/inet.h>

static NSString *const kTIMAVMeasureSpeed = @"kTIMAVMeasureSpeed";

typedef NS_ENUM(int, TestSpeedAlertViewTag)
{
    TestSpeedAlertViewTag_Progress = 1
};

@implementation IMAPlatform (TestSpeed)

UIAlertView *_alert;

- (TIMAVMeasureSpeeder *)measureSpeeder
{
    return objc_getAssociatedObject(self, (__bridge const void *)kTIMAVMeasureSpeed);
}

- (void)setMeasureSpeeder:(TIMAVMeasureSpeeder *)measureSpeeder
{
    objc_setAssociatedObject(self, (__bridge const void *)kTIMAVMeasureSpeed, measureSpeeder, OBJC_ASSOCIATION_RETAIN);
}

- (void)requestTestSpeed;
{
    [[HUDHelper sharedInstance] syncLoading:@"正在请求测速"];

    if (!self.measureSpeeder)
    {
        self.measureSpeeder = [[TIMAVMeasureSpeeder alloc] init];
        self.measureSpeeder.delegate = self;
    }
    
    [self.measureSpeeder requestMeasureSpeedWith:7 authType:6];
}

#pragma mark -AVMeasureSpeederDelegate

// 请求测速失败
- (void)onAVMeasureSpeedRequestFailed:(TIMAVMeasureSpeeder *)avts
{
    DebugLog(@"--------->onAVMeasureSpeedRequestFailed");
    
    [[HUDHelper sharedInstance] syncStopLoadingMessage:@"请求测速失败"];
}

// 请求测速成功
- (void)onAVMeasureSpeedRequestSucc:(TIMAVMeasureSpeeder *)avts
{
    DebugLog(@"--------->onAVMeasureSpeedRequestSucc");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[HUDHelper sharedInstance] syncStopLoading];
        
        _alert = [UIAlertView bk_showAlertViewWithTitle:@"正在测速" message:@"0/0" cancelButtonTitle:@"取消" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0)
            {
                DebugLog(@"取消测速");
                [[IMAPlatform sharedInstance].measureSpeeder cancelMeasureSpeed];
            }
        }];
        
        UIActivityIndicatorView *progressAi = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
        progressAi.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [progressAi startAnimating];
        [progressAi setColor:[UIColor darkGrayColor]];
        
        [_alert setValue:progressAi forKey:@"accessoryView"];
        
        [_alert show];
    });
}

// UDP未成功创建
- (void)onAVMeasureSpeedPingFailed:(TIMAVMeasureSpeeder *)avts
{
    
}

// 开始拼包
- (void)onAVMeasureSpeedStarted:(TIMAVMeasureSpeeder *)avts
{
    DebugLog(@"--------->onAVMeasureSpeedStarted");
}

- (void)onAVMeasureSpeedProgress:(TIMAVMeasureProgressItem *)item
{
    DebugLog(@"--------->%d/%d", item.recvPkgNum, item.totalPkgNum);
    
    if (_alert)
    {
        _alert.message = [NSString stringWithFormat:@"%d/%d", item.recvPkgNum, item.totalPkgNum];
    }
}
// 收包结束
// isByUser YES, 用户手动取消 NO : 收完所有包或内部超时自动返回
- (void)onAVMeasureSpeedPingCompleted:(TIMAVMeasureSpeeder *)avts byUser:(BOOL)isByUser
{
    [_alert dismissWithClickedButtonIndex:1 animated:YES];
    
    DebugLog(@"isbyuser = %d", isByUser);
    NSMutableString *text = [NSMutableString string];
    
    NSArray *result = [avts getMeasureResult];
    
    for (TIMAVMeasureSpeederItem *item in result)
    {
        [text appendString:[NSMutableString stringWithFormat:@"%d:",item.interfacePort]];
        
        struct in_addr ipAddr;
        ipAddr.s_addr = item.interfaceIP;
        char * charIpAddr = inet_ntoa(ipAddr);
        [text appendString:[NSString stringWithCString:charIpAddr encoding:NSUTF8StringEncoding]];
        
        [text appendString:[NSString stringWithFormat:@":%@,%@", item.idc, item.isp]];
        
        [text appendString:@"\n"];
        
        if (item.sendPkgNum == 0)
        {
            [text appendString:[NSString stringWithFormat:@"未发包"]];
        }
        else
        {
            float lose = (float)(item.sendPkgNum-item.recvPkgNum)/item.sendPkgNum;
            
            [text appendString:[NSString stringWithFormat:@"丢包率:%d%@, ", (int)(lose*100), @"%"]];
        }
        
        [text appendString:[NSString stringWithFormat:@"时延:%lums\n", (unsigned long)item.averageDelay]];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"测速结果" message:text delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
    [alert show];
}


@end
#endif