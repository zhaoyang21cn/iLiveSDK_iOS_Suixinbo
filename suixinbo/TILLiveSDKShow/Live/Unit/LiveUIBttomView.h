//
//  LiveUIBttomView.h
//  TILLiveSDKShow
//
//  Created by wilderliao on 16/11/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BottomViewDelegate <NSObject>

- (void)popMsgInputView;

- (void)setTilBeauty:(float)beauty;
- (void)setTilWhite:(float)white;

@end

@interface LiveUIBttomView : UIView
{
    //bottom function view
    NSMutableArray *_btnArray; //将底部功能按钮全部放在数组中，方便布局
    UIButton    *_flashBtn;          //闪关灯
    UIButton    *_cameraBtn;         //相机切换
    UIButton    *_beautyBtn;         //美颜／美白
    UIButton    *_micBtn;            //mic
    UIButton    *_pureBtn;           //纯净模式
    UIButton    *_praiseBtn;         //点赞
    UIButton    *_sendMsgBtn;        //发送消息（只有观众端才有）
    UIButton    *_downVideo;         //下麦
}

@property (nonatomic, assign) BOOL isHost; //自己是不是主播
@property (nonatomic, assign) BOOL isUpVideo; //自己是不是上麦
@property (nonatomic, copy) NSString *mainWindowRole;//主窗口角色，不同角色显示不同功能

@property (nonatomic, weak) id<BottomViewDelegate> delegate;

- (instancetype)initWith:(NSString *)role;

@end
