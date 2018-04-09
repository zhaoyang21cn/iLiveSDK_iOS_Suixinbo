//
//  SpeedTest.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/11/10.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "SpeedTest.h"

UIAlertController *_alert;

@implementation SpeedTest

+ (instancetype)shareInstance
{
    static SpeedTest *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SpeedTest alloc] init];
    });
    return instance;
}

- (void)startTest
{
    [ILiveSpeedTestManager shareInstance].delegate = self;
    
    SpeedTestRequestParam *param = [[SpeedTestRequestParam alloc] init];
    [[ILiveSpeedTestManager shareInstance] requestSpeedTest:param succ:^{
        
    } fail:^(NSString *module, int errId, NSString *errMsg) {
//        NSString *string = [NSString stringWithFormat:@"module=%@,code=%d,msg=%@",module,errId,errMsg];
//        [AlertHelp alertWith:@"请求测速失败" message:string cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
    }];
}

#pragma mark - measure speed delegate

//开始测速成功
- (void)onILiveSpeedTestStartSucc
{
    _alert = [UIAlertController alertControllerWithTitle:@"正在测速" message:@"0/0" preferredStyle:UIAlertControllerStyleAlert];
    [_alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[ILiveSpeedTestManager shareInstance] cancelSpeedTest:^{
            
        } fail:^(int code, NSString *msg) {
            NSString *string = [NSString stringWithFormat:@"code=%d,msg=%@",code,msg];
            [AlertHelp alertWith:@"取消测速失败" message:string cancelBtn:@"明白了" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
        }];
    }]];
    [[AlertHelp topViewController] presentViewController:_alert animated:YES completion:nil];
}

//开始测速失败
- (void)onILiveSpeedTestStartFail:(int)code errMsg:(NSString *)errMsg
{
    NSString *string = [NSString stringWithFormat:@"code=%d,msg=%@",code,errMsg];
    [AlertHelp alertWith:@"开始测速失败" message:string cancelBtn:@"明白了" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
}

//测速进度回调
- (void)onILiveSpeedTestProgress:(SpeedTestProgressItem *)item
{
    if (_alert)
    {
        _alert.message = [NSString stringWithFormat:@"%d/%d", item.recvPkgNum, item.totalPkgNum];
    }
}

//测速完成(超时时间30s)
- (void)onILiveSpeedTestCompleted:(SpeedTestResult *)result code:(int)code msg:(NSString *)msg
{
    if (code == 0)
    {
#if kIsAppstoreVersion
        [self appstoreResult:result code:code msg:msg];
#else
        [self developResult:result code:code msg:msg];
#endif
    }
    else
    {
        //测速失败
        NSString *str = [NSString stringWithFormat:@"%d,%@",code,msg];
        [AlertHelp alertWith:@"测速失败" message:str cancelBtn:@"关闭" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
    }
}

- (NSString *)ip4FromUInt:(unsigned int)ipNumber
{
    if (sizeof (unsigned int) != 4)
    {
        NSLog(@"Unkown type!");
        return @"";
    }
    unsigned int mask = 0xFF000000;
    unsigned int array[sizeof(unsigned int)];
    int steps = 8;
    int counter;
    for (counter = 0; counter < 4 ; counter++)
    {
        array[counter] = ((ipNumber & mask) >> (32-steps*(counter+1)));
        mask >>= steps;
    }
    NSMutableString *mutableString = [NSMutableString string];
    for (int index = counter-1; index >=0; index--)
    {
        [mutableString appendString:[NSString stringWithFormat:@"%d",array[index]]];
        if (index != 0)
        {
            [mutableString appendString:@"."];
        }
    }
    
    return mutableString;
}

//appstore版本显示的内容
- (void)appstoreResult:(SpeedTestResult *)result code:(int)code msg:(NSString *)msg
{
    NSMutableString *text = [NSMutableString string];
    //测试信息
    //测试结果列表
    for (SpeedTestResultItem *item in result.results)
    {
        [text appendFormat:@"%@ %@:\n",item.accessProv,item.accessIsp];
        [text appendFormat:@"上行丢包率:%.2f",item.upLoss/100.0];
        [text appendString:@"%,"];
        [text appendFormat:@"下行丢包率:%.2f",item.dwLoss/100.0];
        [text appendString:@"%,"];
        [text appendFormat:@"延时:%dms.\n",item.avgRtt];
    }
    AlertActionHandle copyBlock = ^(UIAlertAction * _Nonnull action){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:text];
    };
    [AlertHelp alertWith:@"测速结果" message:text funBtns:@{@"复制":copyBlock} cancelBtn:@"关闭" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
}

//开发版本显示的内容
- (void)developResult:(SpeedTestResult *)result code:(int)code msg:(NSString *)msg
{
    NSMutableString *text = [NSMutableString string];
    //测试信息
    //测速id
    [text appendFormat:@"测速Id：%llu\n", result.testId];
    //测速结束时间
    [text appendFormat:@"测速结束时间：%llu\n", result.testTime];
    //客户端类型
    [text appendFormat:@"客户端类型：%llu.(3:iphone 4:ipad)\n", result.clientType];
    //网络类型
    [text appendFormat:@"网络类型：%d.(1:wifi 2,3,4(G))\n", result.netType];
    //网络变换次数
    [text appendFormat:@"网络变换次数：%d.\n", result.netChangeCnt];
    //客户端ip
    [text appendFormat:@"客户端IP：%d(%@)\n", result.clientIp,[self ip4FromUInt:result.clientIp]];
    //通话类型
    [text appendFormat:@"通话类型：%d(0:纯音频，1:音视频)\n", result.callType];
    //sdkappid
    [text appendFormat:@"SDKAPPID：%d\n", result.sdkAppid];
    //测试结果列表
    for (SpeedTestResultItem *item in result.results)
    {
        //接口机端口、ip
        NSString *accInfo = [NSString stringWithFormat:@"%d:%u(%@)\n",item.accessPort,item.accessIp,[self ip4FromUInt:item.accessIp]];
        [text appendString:accInfo];
        //运营商 测试次数
        [text appendFormat:@"%@:%@:%@; 测试次数:%d\n",item.accessCountry,item.accessProv,item.accessIsp,item.testCnt];
        //上行、下行丢包率，平均延时
        [text appendFormat:@"upLoss:%d,dwLoss:%d,延时:%dms.\n",item.upLoss,item.dwLoss,item.avgRtt];
    }
    AlertActionHandle copyBlock = ^(UIAlertAction * _Nonnull action){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:text];
    };
    [AlertHelp alertWith:@"测速结果" message:text funBtns:@{@"复制":copyBlock} cancelBtn:@"关闭" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
}
@end
