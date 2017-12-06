//
//  MoreFunView.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/4/6.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MoreFunItem;

@protocol MoreFunDelegate <NSObject>

@optional
- (void)changeAudioDelegate:(QAVVoiceType)type;
- (void)changeRoleDelegate:(NSString *)role;

@end

@interface MoreFunView : UIView

@property (nonatomic, strong) MoreFunItem *item;

@property (nonatomic, strong) UIView *clearBg;      //用来做点击消失事件

@property (nonatomic, strong) UIView *alphaBg;      //透明度背景
@property (nonatomic, strong) UIButton *changeAudioBtn;
@property (nonatomic, strong) UIButton *changeRoleBtn;
@property (nonatomic, strong) UIButton *reportLogBtn;
@property (nonatomic, strong) UIButton *flashBtn;       //闪关灯
//@property (nonatomic, strong) UIButton *linkRoomBtn;    //跨房间连麦
//@property (nonatomic, strong) UIButton *endLinkRoomBtn; //结束跨房间连麦
@property (nonatomic, strong) UIButton *filterBtn;      //滤镜
@property (nonatomic, strong) UIButton *pendantBtn;     //挂件

@property (nonatomic, weak) id<MoreFunDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *funs;

- (void)configMoreFun:(MoreFunItem *)item;

@end

@interface MoreFunItem : NSObject

@property (nonatomic, assign) BOOL isHost; //自己是不是主播
@property (nonatomic, assign) BOOL isUpVideo;//自己是不是连麦观众
@property (nonatomic, strong) NSString *curRole;//当前角色
@property (nonatomic, assign) CGRect moreFunViewRect;
@property (nonatomic, strong) UIView *bottomView;

//声明变量
@property (nonatomic, strong) TXCVideoPreprocessor *preProcessor;
@property (nonatomic, assign) Byte  *processorBytes;

@end
