//
//  LiveUIParView.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InviteInteractDelegate <NSObject>

- (void)onInteract;

- (void)onRecReport:(NSString *)name type:(ILiveRecordType)type;

@end

@interface LiveUIParViewConfig : NSObject
@property (nonatomic, strong) TCShowLiveListItem *item;
@property (nonatomic, assign) BOOL isHost;
@end

@interface LiveUIParView : UIView
{
    UIButton    *_interactBtn;       //互动连线
    UIButton    *_parBtn;            //avsdk参数信息
    UIButton    *_pushStreamBtn;     //推流
    UIButton    *_recBtn;            //录制
    UIButton    *_speedBtn;          //测速
    
    UIButton    *_linkRoomBtn;       //串门
    UIButton    *_unlinkRoomBtn;     //取消串门
    
    UITextView  *_paramTextView;     //参数展示
}

@property (nonatomic, strong) LiveUIParViewConfig *config;
@property (nonatomic, weak) id<InviteInteractDelegate> delegate;

@property (nonatomic, copy) NSTimer *logTimer;
@property (nonatomic,strong) UITextView *paramTextView;
@property (nonatomic, strong) NSMutableDictionary *resolutionDic;//纯粹是为了打印log需要

@property (nonatomic, strong) NSMutableArray *funs;

@property (nonatomic, assign) CGRect restoreRect;

- (void)configWith:(LiveUIParViewConfig *)config;

@end
