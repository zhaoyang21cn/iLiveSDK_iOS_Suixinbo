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

- (void)onRecReport:(NSString *)name type:(AVRecordType)type;

@end

@interface LiveUIParView : UIView
{
    UIButton    *_interactBtn;       //互动连线
    UIButton    *_parBtn;            //avsdk参数信息
    UIButton    *_pushStreamBtn;     //推流
    UIButton    *_recBtn;            //录制
    UIButton    *_speedBtn;          //测速
    
    UITextView  *_paramTextView;     //参数展示
}

@property (nonatomic, assign) BOOL isHost;
@property (nonatomic, copy) NSString *roomTitle;//用于记录当前直播房间标题
@property (nonatomic, copy) NSString *coverUrl;//用于记录当前直播封面的URL
@property (nonatomic, copy) NSTimer *logTimer;
@property (nonatomic,strong) UITextView *paramTextView;
@property (nonatomic, strong) NSMutableDictionary *resolutionDic;//纯粹是为了打印log需要
@property (nonatomic, weak) id<InviteInteractDelegate> delegate;

@property (nonatomic, assign) CGRect restoreRect;

@end
