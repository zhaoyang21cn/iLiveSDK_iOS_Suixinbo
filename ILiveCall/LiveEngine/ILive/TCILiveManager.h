//
//  TCILiveManager.h
//  ILiveSDK
//
//  Created by AlexiChen on 16/9/9.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK/ImSDK.h>
#import <QAVSDK/QAVSDK.h>

#import "TCILiveConst.h"
#import "TCILiveRoom.h"

#import "TCILiveManagerDelegate.h"


@class AVGLBaseView;
@class AVGLRenderView;
/*
 * 不做网络检查，以及权限检查，以及前后台判断
 *
 */


@interface TCILiveManager : NSObject
{
@protected
    TIMUserProfile  *_host;
    QAVContext      *_avContext;
    
@protected
    TCILiveRoom     *_room;
    
    __weak id<TCILiveManagerDelegate> _delegate;
}

@property (nonatomic, readonly) TIMUserProfile *host;
@property (nonatomic, readonly) QAVContext *avContext;
@property (nonatomic, readonly) AVGLBaseView *avglView;
@property (nonatomic, weak) id<TCILiveManagerDelegate> delegate;

@property (nonatomic, readonly) TCILiveRoom *room;

/*
 * @brief 没有接入IMSDK，可使用该方法配置IMSDK，如果之前已接入IMSDK，则可以不使用该方法进行接入
 */
// 配置IMSDK
+ (void)configWithAppID:(int)sdkAppId accountType:(NSString *)accountType willInit:(TCIVoidBlock)willDo initCompleted:(TCIVoidBlock)completion;

+ (instancetype)sharedInstance;

// 当前是不是主播
- (BOOL)isHostLive;

// 外部状态判断：当前是不是在直播
- (BOOL)isLiving;

/*
 * @bried 未接入IMSDK的可直接使用下面的方法进行登录, 其内部会自动调用下面的configHost:，以及startContextWith:completion:两个方法
 * @param param : 登录IMSDK的参数
 * @param fail : 登录IMSDK失败回调
 * @param offline : 登录时，遇到互踢回调回调
 * @param completion : 登录IMSDK，并且始化AVSDK Context的回调
 */

- (void)login:(TIMLoginParam *)param loginFail:(TIMFail)fail offlineKicked:(void (^)(TIMLoginParam *param, TCIRoomBlock succ, TIMFail fail))offline startContextCompletion:(TCIRoomBlock)completion;


// 如果已用IMSDK实现登录，只需要在TIMManager成功回调succ里面-(int) login: (TIMLoginParam *)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail;，手动添加下面的代码进行配置即可
- (void)configHost:(TIMLoginParam *)param;
- (void)startContextWith:(TIMLoginParam *)param completion:(TCIRoomBlock)completion;

// 登录
- (void)logout:(TIMLoginSucc)succ fail:(TIMFail)fail;

//=============================================================

// 手动处理渲染
/*
 * @brief 向直播界面添加渲染控件，所创建的AVGLBaseView会自动insert到vc.view的0位置
 * @param vc:创建的直播界面
 * @return 返回创建的渲染控件，以便外部可作其他处理
 */
- (AVGLBaseView *)createAVGLViewIn:(UIViewController *)vc;

/*
 * @brief 向直播界面所添加渲染控件AVGLBaseView上添加渲染窗口，如果已添加过该uid，会对应只更新对应的renderView的区域
 * @param uid : 视频源标识id （如果业务是只处理手机视频，可使用用户id作标识，如果还要处理屏幕分享事件，则可以）
 * @return 返回渲染所用的renderview，以便外部可作其他处理
 */

- (AVGLRenderView *)renderFor:(NSString *)uid;

- (AVGLRenderView *)addRenderFor:(NSString *)uid atFrame:(CGRect)rect;

- (void)removeRenderFor:(NSString *)uid;

