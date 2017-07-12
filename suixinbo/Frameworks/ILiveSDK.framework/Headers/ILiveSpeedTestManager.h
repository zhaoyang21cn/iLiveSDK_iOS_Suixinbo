//
//  ILiveSpeedTestManager.h
//  ILiveSDK
//
//  Created by wilderliao on 16/12/20.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "ILiveCommon.h"

@class ILiveSpeedTestManager;
@class SpeedTestProgressItem;
@class SpeedTestRequestParam;
@class SpeedTestResult;

@protocol ILiveSpeedTestDelegate;

@interface ILiveSpeedTestManager : NSObject

@property (nonatomic, weak) id<ILiveSpeedTestDelegate> delegate;

+ (instancetype)shareInstance;

// 请求测速，请求成功之后自动开始测速。param:测速参数
- (void)requestSpeedTest:(SpeedTestRequestParam *)param succ:(TCIVoidBlock)succ fail:(TCIErrorBlock)fail;

// 取消本次测速
- (void)cancelSpeedTest:(TIMSucc)succ fail:(TIMFail)fail;

@end


@protocol ILiveSpeedTestDelegate <NSObject>

@optional

//开始测速成功
- (void)onILiveSpeedTestStartSucc;

//开始测速失败
- (void)onILiveSpeedTestStartFail:(int)code errMsg:(NSString *)errMsg;

//测速进度回调
- (void)onILiveSpeedTestProgress:(SpeedTestProgressItem *)item;

//测速完成(超时时间30s)
- (void)onILiveSpeedTestCompleted:(SpeedTestResult *)result code:(int)code msg:(NSString *)msg;

@end


//请求测速参数
@interface SpeedTestRequestParam : NSObject

//callType 默认1  //通话类型，0:纯音频，1:音视频
@property (nonatomic, assign) uint32_t  callType;

//房间id(普通测速时不需填写，直播结束时测速填写上直播房间id)
@property (nonatomic, assign) uint32_t  roomId;

@end

//测速进度
@interface SpeedTestProgressItem : NSObject

@property (nonatomic, assign) unsigned int recvPkgNum;  //已收到

@property (nonatomic, assign) unsigned int totalPkgNum; //应发包总数

@end

@interface SpeedTestResult : NSObject

@property (nonatomic, assign) uint64_t testId;          // 测速id

@property (nonatomic, assign) uint64_t testTime;        //目前填测速结束时的时间

@property (nonatomic, assign) uint64_t clientType;      //0：unknown 1： pc 2： android 3： iphone 4： ipad

@property (nonatomic, assign) uint32_t netType;         //0:无网络；1:wifi；2:2g；3:3g；4:4g；10:wap；255:unknow；
@property (nonatomic, assign) uint32_t netChangeCnt;    //网络变换的次数

@property (nonatomic, assign) uint32_t clientIp;        // 用户ip,申请测速时server返回的clientip

@property (nonatomic, assign) uint32_t callType;        // 通话类型，0:纯音频，1:音视频

@property (nonatomic, assign) uint32_t sdkAppid;        // sdkappid

@property (nonatomic, strong) NSArray *results;         // 测试结果列表SpeedTestResultItem数组

@end

@interface SpeedTestResultItem : NSObject

@property (nonatomic, assign) uint32_t accessIp;        //接口机地址
@property (nonatomic, assign) uint32_t accessPort;      //接口机端口
@property (nonatomic, assign) uint32_t clientIp;        //客户端地址
@property (nonatomic, assign) uint32_t testCnt;         //测速次数
@property (nonatomic, assign) uint32_t upLoss;          //上行丢包率
@property (nonatomic, assign) uint32_t dwLoss;          //下行丢包率
@property (nonatomic, copy)  NSString *accessCountry;   //国家
@property (nonatomic, copy)  NSString *accessProv;      //省份
@property (nonatomic, copy)  NSString *accessIsp;       //运营商
@property (nonatomic, assign) uint32_t testPkgSize;     //测试包包长
@property (nonatomic, assign) uint32_t avgRtt;          //平均延时
@property (nonatomic, assign) uint32_t maxRtt;          //最大延时
@property (nonatomic, assign) uint32_t minRtt;          //最小延时
@property (nonatomic, assign) uint32_t rtt0_50;         //延时在 0-50ms 区间的包个数 [)区间
@property (nonatomic, assign) uint32_t rtt50_100;
@property (nonatomic, assign) uint32_t rtt100_200;
@property (nonatomic, assign) uint32_t rtt200_300;
@property (nonatomic, assign) uint32_t rtt300_700;
@property (nonatomic, assign) uint32_t rtt700_1000;
@property (nonatomic, assign) uint32_t rtt1000;			//延时在 1000ms以上的包个数
@property (nonatomic, assign) uint32_t jitter0_20;      //抖动在 0-20ms区间的个数
@property (nonatomic, assign) uint32_t jitter20_50;
@property (nonatomic, assign) uint32_t jitter50_100;
@property (nonatomic, assign) uint32_t jitter100_200;
@property (nonatomic, assign) uint32_t jitter200_300;
@property (nonatomic, assign) uint32_t jitter300_500;
@property (nonatomic, assign) uint32_t jitter500_800;
@property (nonatomic, assign) uint32_t jitter800;       //抖动在 800ms以上的个数
@property (nonatomic, assign) uint32_t upConsLoss0;     //上行连续丢0个包的包数量(即没有丢包)
@property (nonatomic, assign) uint32_t upConsLoss1;     //上行连续丢1个包的数量
@property (nonatomic, assign) uint32_t upConsLoss2;
@property (nonatomic, assign) uint32_t upConsLoss3;
@property (nonatomic, assign) uint32_t upConsLossb3;    //上行连续丢包超过3个的数量
@property (nonatomic, assign) uint32_t dwConsLoss0;
@property (nonatomic, assign) uint32_t dwConsLoss1;
@property (nonatomic, assign) uint32_t dwConsLoss2;
@property (nonatomic, assign) uint32_t dwConsLoss3;
@property (nonatomic, assign) uint32_t dwConsLossb3;
@property (nonatomic, assign) uint32_t upDisorder;      //上行乱序包的数量
@property (nonatomic, assign) uint32_t dwDisorder;      //下行乱序包的数量

@property (nonatomic, strong) NSArray *upSeqs;          //上行数据包序号
@property (nonatomic, strong) NSArray *dwSeqs;          //下行数据包序号

@end