// 直播前配置好渲染
/*
 * @brief 如果在直播界面外，采用默内内部处理的逻辑（调用该接口- (void)enterRoom:imChatRoomBlock:avRoomCallBack:listener:）。
 *        因开始enterRoom，在进入到直播界面时，会收到半自动推送视频画面。提前在本地处理好要渲染的区域(未开始直播前设置)
 * @param list : 为TCIMemoItem列表，所传的TCIMemoItem.showRect不能为CGRectZero，若为CGRectZero内部会过滤，其有顺序要求，外部控制好逻辑（全屏的放在前面，小窗口放至后面）。最多为4个，为空或大于四个则不作处理
 * @return 返回一个全屏的AVGLRenderView，外部而不急于添加到直播界面
 */
- (void)registerRenderMemo:(NSArray *)list;

// 直播进房间接口
/*
 * @brief 进入房间，内部统一处理AVSDK回调, 默认已使用请求画面，打开摄像头操作，以及回调设置，但是外部，还是要监一下，直播中的遇到的问题
 * @param room不能为空
 * @param imblock:IM处理回调
 * @param avblock:AV进房间(-(void)OnEnterRoomComplete:(int)result)回调处理
 */
- (void)enterRoom:(TCILiveRoom *)room imChatRoomBlock:(TCIRoomBlock)imblock avRoomCallBack:(TCIRoomBlock)avblock;

/*
 * @brief 进入房间，外部处理AVSDK回调
 * @param room不能为空
 * @param imblock:IM处理回调
 * @param delegate:进AV房间处理回调，若delegate不为空且不为[TCILiveManager sharedInstance]，外部处理，不走该回调
 */
- (void)enterRoom:(TCILiveRoom *)room imChatRoomBlock:(TCIRoomBlock)imblock avListener:(id<QAVRoomDelegate>)delegate;

/*
 * @brief 打开或关闭摄像头，外部尽量使用该方法进行摄像头操作，其内部会记录摄像头状态
 * @param pos: 摄像头ID，CameraPosFront:前置摄像头 CameraPosBack:后置摄像头
 * @param bEnable : YES/打开, NO/关闭
 * @parma block : 返回操作结果
 */
- (void)enableCamera:(cameraPos)pos isEnable:(BOOL)bEnable complete:(void (^)(BOOL succ, QAVResult result))block;

/*
 * @brief 打开/关闭扬声器。
 * @param bEnable 是否打开。
 * @return YES表示操作成功，NO表示操作失败。
 */
- (BOOL)enableSpeaker:(BOOL)bEnable;

/**
 @brief 打开/关闭麦克风。
 
 @param isEnable 是否打开。
 
 @return YES表示操作成功，NO表示操作失败。
 */
- (BOOL)enableMic:(BOOL)isEnable;

/*
 * @brief 摄像头切换，外部尽量使用该方法进行摄像头操作，其内部会记录摄像头状态
 * @param pos: 摄像头ID，CameraPosFront:前置摄像头 CameraPosBack:后置摄像头
 * @param bEnable : YES/打开, NO/关闭
 */
- (void)switchCamera:(cameraPos)pos complete:(void (^)(BOOL succ, QAVResult result))block;



- (void)requestViewList:(NSArray *)identifierList srcTypeList:(NSArray *)srcTypeList ret:(RequestViewListBlock)block;


/*
 * @brief 退出房间，内部统一处理
 * @param imblock:IM退群处理回调
 * @param avblock:AV出房间(-(void)OnExitRoomComplete)回调处理
 */
- (void)exitRoom:(TCIRoomBlock)avBlock;

/*
 * @brief 退出房间，外部统一处理回调;
 */
- (void)exitRoom;

//================================
// 外部监听前后台事件，然后主动调用下面的方法
// 进入后台时回调
- (void)onEnterBackground;

// 进入前台时回调
- (void)onEnterForeground;

//================================
// 发送C2C消息
- (void)sendToC2C:(NSString *)recvID message:(TIMMessage *)message succ:(TIMSucc)succ fail:(TIMFail)fail;

// 发送群消息
- (void)sendGroupMessage:(TIMMessage *)message succ:(TIMSucc)succ fail:(TIMFail)fail;

@end


@interface TCILiveManager (ProtectedMethod)
- (void)onLogoutCompletion;
@end
